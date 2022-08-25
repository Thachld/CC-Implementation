public with sharing class cc_TransferSpendingCashHandler implements cc_ITrigger{
    Set<String> rqIds = new Set<String>();    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {	
        if(Trigger.isInsert){           
            for(TransferSpendingCash__c rq :(List<TransferSpendingCash__c>)Trigger.new){
                if( rq.Approval_Status__c == TransferRequestConstant.APPROVAL_STATUS_APPROVED
                    && rq.Transfer_Immediately__c == true
                    && rq.Status__c != TransferRequestConstant.STATUS_COMPLETED){
                        rqIds.add(rq.Id);
                }
            }
        }else if (Trigger.isUpdate) {     
            Map<Id,TransferSpendingCash__c> newMap = (Map<Id,TransferSpendingCash__c>)Trigger.newMap; 
            Map<Id,TransferSpendingCash__c> oldMap = (Map<Id,TransferSpendingCash__c>)Trigger.oldMap;     

            for(TransferSpendingCash__c newrq: newMap.values()){
                TransferSpendingCash__c oldrq = oldMap.get(newrq.Id);

                if(( (newrq.Approval_Status__c != oldrq.Approval_Status__c ) || (newrq.Transfer_Immediately__c != oldrq.Transfer_Immediately__c) )
                    && newrq.Status__c != TransferRequestConstant.STATUS_COMPLETED
                    && newrq.Approval_Status__c == TransferRequestConstant.APPROVAL_STATUS_APPROVED
                    && newrq.Transfer_Immediately__c == true){
                    rqIds.add(newrq.Id);
                }
            }
        }			
    }
    
    /**
    * beforeInsert
    *
    * This method is called iteratively for each record to be inserted during a BEFORE
    * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    */
    public void beforeInsert(SObject so) {}
    
    /**
    * beforeUpdate
    *
    * This method is called iteratively for each record to be updated during a BEFORE
    * trigger.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {}

    /**
    * beforeDelete
    *
    * This method is called iteratively for each record to be deleted during a BEFORE
    * trigger.
    */
    public void beforeDelete(SObject so) {}
       

    /**
    * afterInsert
    *
    * This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field validation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    */
    public void afterInsert(SObject so) {}

    /**
    * afterUpdate
    *
    * This method is called iteratively for each record updated during an AFTER
    * trigger.
    */
    public void afterUpdate(SObject oldSo, SObject so) {}

    /**
    * afterDelete
    *
    * This method is called iteratively for each record deleted during an AFTER
    * trigger.
    */
    public void afterDelete(SObject so) {}
    
    /**
    * afterUnDelete
    *
    * This method is called iteratively for each record Undeleted during an AFTER
    * trigger.
    */
    public void afterUnDelete(SObject so) {}

    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally() {       
        System.debug('rqIds =>' + rqIds.size());
        if(rqIds.size() > 0){            
            cc_TransferSpendingCashHelper.attemptTransferdata(rqIds);
        }        
    }   
}