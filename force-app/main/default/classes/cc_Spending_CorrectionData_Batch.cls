public class cc_Spending_CorrectionData_Batch implements Database.Batchable<SObject>,Database.Stateful{
    public Datetime fromdt {get;set;}
    public Datetime todt {get;set;}
    List<Error_log__c> errLogs {get;set;}

    public cc_Spending_CorrectionData_Batch(Date pfdt, Date ptodt) {

        this.fromdt = Datetime.newInstance(pfdt.year(), pfdt.month(), pfdt.day(), 0,0,0);       
        this.todt = Datetime.newInstance(ptodt.year(), ptodt.month(), ptodt.day(), 23,59,59); 
        this.errLogs = new List<Error_log__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, QC_Account__c, Sale__c, Industry__c, Agency__c, Support__c, Accounts__c
                                            FROM QC_Account_data__c 
                                            WHERE (Sale__c = '' OR Industry__c = '' OR Agency__c = '')
                                                AND syn_date__c >= :this.fromdt
                                                AND syn_date__c <= :this.todt
                                            ]);
    }

    public void execute(Database.BatchableContext bc, List<QC_Account_data__c> scope){        
        List<QC_Account_data__c> listSPToUpdate = new List<QC_Account_data__c>();
        Set<String> qcIds = new Set<String>();
        Map<String, QC_Account__c> mapQC;
        Map<String, List<QC_Account_data__c>> mapSPS = new Map<String, List<QC_Account_data__c>>();

        for(QC_Account_data__c sp: scope){
            qcIds.add(sp.QC_Account__c);

            if(mapSPS.containsKey(sp.QC_Account__c)){
                mapSPS.get(sp.QC_Account__c).add(sp);
            }else {
                mapSPS.put(sp.QC_Account__c, new List<QC_Account_data__c>{sp});
            }
            
        }

        mapQC = new Map<String, QC_Account__c>([SELECT ID, Sales__c, Industry__c, Agency__c, AccountOwner__c, Support__c FROM QC_Account__c WHERE Id IN :qcIds]);

        if(mapQC !=null){
            for(String qcId : mapQC.keyset()){
                QC_Account__c qcAcc = mapQC.get(qcId);
                List<QC_Account_data__c> sps = mapSPS.get(qcId);

                if(qcAcc != null && sps !=null){
                    for(QC_Account_data__c sp: sps){
                        Boolean isCorrection = false;
                        if(String.isBlank(sp.Sale__c) && !String.isBlank(qcAcc.Sales__c)){
                            sp.Sale__c = qcAcc.Sales__c;
                            isCorrection = true;
                        }

                        if(String.isBlank(sp.Industry__c) && !String.isBlank(qcAcc.Industry__c)){
                            sp.Industry__c = qcAcc.Industry__c;
                            isCorrection = true;
                        }

                        if(String.isBlank(sp.Agency__c) && !String.isBlank(qcAcc.Agency__c)){
                            sp.Agency__c = qcAcc.Agency__c;
                            isCorrection = true;
                        }

                        if(String.isBlank(sp.Accounts__c) && !String.isBlank(qcAcc.AccountOwner__c)){
                            sp.Accounts__c = qcAcc.AccountOwner__c;
                            isCorrection = true;
                        }

                        if(String.isBlank(sp.Support__c) && !String.isBlank(qcAcc.Support__c)){
                            sp.Support__c = qcAcc.Support__c;
                            isCorrection = true;
                        }

                        if(isCorrection){
                            listSPToUpdate.add(sp);
                        }
                    }
                }

            }
        }    

        if(listSPToUpdate.size() > 0){
            Database.SaveResult[] results = Database.update(listSPToUpdate, false);

            for(Database.SaveResult rs: results){
                if (!rs.isSuccess()){
                    Error_log__c error = new Error_log__c();
                    error.Name = 'cc_Spending_CorrectionData_Batch';
                    error.error_description__c  = JSON.serialize(rs.getErrors()) + '  /r/n' + rs.getId() ;  
                    this.errLogs.add(error);                 
                }
            }
        }


    }

    public void finish(Database.BatchableContext bc){
        if(this.errLogs.size() > 0){
            insert this.errLogs;
        }

    }
}