/**
 * @description       : Test class for Coupon trigger
 * @author            : @Thach Le
 * @group             : Coupon trigger
 * @last modified on  : 07-29-2022
 * @last modified by  : @Thach Le
**/
@istest
public with sharing class cc_CouponTrigger_Test {
    @istest
    public static void testDeleteCoupon(){
        Test.startTest();
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;           
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;
            
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.COMPENSATION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.COMPENSATION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setTransactionType(transtype.Id)
                                .setStatus( CampaignConstant.STATUS_IN_PROGRESS )
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .buildAndSave();   
                               
            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setName('Coupon Test Delete')
                                .setStatus(CouponConstant.STATUS_ACTIVE    )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)   
                                .setCouponId('11')
                                .buildAndSave();     
                                  
            try {
                delete coupon;
            } catch (Exception ex) {
                Boolean valid = ex.getMessage().contains('You can not delete this coupon')?true:false;
                System.assertEquals(true, valid);
            }

        Test.stopTest();    
    }

    @istest
    public static void testDuplicateInsertCoupon(){
        Test.startTest();
            
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
           
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.COMPENSATION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.COMPENSATION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)                                
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .setMultipleUsage(false)
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
                                .setName('Coupon Test')
                                .setStatus(CouponConstant.STATUS_DRAFT)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .buildAndSave();      

            Coupon__c coupon2 =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setName('Coupon Test Insert Duplicate')
                                .setStatus(CouponConstant.STATUS_DRAFT)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .build();                                 
            try {

                insert coupon2;  
            } catch (Exception ex) {
                Boolean isValid = ex.getMessage().contains('already has coupon record');
                System.assertEquals(true, isValid);
            }

        Test.stopTest();
    }

    @istest
    public static void testInsertCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CreateCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> couponIds = new Set<String>();

            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.COMPENSATION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.COMPENSATION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
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
                                .setStatus(CouponConstant.STATUS_ACTIVE    )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .buildAndSave();      

                            
            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptCreateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }
   
    @istest
    public static void testInsertPromotionCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CreateCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> couponIds = new Set<String>();

            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();    
            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testclient@qc.coccoc.com')
                                .setApplyTransactionType(true)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setName('Coupon Test Create')
                                .setStatus(CouponConstant.STATUS_ACTIVE)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .setIntervalSpendingDays(365)
                                .buildAndSave();      

                            
            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptCreateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testInsertPromotionWithConditionCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ActivateCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION_WITH_CONDITION)
                                                .setTransactionTypeId('15')
                                                .setInternalType(TransactionTypeConstant.PROMOTION_WITH_CONDITION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign pycamp = new CampaignTestDataBuilder()
                            .setRecordType(recordtypeId)
                            .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                            .setName('Campaign Test PROMOTION_WITH_CONDITION Payment')
                            .setQCCampaignId('123')
                            .setTransactionType(transtype.Id)
                            .setConditionType(CampaignConstant.CONDITION_TYPE_PAYMENT)
                            .setCampaignContent('Test Content')
                            .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testclient@qc.coccoc.com')
                                .setApplyTransactionType(true)
                                .buildAndSave();

            Coupon__c pycoupon =  new CouponTestDataBuilder()
                                .setCampaign(pycamp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)                               
                                .setName('Coupon PROMOTION_WITH_CONDITION Payment Test')
                                .setStatus(CouponConstant.STATUS_ACTIVE)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE) 
                                .setStartDate(System.today().AddDays(-5))  
                                .setEndDate(System.today().AddDays(5))
                                .setIntervalSpendingDays(365)
                                .setConditionAmount(1000)
                                .buildAndSave();     
                            
            couponIds.add(pycoupon.Id);
            cc_CouponHelper.attemptCreateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :pycoupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testInsertCouponFailed(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CouponAPIFailedHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
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
                                .setStatus(CouponConstant.STATUS_ACTIVE    )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .buildAndSave();      

                            
            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptCreateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();
            
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testUpdateCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_UpdateCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('updatecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Update')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setApplyTransactionType(true)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Update')
                                .setStatus(CouponConstant.STATUS_ACTIVE    )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .buildAndSave();      

            coupon.Amount__c = 9;  
            coupon.ExpirationDate__c = coupon.ExpirationDate__c + 5;              
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptUpdateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testUpdateCouponPromotionWithCondition(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_UpdateCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('updatecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION_WITH_CONDITION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION_WITH_CONDITION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                            .setRecordType(recordtypeId)
                            .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                            .setName('Campaign Test PROMOTION_WITH_CONDITION Payment')
                            .setQCCampaignId('123')
                            .setTransactionType(transtype.Id)
                            .setConditionType(CampaignConstant.CONDITION_TYPE_PAYMENT)
                            .setCampaignContent('Test Content')
                            .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setApplyTransactionType(true)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Update')
                                .setStatus(CouponConstant.STATUS_ACTIVE)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .setStartDate(System.today().AddDays(-5))  
                                .setEndDate(System.today().AddDays(5))
                                .setIntervalSpendingDays(365)
                                .setConditionAmount(1000)
                                .buildAndSave();      

            coupon.Amount__c = 9;  
            coupon.ExpirationDate__c = coupon.ExpirationDate__c + 5;              
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptUpdateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testUpdateCouponFailed(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CouponAPIFailedHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('updatecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test update failed')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Update')
                                .setStatus(CouponConstant.STATUS_ACTIVE    )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)   
                                .buildAndSave();      

            coupon.Amount__c = 9;  
            coupon.ExpirationDate__c = coupon.ExpirationDate__c + 5;              
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptUpdateCouponsToQC(couponIds);            
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testEnableCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_EnableCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('enablecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Enable')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Enable')
                                .setStatus('Deactivated')   
                                .buildAndSave();      

            coupon.Status__c = CouponConstant.STATUS_ACTIVE    ;  
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptEnableCouponsToQC(couponIds);    
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testEnableCouponFailed(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CouponAPIFailedHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('enablecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Enable Failed')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Enable')
                                .setStatus('Deactivated')   
                                .buildAndSave();      

            coupon.Status__c = CouponConstant.STATUS_ACTIVE    ;  
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptEnableCouponsToQC(couponIds);    
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testDisableCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_DisableCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('disablecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Disable')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)                                
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Enable')
                                .setStatus(CouponConstant.STATUS_ACTIVE    )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)   
                                .buildAndSave();      

            coupon.Status__c = 'Deactivated';  
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptDisableCouponsToQC(couponIds);   
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testActivateCoupon(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ActivateCouponHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('activatecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION_WITH_CONDITION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION_WITH_CONDITION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                            .setRecordType(recordtypeId)
                            .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                            .setName('Campaign Test PROMOTION_WITH_CONDITION Payment')
                            .setQCCampaignId('123')
                            .setTransactionType(transtype.Id)
                            .setConditionType(CampaignConstant.CONDITION_TYPE_PAYMENT)
                            .setCampaignContent('Test Content')
                            .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setQcId('49626')
                                .setApplyTransactionType(true)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Update')
                                .setStatus(CouponConstant.STATUS_ACTIVE)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .setStartDate(System.today().AddDays(-5))  
                                .setEndDate(System.today().AddDays(5))
                                .setIntervalSpendingDays(365)
                                .setConditionAmount(1000)
                                .buildAndSave();       

            coupon.Status__c = CouponConstant.STATUS_USED;  
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptActivateCouponsToQC(couponIds);
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testDisableCouponFailed(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CouponAPIFailedHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('disablecouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();                                                

            Set<String> couponIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Disable Failed')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();

            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .buildAndSave();

            Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(10)
                                .setCouponId('11')
                                .setName('Coupon Test Enable')
                                .setStatus(CouponConstant.STATUS_ACTIVE)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)   
                                .buildAndSave();      

            coupon.Status__c = 'Deactivated';  
            update coupon;                  

            couponIds.add(coupon.Id);
            cc_CouponHelper.attemptDisableCouponsToQC(couponIds);   
                             
        try {
            Test.stopTest();

            Coupon__c testcp = [SELECT CouponId__c FROM Coupon__c WHERE Id = :coupon.Id LIMIT 1];
            System.assert(!String.isBlank(testcp.CouponId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }   


    @istest
    public static void testBulkCreateCoupon(){
        Test.startTest();   
            Test.setMock(HttpCalloutMock.class, new cc_CreateCouponHttpCalloutMock());
            List<Coupon__c> listInsertCoupon = new List<Coupon__c>();
            cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            cc_setting__c setting = cc_initData.initCustomeSetting();
            insert setting;
            
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.COMPENSATION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.COMPENSATION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();
            Set<String> couponIds = new Set<String>();
            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                                .setTransactionType(transtype.Id)
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .buildAndSave();    
            Account acc = new AccountTestDataBuilder().buildAndSave();
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .buildAndSave();            
                                        
            for(Integer i = 0; i< 100 ; i++){
                Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcacc.Id)
                                .setAmount(i+1)
                                .setName('Coupon Test Bulk Create' + String.valueOf(i))
                                .setStatus(CouponConstant.STATUS_ACTIVE )   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)   
                                .build();      

                listInsertCoupon.add(coupon); 
            }

            insert listInsertCoupon;
            

            for(Coupon__c cp: listInsertCoupon ){
                couponIds.add(cp.Id);
            }            
           
            cc_CouponHelper.attemptCreateCouponsToQC(couponIds);    
                             
        try {
            Test.stopTest();

            List<Coupon__c> testcp = [SELECT Id, CouponId__c FROM Coupon__c WHERE CouponId__c != '' LIMIT 1];
            System.assertNotEquals(100, testcp.size(), 'false');
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }

    
}