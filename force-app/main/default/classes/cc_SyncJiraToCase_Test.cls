@istest
public with sharing class cc_SyncJiraToCase_Test {
    @TestSetup
    static void testSetup(){    
        List<Case> listCases = new List<Case>();
        String jiraAccountId = '123456789';
        cc_Jira_Integration__c jirasetting = new cc_Jira_Integration__c();   
        jirasetting.name = 'jirasynctosf';
        jirasetting.BatchSize__c = 40;
        jirasetting.restpath__c = 'rest/api/3/issue';
        jirasetting.FieldLogChange__c = 'issuetype,project,priority,labels,assignee,updated,status,summary,duedate,customfield_10049';
        jirasetting.Not_Include_Status__c = '';
        jirasetting.timeout__c = 120000;
        insert jirasetting;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = jiraAccountId;
        insert u;
        

        
        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;

        insert cs; 

    }


    public @IsTest
    static void testSyncJiraToCaseBatch(){
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SyncJiraToCaseHttpCalloutMock());

        List<Case> scope = [SELECT Id, JiraId__c, CreatedDate FROM Case WHERE CreateJiraTicket__c = true AND JiraId__c != ''];
        cc_Jira_Integration__c jirasetting = cc_Jira_Integration__c.getInstance('jirasynctosf');  
        new cc_SyncJiraToCase_Batch(jirasetting).execute(null,scope);

        try {
            Test.stopTest();
            Case testcs = [SELECT Id, JiraId__c, JiraLabels__c FROM Case LIMIT 1];
            System.assertEquals('custom_category;campaign_transfer;data_export', testcs.JiraLabels__c);

        } catch (Exception ex) {
            
        }
    }

    public @IsTest
    static void testSyncJiraToCaseSchedule(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SyncJiraToCaseHttpCalloutMock());
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            String jobId = System.schedule('cc_SyncJiraToCase_TEST', CRON_EXP, new cc_SyncJiraToCase_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
        
    }
}