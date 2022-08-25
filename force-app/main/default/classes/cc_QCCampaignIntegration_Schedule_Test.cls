@istest(seeAllData = true)
public class cc_QCCampaignIntegration_Schedule_Test {      

    @istest
    public static void testSchedule(){


        
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();            
            Test.setMock(HttpCalloutMock.class, new cc_CampaignAPIHttpMockResponse());    
            String scjobId = System.Schedule('QCCampaignIntegrationTest', CRON_EXP, new cc_QCCampaignIntegration_Schedule());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :scjobId];
                
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

        try {
            Test.stopTest();
            
            
        } catch (Exception ex) {
            
        }
    }

    @istest
    public static void testBatch(){

        Date today = System.today();
        Date startDate = today.toStartOfMonth();        
        Date endDate = startDate.addMonths(1)-1;        

        // QC_Integration__c ccQCIntergration = cc_initData.initQcIntegrationSetting();
        // insert ccQCIntergration;

        String accname = 'Batch Account test';
        Account acc = cc_initData.initAccount(accname);  
        insert acc;

        String qcname = 'qcAccount123@qcCococ.com.testclass';
        QC_Account__c qcacc = cc_initData.initQCAccount(qcname, acc.Id);           
        insert qcacc;        
        
        Opportunity  opp = cc_initData.initOpportunity(acc.Id); 
        insert opp;

        Ads_Campaign__c ads = cc_initData.initAdsCampaign(acc.Id, opp.Id, qcacc.Id);
        ads.Start_Date__c = startDate;
        ads.End_Date__c = endDate;
        insert ads;


        QC_Campaign__c qccamp = new QC_Campaign__c();
        qccamp.Name = 'Test API';
        qccamp.CampaignId__c = '12345';
        qccamp.Ads_Campaign__c = ads.Id;

        insert qccamp;

        QC_Campaign__c scope = [SELECT Id, CampaignId__c, Clicks__c,Impressions__c,Spending__c,
                                            Ads_Campaign__c,Ads_Campaign__r.Start_Date__c, Ads_Campaign__r.End_Date__c
                                        FROM QC_Campaign__c 
                                        WHERE Id = :qccamp.Id
                                        LIMIT 1];
        System.assert(scope != null);                               
        Test.startTest();        
            Test.setMock(HttpCalloutMock.class, new cc_CampaignAPIHttpMockResponse());    
            Datetime rundate = System.now();    

            new cc_QCCampaignIntegration_Batch(rundate, null).execute(null,new QC_Campaign__c []{scope});      
            
            
           
        
        try {
            Test.stopTest();    
            QC_Campaign__c camptest = [SELECT Id, Clicks__c, Impressions__c, Spending__c FROM  QC_Campaign__c WHERE Id = :qccamp.Id LIMIT 1];   
            
            System.assertEquals(3660724.32, camptest.Spending__c);
            System.assertEquals(252611, camptest.Impressions__c);
            System.assertEquals(800, camptest.Clicks__c);
        } catch (Exception ex) {
            
        }
        
    }
    
}