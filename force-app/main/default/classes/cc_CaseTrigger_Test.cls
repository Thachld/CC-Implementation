@istest
public with sharing class cc_CaseTrigger_Test {   

    @istest
    public static void testCreateCase(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_CreateJiraHttpCalloutMock());
        cc_Trigger_Control__c trg = cc_initData.initTrigger('CASE_TRIGGER',true);
        insert trg;

        String jiraAccountId = '123456789';
        cc_Jira_Integration__c jirasetting = cc_initData.initJiraIntegrationSetting('coccocjira', jiraAccountId);
        insert jirasetting;

        Jira_Setting__c jirast = cc_initData.initJiraSetting();
        insert jirast;


        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Chatter Free User'];
        User u = cc_initData.initUser(pf.Id, 'Chatter Free' ,'User' + String.valueOf(1), null);
        u.UserPermissionsSupportUser =false;
        u.JiraaccountId__c = jiraAccountId;
        insert u;
        
        Case cs = cc_initData.initJiraCase('Subject Test Update', 'Description Test Update', u.Id);
        cs.JiraId__c = '10000';
        insert cs;

        List<cc_CaseTriggerHelper.CaseChangeEvtWrapper> msgs = new List<cc_CaseTriggerHelper.CaseChangeEvtWrapper>();
        cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();
            
        msg.Description = cs.Description;
        msg.DueDate = cs.DueDate__c;                    
        msg.IssueType = cs.IssueType__c;                                   
        msg.JiraProject = 'FS';  
        msg.Status = cs.JiraStatus__c;
        msg.Severity = cs.Severity__c;
        msg.Subject = cs.Subject;
        msg.CaseId = cs.Id;
        msg.jiracc = new Set<String>{cs.JiraCC__c} ;    
        
        msgs.add(msg);

        String params = JSON.serialize(msgs);
        cc_CaseTriggerHelper.attemptCreateJiraIssue(params);

        try {
            Test.stopTest();

            Case newCs = [SELECT Id,JiraKey__c,JiraId__c FROM Case WHERE Id = : cs.Id];
                  

            System.assertEquals('10000', newCs.JiraId__c);
            System.assertEquals('FS-24', newCs.JiraKey__c);
        } catch (Exception ex) {
            
        }


    }    

    @istest
    public static void testUpdateCaseCreateTicket(){

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_CreateJiraHttpCalloutMock());
        cc_Trigger_Control__c trg = cc_initData.initTrigger('CASE_TRIGGER',true);
        insert trg;

        String jiraAccountId = '123456789';
        cc_Jira_Integration__c jirasetting = cc_initData.initJiraIntegrationSetting('coccocjira', jiraAccountId);
        insert jirasetting;

        Jira_Setting__c jirast = cc_initData.initJiraSetting();
        insert jirast;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Chatter Free User'];
        User u = cc_initData.initUser(pf.Id, 'Chatter Free' ,'User' + String.valueOf(1), null);
        u.UserPermissionsSupportUser =false;
        u.JiraaccountId__c = jiraAccountId;
        insert u;
        
        Case cs = cc_initData.initJiraCase('Subject Test Update', 'Description Test Update', u.Id);
        cs.JiraId__c = '10000';
        cs.CreateJiraTicket__c = false;
        insert cs;

        Case testcs = [SELECT Id, Subject, Description, Severity__c, Duedate__c,JiraId__c,CreateJiraTicket__c  FROM Case WHERE Id = :cs.Id  LIMIT 1];
        testcs.CreateJiraTicket__c = true;
        testcs.JiraId__c = '';
        update testcs;

        List<cc_CaseTriggerHelper.CaseChangeEvtWrapper> msgs = new List<cc_CaseTriggerHelper.CaseChangeEvtWrapper>();
        cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();
            
        msg.Description = cs.Description;
        msg.DueDate = cs.DueDate__c;                    
        msg.IssueType = cs.IssueType__c;                                   
        msg.JiraProject = 'FS';  
        msg.Status = cs.JiraStatus__c;
        msg.Severity = cs.Severity__c;
        msg.Subject = cs.Subject;
        msg.CaseId = cs.Id;
        msg.jiracc = new Set<String>{cs.JiraCC__c};    
        
        msgs.add(msg);

        String params = JSON.serialize(msgs);
        cc_CaseTriggerHelper.attemptCreateJiraIssue(params);

        try {
            Test.stopTest();

            Case newCs = [SELECT Id,JiraKey__c,JiraId__c FROM Case WHERE Id = : cs.Id];
                  

            System.assertEquals('10000', newCs.JiraId__c);
            System.assertEquals('FS-24', newCs.JiraKey__c);
        } catch (Exception ex) {
            
        }


    }

    @istest
    public static void testUpdateCase(){
        

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_UpdateJiraHttpCalloutMock());     
        
            cc_Trigger_Control__c trg = cc_initData.initTrigger('CASE_TRIGGER',true);
            insert trg;

            String jiraAccountId = '123456789';
            cc_Jira_Integration__c jirasetting = cc_initData.initJiraIntegrationSetting('coccocjira', jiraAccountId);
            insert jirasetting;

            Jira_Setting__c jirast = cc_initData.initJiraSetting();
            insert jirast;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Chatter Free User'];
            User u = cc_initData.initUser(pf.Id, 'Chatter Free' ,'User' + String.valueOf(1), null);
            u.UserPermissionsSupportUser =false;
            u.JiraaccountId__c = jiraAccountId;
            insert u;
            
            Case cs = cc_initData.initJiraCase('Subject Test Update', 'Description Test Update', u.Id);            
            cs.CreateJiraTicket__c = false;
            insert cs;    

            Case testcsdraft = [SELECT Id, Subject, Description, Severity__c, Duedate__c, CreateJiraTicket__c FROM Case WHERE Id = :cs.Id  LIMIT 1];
            testcsdraft.CreateJiraTicket__c = true;
            testcsdraft.JiraId__c = '10000';
            update testcsdraft;

            Case testcs = [SELECT Id, Subject, Description, Severity__c, Duedate__c,CreateJiraTicket__c FROM Case WHERE Id = :testcsdraft.Id  LIMIT 1];
            testcs.Subject = 'Subject Test Update V1';
            testcs.Description = 'Description Test Update V1';
            testcs.Severity__c = 'Blocker';
            testcs.JiraId__c = '10000';
            testcs.CreateJiraTicket__c = true;
            testcs.Duedate__c = System.today() + 5;     
            
            update testcs;
            
            List<cc_CaseTriggerHelper.CaseChangeEvtWrapper> msgs = new List<cc_CaseTriggerHelper.CaseChangeEvtWrapper>();
            cc_CaseTriggerHelper.CaseChangeEvtWrapper msg = new cc_CaseTriggerHelper.CaseChangeEvtWrapper();

            msg.Description = testcs.Description;
            msg.DueDate = testcs.DueDate__c;     
            msg.Severity = testcs.Severity__c;
            msg.Subject = testcs.Subject;         
            msg.JiraId = testcs.JiraId__c;
            
            msgs.add(msg);

            String params = JSON.serialize(msgs);
            cc_CaseTriggerHelper.attemptUpdateJiraIssue(params);
            
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }
    
}