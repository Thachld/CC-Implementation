public with sharing class ClientSharingTriggerHandler implements cc_ITrigger{        
    /* bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */

    Set<String> clIdstoSharing = new Set<String>();
    Set<String> clIdstoStopSharing = new Set<String>();

    public void bulkBefore() {  
        // isInsert
        if(Trigger.isInsert){  
            Set<String> accIds = new Set<String>();

            for(Client_Sharing__c cl : (List<Client_Sharing__c>)Trigger.new){
                if(!String.isBlank(cl.Account__c)){                    
                    accIds.add(cl.Account__c);
                }
            } 

            ClientSharingTriggerHelper.checkValidDate((List<Client_Sharing__c>)Trigger.new, accIds);
            
        }else if(Trigger.isUpdate){
            Set<String> accIds = new Set<String>();
            Map<Id,Client_Sharing__c> oldMap = (Map<Id,Client_Sharing__c>)Trigger.oldMap;
            for(Client_Sharing__c cl : (List<Client_Sharing__c>)Trigger.new){
                Client_Sharing__c oldCL = oldMap.get(cl.Id);
                if(!String.isBlank(cl.Account__c)
                    && (cl.Start_date__c != oldCL.Start_date__c
                        || cl.End_date__c != oldCL.End_date__c 
                        || (cl.Status__c != oldCL.Status__c && cl.Status__c == ClientSharingConstant.STATUS_WAITING_FOR_APPROVAL)
                        )
                ){                    
                    accIds.add(cl.Account__c);
                }
            } 

            ClientSharingTriggerHelper.checkValidDate((List<Client_Sharing__c>)Trigger.new, accIds);
        }
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {	
        if(Trigger.isUpdate){            
            Map<Id,Client_Sharing__c> oldMap = (Map<Id,Client_Sharing__c>)Trigger.oldMap;
            for(Client_Sharing__c cl : (List<Client_Sharing__c>)Trigger.new){
                Client_Sharing__c oldCL = oldMap.get(cl.Id);
                if(cl.Status__c != oldCL.Status__c && cl.Status__c == ClientSharingConstant.STATUS_IN_PROGRESS){
                    clIdstoSharing.add(cl.Id);
                }else if(cl.Status__c != oldCL.Status__c && cl.Status__c == ClientSharingConstant.STATUS_COMPLETED){
                    clIdstoStopSharing.add(cl.Id);
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
        System.debug('this.clIdstoSharing.size()=>' + this.clIdstoSharing.size());
        if(this.clIdstoSharing.size() > 0){
            ClientSharingTriggerHelper.attemptSharing(this.clIdstoSharing);
        }

        System.debug('this.clIdstoStopSharing.size()=>' + this.clIdstoStopSharing.size());
        if(this.clIdstoStopSharing.size() > 0){
            ClientSharingTriggerHelper.attemptStopSharing(this.clIdstoStopSharing);
        }
    } 
}