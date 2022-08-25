/********************************************************************************************************
* @author        CocCoc - THACHLD
* @date          2022 May 05
* @description   Rest service for update Case from Jira webhook
* @param   jiraId - Jira Ticket Id.
*********************************************************************************************************/
@RestResource(urlMapping='/jiratocase/*')
global class UpdateCaseFromJiraRest {
    @HttpPut
    global static String doUpdateCase(){
        PaymentToQCWrapper.Responds rp = new PaymentToQCWrapper.Responds();
        RestRequest restReq = RestContext.request;   
        cc_static_Message.isUpdateCaseViaAPI = true;    
        
        try {
            String jiraId = restReq.params.get('jiraId');       
            System.debug('jiraId=>' + jiraId);
            Case upCase = new Case();
            upCase = [SELECT Id, IssueType__c, DueDate__c, Assignee__c, JiraLabels__c, Priority,
                            JiraProject__c,JiraStatus__c,Subject,Severity__c
                        FROM Case WHERE JiraId__c = :jiraId ];
            if(upCase != null){
                String rqbody = restReq.requestBody.tostring();
                System.debug('rqbody=>' + rqbody);
                JiraFieldChangeWrapper jiraWrap = JiraFieldChangeWrapper.parse(rqbody);
                System.debug('jiraWrap=>' + jiraWrap);

                Boolean hasChanged = false;
                if(jiraWrap != null){

                    if(jiraWrap.fieldId == 'summary'){
                        upCase.Subject = jiraWrap.toString;
                        hasChanged = true;
                    }else if(jiraWrap.fieldId == 'status'){
                        upCase.JiraStatus__c = jiraWrap.toString;
                        hasChanged = true;
                    }else if(jiraWrap.fieldId == 'assignee'){     
                        Map<String,User> mapUser = new Map<String,User>();
                        for (User us: [SELECT Id, JiraaccountId__c FROM User WHERE JiraaccountId__c != null AND JiraaccountId__c!='']){
                            if(!mapUser.containsKey(us.JiraaccountId__c)){
                                mapUser.put(us.JiraaccountId__c, us);
                            }
                        }

                        System.debug('jiraWrap.toValue=>' + jiraWrap.toValue);
                        if(!String.isBlank(jiraWrap.toValue)){
                            System.debug('Id=>' + (mapUser.get(jiraWrap.toValue).Id));
                            if(!String.isBlank(mapUser.get(jiraWrap.toValue).Id)){ 
                                
                                upCase.Assignee__c = mapUser.get(jiraWrap.toValue).Id;
                                hasChanged = true;
                            }
                        }else{
                            upCase.Assignee__c = null;
                            hasChanged = true;
                        }
                    }else if(jiraWrap.fieldId == 'priority'){
                        upCase.Priority = jiraWrap.toString;
                        hasChanged = true;
                    }else if(jiraWrap.fieldId == 'customfield_10049'){
                        upCase.Severity__c = jiraWrap.toString;
                        hasChanged = true;
                    }else if(jiraWrap.fieldId == 'labels'){                                    
                        if(!String.isBlank(jiraWrap.toString)){
                            
                            String labelstr = jiraWrap.toString.replace(' ', ';');
                            System.debug('labelstr=>'+ labelstr);
                            upCase.JiraLabels__c = labelstr;
                            hasChanged = true;
                        }else {
                            upCase.JiraLabels__c = '';
                        }
                    }else if(jiraWrap.fieldId == 'issuetype'){
                        upCase.IssueType__c = jiraWrap.toString;
                        hasChanged = true;
                    }else if(jiraWrap.fieldId == 'duedate'){
                        upCase.duedate__c = Date.valueOf(jiraWrap.toValue) ;
                        hasChanged = true;
                    }

                    if(hasChanged){
                        update upCase;
                    }                    

                    rp.status = 'success';
                    rp.message = '';                            
                }else {
                    rp.status = 'fail';
                    rp.message = 'Missing payload';                             
                }
            }else {
                rp.status = 'fail';
                rp.message = 'Case not found';                             
            }
        } catch (Exception ex) {
            rp.status = 'fail';
            rp.message = ex.getMessage();        
        }

        if (rp.status == 'fail'){
            cc_Util.writeLog('jiratocase',rp.message, RestContext.request.requestBody.tostring());
        }
        

        System.debug('rp=>' + rp);
        String str = system.JSON.serialize(rp);
        return str;
    }

}