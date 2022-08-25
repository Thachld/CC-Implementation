public class cc_UpdateCaseFromJira_Batch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    public string[] logfields {get;set;}  
    public Datetime lastSyncDatetime {get;set;} 

    public cc_UpdateCaseFromJira_Batch(Datetime plastSyncDatetime){
        Datetime sytemdate = System.Now();
        this.lastSyncDatetime = plastSyncDatetime ==null? sytemdate.addMinutes(-60): plastSyncDatetime;

        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String fields = jira.FieldLogChange__c;       
        logfields = fields.split(',');
        
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, JiraId__c, CreatedDate FROM Case WHERE CreateJiraTicket__c = true AND JiraId__c != '' AND Status != 'Closed']);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope){

        Map<String,User> mapUser = new Map<String,User>();
        List<Case> updateCases = new List<Case>();
        Map<String,String> mapCaseJira = new Map<String,String>();
        String filterStr;
        String fieldtypefilterStr = 'issuetype IN (Task,Bug)';
        String jiraIdfilterStr=' id IN (';

        Integer i = 0;
        for(Case cs : scope){
            if(!String.isBlank(cs.JiraId__c)){
                if(i == 0){
                    jiraIdfilterStr += cs.JiraId__c;
                }else {
                    jiraIdfilterStr += ',' + cs.JiraId__c;
                }
                
                i = i + 1; 

                mapCaseJira.put(cs.JiraId__c, cs.Id);
            }
        }

        jiraIdfilterStr = jiraIdfilterStr + ')';
        filterStr = fieldtypefilterStr + ' AND ' + jiraIdfilterStr;
        String jsbody = genJSONBody(filterStr);    

        for (User us: [SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']){
            if(!mapUser.containsKey(us.JiraaccountId__c)){
                mapUser.put(us.JiraaccountId__c, us);
            }
        }

        
        Map<String,List<cc_JiraLogWrapper>> maplogs = makeRequest(filterStr, jsbody,this.lastSyncDatetime);  
            if(maplogs.size() != null ){
                
                for(String jiraId : maplogs.keySet()){
                    Case upCase = new Case();
                    if(!String.isBlank(mapCaseJira.get(jiraId))){
                        upCase.Id = mapCaseJira.get(jiraId);                    
                    
                        List<cc_JiraLogWrapper> logs = maplogs.get(jiraId);
                        Boolean hasChanged = false;
                        for(cc_JiraLogWrapper log : logs){
                            System.debug('log=>' + log);

                            if(!String.isBlank(log.field) && logfields.contains(log.field)){
                                if(log.field == 'summary'){
                                    upCase.Subject = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'status'){
                                    upCase.JiraStatus__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'assignee'){
                                    if(!String.isBlank(mapUser.get(log.toValue).Id )){
                                        upCase.Assignee__c = mapUser.get(log.toValue).Id;
                                        hasChanged = true;
                                    }
                                }else if(log.field == 'project'){
                                    upCase.JiraProject__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'priority'){
                                    upCase.Priority = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'description'){
                                    upCase.Description = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'customfield_10049'){
                                    upCase.Severity__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'labels'){                                    
                                    if(!String.isBlank(log.toString)){
                                        String labelstr = log.toString.replace(' ', ';');
                                        upCase.JiraLabels__c = labelstr;
                                    }
                                }else if(log.field == 'issuetype'){
                                    upCase.IssueType__c = log.toString;
                                    hasChanged = true;
                                }else if(log.field == 'duedate'){
                                    upCase.duedate__c = Date.valueOf(log.toValue) ;
                                    hasChanged = true;
                                }                                
                            }
                        }

                        if(hasChanged){
                            updateCases.add(upCase);                            
                        }
                       
                    }
                }

            }               

        System.debug('updateCases=>' + updateCases.size());
        if(updateCases.size() > 0){
            update updateCases;
        }


    }

    public void finish(Database.BatchableContext bc){

    }
    
    public static Map<String,List<cc_JiraLogWrapper>> makeRequest(String filterStr, String jsbody, Datetime lastSyncDatetime){
        Map<String,List<cc_JiraLogWrapper>> maplogs = new Map<String,List<cc_JiraLogWrapper>>();
        try {            
            cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
            String restUrl = jira.restpath__c;
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
            System.debug('response=>' + response.getBody());
            if (response.getStatusCode() == 200){
                String resBody = response.getBody();
                maplogs = parseJSON(resBody, lastSyncDatetime);                
            }
        } catch (Exception ex) {
            
        }

        return maplogs;
    }

    public static String genJSONBody(String jqlStr){
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

    public static Map<String,List<cc_JiraLogWrapper>> parseJSON(String response, Datetime lastSyncDatetime){

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
}