public with sharing class BalanceServiceHelper {

    /*************************************************************************
    * author: Thach LD
    * date: 27/07/2021 
    * Description: Get balance Amount for withdraw transaction
    *************************************************************************/
    public static void attemptgetBalanceService(Set<String> pyIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncgetBalanceService(pyIds);
        }
    }

    
    @future(callout=true)
    public static void asyncgetBalanceService(Set<String> pyIds){
        Datetime balanceTodate = Datetime.now();    
        Map<String,BalanceServiceWrapper.SummaryWrapper> mapResults = getBalance(pyIds,balanceTodate);

        if(mapResults.size() > 0 ){
            updatePayment(mapResults);
        }
    }

    public static Map<String,BalanceServiceWrapper.SummaryWrapper> getBalance(Set<String> pyIds, Datetime balanceTodate){    
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>(); 
        Map<String,BalanceServiceWrapper.SummaryWrapper> mapResults = new Map<String,BalanceServiceWrapper.SummaryWrapper>();
        Map<String,List<String>> mapQCPys = new Map<String,List<String>>();
        

        for(Payment__c py: [SELECT Id, Name, QC_Account__r.QC_Account_Id__c,
                                        Coupon_Amount__c, Real_Amount__c, Total_Amount__c, Last_Sync_Datetime__c
                                FROM Payment__c WHERE Id IN :pyIds]){   
            if(!String.isBlank(py.QC_Account__r.QC_Account_Id__c)){

                if(mapQCPys.containsKey(py.QC_Account__r.QC_Account_Id__c)){
                    mapQCPys.get(py.QC_Account__r.QC_Account_Id__c).add(py.Id);
                }else {
                    mapQCPys.put(py.QC_Account__r.QC_Account_Id__c, new List<String>{py.Id});
                }
            }
        } 
        
        List<BalanceServiceWrapper.BalanceWrapper> blresult = BalanceServiceController.getBalanceService(mapQCPys.keySet(),balanceTodate);     
        
        for(BalanceServiceWrapper.BalanceWrapper blance: blresult){
            System.debug('blance=>' + blance);
            System.debug('summary=>' + blance.summary);
            if(blance != null){
                BalanceServiceWrapper.SummaryWrapper summary = new BalanceServiceWrapper.SummaryWrapper();

                List<String> listPy = mapQCPys.get(blance.user_id);
                if(listPy !=null && listPy.size() > 0){
                    for (String py: listPy){
                        mapResults.put(py, blance.summary);
                    }
                }                   
            }
        }

 
        return mapResults;
    }

    public static void updatePayment(Map<String,BalanceServiceWrapper.SummaryWrapper> mapResults){
        List<Payment__c> listUpdatePy = new List<Payment__c>();
        Datetime dt =  System.now();        

        for(String paymentId: mapResults.keySet()){
            BalanceServiceWrapper.SummaryWrapper summary = mapResults.get(paymentId);            
            if(summary !=null){
                Payment__c py = new Payment__c();
                py.Id = paymentId;
                py.Coupon_Amount__c = Math.Floor(summary.COUPON_MONEY);
                py.Real_Amount__c = Math.Floor(summary.REAL_MONEY);
                py.Total_Amount__c = Math.Floor(summary.TOTAL_MONEY);
                py.Last_Sync_Datetime__c = dt;

                listUpdatePy.add(py);
            }  
        }
        
        System.debug('listUpdatePy=>' + listUpdatePy.size());
        if(listUpdatePy.size() > 0 && Schema.sObjectType.CalloutLog__c.isCreateable()){
            update listUpdatePy;
        }  
    }
}