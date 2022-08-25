/********************************************************************************************************
* @author        CocCoc - THACHLD
* @date          2022 May 30
* @description   Helper class to sync jira comments
* @param   mapCaseFeed - Map Case Id vs List of Jira Comment id.
*********************************************************************************************************/
public with sharing class CaseFeedSyncFromJira {    

    public static void syncCreateCaseFeed(Map<String,JiraCommentAPIWrapper> mapCaseFeed){        
        Map<String, List<JiraCommentWrapper.CommentWrapper>> mapComment = new Map<String, List<JiraCommentWrapper.CommentWrapper>>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        Map<String,User> mapUser = new Map<String,User>();
        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String restUrl = jira.restpath__c;
        String apiURI = restUrl;
         
        for(String caseId : mapCaseFeed.keySet()){
            String jiraId = mapCaseFeed.get(caseId).jiraId;
            String commentId = mapCaseFeed.get(caseId).commentId;
            String URI = restUrl + '/' + jiraId + '/comment/' + commentId;
            String endpoint = 'callout:JiraBasicAuth/' +  URI;
            Integer timeout = 120000;            

            cc_Callout calloutWrapper = new cc_Callout('{}', endpoint, 'GET', timeout, null);
            HttpRequest req = cc_HttpCallout.setupHttpRequest(calloutWrapper);
            HttpResponse res = cc_HttpCallout.makeRequest(req);

            System.debug('req.getEndpoint() =>' + req.getEndpoint());
            System.debug('res.getStatusCode() =>' + res.getStatusCode());
            System.debug('res.getBody() =>' + res.getBody());
            if(res.getStatusCode() == 200){
                String jsbody = res.getBody();
                JiraCommentWrapper.CommentWrapper comment = parseSingleComment(jsbody);
                if(mapComment.containsKey(caseId)){
                    mapComment.get(caseId).add(comment);
                }else {
                    mapComment.put(caseId, new List<JiraCommentWrapper.CommentWrapper>{comment});
                }
            }

        }


        if(mapComment.size() > 0){
            for (User us: [SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']){
                if(!mapUser.containsKey(us.JiraaccountId__c)){
                    mapUser.put(us.JiraaccountId__c, us);
                }
            }

            for (String caseId : mapComment.keySet()){
                List<JiraCommentWrapper.CommentWrapper> comments = mapComment.get(caseId);
                if(comments !=null){
                    for(JiraCommentWrapper.CommentWrapper comment: comments){ 
                        if(comment.body != null){
                            ConnectApi.FeedItemInput feedInput = ChatterAPIBuilder.initFeedItem(comment, caseId, mapUser, true);
                            if(feedInput !=null){
                                System.debug('newcomment=> ' + comment);
                                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedInput);
                                batchInputs.add(batchInput);                                
                            }
                        }
                    }
                }
            }
            
        }

        if(batchInputs.size() > 0){
            cc_static_Message.isCreateCaseFeedViaAPI = true;
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);            
        }
    }


    public static void syncUpdateCaseFeed(Map<String,JiraCommentAPIWrapper> mapCaseFeed){        
        Map<String, List<JiraCommentWrapper.CommentWrapper>> mapComment = new Map<String, List<JiraCommentWrapper.CommentWrapper>>();
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        Map<String,String> mapexistsFeeds = new Map<String,String>();
        Map<String,User> mapUser = new Map<String,User>();
        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String restUrl = jira.restpath__c;
        String apiURI = restUrl;
         
        for(String caseId : mapCaseFeed.keySet()){
            String jiraId = mapCaseFeed.get(caseId).jiraId;
            String commentId = mapCaseFeed.get(caseId).commentId;

            String URI = restUrl + '/' + jiraId + '/comment/' + commentId;
            String endpoint = 'callout:JiraBasicAuth/' +  URI;
            Integer timeout = 120000;            

            cc_Callout calloutWrapper = new cc_Callout('{}', endpoint, 'GET', timeout, null);
            HttpRequest req = cc_HttpCallout.setupHttpRequest(calloutWrapper);
            HttpResponse res = cc_HttpCallout.makeRequest(req);

            System.debug('req.getEndpoint() =>' + req.getEndpoint());
            System.debug('res.getStatusCode() =>' + res.getStatusCode());
            System.debug('res.getBody() =>' + res.getBody());
            if(res.getStatusCode() == 200){
                String jsbody = res.getBody();
                JiraCommentWrapper.CommentWrapper comment = parseSingleComment(jsbody);
                if(mapComment.containsKey(caseId)){
                    mapComment.get(caseId).add(comment);
                }else {
                    mapComment.put(caseId, new List<JiraCommentWrapper.CommentWrapper>{comment});
                }
            }

        }


        if(mapComment.size() > 0){
            for (User us: [SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']){
                if(!mapUser.containsKey(us.JiraaccountId__c)){
                    mapUser.put(us.JiraaccountId__c, us);
                }
            }

            for(JiraCommentMapping__c mapp :[SELECT JiraCommentId__c, FeedItemId__c FROM JiraCommentMapping__c WHERE CaseId__c IN :mapCaseFeed.keySet() ]){
                if(!mapexistsFeeds.containsKey(mapp.JiraCommentId__c)){
                    mapexistsFeeds.put(mapp.JiraCommentId__c, mapp.FeedItemId__c);
    
                }
            }

            for (String caseId : mapComment.keySet()){
                List<JiraCommentWrapper.CommentWrapper> comments = mapComment.get(caseId);
                if(comments !=null){
                    for(JiraCommentWrapper.CommentWrapper comment: comments){ 
                        if(comment.body != null){
                            String feedId = mapexistsFeeds.get(comment.id);
                            ConnectApi.FeedItemInput feedIput = ChatterAPIBuilder.initFeedItem(comment, caseId, mapUser,false);

                            if(!String.isBlank(feedId)){                                
                                if(feedIput !=null){
                                    cc_static_Message.isUpdateCaseFeedViaAPI = true;
                                    if(!Test.isRunningTest()){
                                        ConnectApi.ChatterFeeds.updateFeedElement(Network.getNetworkId(), feedId, feedIput);
                                    }
                                }
                            }else {
                                if(feedIput !=null){
                                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedIput);
                                    batchInputs.add(batchInput);
                                }
                            }                            
                        }                    
                    }
                }
            }
            
        }

        if(batchInputs.size() > 0){
            cc_static_Message.isCreateCaseFeedViaAPI = true;
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);            
        }
    }

    public static JiraCommentWrapper.CommentWrapper parseSingleComment(String json){
		return (JiraCommentWrapper.CommentWrapper) System.JSON.deserialize(json, JiraCommentWrapper.CommentWrapper.class);
	}
}