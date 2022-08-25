@istest
public with sharing class GetCouponFromQC_Batch_Test {
    @istest
    public static void Testbatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_GetCouponHttpCalloutMock());     
            QC_Integration__c qcinte = cc_initData.initQcIntegrationSetting('qccampaignInternal');
            insert qcinte;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('getcoupon')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('GET')
                                                .setTimeout(10000)
                                                .buildAndSave();
        
            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus('In Progress')
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .buildAndSave(); 

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testclient@qc.coccoc.com')
                                .setQcId('1234')
                                .buildAndSave();

            
                                
            String standard_payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Standard_payment').getRecordTypeId(); 
            Date dt = Date.today();
            Payment__c py = cc_initData.initPayment(standard_payment, 'abcxyz' + String.valueOf(1), qcacc.Id, dt, null, qcacc.Industry__c, 'Local Agency');  
            py.CouponId__c = '11';
            py.CampaignId__c = '123';  
            insert py;

            
            List<Payment__c> scope = new List<Payment__c>();
            scope = [SELECT Id,CouponId__c, CampaignId__c , QC_Account__c  FROM Payment__c];

            new GetCouponFromQC_Batch().execute(null,scope);   
            
        try {
            Test.stopTest();
        } catch (Exception ex) {
            System.debug( 'Get Coupon Test ' + ex.getMessage());
        }    
    }


    @istest
    public static void testSchedule(){
        
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();            
            Test.setMock(HttpCalloutMock.class, new cc_GetCouponHttpCalloutMock());    
            String scjobId = System.Schedule('GetCouponFromQC_Schedule_TEST', CRON_EXP, new GetCouponFromQC_Schedule());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :scjobId];
                
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

        try {
            Test.stopTest();
            
            
        } catch (Exception ex) {
            
        }
    }
}