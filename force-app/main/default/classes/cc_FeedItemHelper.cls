public with sharing class cc_FeedItemHelper {
    
    //Create Comment by user
    public static void attemptCreatePosttoJira(Set<String> createPostIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsyncCreatePosttoJira(createPostIds);
        }
    }

    //edit Comment
    public static void attemptUpdatePosttoJira(Set<String> updatePostIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsyncUpdatePosttoJira(updatePostIds);
        }
        
    }

    //Create Case Feed by API
    public static void attemptCreatePostViaAPI(Set<String> insertviaAPIFeeds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsyncCreatePostViaAPI(insertviaAPIFeeds);
        }else {
            attemptSyncCreatePostViaAPI(insertviaAPIFeeds);
        }        
    }


    public static void attemptPublishFeedEvt(List<cc_CaseTriggerHelper.CaseChangeWrp> msgs){
        List<CaseChangeEvent__e> evtns = new  List<CaseChangeEvent__e>();
        for(cc_CaseTriggerHelper.CaseChangeWrp msg :msgs){
            CaseChangeEvent__e evt = new CaseChangeEvent__e();
            evt.CaseId__c = msg.CaseId;
            evt.CaseNumber__c = msg.CaseNumber;
            evt.ChangeLogs__c = msg.ChangeLogs.stripHtmlTags();
            evt.Subject__c = msg.Subject;
            evt.Type__c = msg.Type;
            evt.UserChange__c = msg.UserChange;

            evtns.add(evt);
        }   

        if(evtns.size() > 0){
            Eventbus.publish(evtns);
        }
    }



    @future
    public static void attemptAsyncCreatePostViaAPI(Set<String> insertviaAPIFeeds){
        attemptSyncCreatePostViaAPI(insertviaAPIFeeds);
    }


    @future(callout=true)
    public static void attemptAsyncUpdatePosttoJira(Set<String> updatePostIds){
        Map<String,User> mapUser = new Map<String,User>([SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']);
        Map<String, JiraCommentMapping__c> mapJiraComment = new Map<String, JiraCommentMapping__c>();
        for(JiraCommentMapping__c mapping : [SELECT FeedItemId__c,  CaseId__c, CaseId__r.JiraId__c, JiraCommentId__c, Id FROM  JiraCommentMapping__c WHERE FeedItemId__c IN :updatePostIds]){
            if(!mapJiraComment.containsKey(mapping.FeedItemId__c)){
                mapJiraComment.put(mapping.FeedItemId__c, mapping);
            }
        }
        
        if(Test.isRunningTest()){
            Jira_Intergration_Test__c testdata = [SELECT CaseId__c, CommentId__c, FeedId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
            JiraCommentMapping__c mapping = new JiraCommentMapping__c();
            mapping.FeedItemId__c = testdata.FeedId__c;
            mapping.JiraCommentId__c = testdata.CommentId__c;//Comment Id in Mock class
            mapping.CaseId__c = testdata.CaseId__c;
            mapJiraComment.put(testdata.FeedId__c, mapping);
            
        }
        
        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String restUrl = jira.restpath__c;       


        for(String feedItemId: mapJiraComment.keyset()){
            JiraCommentMapping__c mapping = mapJiraComment.get(feedItemId);
            ConnectApi.FeedElement feedItem;

            if(Test.isRunningTest()){
                Jira_Intergration_Test__c testdata = [SELECT CaseId__c, CommentId__c, FeedId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];

                feedItem = ConnectApi.ChatterFeeds.getFeedElement(Network.getNetworkId(), testdata.FeedId__c);
            }else{
                feedItem = ConnectApi.ChatterFeeds.getFeedElement(Network.getNetworkId(), feedItemId);
            }            
            
            if(!String.isBlank(mapping.JiraCommentId__c) && !String.isBlank(mapping.CaseId__c)){
                String jiraId = mapping.CaseId__r.JiraId__c;
                String commentId = mapping.JiraCommentId__c;
                String apiURI = restUrl + '/' + jiraId + '/comment/' + commentId;

                String endpoint;
                if(Test.isRunningTest()){
                    Jira_Intergration_Test__c testdata = [SELECT JiraId__c, CommentId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
                    endpoint = 'https://coccoc.atlassian.net/rest/api/3/issue/' + testdata.JiraId__c + '/comment/' +  testdata.CommentId__c;
                }else{
                    endpoint = 'callout:JiraBasicAuth/' +  apiURI;  
                }
                
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http(); 
                String jsbody = genJsonCreateCommentAPI(feedItem, mapUser,false);

                request.setEndpoint(endpoint);		
                request.setHeader('Content-Type','application/json');            
                request.setMethod('PUT');
                request.setTimeout(120000);
                request.setBody(jsbody);
                
                response = http.send(request);
                
                System.debug('response=>' + response.getBody());
                System.debug('response.getStatusCode()=>' + response.getStatusCode());
                if (response.getStatusCode() == 204){

                }
            }
               
        }

    }


    public static void attemptSyncCreatePostViaAPI(Set<String> createPostIds){
        List<JiraCommentMapping__c> commentMapping = new List<JiraCommentMapping__c>();

        List<FeedItem> listFeeds = [SELECT Id, Body, ParentId FROM FeedItem WHERE Id IN : createPostIds];
        if(listFeeds != null){
            for(FeedItem feed: listFeeds){
                if(!String.isBlank(feed.Body)){                
                    String body = (String)feed.Body;
                    Integer maxlen = body.Length();
                    String firstStr = body.substring(0, 50 > maxlen? maxlen : 50);
                    String substr = 'CommentId[';
                    Integer indx = firstStr.indexOf(substr);

                    if(indx != -1){                           
                        String commentId = firstStr.substringBetween('[',']');

                        if(!String.isBlank(commentId)){
                            JiraCommentMapping__c mapping = new JiraCommentMapping__c();
                            mapping.FeedItemId__c = feed.Id;
                            mapping.JiraCommentId__c = commentId;
                            mapping.CaseId__c = feed.ParentId;

                            commentMapping.add(mapping);
                        }
                    }               

                }
            }
        }
        
        if(commentMapping.size()>0){
            Database.insert(commentMapping, false);
        }
    }

    @future(callout=true)
    public static void attemptAsyncCreatePosttoJira(Set<String> createPostIds){
        List<JiraCommentMapping__c> commentMapping = new List<JiraCommentMapping__c>();
        Map<String,Set<String>> mapCaseFeedItems = new Map<String,Set<String>>();
        Map<String,Case> mapFeedCase = new Map<String,Case>();
        Map<String,User> mapUser = new Map<String,User>([SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']);

       

        for(FeedItem fitem: [SELECT Id, ParentId FROM FeedItem WHERE Id IN :createPostIds]){
            if(mapCaseFeedItems.containsKey(fitem.ParentId)){
                mapCaseFeedItems.get(fitem.ParentId).add(fitem.Id);
            }else {
                mapCaseFeedItems.put(fitem.ParentId, new Set<String>{fitem.Id});
            }            
        }

        for(Case cs: [SELECT Id, JiraId__c, OwnerId FROM Case WHERE Id IN :mapCaseFeedItems.keySet()]){
            if(!String.isBlank(cs.JiraId__c)){
                Set<String> feeditemIds = new Set<String>();
                feeditemIds = mapCaseFeedItems.get(cs.Id);
                for(String fId : feeditemIds){
                    if(!mapFeedCase.containsKey(fId)){
                        mapFeedCase.put(fId, cs);
                    }                    
                }
            }
        }


        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String restUrl = jira.restpath__c;         

        for(String feedItemId : createPostIds){
            String jiraId = mapFeedCase.get(feedItemId).JiraId__c;
            String caseId = mapFeedCase.get(feedItemId).Id;
            String ownerId = mapFeedCase.get(feedItemId).OwnerId;
            ConnectApi.FeedElement feedItem;

            if(Test.isRunningTest()){
                Jira_Intergration_Test__c testdata = [SELECT FeedId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
                feedItem = ConnectApi.ChatterFeeds.getFeedElement(Network.getNetworkId(), testdata.FeedId__c);
            }else{
                feedItem = ConnectApi.ChatterFeeds.getFeedElement(Network.getNetworkId(), feedItemId);
            }
            
           

            if(!String.isBlank(jiraId)){
                String apiURI = restUrl + '/' + jiraId + '/comment';
                String endpoint;
                if(Test.isRunningTest()){
                    Jira_Intergration_Test__c testdata = [SELECT JiraId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
                    endpoint = 'https://coccoc.atlassian.net/rest/api/3/issue/' + testdata.JiraId__c + '/comment';  
                }else{
                    endpoint = 'callout:JiraBasicAuth/' +  apiURI;  
                }
                
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http(); 
                String jsbody = genJsonCreateCommentAPI(feedItem, mapUser, true);

                request.setEndpoint(endpoint);		
                request.setHeader('Content-Type','application/json');            
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setBody(jsbody);
                
                response = http.send(request);
                
                System.debug('jsbody=>' + jsbody);
                System.debug('response.getStatusCode()=>' + response.getStatusCode());
                System.debug('response.getBody()=>' + response.getBody());
                
                if (response.getStatusCode() == 201){
                    String jsres = response.getBody();      
                    
                    String commentId = parseCommentResponse(jsres);
                    JiraCommentMapping__c mapping = new JiraCommentMapping__c();
                    mapping.FeedItemId__c = feedItemId;
                    mapping.JiraCommentId__c = commentId;
                    mapping.CaseId__c = caseId;

                    commentMapping.add(mapping);
                }
            }

        }

        if(commentMapping.size() > 0){
            Database.insert(commentMapping, false) ;            
        }

    }


    public static string parseCommentResponse(String jsres){

        JSONParser parser = JSON.createParser(jsres);
        String commentId = '';

        while (parser.nextToken() != JSONToken.END_OBJECT) {
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                String attr = parser.getText(); 
                parser.nextToken();

                if(attr == 'id'){
                    commentId = parser.getText();                     
                }else{
                    parser.skipChildren();
                }
            }
        }


        return commentId;
    }


    public static String genJsonCreateCommentAPI(ConnectApi.FeedElement feedItem, Map<String, User> mapUser, Boolean isCreate){
        List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
        ConnectApi.MarkupBeginSegment beginMarkup;
        ConnectApi.MarkupEndSegment endMarkup;
        ConnectApi.TextSegment textSegment;
        ConnectApi.MentionSegment mentionSegment;
        ConnectApi.LinkSegment linkSegment;


        Boolean isReturn = false;

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeFieldName('body');
                gen.writeStartObject();
                    gen.writeStringField('type', 'doc');
                    gen.writeNumberField('version', 1);
                    gen.writeFieldName('content');
                        gen.writeStartArray();       
                        
                            if(isCreate){
                                gen.writeStartObject();
                                    gen.writeStringField('type', 'paragraph');   
                                    gen.writeFieldName('content'); 
                                        gen.writeStartArray();    
                                            gen.writeStartObject();
                                                gen.writeStringField('type', 'text'); 
                                                gen.writeStringField('text', 'Comment from SF by @' + UserInfo.getName()); 
                                                gen.writeFieldName('marks');
                                                    gen.writeStartArray();    
                                                        gen.writeStartObject();
                                                            gen.writeStringField('type', 'em'); 
                                                        gen.writeEndObject();

                                                        gen.writeStartObject();
                                                            gen.writeStringField('type', 'textColor'); 
                                                            gen.writeFieldName('attrs');
                                                                gen.writeStartObject();
                                                                    gen.writeStringField('color', '#97a0af'); 
                                                                gen.writeEndObject();

                                                        gen.writeEndObject();

                                                    gen.writeEndArray();    
                                            gen.writeEndObject();
                                        gen.writeEndArray();    
                                gen.writeEndObject();
                            }

                            for (ConnectApi.MessageSegment messageSegment : messageSegments) {

                                if(messageSegment instanceof ConnectApi.MarkupBeginSegment){                                                
                                    beginMarkup = (ConnectApi.MarkupBeginSegment) messageSegment;
                                    if(beginMarkup.markupType == ConnectApi.MarkupType.UNORDEREDLIST){
                                        gen.writeStartObject();
                                            gen.writeStringField('type', 'bulletList'); 
                                            gen.writeFieldName('content'); 
                                                gen.writeStartArray();       
                                            
                                    }else if(beginMarkup.markupType ==ConnectApi.MarkupType.ORDEREDLIST){
                                        gen.writeStartObject(); 
                                            gen.writeStringField('type', 'orderedList'); 
                                            gen.writeFieldName('content');   
                                                gen.writeStartArray();       
                                                
                                    }else if(beginMarkup.markupType == ConnectApi.MarkupType.LISTITEM){
                                        gen.writeStartObject(); 
                                            gen.writeStringField('type', 'listItem'); 
                                            gen.writeFieldName('content'); 
                                                gen.writeStartArray();    
                                                    gen.writeStartObject(); 
                                                        gen.writeStringField('type', 'paragraph');   
                                                        gen.writeFieldName('content'); 
                                                            gen.writeStartArray();     
                                                
                                    }else if(beginMarkup.markupType == ConnectApi.MarkupType.PARAGRAPH 
                                                || beginMarkup.markupType == ConnectApi.MarkupType.ITALIC 
                                                || beginMarkup.markupType == ConnectApi.MarkupType.BOLD){
                                        gen.writeStartObject(); 
                                            gen.writeStringField('type', 'paragraph'); 
                                            gen.writeFieldName('content'); 
                                                gen.writeStartArray();       
                                            
                                    }
                                }else if(messageSegment instanceof ConnectApi.MarkupEndSegment){
                                    endMarkup = (ConnectApi.MarkupEndSegment) messageSegment;
                                    if(endMarkup.markupType == ConnectApi.MarkupType.UNORDEREDLIST){                                      
                                            gen.writeEndArray();       
                                            gen.writeEndObject();
                                    }else if(endMarkup.markupType ==ConnectApi.MarkupType.ORDEREDLIST){
                                            gen.writeEndArray();       
                                            gen.writeEndObject();
                                    }else if(endMarkup.markupType ==ConnectApi.MarkupType.LISTITEM){
                                                            gen.writeEndArray();
                                                        gen.writeEndObject();
                                                    gen.writeEndArray();       
                                                gen.writeEndObject();
                                    }else if(endMarkup.markupType == ConnectApi.MarkupType.PARAGRAPH 
                                            || endMarkup.markupType == ConnectApi.MarkupType.ITALIC 
                                            || endMarkup.markupType == ConnectApi.MarkupType.BOLD){
                                            gen.writeEndArray();       
                                            gen.writeEndObject();
                                    }
                                }else if(messageSegment instanceof ConnectApi.TextSegment){
                                    textSegment = (ConnectApi.TextSegment) messageSegment;
                                  
                                    gen.writeStartObject();
                                        gen.writeStringField('type', 'text'); 
                                        gen.writeStringField('text', (String.valueOf(textSegment.text))); 
                                    gen.writeEndObject();
                                                                        
                                }else if(messageSegment instanceof ConnectApi.MentionSegment){
                                    mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                                    ConnectApi.ActorWithId userinfo= mentionSegment.record;
                                    User us = mapUser.get(userinfo.Id);

                                    if(us != null){
                                        String jiraaccountId = us.JiraaccountId__c==null? '' : us.JiraaccountId__c;
                                        String name = mentionSegment.name;
                                        
                                            gen.writeStartObject();
                                                gen.writeStringField('type', 'mention'); 
                                                gen.writeFieldName('attrs');    
                                                    gen.writeStartObject();
                                                        gen.writeStringField('id', jiraaccountId);
                                                        gen.writeStringField('text', (String.valueOf(mentionSegment.name))); 
                                                    gen.writeEndObject();  
                                            gen.writeEndObject();  
                                    }else {
                                        gen.writeStartObject();
                                            gen.writeStringField('type', 'text'); 
                                            gen.writeStringField('text', '@' + (String.valueOf(mentionSegment.name)) ); 
                                        gen.writeEndObject();
                                    }
                                    
                                    
                                     
                                }else if(messageSegment instanceof ConnectApi.LinkSegment){
                                    linkSegment = (ConnectApi.LinkSegment)messageSegment;
                                                                                             
                                        gen.writeStartObject();
                                            gen.writeStringField('type', 'inlineCard'); 
                                            gen.writeFieldName('attrs');    
                                                gen.writeStartObject();
                                                    gen.writeStringField('url', linkSegment.url);                                               
                                                gen.writeEndObject();  
                                            gen.writeEndObject();
                                    
                                }
                            } 
                        gen.writeEndArray();
                gen.writeEndObject();

        gen.writeEndObject();


        return gen.getAsString();

    }
}