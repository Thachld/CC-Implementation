@istest
public with sharing class MassGenerateCouponToQC_Batch_Test {
    public static final String SF_SOURCE = 'Salesforce';
    @istest
    public static void testInsertCoupon(){
        
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );            

            QC_Integration__c qcinte =  cc_initData.initQcIntegrationSetting('qccampaignInternal');
            insert qcinte;
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> couponIds = new Set<String>();
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
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setName('Coupon Test Create')
                                .setStatus('Draft')   
                                .setSource(SF_SOURCE)
                                .buildAndSave();      

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CreateCouponHttpCalloutMock());                
                List<Coupon__c> scope = [SELECT Id, Name, Campaign__c, Campaign__r.QCCampaignId__c, QC_Account__r.Name, 
                                    ExpirationDate__c,SpendingExpirationDate__c, Amount__c, Quantity__c
                                    FROM Coupon__c 
                                    WHERE Campaign__c = :camp.Id
                                        AND Status__c = 'Draft'
                                    ];


            new MassGenerateCouponToQC_Batch(camp.Id).execute(null, scope);                 
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }
}