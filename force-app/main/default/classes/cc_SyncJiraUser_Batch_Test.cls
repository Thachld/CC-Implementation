@istest
public with sharing class cc_SyncJiraUser_Batch_Test {
    @TestSetup
    static void makeData(){
        cc_Jira_Integration__c jirasetting = cc_initData.initJiraIntegrationSetting('coccocjira','5be28ed5042c0320792e9cf0');
        insert jirasetting;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Support' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false, 'Direct');
        u1.Email = 'thuy.nguyen@coccoc.com';
        u1.JiraAccountId__c = '5cd00a144401890dcab36188';
        u1.IsActive = false;
        insert u1;

    }
    
    public testMethod static void testBatch(){
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new cc_SyncJiraUserHttpCalloutMock());

        List<User> scope = [SELECT Id, UserName, Email, JiraAccountId__c, Trac_Name__c, LastName,IsActive FROM User WHERE Email = 'thuy.nguyen@coccoc.com.chatter.invalid'];
        System.debug('scope' + scope);
        new cc_SyncJiraUser_Batch().execute(null, scope);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }

    public testMethod static void testSchedule(){
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            String jobId = System.schedule('cc_SyncJiraUser_Schedule_TEST', CRON_EXP, new cc_SyncJiraUser_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }


    public testMethod static void testWrapper(){
        JiraUserWrapper wrp = new JiraUserWrapper();
        wrp.accountId = '111';
        wrp.accountType = 'atlassian';
        wrp.active = true;
        wrp.displayName = 'TestUser';
        wrp.emailAddress = 'TestUser@gmail.com';
        wrp.locale = 'us';
    }
}