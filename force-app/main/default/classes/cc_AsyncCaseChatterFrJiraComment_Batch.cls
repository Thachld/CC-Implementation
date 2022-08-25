public class cc_AsyncCaseChatterFrJiraComment_Batch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    public Datetime lastSyncDatetime {get;set;}     

    public cc_AsyncCaseChatterFrJiraComment_Batch(Datetime plastSyncDatetime) {
        Datetime sytemdate = System.Now();        

        this.lastSyncDatetime = plastSyncDatetime ==null? sytemdate.addMinutes(-60): plastSyncDatetime;
    }


    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, JiraId__c FROM Case 
                                        WHERE CreateJiraTicket__c = true 
                                        AND JiraId__c != ''
                                        AND Status != 'Closed']);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope){
        Map<String,User> mapUser = new Map<String,User>();
        Map<String,String> mapCaseJira = new Map<String,String>();
        Map<String,String> mapexistsFeeds = new Map<String,String>();
        Map<String, List<JiraCommentWrapper.CommentWrapper>> mapCaseFeeds = new Map<String, List<JiraCommentWrapper.CommentWrapper>>();       
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        List<JiraCommentMapping__c> commentMapping = new List<JiraCommentMapping__c>();

        for (User us: [SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']){
            if(!mapUser.containsKey(us.JiraaccountId__c)){
                mapUser.put(us.JiraaccountId__c, us);
            }
        }

        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String restUrl = jira.restpath__c;
        String apiURI = restUrl;

        for(Case cs : scope){
            if(!String.isBlank(cs.JiraId__c)){         
                mapCaseJira.put(cs.JiraId__c, cs.Id);
            }
        }
        

        for(JiraCommentMapping__c mapp :[SELECT JiraCommentId__c, FeedItemId__c FROM JiraCommentMapping__c WHERE CaseId__c IN :mapCaseJira.values() ]){
            if(!mapexistsFeeds.containsKey(mapp.JiraCommentId__c)){
                mapexistsFeeds.put(mapp.JiraCommentId__c, mapp.FeedItemId__c);

            }
        }

        
        for(Case cs : scope){
            if(!String.isBlank(cs.JiraId__c)){                
                String URI = apiURI + '/' + cs.JiraId__c + '/comment';

                String endpoint;
                if(Test.isRunningTest()){
                    endpoint = 'https://coccoc.atlassian.net/rest/api/3/issue/10000/comment';
                }else{
                    endpoint = 'callout:JiraBasicAuth/' +  URI;
                }
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http();   

                request.setEndpoint(endpoint);		
                request.setHeader('Content-Type','application/json');            
                request.setMethod('GET');
                request.setTimeout(120000);                
                
                response = http.send(request);
               
                                  
                if (response.getStatusCode() == 200){
                    String jsbody = response.getBody();     
                    JiraCommentWrapper.JiraComment comment = JiraCommentWrapper.parse(jsbody);
                   
                    if(comment != null) {
                        mapCaseFeeds.put(cs.Id, comment.comments);
                                                
                    }
                }                
            }
        }
        
        if(mapCaseFeeds.size() > 0){
            for(String caseId: mapCaseFeeds.keySet()){
                List<JiraCommentWrapper.CommentWrapper> comments = mapCaseFeeds.get(caseId);

                for(JiraCommentWrapper.CommentWrapper comment: comments){ 
                   
                    if(!mapexistsFeeds.containsKey(comment.id) ){    
                        // System.debug('newcomment=> ' + comment);                    
                        if(comment.body != null){
                            ConnectApi.FeedItemInput feedIput = ChatterAPIBuilder.initFeedItem(comment, caseId, mapUser, true);
                            if(feedIput !=null){
                                System.debug('newcomment=> ' + comment);
                                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedIput);
                                batchInputs.add(batchInput);                                
                            }
                        }
                    }else {
                        // System.debug('updatecomment=> ' + comment);       
                        if((comment.updated > comment.created && comment.updated >= this.lastSyncDatetime) || (Test.isRunningTest())){

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
                                        System.debug('updatecomment=> ' + comment);   
                                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedIput);
                                        batchInputs.add(batchInput);
                                    }
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

    public void finish(Database.BatchableContext bc){

    }       
}