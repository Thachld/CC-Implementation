global class cc_Account_SpendingAccum_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        callBatch();
    }

    public cc_Account_SpendingAccum_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){       
        /* ------- Parameter ------------*/
        cc_Batch_Parameter__c params = cc_Util.getBatchParameter('AccountSpemdingByYearAccum');  
        
        String pTotalWhereClause = params.Where_Clause1__c == null? '': params.Where_Clause1__c;   
        String pAccumWhereClause = params.Where_Clause2__c == null? '': params.Where_Clause2__c ;
        String pFieldTotal = params.Field_Total__c; // 'Spending_2020__c';       
        String pObjectAccum = params.ObjectAccum__c;//'QC_Account__c'; 
        String pFieldAccum = params.FieldAccum__c;//'AccountOwner__c';
        String pFieldAccumAlias = params.FieldAccumAlias__c;//'AccountOwner';
        String pAgregateField = params.AgregateField__c ;//'Spending_2020__c';        
        String pAggregateFunc = params.AggregateFunc__c ; //'SUM';  
        Integer BatchSize = params.BatchSize__c == null?200: (Integer)params.BatchSize__c; 
        Date pFromDate = null; 
        Date pToDate = null;			

        cc_Account_SpendingAccumByTime_Batch transfer = 
        new cc_Account_SpendingAccumByTime_Batch(   pFieldTotal.trim(),
                                                    pTotalWhereClause,
                                                    pObjectAccum.trim(), 
                                                    pFieldAccum.trim(),
                                                    pFieldAccumAlias.trim(),
                                                    pAgregateField.trim(),
                                                    pAccumWhereClause,
                                                    pAggregateFunc.trim(),
                                                    pFromDate,
                                                    pToDate
                                                );
        database.executeBatch(transfer,BatchSize);
        
    }
}