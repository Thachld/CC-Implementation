@istest
public class cc_UpdateCaseFromJira_Batch_Test {
    
    @TestSetup
    static void testSetup(){    
        List<Case> listCases = new List<Case>();
        String jiraAccountId = '123456789';
        cc_Jira_Integration__c jirasetting = cc_initData.initJiraIntegrationSetting('coccocjira', jiraAccountId);
        jirasetting.BatchSize__c = 40;
        jirasetting.CasePullPeriod__c = 10;
        insert jirasetting;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = jiraAccountId;
        insert u;
        

        for(Integer i =1 ;i <= 8; i ++){
            String jiraId = '1000'+ String.valueOf(i);
            String jiraKey = 'FS-0' + String.valueOf(i);

            Case cs = cc_initData.initJiraCase('Subject Test Update' + String.valueOf(i), 'Description Test Update' + String.valueOf(i), u.Id);
            cs.JiraId__c = jiraId;
            cs.JiraKey__c = jiraKey;

            listCases.add(cs);
        }
       
        insert listCases;

    }


    public testMethod static void testSyncCasefromJira(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_UpdateCaseHttpCalloutMock());

        List<Case> scope = [SELECT Id, JiraId__c, CreatedDate FROM Case WHERE CreateJiraTicket__c = true AND JiraId__c != '' AND Status != 'Closed'];

        Datetime dtnow = System.now();
        Integer year = dtnow.year();
        Datetime plastSyncDatetime = dtnow - (year - 2021 == 0? 1: year - 2021) * 765;


        new cc_UpdateCaseFromJira_Batch(plastSyncDatetime).execute(null,scope);

        try {
            Test.stopTest();

        } catch (Exception ex) {
            
        }
        

    }

    public testmethod static void testSchedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            Test.setMock(HttpCalloutMock.class, new cc_UpdateCaseHttpCalloutMock());    
            String jobId = System.schedule('cc_UpdateCaseFromJira_Batch_Test', CRON_EXP, new cc_UpdateCaseFromJira_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);        

        Test.stopTest();
    }
}