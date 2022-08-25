public with sharing class cc_SyncJiraToCase_Batch implements Database.Batchable<SObject>,Database.AllowsCallouts{   
    public cc_Jira_Integration__c jirasetting{get;set;}

    public cc_SyncJiraToCase_Batch(cc_Jira_Integration__c pjirasetting ) {
        this.jirasetting = pjirasetting ==null? cc_Jira_Integration__c.getInstance('jirasynctosf') : pjirasetting;       
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, JiraId__c, CreatedDate 
                                            FROM Case 
                                            WHERE CreateJiraTicket__c = true 
                                                AND JiraId__c != '' 
                                                AND Status != :this.jirasetting.Not_Include_Status__c]);
    }

    public void execute(Database.BatchableContext bc, List<Case> scope){
        Map<String,User> mapUser = new Map<String,User>();
        List<Case> updateCases = new List<Case>();        
        Map<Id,JiraInfoWrapper> mapResult = new Map<Id,JiraInfoWrapper>();

        String fielsParam = '';
        if(this.jirasetting != null){
            fielsParam = !String.isBlank(this.jirasetting.FieldLogChange__c)? this.jirasetting.FieldLogChange__c : 'issuetype,project,priority,labels,assignee,updated,status,summary,duedate,customfield_10049';
            
            for(Case cs : scope){
                String params = '/' + cs.JiraId__c + '?fields=' + fielsParam;

                JiraInfoWrapper result = makeRequest(params, this.jirasetting);
                mapResult.put(cs.Id, result);
            }


            if(mapResult.size() > 0){
                for (User us: [SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']){
                    if(!mapUser.containsKey(us.JiraaccountId__c)){
                        mapUser.put(us.JiraaccountId__c, us);
                    }
                }

                for(Id caseId : mapResult.keySet()){
                    JiraInfoWrapper info = mapResult.get(caseId);
                    if(info != null && info.fields != null){  
                    
                        Case udCase = new Case();
                        udCase.Id = caseId;

                        if(info.fields.issuetype != null){
                            udCase.IssueType__c = info.fields.issuetype.name;
                        }
                        
                        if(!String.isBlank(info.fields.duedate)){
                            udCase.DueDate__c = Date.valueOf(info.fields.duedate);
                        }
                        
                        if(info.fields.assignee != null){
                            User u = mapUser.get(info.fields.assignee.accountId);
                            if(u != null){
                                udCase.Assignee__c = u.Id;
                            }
                        }

                        String[] labelArr = info.fields.labels;
                        if(labelArr.size() > 0){
                            String labelstr = String.join(labelArr, ';');
                            udCase.JiraLabels__c = labelstr;
                        }

                        if(info.fields.priority != null){
                            udCase.Priority = info.fields.priority.name;
                        }                    

                        if(info.fields.project != null){
                            udCase.JiraProject__c = info.fields.project.key;
                        }

                        if(info.fields.status != null){
                            udCase.JiraStatus__c = info.fields.status.name;
                        }

                        if( !String.isBlank(info.fields.summary)){
                            udCase.Subject = info.fields.summary;
                        }

                        if(info.fields.customfield_10049 != null){
                            udCase.Severity__c = info.fields.customfield_10049.value;
                        }

                        if(!String.isBlank(info.fields.updated)){                           
                            Datetime uddt = (DateTime)JSON.deserialize('"' + info.fields.updated + '"', DateTime.class);
                            udCase.LatestSyncDatetime__c = uddt;
                        }
                        
                        updateCases.add(udCase);
                        
                    }
                }
            }
        }

        if(updateCases.size() > 0){
            update updateCases;
        }

    }

    public void finish(Database.BatchableContext bc){}

    public static JiraInfoWrapper makeRequest(String paramStr, cc_Jira_Integration__c jirasetting){
        JiraInfoWrapper jiraInfo = new JiraInfoWrapper();

        try {            
            
            String restUrl = jirasetting.restpath__c;
            
            String endpoint;
            endpoint = 'callout:JiraBasicAuth/' +  restUrl + paramStr;
            
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            Http http = new Http();                     

            request.setEndpoint(endpoint);		
            request.setHeader('Content-Type','application/json');            
            request.setMethod('GET');

            Integer timeout = (jirasetting.timeout__c == null || jirasetting.timeout__c == 0)?120000 : Integer.valueOf(jirasetting.timeout__c);
            request.setTimeout(timeout);            
            
            response = http.send(request);
        
            System.debug('response.getStatusCode()=>' + response.getStatusCode());
            System.debug('response=>' + response.getBody());
            System.debug('endpoint=>' + request.getEndpoint());
            if (response.getStatusCode() == 200){
                String resBody = response.getBody();
                jiraInfo = JiraInfoWrapper.parse(resBody);
                System.debug('jiraInfo=>' + jiraInfo);
            }
        } catch (Exception ex) {
            
        }

        return jiraInfo;
    }
}