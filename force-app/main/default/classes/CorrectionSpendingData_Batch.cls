public with sharing class CorrectionSpendingData_Batch implements Database.Batchable<SObject>{
    private Datetime fromDT;
    private Datetime toDT;
    public CorrectionSpendingData_Batch(Date pfrom, Date pto) {
        this.fromDT = Datetime.newInstance(pfrom.year(), pfrom.month(), pfrom.day(), 0,0,0);       
        this.toDT = Datetime.newInstance(pto.year(), pto.month(), pto.day(), 23,59,59); 
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, QC_Account__c, Sale__c, Support__c, Agency__c, Industry__c
                                        FROM QC_Account_data__c 
                                        WHERE syn_date__c >= :this.fromDT 
                                            AND syn_date__c <= :this.toDT
                                            AND QC_Account__c != null
                                            AND ( Sale__c = null
                                                OR Support__c = null
                                                OR Agency__c = null
                                                OR Industry__c = null                                                
                                            )
        ]);     
    }

    public void execute(Database.BatchableContext bc, List<QC_Account_data__c> scope){
        List<QC_Account_data__c> listUpdateData = new List<QC_Account_data__c>();
        Set<String> qcAccIds = new Set<String>();
        Map<String,QC_Account__c> mapQC;


        for(QC_Account_data__c data: scope){
            qcAccIds.add(data.QC_Account__c);            
        }

        mapQC = new Map<String,QC_Account__c>([SELECT Id, Sales__c,Support__c, Industry__c, Agency__c FROM QC_Account__c WHERE Id IN :qcAccIds]);


        for(QC_Account_data__c data: scope){
            QC_Account__c qc = mapQC.get(data.QC_Account__c);
            if(qc != null){
                Boolean needUpdate = false;
                if(String.isBlank(data.Sale__c) && !String.isBlank(qc.Sales__c)){
                    data.Sale__c = qc.Sales__c;
                    needUpdate = true;
                }

                if(String.isBlank(data.Support__c) && !String.isBlank(qc.Support__c)){
                    data.Support__c = qc.Support__c;
                    needUpdate = true;
                }

                if(String.isBlank(data.Industry__c) && !String.isBlank(qc.Industry__c)){
                    data.Industry__c = qc.Industry__c;
                    needUpdate = true;
                }

                if(String.isBlank(data.Agency__c) && !String.isBlank(qc.Agency__c)){
                    data.Agency__c = qc.Agency__c;
                    needUpdate = true;
                }

                if(needUpdate){
                    listUpdateData.add(data);
                }
            }
        }


        if(listUpdateData.size() > 0){
            Database.update(listUpdateData, false);
        }

    }

    public void finish(Database.BatchableContext bc){

    }
}