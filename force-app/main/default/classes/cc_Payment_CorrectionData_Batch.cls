public class cc_Payment_CorrectionData_Batch implements Database.Batchable<SObject>,Database.Stateful{
    public Date fromdt {get;set;}
    public Date todt {get;set;}
    List<Error_log__c> errLogs {get;set;}

    public cc_Payment_CorrectionData_Batch(Date pfdt, Date ptodt) {
        this.fromdt = pfdt;
        this.todt = ptodt;
        this.errLogs = new List<Error_log__c>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, QC_Account__c, Sale__c, Industry__c, Agency__c
                                            FROM Payment__c 
                                            WHERE (Sale__c = '' OR Industry__c = '' OR Agency__c = '')
                                                AND Stage__c = 'Done'
                                                AND EffectiveDate__c >= :this.fromdt
                                                AND EffectiveDate__c <= :this.todt
                                            ]);
    }

    public void execute(Database.BatchableContext bc, List<Payment__c> scope){        
        List<Payment__c> listPYToUpdate = new List<Payment__c>();
        Set<String> qcIds = new Set<String>();
        Map<String, QC_Account__c> mapQC;
        Map<String, List<Payment__c>> mapPY = new Map<String, List<Payment__c>>();

        for(Payment__c py: scope){
            qcIds.add(py.QC_Account__c);

            if(mapPY.containsKey(py.QC_Account__c)){
                mapPY.get(py.QC_Account__c).add(py);
            }else {
                mapPY.put(py.QC_Account__c, new List<Payment__c>{py});
            }
            
        }

        mapQC = new Map<String, QC_Account__c>([SELECT Id, Sales__c, Industry__c, Agency__c FROM QC_Account__c WHERE Id IN :qcIds]);
        System.debug('mapQC =>' + mapQC.size());
        System.debug('qcIds =>' + qcIds.size());
        System.debug('mapPY =>' + mapPY.size());

        if(mapQC != null){
            for(String qcId : mapQC.keyset()){
                QC_Account__c qcAcc = mapQC.get(qcId);
                List<Payment__c> pys = mapPY.get(qcId);

                if(qcAcc != null && pys !=null){
                    for(Payment__c py: pys){
                        Boolean isCorrection = false;
                        if(String.isBlank(py.Sale__c) && !String.isBlank(qcAcc.Sales__c)){
                            py.Sale__c = qcAcc.Sales__c;
                            isCorrection = true;
                        }

                        if(String.isBlank(py.Industry__c) && !String.isBlank(qcAcc.Industry__c)){
                            py.Industry__c = qcAcc.Industry__c;
                            isCorrection = true;
                        }

                        if(String.isBlank(py.Agency__c) && !String.isBlank(qcAcc.Agency__c)){
                            py.Agency__c = qcAcc.Agency__c;
                            isCorrection = true;
                        }

                        // System.debug('isCorrection =>' + isCorrection);
                        // System.debug('PYID =>' + py.Id);
                        if(isCorrection){
                            listPYToUpdate.add(py);
                        }
                    }
                }

            }
        }    

        if(listPYToUpdate.size() > 0){
            Database.SaveResult[] results = Database.update(listPYToUpdate, false);

            for(Database.SaveResult rs: results){
                if (!rs.isSuccess()){
                    Error_log__c error = new Error_log__c();
                    error.Name = 'cc_Payment_CorrectionData_Batch';
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


        cc_Spending_CorrectionData_Batch spendingbatch = new cc_Spending_CorrectionData_Batch(this.fromdt, this.todt);
        Database.executeBatch(spendingbatch, 200);
    }
}