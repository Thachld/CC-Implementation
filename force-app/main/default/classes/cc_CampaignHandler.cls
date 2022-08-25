public with sharing class cc_CampaignHandler implements cc_Itrigger{    
    Set<String> createCampIds = new Set<String>();
    Set<String> updateCampIds = new Set<String>();
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
        if(Trigger.isDelete){
            for(Campaign oldCamp : (List<Campaign>)Trigger.old){
                if(!String.isBlank(oldCamp.QCCampaignId__c)){                     
                    oldCamp.addError('You can not delete this Campaign because this Campaign already created on QC System!');
                }
            }
        }
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {
        if(Trigger.isInsert){
            String recordTypeID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId();
            for(Campaign newCamp : (List<Campaign>)Trigger.new){                 
                if(newCamp.Status == CampaignConstant.STATUS_IN_PROGRESS 
                    && newCamp.RecordTypeId == recordTypeID 
                    && String.isBlank(newCamp.QCCampaignId__c)
                    // && newCamp.Internal_Type__c == TransactionTypeConstant.PROMOTION
                    ){
                    createCampIds.add(newCamp.Id);
                }                
            }


        }else if (Trigger.isUpdate) { 
            Map<Id, Campaign>  oldMap = (Map<Id, Campaign>)Trigger.oldMap;
            String recordTypeID = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            for(Campaign newCamp : (List<Campaign>)Trigger.new){                
                Campaign oldCamp = oldMap.get(newCamp.Id);
                if(newCamp.Status == CampaignConstant.STATUS_IN_PROGRESS 
                    // && newCamp.Internal_Type__c == TransactionTypeConstant.PROMOTION
                    ){                
                    if( ((oldCamp.Status != newCamp.Status) || (oldCamp.Transactions_Type__c != newCamp.Transactions_Type__c))
                        && newCamp.RecordTypeId == recordTypeID 
                        && String.isBlank(newCamp.QCCampaignId__c)){
                        createCampIds.add(newCamp.Id);
                    }else if(oldCamp.Status == newCamp.Status){
                        if((oldCamp.Name != newCamp.Name) || (oldCamp.MultipleUsage__c != newCamp.MultipleUsage__c)){
                            updateCampIds.add(newCamp.Id);
                        }
                    }
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
        
        System.debug('createCampIds=>' + createCampIds.size());
        if(createCampIds.size() > 0){
            cc_CampaignHelper.attemptCreateCampaignToQC(createCampIds);
        }


        System.debug('updateCampIds=>' + updateCampIds.size());
        if(updateCampIds.size() > 0){
            cc_CampaignHelper.attemptUpdateCampaignToQC(updateCampIds);
        }
    }       
}