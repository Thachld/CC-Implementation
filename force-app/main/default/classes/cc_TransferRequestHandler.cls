public with sharing class cc_TransferRequestHandler implements  cc_ITrigger{     
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
        if (Trigger.isUpdate) {     
            Map<Id,Transfer_Request__c> newMap = (Map<Id,Transfer_Request__c>)Trigger.newMap; 
            Map<Id,Transfer_Request__c> oldMap = (Map<Id,Transfer_Request__c>)Trigger.oldMap;     

            for(Transfer_Request__c newrq: newMap.values()){
                Transfer_Request__c oldrq = oldMap.get(newrq.Id);

                if( (newrq.Approval_Status__c !=  oldrq.Approval_Status__c) 
                    && newrq.Approval_Status__c == 'Approved'
                    && newrq.Status__c != 'Completed'
                    && newrq.Is_Immediately__c == true ){
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
        if(rqIds.size() > 0){
            cc_TF_TransferUser_Batch transfer = new cc_TF_TransferUser_Batch(rqIds);
            Database.executeBatch(transfer, 20);
        }
    }        
    
}