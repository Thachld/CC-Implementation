public with sharing class cc_CaseTriggerHander implements cc_ITrigger{
    List<cc_CaseTriggerHelper.CaseChangeEvtWrapper> msgMessages = new List<cc_CaseTriggerHelper.CaseChangeEvtWrapper>();
    List<cc_CaseTriggerHelper.CaseChangeEvtWrapper> createIssues = new List<cc_CaseTriggerHelper.CaseChangeEvtWrapper>();
    List<cc_CaseTriggerHelper.CaseChangeEvtWrapper> updateIssues = new List<cc_CaseTriggerHelper.CaseChangeEvtWrapper>();
    Map<String,cc_CaseTriggerHelper.CaseChangeWrp> mapCaseChange = new Map<String,cc_CaseTriggerHelper.CaseChangeWrp>();
    cc_CaseTriggerHelper caseHelper = cc_CaseTriggerHelper.getCaseHelperInstance();    
    cc_Jira_Integration__c jira = caseHelper.jira;  
    Jira_Setting__c jiraSeting = caseHelper.jiraSetting;      
    
           
    /* bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  

        //isInsert
        if (Trigger.isUpdate){
            Map<Id,Case> oldMap = (Map<Id,Case>)Trigger.oldMap;
            for(Case newcs: (List<Case>)Trigger.new){
                Case oldcs = oldMap.get(newcs.Id);
                //Not allow user change Create Jira ticket Option
                if(newcs.CreateJiraTicket__c == false && oldcs.CreateJiraTicket__c == true && !String.isBlank(newcs.JiraId__c)){
                    String msg = 'Jira ticket {0} has been created, You unable to change this option?';
                    newcs.addError(String.format(msg, new List<String>{newcs.JiraKey__c}));
                }else if(newcs.CreateJiraTicket__c == true && oldcs.CreateJiraTicket__c == false && String.isBlank(newcs.JiraId__c)){
                    newcs.AssignedDate__c = Datetime.now();
                    newcs.Assignee__c = jiraSeting.Default_FrontLine_User__c;
                    newcs.JiraProject__c = jiraSeting.Default_Jira_Project__c;
                    newcs.JiraStatus__c = jiraSeting.Default_Jira_Status__c;
                    newcs.Status = CaseConstant.STATUS_ASSIGNED_TO_DEV;
                }

                if(newcs.CreateJiraTicket__c == true 
                    && oldcs.CreateJiraTicket__c == false 
                    && String.isBlank(newcs.JiraId__c) 
                    && String.isBlank(newcs.JiraCC__c)){
                    newcs.JiraCC__c = jiraSeting.Default_Jira_CC__c;                
                }

                if(newcs.Assignee__c != oldcs.Assignee__c && !String.isBlank(newcs.Assignee__c)){
                    String newStatus;
                    for(Case_Status_Mapping__mdt csm : [SELECT Operator__c,Status__c,Value__c FROM Case_Status_Mapping__mdt WHERE Field_Change__c = 'Assignee__c']){
                        if(!String.isBlank(csm.Value__c)){
                            if(csm.Operator__c == CaseConstant.OPERATOR_CONTAINS){
                                String [] valueArr = csm.Value__c.split(';');
                                if(valueArr.contains(newcs.Assignee__c)){
                                    newStatus = csm.Status__c;
                                }
                            }else if(csm.Operator__c == CaseConstant.OPERATOR_NOT_CONTAINS){
                                String [] valueArr = csm.Value__c.split(';');
                                if(!valueArr.contains(newcs.Assignee__c)){
                                    newStatus = csm.Status__c;
                                }
                            }else if(csm.Operator__c == CaseConstant.OPERATOR_EQUAL){
                                if(csm.Value__c == newcs.Assignee__c){
                                    newStatus = csm.Status__c;
                                }
                            }else if(csm.Operator__c == CaseConstant.OPERATOR_NOT_EQUAL){
                                if(csm.Value__c != newcs.Assignee__c){
                                    newStatus = csm.Status__c;
                                }
                            }
                        }
                    }

                    System.debug('newStatus=>' + newStatus);
                    if(!String.isBlank(newStatus)){
                        newcs.Status = newStatus;
                    }
                }



                //Jira Close Date
                if(newcs.JiraStatus__c != oldcs.JiraStatus__c){
                    if(newcs.JiraStatus__c == 'Done' ){
                        newcs.JiraClosedDate__c =System.now();
                    }
                }


                //Case Status Changed (Put this code in the last)
                if(newcs.Status != oldcs.Status){
                    if(oldcs.Status == CaseConstant.STATUS_ASSIGNED_TO_DEV ){
                        newcs.Last_FrontLine_User_Assigned__c = oldcs.Assignee__c;
                    }else if(oldcs.Status == CaseConstant.STATUS_DEV_PROCESSING){
                        newcs.Last_Dev_User_Assigned__c = oldcs.Assignee__c;
                    }


                    //AOM Re-Assign to Front-Line team
                    if(newcs.Status == CaseConstant.STATUS_ASSIGNED_TO_DEV){
                        if( !String.isBlank(newcs.JiraId__c)){                        
                            String newAssignee = newcs.Last_FrontLine_User_Assigned__c == null? jiraSeting.Default_FrontLine_User__c : newcs.Last_FrontLine_User_Assigned__c;
                            newcs.Assignee__c = newAssignee;
                        }else{
                            newcs.Assignee__c = jiraSeting.Default_FrontLine_User__c;
                            newcs.CreateJiraTicket__c = true;
                        }
                    }
                }
            }


        }else if (Trigger.isInsert) {
            for(Case newcs: (List<Case>)Trigger.new){
                if(newcs.CreateJiraTicket__c == true){
                    newcs.AssignedDate__c = Datetime.now();
                    newcs.Assignee__c = jiraSeting.Default_FrontLine_User__c;
                    newcs.JiraProject__c = jiraSeting.Default_Jira_Project__c;
                    newcs.JiraStatus__c = jiraSeting.Default_Jira_Status__c;
                    newcs.Status = CaseConstant.STATUS_ASSIGNED_TO_DEV;
                }

                if(newcs.CreateJiraTicket__c == true && String.isBlank(newcs.JiraCC__c)){                   
                    newcs.JiraCC__c = jiraSeting.Default_Jira_CC__c;           
                }
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
        if( cc_static_Message.isUpdateCaseViaAPI == null){
            cc_static_Message.isUpdateCaseViaAPI = false;
        }
        
        if(Trigger.isInsert){            

            System.debug('jira=>' + this.jira);
            Set<String> ownerIds = new Set<String>();
            Map<Id,String> ownerMap = new Map<Id,String>();

            for(Case newcs : (List<Case>)Trigger.new){
                if(newcs.CreateJiraTicket__c == true){
                    ownerIds.add(newcs.OwnerId);
                }
            }    

            //get Owner from User
            for(User u: [SELECT Id, Name FROM User WHERE Id IN :ownerIds]){
                ownerMap.put(u.Id, u.name);
            }

            //get Owner from Queue
            for(Group g: [SELECT Id, Name FROM Group WHERE Id IN :ownerIds AND Type = 'Queue']){
                ownerMap.put(g.Id, g.name);
            }

            //Create Jira ticket
            for(Case newcs : (List<Case>)Trigger.new){
                if(newcs.CreateJiraTicket__c == true){                   
                    cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();

                    msg = initCreateMessage(newcs, ownerMap);                   
                    createIssues.add(msg);
                }
            }
        }else if (Trigger.isUpdate){
            Set<String> ownerIds = new Set<String>();
            Map<Id,String> ownerMap = new Map<Id,String>();
            Map<Id,Case> oldMap = (Map<Id,Case>)Trigger.oldMap;

            
            System.debug('jira=>' + this.jira);

            for(Case newcs : (List<Case>)Trigger.new){
                Case oldcs = oldMap.get(newcs.Id);
                if( ( newcs.CreateJiraTicket__c == true && oldcs.CreateJiraTicket__c == true 
                        && !String.isBlank(newcs.JiraId__c) && newcs.OwnerId != oldcs.OwnerId)
                    || ( newcs.CreateJiraTicket__c == true && oldcs.CreateJiraTicket__c == false && String.isBlank(newcs.JiraId__c)) ){
                    ownerIds.add(newcs.OwnerId);
                }
            }    

            //get Owner from User
            for(User u: [SELECT Id, Name FROM User WHERE Id IN :ownerIds]){
                ownerMap.put(u.Id, u.name);
            }

            //get Owner from Queue
            for(Group g: [SELECT Id, Name FROM Group WHERE Id IN :ownerIds AND Type = 'Queue']){
                ownerMap.put(g.Id, g.name);
            }

            
            for(Case newcs: (List<Case>)Trigger.new){
                Case oldcs = oldMap.get(newcs.Id);

                //Update Jira Issue
                if(newcs.CreateJiraTicket__c == true && oldcs.CreateJiraTicket__c == true && !String.isBlank(newcs.JiraId__c)){
                    
                    if(!cc_static_Message.isUpdateCaseViaAPI){
                        cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();
                        msg = initUpdateMessage(newcs, oldcs, ownerMap);                    
                        if(msg.caseId != null){
                            updateIssues.add(msg);
                        }
                    }
                
                //Create Jira Issue
                }else if( (( newcs.CreateJiraTicket__c == true && oldcs.CreateJiraTicket__c == false)
                                || (newcs.Status != oldcs.Status && newcs.Status == CaseConstant.STATUS_ASSIGNED_TO_DEV ))                
                            && String.isBlank(newcs.JiraId__c)){                   
                    cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();                    
                    msg = initCreateMessage(newcs, ownerMap);  
                    if(msg.caseId != null){
                        createIssues.add(msg);
                    }
                    
                }


                //Push change platform event;
                String changeLogs = '';
                cc_CaseTriggerHelper.CaseChangeWrp msgChange = new cc_CaseTriggerHelper.CaseChangeWrp();
                msgChange = initChangeLogs(newCs, oldcs);                
                if(msgChange.caseId != null){
                    mapCaseChange.put(newcs.Id, msgChange);
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
        
        //Publish Platform event


        // if(msgMessages.size() > 0 ){            

        //     cc_CaseTriggerHelper.publishCaseChangeEvt(msgMessages);
        // }

        System.debug('createIssues=>' + createIssues.size());
        if(createIssues.size() > 0){
            String params = JSON.serialize(createIssues);
            cc_CaseTriggerHelper.attemptCreateJiraIssue(params);
        }

        System.debug('updateIssues=>' + updateIssues.size());
        if(updateIssues.size() > 0){
            String params = JSON.serialize(updateIssues);
            cc_CaseTriggerHelper.attemptUpdateJiraIssue(params);
        }

        System.debug('mapCaseChange=>' + mapCaseChange.size());
        if(mapCaseChange.size() > 0){
            cc_CaseTriggerHelper.attemptPublishCaseChangeEvt(mapCaseChange.values());
        }
    }  

    private cc_CaseTriggerHelper.CaseChangeEvtWrapper initCreateMessage(Case newCs, Map<Id,String> ownerMap){
        cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();
        Set<String> ccUser = new Set<String>();

        msg.Assignee = this.jira.defaultUser__c;
        msg.ChangeType = 'CREATE';
        msg.Description = newcs.Description;
        msg.DueDate = newcs.DueDate__c;                    
        msg.IssueType = newcs.IssueType__c;                                   
        msg.JiraProject = this.jira.Defaut_Project__c;  
        msg.Status = newcs.JiraStatus__c;
        msg.Severity = newcs.Severity__c;
        msg.Subject = newcs.Subject;
        msg.CaseId = newcs.Id;        
        if(!String.isBlank(newcs.JiraCC__c)){
            ccUser.add(newcs.JiraCC__c);
        }       

        if(!String.isBlank(newcs.ManagerId__c)){
            ccUser.add(newcs.ManagerId__c);
        }
        
        msg.jiracc = ccUser;
        msg.CaseOwner = ownerMap.get(newcs.OwnerId) == null? '' : ownerMap.get(newcs.OwnerId);   
        
        return msg;
    }


    private cc_CaseTriggerHelper.CaseChangeWrp initChangeLogs(Case newCs, Case oldcs){
        String changeLogs = '';
        cc_CaseTriggerHelper.CaseChangeWrp msgChange = new cc_CaseTriggerHelper.CaseChangeWrp();
        if(newcs.Status != oldcs.Status){
            changeLogs = changeLogs + ' Case status: ' + oldcs.Status + ' => ' + newcs.Status + '\n';
        }

        if(newcs.Assignee__c != oldcs.Assignee__c){
            changeLogs = changeLogs + ' Jira Assignee: ' + (oldcs.AssigneeName__c ==null?'': oldcs.AssigneeName__c ) +' => ' 
                                                        + (newcs.AssigneeName__c ==null?'': newcs.AssigneeName__c ) + '\n'; 

        }

        if(newcs.JiraStatus__c != oldcs.JiraStatus__c){
            changeLogs = changeLogs + ' Jira status: '   + (oldcs.JiraStatus__c == null?'': oldcs.JiraStatus__c)  + ' => ' 
                                                        + (newcs.JiraStatus__c == null?'': newcs.JiraStatus__c) + '\n';            
        }

        if(newcs.DueDate__c != oldcs.DueDate__c){
            Datetime olddt = oldcs.DueDate__c;
            Datetime newsdt = newcs.DueDate__c;
            changeLogs = changeLogs + ' Jira duedate: '  + (oldcs.DueDate__c == null? '': olddt.format('dd/MM/yyyy')) + ' => ' 
                                                        + (newcs.DueDate__c == null? '': newsdt.format('dd/MM/yyyy')) + '\n';
                                
        }

        if(!String.isBlank(changeLogs)){
            msgChange.CaseId = newcs.Id;
            msgChange.Subject = newcs.Subject;
            msgChange.CaseNumber = newcs.CaseNumber;
            msgChange.Type = 'CASE';
            msgChange.UserChange = UserInfo.getName(); 
            msgChange.ChangeLogs = changeLogs;            
        }    
        
        return msgChange;
    }


    private cc_CaseTriggerHelper.CaseChangeEvtWrapper initUpdateMessage(Case newcs, Case oldcs, Map<Id,String> ownerMap){
        cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();

        String fields = '';
        Boolean isUpdated = false;
        
        if(newcs.Description != oldcs.Description){
            fields = fields + ',' + 'description';
            msg.Description = newcs.Description;
            isUpdated = true;
        }

        if(newcs.Subject != oldcs.Subject){
            fields = fields + ',' + 'summary';
            msg.Subject = newcs.Subject;
            isUpdated = true;
        }
        
        if(newcs.OwnerId != oldcs.OwnerId){
            fields = fields + ',' + 'AOM';
            msg.CaseOwner = ownerMap.get(newcs.OwnerId) == null? '' : ownerMap.get(newcs.OwnerId);
            isUpdated = true;
        }

        if(newcs.Assignee__c != oldcs.Assignee__c && !String.isBlank(newcs.Jira_Assignee_Id__c)){
            fields = fields + ',' + 'assignee';
            msg.assignee = newcs.Jira_Assignee_Id__c;
            isUpdated = true;
        }

        if(isUpdated){
            msg.JiraId = newcs.JiraId__c;
            msg.CaseId = newcs.Id;
            msg.ChangeType = 'UPDATE';
            msg.Fields = fields;            
        }     
        
        return msg;
    }
}