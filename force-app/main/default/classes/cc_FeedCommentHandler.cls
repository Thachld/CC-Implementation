public with sharing class cc_FeedCommentHandler implements cc_ITrigger{        
    /* bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
        if(Trigger.isDelete){
            if (!DisableChatterDeleteDelegate.allowDelete()) {
                for(FeedComment f : (List<FeedComment>)Trigger.old){
                    f.addError('Your administrator has disabled feed comment and comment deletions.'); 
                }
            }
        }else if(Trigger.isInsert){
            Set<String> parentIds = new Set<String>();
            Set<String> jiracaseIds = new Set<String>();
            Map<String,String> mapObType = new Map<String,String>();

            for(FeedComment fm : (List<FeedComment>)Trigger.new){
                if(!String.isBlank(fm.ParentId)){                    
                    Id parentId = fm.ParentId;
                    String obName = parentId.getSObjectType().getDescribe().getName();

                    if(obName == 'Case'){
                        parentIds.add(fm.ParentId);
                    }
                }
            }


            for(Case cs: [SELECT Id,JiraId__c FROM Case WHERE Id IN :parentIds AND CreateJiraTicket__c = true]){                
                if(!String.isBlank(cs.JiraId__c)){
                    jiracaseIds.add(cs.Id);
                } 
            }

            
            for(FeedComment fm : (List<FeedComment>)Trigger.new){
                if(!String.isBlank(fm.ParentId)){                    
                    Id parentId = fm.ParentId;
                    String obName = parentId.getSObjectType().getDescribe().getName();

                    if(obName == 'Case'){
                        if(jiracaseIds.contains(fm.ParentId)){
                            fm.addError('Unable to create comment on Case linked with Jira Issue/Bug, Please create new post chater instead of Comment'); 
                        }
                    }
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
        
    } 
}