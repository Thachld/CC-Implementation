public with sharing class cc_FeedItemHandler implements cc_ITrigger{   
    Set<String> insertFeedIds = new Set<String>();
    Set<String> insertviaAPIFeeds = new Set<String>();
    Set<String> updateFeedIds = new Set<String>();      
    Map<String,cc_CaseTriggerHelper.CaseChangeWrp> mapFeedChange = new Map<String,cc_CaseTriggerHelper.CaseChangeWrp>();    
    /* bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
        if(Trigger.isDelete){
            if (!DisableChatterDeleteDelegate.allowDelete()) {
                for(FeedItem f : (List<FeedItem>)Trigger.old){
                    f.addError('Your administrator has disabled feed post and comment deletions.'); 
                }
            }
        }else if(Trigger.isInsert){
            if(cc_static_Message.isCreateCaseFeedViaAPI == null){
                cc_static_Message.isCreateCaseFeedViaAPI = false;
            }            
        }else if(Trigger.isUpdate){
            if(cc_static_Message.isUpdateCaseFeedViaAPI == null){
                cc_static_Message.isUpdateCaseFeedViaAPI = false;
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
            Set<String> parentIds = new Set<String>();
            Set<String> jiracaseIds = new Set<String>();
            Map<String,String> mapObType = new Map<String,String>();
            Map<String,Case> mapCase = new Map<String,Case>();
            for(FeedItem fitem: (List<FeedItem>)Trigger.new){  
                Id parentId = fitem.ParentId;
                String obName = parentId.getSObjectType().getDescribe().getName();
                System.debug('cc_static_Message.isCreateCaseFeedViaAPI=>' + cc_static_Message.isCreateCaseFeedViaAPI);
                if(obName == 'Case'){
                    parentIds.add(fitem.ParentId);
                }             
            }     


            for(Case cs: [SELECT Id, JiraId__c, Subject, CaseNumber, CreateJiraTicket__c FROM Case WHERE Id IN :parentIds]){
                if(!String.isBlank(cs.JiraId__c) && cs.CreateJiraTicket__c == true){
                    jiracaseIds.add(cs.Id);
                }               
                
                mapCase.put(cs.Id, cs);
            }

            System.debug('cc_static_Message.isCreateCaseFeedViaAPI=>' + cc_static_Message.isCreateCaseFeedViaAPI);
            for(FeedItem feed : (List<FeedItem>)Trigger.new){
                if(!String.isBlank(feed.ParentId)){                    
                    Id parentId = feed.ParentId;
                    String obName = parentId.getSObjectType().getDescribe().getName();

                    if(obName == 'Case'){

                        //Create Feed with case Linked to Jira ticket
                        if(jiracaseIds.contains(feed.ParentId)){                    
                            if(cc_static_Message.isCreateCaseFeedViaAPI == false){
                                insertFeedIds.add(feed.Id);
                            }else{
                                insertviaAPIFeeds.add(feed.Id);
                            }
                        }

                        //Push message Create Feed to Platform evetn
                        if(mapCase.containsKey(feed.ParentId)){
                            Case cs = mapCase.get(feed.ParentId);
                            cc_CaseTriggerHelper.CaseChangeWrp msgFeed = new cc_CaseTriggerHelper.CaseChangeWrp();
                            msgFeed.CaseId = cs.Id;
                            msgFeed.Subject = cs.Subject;
                            msgFeed.CaseNumber = cs.CaseNumber;
                            msgFeed.Type = 'INSERT_FEED';
                            msgFeed.UserChange = UserInfo.getName(); 
                            msgFeed.ChangeLogs = feed.Body;

                            mapFeedChange.put(feed.Id, msgFeed);
                        }
                    }
                }
            }

        }else if (Trigger.isUpdate){    
            Set<String> parentIds = new Set<String>();
            Set<String> jiracaseIds = new Set<String>();
            Map<String,String> mapObType = new Map<String,String>();
            Map<String,Case> mapCase = new Map<String,Case>();
            Map<Id,FeedItem> oldMap = (Map<Id,FeedItem>)Trigger.oldMap;
                    
            for(FeedItem fitem: (List<FeedItem>)Trigger.new){
                FeedItem oldfItem = oldMap.get(fitem.Id);
                Id parentId = fitem.ParentId;
                String obName = parentId.getSObjectType().getDescribe().getName();
                System.debug('cc_static_Message.isUpdateCaseFeedViaAPI=>' + cc_static_Message.isUpdateCaseFeedViaAPI);
                if(obName == 'Case' && cc_static_Message.isUpdateCaseFeedViaAPI == false && oldfItem.Body != fitem.Body){
                    parentIds.add(fitem.ParentId);
                }                           
            } 

            for(Case cs: [SELECT Id, JiraId__c, Subject, CaseNumber, CreateJiraTicket__c FROM Case WHERE Id IN :parentIds]){
                if(!String.isBlank(cs.JiraId__c) && cs.CreateJiraTicket__c == true){
                    jiracaseIds.add(cs.Id);
                }               
                
                mapCase.put(cs.Id, cs);
            }

            
            for(FeedItem feed : (List<FeedItem>)Trigger.new){
                if(!String.isBlank(feed.ParentId)){   
                    Id parentId = feed.ParentId;
                    String obName = parentId.getSObjectType().getDescribe().getName();

                    if(obName == 'Case'){

                        //Update Feed with case Linked to Jira ticket
                        if(jiracaseIds.contains(feed.ParentId)){
                            updateFeedIds.add(feed.Id);
                        }


                        //Push message change Feed to Platform evetn
                        if(mapCase.containsKey(feed.ParentId) ){
                            Case cs = mapCase.get(feed.ParentId);
                            cc_CaseTriggerHelper.CaseChangeWrp msgFeed = new cc_CaseTriggerHelper.CaseChangeWrp();
                            msgFeed.CaseId = cs.Id;
                            msgFeed.Subject = cs.Subject;
                            msgFeed.CaseNumber = cs.CaseNumber;
                            msgFeed.Type = 'UPDATE_FEED';
                            msgFeed.UserChange = UserInfo.getName(); 
                            msgFeed.ChangeLogs = feed.Body;

                            mapFeedChange.put(feed.Id, msgFeed);
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
        System.debug('insertFeedIds=>' + insertFeedIds.size());
        if(insertFeedIds.size() > 0 && !Test.isRunningTest()){
            cc_FeedItemHelper.attemptCreatePosttoJira(insertFeedIds);
        }

        System.debug('updateFeedIds=>' + updateFeedIds.size());
        if(updateFeedIds.size() > 0 && !Test.isRunningTest()){
            cc_FeedItemHelper.attemptUpdatePosttoJira(updateFeedIds);
        }

        System.debug('insertviaAPIFeeds=>' + insertviaAPIFeeds.size());
        if(insertviaAPIFeeds.size() > 0){
            cc_FeedItemHelper.attemptCreatePostViaAPI(insertviaAPIFeeds);
        }

        System.debug('mapFeedChange=>' + mapFeedChange.size());
        if(mapFeedChange.size() > 0){
            cc_FeedItemHelper.attemptPublishFeedEvt(mapFeedChange.values());
        }        
    }  
}