global class cc_Account_PaymentAccum_Schedule implements Schedulable{    
    global void execute(SchedulableContext SC) {
        callBatch();
    }

    public cc_Account_PaymentAccum_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/
        cc_Batch_Parameter__c params = cc_Util.getBatchParameter('AccountPaymentAccum');

        String pTotalWhereClause = '';
        String pAccumWhereClause = ''; 

        Date pfromDT = params.From_Date__c ==null? Date.newInstance(2020, 1, 1) : params.From_Date__c;
        Datetime fromDatetime = Datetime.newInstance(pfromDT.year(), pfromDT.month(), pfromDT.day(), 0,0,0);  
        String sfromDt = fromDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');   

        pTotalWhereClause = ' CreatedDate >= ' + sfromDt;  
        
        
        if(!String.isBlank(params.Where_Clause1__c) && params.Where_Clause1__c != null){
            pTotalWhereClause = pTotalWhereClause + ' ' + params.Where_Clause1__c;
        }  

        pAccumWhereClause = params.Where_Clause2__c == null? '': params.Where_Clause2__c ;
        String pFieldTotal = params.Field_Total__c;       
        String pObjectAccum = params.ObjectAccum__c;       
        String pFieldAccum = params.FieldAccum__c;       
        String pFieldAccumAlias = params.FieldAccumAlias__c;    
        String pAgregateField = params.AgregateField__c;        
        String pAggregateFunc = params.AggregateFunc__c;        
        Integer BatchSize = params.BatchSize__c == null?200: (Integer)params.BatchSize__c;    
        Date pFromDate = null; 
        Date pToDate = null;			

        cc_Account_SpendingAccumByTime_Batch transfer = 
        new cc_Account_SpendingAccumByTime_Batch(pFieldTotal,
                                                        pTotalWhereClause,
                                                        pObjectAccum, 
                                                        pFieldAccum,
                                                        pFieldAccumAlias,
                                                        pAgregateField,
                                                        pAccumWhereClause,
                                                        pAggregateFunc,
                                                        pFromDate,
                                                        pToDate
                                                        );
        database.executeBatch(transfer);
        
    }
}