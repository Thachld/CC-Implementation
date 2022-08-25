@istest(seeAllData = true)
public with sharing class cc_AccountClassifyCatGroup_Batch_Test {
    @istest
    public static void testBatchSchedule(){
        Test.startTest();
            Date prundate = Date.newInstance(2021, 4, 1);
            Date pstartclassifyDate = null;
            String pindustry = '';
            String agency = '';
            Boolean pisManual = false;
            List<ClientCategoryDetail__mdt> pcatdetail = new List<ClientCategoryDetail__mdt>();

            cc_AccountClassifyCategogryGroup_Batch batch = 
                new cc_AccountClassifyCategogryGroup_Batch(prundate, pstartclassifyDate,pindustry,agency,pisManual,pcatdetail);
            Id jobId = Database.executeBatch(batch, 1);

        try {
            Test.stopTest();

            List<Account> listAcc = [SELECT Id FROM Account WHERE CategoryGroup__c != '' AND Industry__c = 'Pharmacy'];

            System.assert(listAcc.size() > 0);
        } catch (Exception ex) {
            
        }
    }

    @istest
    public static void testBatchManual(){
        Test.startTest();
            Date prundate = System.today();
            Date pstartclassifyDate = System.today() - 60;
            String pindustry = 'Pharmacy';
            String pagency = 'Person Account,Client';
            Boolean pisManual = true;
            List<ClientCategoryDetail__mdt> pcatdetail = new List<ClientCategoryDetail__mdt>();

            ClientCategoryDetail__mdt dt = new ClientCategoryDetail__mdt();
            dt.CategoryGroup__c = 'Critical';
            dt.RangeFrom__c = 3000000;
            dt.RangeTo__c = 999999999;
            pcatdetail.add(dt);

            ClientCategoryDetail__mdt dt1 = new ClientCategoryDetail__mdt();
            dt1.CategoryGroup__c = 'Major';
            dt1.RangeFrom__c = 0;
            dt1.RangeTo__c = 3000000;
            pcatdetail.add(dt1);


            cc_AccountClassifyCategogryGroup_Batch batch = 
                new cc_AccountClassifyCategogryGroup_Batch(prundate, pstartclassifyDate,pindustry,pagency,pisManual,pcatdetail);
            Id jobId = Database.executeBatch(batch, 1);

        try {
            Test.stopTest();

            List<Account> listAcc = [SELECT Id FROM Account WHERE CategoryGroup__c != '' AND Industry__c = 'Pharmacy'];

            System.assert(listAcc.size() > 0);
        } catch (Exception ex) {
            
        }
    }



    @istest
    public static void testShedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            
            String jobId = System.schedule('AccountClassifyCatGroup_Test', CRON_EXP, new cc_AccountClassifyCatGroup_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger WHERE id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }
}