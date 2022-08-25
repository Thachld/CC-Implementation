public with sharing class cc_SyncJiraUser_Batch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    public cc_SyncJiraUser_Batch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, UserName, Email, JiraAccountId__c, Trac_Name__c, LastName,IsActive, ProfileId,Sale_Team__c
                                    FROM User ]);
    }

    public void execute(Database.BatchableContext bc, List<User> scope){             

        List<User> updateUser = new List<User>();
        List<User> insertUser = new List<User>();       
        Map<String, User> mapUser = new Map<String, User>();
        List<JiraUserWrapper> listJiraUser = new List<JiraUserWrapper>();        

        cc_Jira_Integration__c jira = cc_Jira_Integration__c.getInstance('coccocjira');
        String chatterProfileId = jira.Chatter_Profile_Id__c.trim();
        String restUrl = jira.restpath__c.trim();
        String exceptionEmail = jira.Exception_Email__c;
        String[] exceptEmails = new String[]{''};
        if(!String.isBlank(exceptionEmail)){
            exceptEmails = exceptionEmail.split(',');
        }
        
        // String apiURI = restUrl + '/users/search';        
        String endpoint;
        if(Test.isRunningTest()){
            endpoint = 'https://coccoc.atlassian.net/rest/api/3/users/search';
        }else{
            endpoint = 'callout:JiraBasicAuth/' +  'rest/api/3/users/search?startAt=0&maxResults=2000';
        }

        for(User us : scope){            
            String email = us.Email;
            Integer invIdx = email.indexOf('.invalid');
            if(invIdx > 0 ){
                email = email.substring(0,invIdx);
            }           
            Integer idx = email.indexOf('.chatter');
            if(idx > 0 ){               
                email = email.substring(0,idx);
            }

            mapUser.put(email, us);
        }

        System.debug('Endpoint=>' + endpoint);
        System.debug('mapUser=>' + mapUser);
        listJiraUser = makeRequest(endpoint);

        if(listJiraUser != null){
            for(JiraUserWrapper jiraUser: listJiraUser){
                if(jiraUser.accountType == 'atlassian' 
                    && !String.isBlank(jiraUser.emailAddress) 
                    && !exceptEmails.contains(jiraUser.emailAddress)){
                    String jiraemail = jiraUser.emailAddress.trim();    

                    User currUser = mapUser.get(jiraemail);
                    Boolean isUpdate = false;
                    
                    System.debug('jiraUser=>' + jiraUser);
                    System.debug('currUser=>' + currUser);
                    if(currUser != null){                        

                        if(jiraUser.accountId != currUser.JiraAccountId__c){
                            currUser.JiraAccountId__c = jiraUser.accountId;
                            isUpdate = true;
                            System.debug('jiraUser=>' + jiraUser);
                            System.debug('currUser=>' + currUser);
                        }

                        if(isUpdate){
                            currUser.Sale_Team__c = 'Other';
                            updateUser.add(currUser);
                        }
                    }else if(jiraUser.active == true){                     
                        User newUser = initChatterUser(jiraUser,chatterProfileId);
                        if(newUser != null){
                            insertUser.add(newUser);
                        }
                    }   
                }        
            }
        }

        System.debug('updateUser=>' + updateUser.size());
        if(updateUser.size() > 0){
            update updateUser;
        }

        System.debug('insertUser=>' + insertUser.size());
        if(insertUser.size() > 0){
            insert insertUser;
        }

    }

    public void finish(Database.BatchableContext bc){

    }

    public static List<JiraUserWrapper> makeRequest(String endpoint){
        try {
            List<JiraUserWrapper> result = new List<JiraUserWrapper>();

            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();   

            request.setEndpoint(endpoint);		
            request.setHeader('Content-Type','application/json');            
            request.setMethod('GET');
            request.setTimeout(120000);                
            
            response = http.send(request);
            System.debug('response.getStatusCode()=>' + response.getStatusCode());
            System.debug('response.getBody()=>' + response.getBody());
            System.debug('request.getEndpoint()=>' + request.getEndpoint());
            
            if (response.getStatusCode() == 200){
                String jsbody = response.getBody();   

                result = JiraUserWrapper.parseListUser(jsbody);
            }

            System.debug('result=>' + result.size());
            return result;

        } catch (Exception ex) {
            System.debug('Http Request Error=>' + ex.getMessage());
        }
        return null;
    }


    public static User initChatterUser(JiraUserWrapper info,String profileId){
        try {

            String email = info.emailAddress.trim();
            Integer idx = email.indexOf('@coccoc');
            String tracName = email.substring(0, idx);

            User auser = new User();
            auser.Lastname = info.displayName;
            auser.Email = info.emailAddress + '.chatter';
            auser.Username = info.emailAddress + '.chatter';
            auser.Alias = tracName.right(8);
            auser.JiraAccountId__c = info.accountId;
            auser.EmailEncodingKey = 'ISO-8859-1';            
            auser.TimeZoneSidKey = 'Asia/Ho_Chi_Minh';
            auser.LocaleSidKey = 'en_US';
            auser.LanguageLocaleKey = 'en_US';       
            auser.IsActive = true;     
            auser.Trac_Name__c = tracName;
            auser.ProfileId = profileId;  
            auser.Sale_Team__c = 'Other';

            return auser;            
        } catch (Exception ex) {
            System.debug('info=>' + info);
            System.debug('Error Generate chatter User=> ' + ex.getMessage());
        }
        return null;
    }
}