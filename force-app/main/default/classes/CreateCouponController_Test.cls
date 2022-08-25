/**
 * @description       : Test class for class CreateCouponController
 * @author            : @Thach Le
 * @group             : Create Coupon
 * @last modified on  : 07-28-2022
 * @last modified by  : @Thach Le
**/
@istest
public with sharing class CreateCouponController_Test {
    @TestSetup 
    static void makeData(){
        cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
        insert trg;

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
    }


    public static testMethod void Test_getCampaign(){

       
        Test.startTest();
            Campaign camp = [SELECT Id FROM Campaign LIMIT 1];
            Campaign testCamp = CreateCouponController.getCampaign(camp.Id);

            System.assertEquals(camp.Id, testCamp.Id);

        Test.stopTest();
    }

    public static testMethod void Test_getCampaign_Failed(){

        Exception capturedException;
        try {
            Test.startTest();            
            Campaign testCamp = CreateCouponController.getCampaign('12345');

        } catch (Exception ex) {
            capturedException= ex;
            System.debug('ex.getMessage()' + ex.getMessage());
            System.debug('capturedException=>' + capturedException);
            System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        }
        

        Test.stopTest();
    }

    public static testMethod void Test_getQCAccount(){


        Test.startTest();
            QC_Account__c qc = [SELECT Id FROM QC_Account__c LIMIT 1];
            QC_Account__c testqc = CreateCouponController.getQCAccount(qc.Id);

            System.assertEquals(qc.Id, testqc.Id);

        Test.stopTest();
    }

    public static testMethod void Test_getQCAccount_Failed(){

        Exception capturedException;
        try {
            Test.startTest();            
            QC_Account__c testqc = CreateCouponController.getQCAccount('12345');

        } catch (Exception ex) {
            capturedException= ex;
            System.debug('ex.getMessage()' + ex.getMessage());
            System.debug('capturedException=>' + capturedException);
            System.assertNotEquals(null, capturedException, 'Exception should be thrown');
        }
        

        Test.stopTest();
    }
}