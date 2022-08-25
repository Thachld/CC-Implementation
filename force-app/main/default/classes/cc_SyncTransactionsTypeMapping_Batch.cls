public with sharing class cc_SyncTransactionsTypeMapping_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{    
    public cc_SyncTransactionsTypeMapping_Batch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, TransactionTypeId__c
                                            FROM Transactions_Type__c 
                                            WHERE TransactionTypeId__c != null]);

       
    }

    public void execute(Database.BatchableContext bc,List<Transactions_Type__c> scope){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();
        List<Transactions_Type__c> transtypeUpsert = new List<Transactions_Type__c>();

        CouponIntegration__c gettransactiontype = CouponIntegration__c.getInstance('gettransactiontype');
        String endpoint = gettransactiontype.apiuri__c;
        String method = gettransactiontype.method__c;
        Integer timeout = (Integer)gettransactiontype.timeout__c;       

        //Make request
            String jsonbody = '';

            if ( String.isNotBlank(jsonbody) ){
                headers.put('Content-Length',jsonbody.length()+'');                        
            }

            cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
            HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
            if(req != null){
                HttpResponse res = cc_HttpCallout.makeRequest(req);

                System.debug('getStatusCode=>' + res.getStatusCode() + ' getBody=> ' + res.getBody());
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    String reponeJs = res.getBody();
                    TransactionTypeWrapper result = TransactionTypeWrapper.parse(reponeJs);
                    if(result.success == true){
                        List<TransactionTypeWrapper.DataWrapper> transtypeinfos = result.data.items;
                        if(transtypeinfos.size() > 0){
                            transtypeUpsert = initUpsertList(transtypeinfos);
                        }
                    } 
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Sync Transaction Type Callout', '','cc_TransactionsTypeMappingHelper', 'syncTransactionTypeFromQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                } 
            }else {
                CalloutLog__c calloutLog = new CalloutLog__c();        
                calloutLog = cc_Util.parseCallOutLog('Sync Transaction Type Callout', '' ,'cc_TransactionsTypeMappingHelper', 'syncTransactionTypeFromQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                calloutLogs.add(calloutLog);
            }   
        
        System.debug('transtypeUpsert=>' + transtypeUpsert.size());
        if(transtypeUpsert.size() > 0){
            Schema.SObjectField f = Transactions_Type__c.Fields.TransactionTypeId__c;
            Database.UpsertResult [] cr = Database.upsert(transtypeUpsert , f, false);
        }
    }

    public void finish(Database.BatchableContext bc){

    }

    public static List<Transactions_Type__c> initUpsertList(List<TransactionTypeWrapper.DataWrapper> transtypeinfos){
        List<Transactions_Type__c> listTransactionType = new List<Transactions_Type__c>();

        for(TransactionTypeWrapper.DataWrapper transtype: transtypeinfos){
            System.debug('transtype=>' + transtype);
            Transactions_Type__c newTranstype = new Transactions_Type__c();                        
            newTranstype.Comment__c = transtype.comment;
            newTranstype.Internal_Type__c = transtype.internal_type;
            newTranstype.Is_Enable__c = transtype.is_enabled == 'YES'?true:false;
            newTranstype.Allow_Coupon__c = transtype.allow_coupon == 'YES'?true:false;
            newTranstype.Label__c = transtype.label;
            newTranstype.Priority__c = (Integer)transtype.priority;
            newTranstype.QC_CreatedDatetime__c =  transtype.created_time !=null? Datetime.valueOf(transtype.created_time) : null;
            newTranstype.QC_LastUpdateDatetime__c = transtype.updated_time !=null? Datetime.valueOf(transtype.updated_time) : null;
            newTranstype.TransactionTypeId__c = transtype.id;
            newTranstype.Name = transtype.label;
            newTranstype.transaction_type__c = transtype.transaction_type;
            newTranstype.Required_interval_spending_days__c = transtype.required_interval_spending_days == 'YES'?true:false;
            newTranstype.maximum_interval_spending_days__c = transtype.maximum_interval_spending_days;

            listTransactionType.add(newTranstype);            
        } 

        return listTransactionType;
    }
}