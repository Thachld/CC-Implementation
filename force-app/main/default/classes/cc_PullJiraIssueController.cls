public with sharing class cc_PullJiraIssueController {
    public Case cs{get;set;}
    public Id caseId {get;set;}
    public Boolean refreshPage {get;set;}
    public Datetime lastSyncDatetime {get;set;}   
    public cc_Jira_Integration__c jira {get;set;}
    List<JiraCommentMapping__c> commentMapping {get;set;}
    List<Case> updateCase {get;set;}
    List<ConnectApi.BatchInput> batchInputs{get;set;}
    Map<String,ConnectApi.FeedItemInput> mapEditInput{get;set;}

    public cc_PullJiraIssueController(ApexPages.StandardController sdt) {
        this.caseId = sdt.getId();        
    }

    
    public Pagereference pullInformation(){
        try{ 
            getInfo();            
            pullJiraIssue();
            pullJiraComment();      
            updateData();
            
            PageReference tempPage = ApexPages.currentPage();           
            tempPage.setRedirect(true);
            this.refreshPage = true;
            return null; 
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }    

    public void updateData(){
        try {
            if(this.updateCase.size() > 0) {
                update this.updateCase;
            }

            // if(this.commentMapping.size() > 0){
            //     insert this.commentMapping;
            // }

            // System.debug('this.mapEditInput=>' + this.mapEditInput.size());
            if(this.mapEditInput !=null ){
                for( String feedId: this.mapEditInput.keySet() ){
                    ConnectApi.FeedItemInput feedIput = this.mapEditInput.get(feedId);
                    cc_static_Message.isUpdateCaseFeedViaAPI = true;
                    ConnectApi.ChatterFeeds.updateFeedElement(Network.getNetworkId(), feedId, feedIput);
                }
            }

            // System.debug('this.batchInputs=>' + this.batchInputs.size());
            if(this.batchInputs != null){
                cc_static_Message.isCreateCaseFeedViaAPI = true;
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
            }
            
        } catch (Exception ex) {
            System.debug('updateData log=>' + ex.getMessage());
        }
    }

    //Pull Jira change Logs
    public void pullJiraIssue(){    
        Map<String,User> mapUser =new Map<String,User>();
        List<Case> updateCases = new List<Case>();       
        if(!String.isBlank(this.cs.JiraId__c)){

            String filterStr;
            String fieldtypefilterStr = 'issuetype IN (Task,Bug)';
            String jiraIdfilterStr = ' id IN (' + this.cs.JiraId__c + ')' ;

            filterStr = fieldtypefilterStr + ' AND ' + jiraIdfilterStr;

            
            String fields = this.jira.FieldLogChange__c;       
            String[] logfields = fields.split(',');

            //generate body;
            String jsbody = genJSONBody(filterStr);  

            for (User us: [SELECT Id, JiraaccountId__c FROM User]){
                if(!String.isBlank(us.JiraaccountId__c)){
                    mapUser.put(us.JiraaccountId__c, us);
                }
            }

            
            Map<String,List<cc_JiraLogWrapper>> maplogs = makeRequest(filterStr, jsbody, this.lastSyncDatetime);  

            
            if(maplogs.size() > 0  ){
                
                for(String jiraId : maplogs.keySet()){                    
                                                   
                    
                        List<cc_JiraLogWrapper> logs = maplogs.get(jiraId);
                        System.debug('log=>' +logs);
                        Boolean hasChanged = false;                        
                        for(cc_JiraLogWrapper log : logs){                            
                            
                            if(!String.isBlank(log.field) && logfields.contains(log.field)){
                                if(log.field == 'summary'){
                                    this.cs.Subject = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'status'){
                                    this.cs.JiraStatus__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'assignee'){
                                    if(!String.isBlank(mapUser.get(log.toValue).Id )){
                                        this.cs.Assignee__c = mapUser.get(log.toValue).Id;
                                        hasChanged = true;
                                    }
                                }else if(log.field == 'project'){
                                    this.cs.JiraProject__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'priority'){
                                    this.cs.Priority = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'description'){
                                    this.cs.Description = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'customfield_10049'){
                                    this.cs.Severity__c = log.toString;
                                    hasChanged = true;                                
                                }else if(log.field == 'issuetype'){
                                    this.cs.IssueType__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'duedate'){
                                    this.cs.duedate__c = Date.valueOf(log.toValue) ;
                                    hasChanged = true;
                                }                                
                            }
                        }
                        
                        if(hasChanged){
                            this.updateCase.add(this.cs);                            
                        }
                       
                    
                }

            }   
        }  
    }

    //Pull Jira comment
    public void pullJiraComment(){
        Map<String,User> mapUser =new Map<String,User>();
        Map<String,String> mapexistsFeeds = new Map<String,String>();       
        
        // System.debug('this.cs.JiraId__c=>' + this.cs.JiraId__c);
        if(!String.isBlank(this.cs.JiraId__c)){
            String restUrl = jira.restpath__c;
            String apiURI = restUrl;

            String URI = apiURI + '/' + cs.JiraId__c + '/comment';
            String endpoint;
            if(Test.isRunningTest()){
                endpoint = 'https://coccoc.atlassian.net/rest/api/3/issue/10000/comment';
            }else{
                endpoint = 'callout:JiraBasicAuth/' +  URI;
            }

            for(JiraCommentMapping__c mapp :[SELECT JiraCommentId__c, FeedItemId__c FROM JiraCommentMapping__c WHERE CaseId__c = :this.caseId ]){
                if(!mapexistsFeeds.containsKey(mapp.JiraCommentId__c)){
                    mapexistsFeeds.put(mapp.JiraCommentId__c, mapp.FeedItemId__c);
    
                }
            }
            // System.debug('mapexistsFeeds=>' + mapexistsFeeds);

            for (User us: [SELECT Id, JiraaccountId__c FROM User]){
                if(!String.isBlank(us.JiraaccountId__c)){
                    mapUser.put(us.JiraaccountId__c, us);
                }
            }

            // System.debug('endpoint=>' + endpoint);            

            JiraCommentWrapper.JiraComment comments = makeCommentRequest(endpoint);

            if(comments != null){
                for(JiraCommentWrapper.CommentWrapper comment: comments.comments){ 

                    //New Jira Comment
                    if(!mapexistsFeeds.containsKey(comment.id) ){                                              
                        if(comment.body != null){                            
                            ConnectApi.FeedItemInput feedIput = ChatterAPIBuilder.initFeedItem(comment, this.caseId, mapUser, true);
                            if(feedIput !=null){
                                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedIput);
                                this.batchInputs.add(batchInput);                                
                            }
                        }

                    //Update Jira Comment
                    }else {  
                                                 
                        if((comment.updated > comment.created && comment.updated >= this.lastSyncDatetime) || (Test.isRunningTest()) ){
                            if(comment.body != null){
                                String feedId = mapexistsFeeds.get(comment.id);
                                ConnectApi.FeedItemInput feedIput = ChatterAPIBuilder.initFeedItem(comment, this.caseId, mapUser, false);     
                                if(!String.isBlank(feedId)){                                
                                    if(feedIput !=null){
                                        this.mapEditInput.put(feedId, feedIput);                                        
                                    }
                                }else {
                                    if(feedIput !=null){
                                        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedIput);
                                        this.batchInputs.add(batchInput);
                                    }
                                }                            
                            }
                        }
                    }                  
                }                                        
            }
        }
                
    }

    public String genJSONBody(String jqlStr){
        JSONGenerator gen = JSON.createGenerator(true);

        gen.writeStartObject();
            gen.writeFieldName('expand');
            gen.writeStartArray();
                gen.WriteString('changelog');                
            gen.writeEndArray();

            gen.writeStringField('jql', jqlStr);
            gen.writeNumberField('maxResults', 100);
            gen.writeBooleanField('fieldsByKeys', false);    
            gen.writeNumberField('startAt', 0);    
        gen.writeEndObject();

        String jsStr = Gen.getAsString();

        return jsStr;
    }

    public Map<String,List<cc_JiraLogWrapper>> makeRequest(String filterStr, String jsbody, Datetime lastSyncDatetime){
        Map<String,List<cc_JiraLogWrapper>> maplogs = new Map<String,List<cc_JiraLogWrapper>>();
        try {
            String restUrl = this.jira.restpath__c;
            String apiURI = 'rest/api/3/search';
            
            String endpoint;
            if(Test.isRunningTest()){
                endpoint = 'https://coccoc.atlassian.net/rest/api/3/search';
            }else {
                endpoint = 'callout:JiraBasicAuth/' +  apiURI;
            }
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();                     

            request.setEndpoint(endpoint);		
            request.setHeader('Content-Type','application/json');            
            request.setMethod('POST');
            request.setTimeout(120000);
            request.setBody(jsbody);
            
            response = http.send(request);
        
            System.debug('response.getStatusCode()=>' + response.getStatusCode());        
                       
            if (response.getStatusCode() == 200){
                String resBody = response.getBody();
                maplogs = parseJSON(resBody, lastSyncDatetime);   
                System.debug('maplogs=>' + maplogs);    
                System.debug('lastSyncDatetime=>' + lastSyncDatetime);             
            }
        } catch (Exception ex) {
            System.debug('Case getMessage()=>' + ex.getMessage());       
        }

        return maplogs;
    }

    public Map<String,List<cc_JiraLogWrapper>> parseJSON(String response, Datetime lastSyncDatetime){

        Map<String,List<cc_JiraLogWrapper>> maplogs = new Map<String,List<cc_JiraLogWrapper>>();
        JSONParser parser = JSON.createParser(response);

        while (parser.nextToken() != JSONToken.END_OBJECT) {            
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                String issueAttr = parser.getText();
                parser.nextToken();
                
                if(issueAttr == 'issues'){                    
                    String jiraId;
                    while (parser.nextToken() != JSONToken.END_ARRAY) {  
                        while (parser.nextToken() != JSONToken.END_OBJECT) {                            
                            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                    String logAttr = parser.getText();                                    
                                    parser.nextToken();
                                    
                                    if(logAttr == 'id'){                                        
                                        jiraId = parser.getText();
                                    }else if(logAttr == 'changelog'){
                                        while (parser.nextToken() != JSONToken.END_OBJECT) {                            
                                            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                                    String hisAttr = parser.getText();                                                    
                                                    parser.nextToken();
                                                    
                                                     if(hisAttr == 'histories'){                                                        
                                                        Map<String,cc_JiraLogWrapper> mapLogstemp = new  Map<String,cc_JiraLogWrapper>();
                                                        while (parser.nextToken() != JSONToken.END_ARRAY) {
                                                            
                                                            cc_JiraLogWrapper log =new cc_JiraLogWrapper();
                                                            while (parser.nextToken() != JSONToken.END_OBJECT) {
                                                                if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                                                     //Create new change Log                                                    
                                                                        String itemAttr = parser.getText();                                                                        
                                                                        parser.nextToken();

                                                                        if(itemAttr == 'id'){                                                                            
                                                                            log.logId = parser.getText();
                                                                        }else if(itemAttr == 'author'){                                                                            
                                                                            while(parser.nextToken() != JSONToken.END_OBJECT) {
                                                                                if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                                                                    String autAttr = parser.getText();                                                                                    
                                                                                    parser.nextToken();

                                                                                    if(autAttr == 'accountId'){
                                                                                        log.author = parser.getText();
                                                                                    }else {
                                                                                        parser.skipChildren();
                                                                                    }
                                                                                }
                                                                            }
                                                                        }else if(itemAttr == 'created'){                                                                            
                                                                            log.created = parser.getDateTimeValue();
                                                                        }else if(itemAttr == 'items'){
                                                                            while (parser.nextToken() != JSONToken.END_ARRAY) {
                                                                                while (parser.nextToken() != JSONToken.END_OBJECT) {
                                                                                    if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                                                                                        String fieldAttr = parser.getText();
                                                                                        parser.nextToken();
                                                                                        if(fieldAttr == 'fieldId'){  
                                                                                            log.field = parser.getText();
                                                                                        }else if(fieldAttr == 'from'){
                                                                                            log.fromValue = parser.getText();   
                                                                                        }else if(fieldAttr == 'fromString'){
                                                                                            log.fromString = parser.getText();   
                                                                                        }else if(fieldAttr == 'to'){
                                                                                            log.toValue = parser.getText();   
                                                                                        }else if(fieldAttr == 'toString'){
                                                                                            log.toString = parser.getText();   
                                                                                        }else {
                                                                                            parser.skipChildren();
                                                                                        }    
                                                                                    }                                                                  
                                                                                }
                                                                            }
                                                                        }else {
                                                                            parser.skipChildren();
                                                                        }                                                        
                                                                }    
                                                                
                                                                
                                                            }  

                                                            
                                                            if(log.created >= lastSyncDatetime ){                                                            
                                                                if(!mapLogstemp.containsKey(log.field)){
                                                                    mapLogstemp.put(log.field, log);
                                                                }else {
                                                                    cc_JiraLogWrapper currLog = mapLogstemp.get(log.field);
                                                                    //get lastest log change
                                                                    if(currLog != null){
                                                                        if(log.created > currLog.created){
                                                                            mapLogstemp.put(log.field, log);
                                                                        }
                                                                    } 
                                                                }
                                                            }
                                                        }
                                                        if(mapLogstemp != null){
                                                            maplogs.put(jiraId, mapLogstemp.values());
                                                        }
                                                        
                                                    }else {
                                                        parser.skipChildren();
                                                    }

                                            }
                                        }
                                    }else {
                                        parser.skipChildren();
                                    }
                            }
                        }
                    }
                }else {
                    parser.skipChildren();
                }
            }            
        }
        return maplogs;
    }


    public JiraCommentWrapper.JiraComment makeCommentRequest(String endpoint){
        JiraCommentWrapper.JiraComment comment = new JiraCommentWrapper.JiraComment();
        try {            
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();   

            request.setEndpoint(endpoint);		
            request.setHeader('Content-Type','application/json');            
            request.setMethod('GET');
            request.setTimeout(120000);                
            
            response = http.send(request);
        
            // System.debug('makeCommentRequest getStatusCode()=>' + response.getStatusCode());                   
            if (response.getStatusCode() == 200){
                String jsbody = response.getBody();                    
                // comments = ChatterAPIBuilder.parseJiraComment(jsbody);
                comment = JiraCommentWrapper.parse(jsbody);
                
            }               

        } catch (Exception ex) {
            System.debug('getMessage()=>' + ex.getMessage());       
        }

        return comment;
    }    

    public void getInfo(){
        this.cs = [SELECT Id, JiraId__c, JiraKey__c, Subject, JiraStatus__c,
                    Assignee__c, JiraProject__c,Priority,Description,Severity__c,IssueType__c,duedate__c, CreatedDate
                FROM Case WHERE Id=:this.caseId LIMIT 1];        

        this.jira = cc_Jira_Integration__c.getInstance('coccocjira');   
        if(!Test.isRunningTest()){
            this.lastSyncDatetime = this.cs.CreatedDate;   
        }else {
            this.lastSyncDatetime = Datetime.newInstance(2020, 1, 1);
        }
       
        this.commentMapping = new List<JiraCommentMapping__c>();
        this.updateCase = new List<Case>();  
        this.batchInputs = new List<ConnectApi.BatchInput>();
        this.mapEditInput = new Map<String,ConnectApi.FeedItemInput>();
        
    }
}