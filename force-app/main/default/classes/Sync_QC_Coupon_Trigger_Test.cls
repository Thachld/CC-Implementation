@istest
public with sharing class Sync_QC_Coupon_Trigger_Test {
    @istest
    public static void TestsyncCoupon(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_GetCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;

            cc_Trigger_Control__c synctrg = cc_initData.initTrigger('SYNC_COUPON_TRIGGER',true);
            insert synctrg;

            QC_Integration__c qcinte = cc_initData.initQcIntegrationSetting('qccampaignInternal');
            insert qcinte;

            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

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
            
            List<cc_CouponAPIWrapper.ParamWrapper> params = new  List<cc_CouponAPIWrapper.ParamWrapper>();                    
            cc_CouponAPIWrapper.ParamWrapper param = new  cc_CouponAPIWrapper.ParamWrapper();
            param.coupon_id = '11';
            param.coupon_campaign_id = '123';
            param.qc_account = qcacc.Id;
            params.add(param);            
            
            String paramstr = JSON.serialize(params);
            Sync_QC_Coupon_Helper.attemptSyncCouponsFromQC(paramstr);
        try {
            Test.stopTest();
        } catch (Exception ex) {
            System.debug( 'Sync Coupon Test ' + ex.getMessage());
        }                            
        
        
    }

    @istest
    public static void TestPlatformTrigger(){
        Test.startTest();
            cc_Trigger_Control__c trg = cc_initData.initTrigger('SYNC_COUPON_TRIGGER',true);
            insert trg;

            Test.setMock(HttpCalloutMock.class, new cc_GetCouponHttpCalloutMock());                     
            QC_Integration__c qcinte = cc_initData.initQcIntegrationSetting('qccampaignInternal');
            insert qcinte;
            
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

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

        Sync_QC_Coupon__e evt = new Sync_QC_Coupon__e();
        evt.CouponId__c = '11';   
        evt.Coupon_Campaign_Id__c = '123';  
        evt.QC_Account__c = qcacc.Id;                   
        Eventbus.publish(evt);

        try {
            Test.stopTest();            
        } catch (Exception ex) {
            System.debug( 'Platform Event Test ' + ex.getMessage());
        }
    }
}