public with sharing class cc_CaseTriggerHelper {
    public class CaseChangeEvtWrapper{
        public String assignee;
        public String changeType;
        public String description;
        public String fields;
        public String issueType;
        public String jiraId;
        public String jiraProject;
        public String link;
        public String priority;
        public Set<String> jiracc;
        public String severity;
        public String status;
        public String subject;
        public String caseNumber;
        public String caseId;
        public Date dueDate;
        public String caseOwner;
    }

    public class CaseChangeWrp{
        public String subject;
        public String caseNumber;
        public String caseId;
        public String changeLogs;
        public String userChange;
        public String type;
    }

    public class JiraIssueResponseWrapper{
        public String id;
        public String key;
        public String self;
    }

    private static cc_CaseTriggerHelper caseHelperInstance = null;
    public cc_Jira_Integration__c jira {get; set;}
    public Jira_Setting__c jiraSetting {get; set;}

    private cc_CaseTriggerHelper(){
        this.jira = cc_Jira_Integration__c.getInstance('coccocjira');
        this.jiraSetting = Jira_Setting__c.getInstance();
    }

    public static cc_CaseTriggerHelper getCaseHelperInstance(){
        if(caseHelperInstance == null){
            caseHelperInstance = new cc_CaseTriggerHelper();
        }

        return caseHelperInstance;
    }


    //Attempt Create Issue from Salesforce
    public static void attemptCreateJiraIssue(String params){
        if (!System.isBatch() && !System.isFuture()) {
            attemptAsyncCreateJiraIssue(params);   
        }
    }

    //Attempt Create Issue from Salesforce
    public static void attemptUpdateJiraIssue(String params){
        if (!System.isBatch() && !System.isFuture()) {
            attemptAsyncUpdateJiraIssue(params);   
        }
    }


    public static void attemptPublishCaseChangeEvt(List<CaseChangeWrp> msgs){
        List<CaseChangeEvent__e> evtns = new  List<CaseChangeEvent__e>();
        for(CaseChangeWrp msg :msgs){
            CaseChangeEvent__e evt = new CaseChangeEvent__e();
            evt.CaseId__c = msg.CaseId;
            evt.CaseNumber__c = msg.CaseNumber;
            evt.ChangeLogs__c = msg.ChangeLogs;
            evt.Subject__c = msg.Subject;
            evt.Type__c = msg.Type;
            evt.UserChange__c = msg.UserChange;

            evtns.add(evt);
        }   

        if(evtns.size() > 0){
            Eventbus.publish(evtns);
        }
    }


    @future(callout=true)
    public static void attemptAsyncCreateJiraIssue(String params){
        Set<String> caseIds = new Set<String>();
        List<Case> casetoUpdates = new  List<Case>();        
        List<CaseChangeEvtWrapper> eventMsgs = (List<CaseChangeEvtWrapper>)JSON.deserialize(params, List<CaseChangeEvtWrapper>.class);        
        Map<String,User> mapUser = new Map<String,User>([SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']);
        
        for(CaseChangeEvtWrapper msg: eventMsgs){
            caseIds.add(msg.CaseId);
        }

        Map<String, Case> mapCase = new Map<String, Case>([SELECT Id, CaseNumber FROM Case WHERE Id IN :caseIds]);
        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String restUrl = jira.restpath__c;        
        String defautProject = jira.restpath__c;    
        System.debug('defautProject=>' + defautProject + 'restUrl=>' + restUrl);

        for(CaseChangeEvtWrapper msg: eventMsgs){
            String caseNumber = (String)mapCase.get(msg.CaseId).CaseNumber;

            msg.CaseNumber = caseNumber;

            //Get mapping Jira Account ID for reporter;            
            if(msg.jiracc !=null ){
                Set<String> jiraAccId = new Set<String>();
                for(String jra: msg.jiracc){
                    if(!String.isBlank(jra)){
                        String jiracc = mapUser.get(jra).JiraaccountId__c;
                        if(!String.isBlank(jiracc)){
                            jiraAccId.add(jiracc);                            
                        }
                    }
                }
                
                if(jiraAccId.size() > 0){
                    msg.jiracc = jiraAccId;
                }else {
                    msg.jiracc = new Set<String>();
                }
            }
            
            if(!String.isBlank(restUrl)){ 
                String endpoint;
                if(Test.isRunningTest()){
                    endpoint = 'https://coccoc.atlassian.net/rest/api/3/issue';                    
                }else{
                    endpoint = 'callout:JiraBasicAuth/' +  restUrl;  
                }       
                
                HttpRequest request = new HttpRequest();
                HttpResponse response = new HttpResponse();
                Http http = new Http(); 
                String jsbody = generateJSONCreateCase(msg);

                request.setEndpoint(endpoint);		
                request.setHeader('Content-Type','application/json');            
                request.setMethod('POST');
                request.setTimeout(120000);
                request.setBody(jsbody);
                
                response = http.send(request);
                
                System.debug('jsbody=>' + jsbody);
                System.debug('response.getStatusCode()=>' + response.getStatusCode());
                if (response.getStatusCode() == 201) {
                    String resJS = response.getBody();
                    JiraIssueResponseWrapper res = (JiraIssueResponseWrapper) JSON.deserialize(resJS, JiraIssueResponseWrapper.class);

                    Case udCase = new Case();
                    udCase.Id = msg.CaseId;
                    udCase.JiraKey__c = res.key;
                    udCase.JiraId__c = res.id;
                    
                    casetoUpdates.add(udCase);
                    System.debug('Response=>' + resJS);
                }else {
                    String resJS = response.getBody();
                    System.debug('Response=>' + resJS);
                }
            }

        }

        if(casetoUpdates.size() > 0 && Case.sObjectType.getDescribe().isUpdateable()){
            update casetoUpdates;
        }

    }


    @future(callout=true)
    public static void attemptAsyncUpdateJiraIssue(String params){
        Set<String> caseIds = new Set<String>();
        List<CaseChangeEvtWrapper> eventMsgs = (List<CaseChangeEvtWrapper>)JSON.deserialize(params, List<CaseChangeEvtWrapper>.class);        
        System.debug('eventMsgs=>' +eventMsgs);
        for(CaseChangeEvtWrapper msg: eventMsgs){

            System.debug('msg.JiraId=>' + msg.JiraId + 'msg.fields' + msg.Fields);
            if(!String.isBlank(msg.JiraId)){            
                cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');

                String restUrl = jira.restpath__c + '/' + msg.JiraId;        
                String defautProject = jira.restpath__c;    

                System.debug('restUrl=>' + restUrl);
                if(!String.isBlank(restUrl)){     
                    String endpoint;
                    if(Test.isRunningTest()){
                        endpoint = 'https://coccoc.atlassian.net/rest/api/3/issue/10000';                    
                    }else{
                        endpoint = 'callout:JiraBasicAuth/' +  restUrl;   
                    } 
                    
                    HttpRequest request = new HttpRequest();
                    HttpResponse response = new HttpResponse();
                    Http http = new Http(); 
                    String jsbody = JSONGenerateUpdateCase(msg);

                    request.setEndpoint(endpoint);		
                    request.setHeader('Content-Type','application/json');            
                    request.setMethod('PUT');
                    request.setTimeout(120000);
                    request.setBody(jsbody);
                    
                    response = http.send(request);
                    
                    System.debug('response.getStatusCode()=>' + response.getStatusCode());
                    if (response.getStatusCode() == 204) { 

                    }
                }
            }
        }

    }


    public static String JSONGenerateUpdateCase(CaseChangeEvtWrapper evt){

        JSONGenerator gen = JSON.createGenerator(true);    

        String fields = evt.Fields;
        String[] changefields;
        if(!String.isBlank(fields)){
            changefields = fields.split(',');
        }

        
        if(changefields.size() > 0){
            gen.writeStartObject();     
            gen.writeFieldName('fields');
                gen.writeStartObject();	


                for (String field : changefields) {
                    if(field == 'summary'){
                        //Sumary
                        gen.writeStringField('summary', evt.Subject);
                    }else if(field == 'duedate'){
                        //Due Date
                        if(evt.duedate != null){            
                            Date duedate = evt.duedate;      
                            String month = duedate.month() < 10?'0' + String.valueOf(duedate.month()) : String.valueOf(duedate.month());
                            String year = String.valueOf(duedate.year());
                            String strduedate = year + '-' + month +'-' + String.valueOf(duedate.day());
                            gen.writeStringField('duedate', strduedate);
                        } 
                    }else if(field == 'issuetype'){
                        //Issue Type
                        if(!String.isBlank(evt.IssueType)){
                            gen.writeFieldName('issuetype');
                                gen.writeStartObject();	
                                    gen.writeStringField('name', evt.IssueType);
                                gen.writeEndObject();
                        } 
                    }else if(field == 'description'){
                        //Description
                        gen.writeFieldName('description');
                        gen.writeStartObject();	
                            gen.writeStringField('type', 'doc');
                            gen.writeNumberField('version', 1);
                            gen.writeFieldName('content');
                                gen.writeStartArray();
                                    gen.writeStartObject();	
                                        gen.writeStringField('type', 'paragraph');
                                        gen.writeFieldName('content');
                                            gen.writeStartArray();
                                                gen.writeStartObject();	
                                                    gen.writeStringField('text', evt.Description);
                                                    gen.writeStringField('type', 'text');
                                                gen.writeEndObject();	    
                                            gen.writeEndArray();
                                    gen.writeEndObject();	    
                                gen.writeEndArray();
                        gen.writeEndObject();

                    }else if(field == 'severity'){
                        //Severity
                        gen.writeFieldName('customfield_10049');
                        gen.writeStartObject();	
                            gen.writeStringField('value', evt.Severity);
                        gen.writeEndObject();
                    }else if(field == 'AOM' && !String.isBlank(evt.CaseOwner)){
                        //AOM
                        gen.writeStringField('customfield_10064', evt.CaseOwner);                           
                    }else if(field == 'assignee' && !String.isBlank(evt.assignee)){
                        //Assignee
                        gen.writeFieldName('assignee');
                        gen.writeStartObject();	
                            gen.writeStringField('accountId', evt.assignee);
                        gen.writeEndObject();                    
                    }                 
                }

                gen.writeEndObject(); 
            gen.writeEndObject();

            String jsonData = gen.getAsString();
            System.debug('jsonData-' + jsonData);
            
            return jsonData;
        }else {
            return null;
        }
    }

    public static String generateJSONCreateCase(CaseChangeEvtWrapper evt){       
                
        JSONGenerator gen = JSON.createGenerator(true);
        // gen.writeStartObject();   

        // for(cc_CaseTriggerHelper.CaseChangeEvtWrapper evt : evts){            
            // gen.writeFieldName('issueUpdates');  
            //     gen.writeStartArray();

                    gen.writeStartObject();     
                        gen.writeFieldName('fields');
                        gen.writeStartObject();	
                        
                            //Sumary
                            gen.writeStringField('summary', evt.Subject);

                            //CaseNumber
                            gen.writeStringField('customfield_10057', evt.CaseNumber);
                            gen.writeStringField('customfield_10059', evt.CaseId);

                            //Due Date
                            if(evt.DueDate != null){            
                                Date duedate = evt.DueDate;      
                                String month = duedate.month() < 10?'0' + String.valueOf(duedate.month()) : String.valueOf(duedate.month());
                                String year = String.valueOf(duedate.year());
                                String strduedate = year + '-' + month +'-' + String.valueOf(duedate.day());
                                gen.writeStringField('duedate', strduedate);
                            }        

                            //Issue Type
                            if(!String.isBlank(evt.IssueType)){
                                gen.writeFieldName('issuetype');
                                    gen.writeStartObject();	
                                        gen.writeStringField('name', evt.IssueType);
                                    gen.writeEndObject();
                            } 
                            
                            //Assignee
                            if(!String.isBlank(evt.Assignee)){
                                gen.writeFieldName('assignee');
                                    gen.writeStartObject();	
                                        gen.writeStringField('id', evt.Assignee);
                                    gen.writeEndObject();
                            } 

                            //jiracc
                            if(evt.jiracc.size() > 0 ){                                
                                gen.writeFieldName('customfield_10034');
                                    gen.writeStartArray();
                                    for(String jra : evt.jiracc){                                       
                                        gen.writeStartObject();	
                                            gen.writeStringField('id', jra);
                                        gen.writeEndObject();                                       
                                    }
                                gen.writeEndArray();    
                            }                             

                            //Project                            
                            if(!String.isBlank(evt.JiraProject) ){                                
                                gen.writeFieldName('project');
                                    gen.writeStartObject();	
                                        gen.writeStringField('id', '10071');
                                    gen.writeEndObject();	
                            }    
                            
                            //Description
                            if(!String.isBlank(evt.Description) ){
                                gen.writeFieldName('description');
                                gen.writeStartObject();	
                                    gen.writeStringField('type', 'doc');
                                    gen.writeNumberField('version', 1);
                                    gen.writeFieldName('content');
                                        gen.writeStartArray();
                                            gen.writeStartObject();	
                                                gen.writeStringField('type', 'paragraph');
                                                gen.writeFieldName('content');
                                                    gen.writeStartArray();
                                                        gen.writeStartObject();	
                                                            gen.writeStringField('text', evt.Description);
                                                            gen.writeStringField('type', 'text');
                                                        gen.writeEndObject();	    
                                                    gen.writeEndArray();
                                            gen.writeEndObject();	    
                                        gen.writeEndArray();
                                gen.writeEndObject();
                            }

                            //Severity
                            if(!String.isBlank(evt.Severity)){
                                gen.writeFieldName('customfield_10049');
                                gen.writeStartObject();	
                                    gen.writeStringField('value', evt.Severity);
                                gen.writeEndObject();    
                            }

                            if(!String.isBlank(evt.CaseOwner)){
                                //AOM
                                gen.writeStringField('customfield_10064', evt.CaseOwner);                           
                            }   
                        
                        gen.writeEndObject(); 
                    gen.writeEndObject();
                // gen.writeEndArray();
            
        // }    
        // gen.writeEndObject();        

        System.debug('gen-' + gen);

        String jsonData = gen.getAsString();
        //System.debug('jsonData-' + jsonData);
        
        return jsonData;
    }
}