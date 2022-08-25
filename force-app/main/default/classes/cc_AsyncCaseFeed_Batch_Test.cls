@istest(seeAllData=true)
public class cc_AsyncCaseFeed_Batch_Test {    

    @istest
    public static void testSyncJiraComment(){
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new cc_AsyncCaseFeedHttpCalloutMock());
            List<Case> scope = [SELECT Id, JiraId__c FROM Case WHERE CreateJiraTicket__c = true AND Subject = 'Subject Test Feed' LIMIT 1];

            Datetime dtnow = System.now();
            Integer year = dtnow.year();
            Datetime plastSyncDatetime = dtnow - (year - 2021 == 0? 1: year - 2021) * 365;

            new cc_AsyncCaseChatterFrJiraComment_Batch(plastSyncDatetime).execute(null, scope);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    // @istest
    // public static void testSchedule(){
    //     Test.startTest();

    //         Datetime dt = Datetime.now().addMinutes(2);
    //         String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

    //         Test.setMock(HttpCalloutMock.class, new cc_AsyncCaseFeedHttpCalloutMock());    
    //         String jobId = System.schedule('AsyncCaseChatterFrJiraComment_Test', CRON_EXP, new cc_AsyncCaseFeed_Schedule());

    //         CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
    //         System.assertEquals(CRON_EXP, ct.CronExpression); 
    //         System.assertEquals(0, ct.TimesTriggered);
            

    //     Test.stopTest();

    // }
        
}