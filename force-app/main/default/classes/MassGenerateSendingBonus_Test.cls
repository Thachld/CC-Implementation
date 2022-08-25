@istest
public with sharing class MassGenerateSendingBonus_Test {
    @TestSetup
    static void makeData(){
        List<QC_Account__c> insertQCAccs = new List<QC_Account__c>();
        List<Coupon__c> insertCoupons = new List<Coupon__c>();

        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

        CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('generatespendingbonus')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons/grant')
                                                .setMethod('GET')
                                                .setTimeout(10000)
                                                .buildAndSave();

        Account acc = new AccountTestDataBuilder().buildAndSave();

        QC_Account__c qcacc1 = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testspendingbonus1@coccoc.com.test')
                                .setQcId('1111')
                                .build();
        insertQCAccs.add(qcacc1);
        
        QC_Account__c qcacc2 = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testspendingbonus2@coccoc.com.test')
                                .setQcId('1112')
                                .build();
        insertQCAccs.add(qcacc2);

        QC_Account__c qcacc3 = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testspendingbonus3@coccoc.com.test')
                                .setQcId('1113')
                                .build();
        insertQCAccs.add(qcacc3);

        QC_Account__c qcacc4 = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setName('testspendingbonus4@coccoc.com.test')
                                .setQcId('1114')
                                .build();
        insertQCAccs.add(qcacc4);


        insert insertQCAccs;

        Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.MONTHLY_SPENDING_BONUS)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.MONTHLY_SPENDING_BONUS)
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


        Coupon__c coupon1 =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(insertQCAccs[0].Id)
                                .setAmount(10)
                                .setName('Coupon Test 1')
                                .setStatus(CouponConstant.STATUS_DRAFT)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .build();   
        insertCoupons.add(coupon1); 
        
        Coupon__c coupon2 =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(insertQCAccs[1].Id)
                                .setAmount(11)
                                .setName('Coupon Test 2')
                                .setStatus(CouponConstant.STATUS_DRAFT)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .build();   
        insertCoupons.add(coupon2);

        Coupon__c coupon3 =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(insertQCAccs[2].Id)
                                .setAmount(12)
                                .setName('Coupon Test 3')
                                .setStatus(CouponConstant.STATUS_DRAFT)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .build();   
        insertCoupons.add(coupon3);

        Coupon__c coupon4 =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(insertQCAccs[3].Id)
                                .setAmount(13)
                                .setName('Coupon Test 4')
                                .setStatus(CouponConstant.STATUS_DRAFT)   
                                .setSource(CouponConstant.SOURCE_SALESFORCE)
                                .build();   
        insertCoupons.add(coupon4);
        
        insert insertCoupons;



    }


    public static testMethod void testBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SpendingBonusHttpCalloutMock());

            Campaign testCamp = [SELECT Id FROM Campaign LIMIT 1];
            List<Coupon__c> scope = [SELECT Id, Name, Campaign__c, Campaign__r.QCCampaignId__c, 
                                    QC_Account__r.Name, QC_Account__r.QC_Account_Id__c, 
                                    ExpirationDate__c,SpendingExpirationDate__c, Amount__c, Quantity__c FROM Coupon__c WHERE Campaign__c = :testCamp.Id];

            new MassGenerateSendingBonus_Batch(testCamp.Id).execute(null,scope);   
        try {

            Test.stopTest();

            List<Coupon__c> successCoupon = [SELECT Id FROM Coupon__c WHERE Status__c = :CouponConstant.STATUS_ACTIVE];

            
            System.assertEquals(2, successCoupon.size());

            Coupon__c failcp1 = [SELECT Id,Error_Log__c FROM Coupon__c WHERE Status__c = :CouponConstant.STATUS_DRAFT AND QC_Account__r.Name ='testspendingbonus3@coccoc.com.test' LIMIT 1];
            System.assertEquals('Amount is too small', failcp1.Error_Log__c);

            Coupon__c failcp2 = [SELECT Id,Error_Log__c FROM Coupon__c WHERE Status__c = :CouponConstant.STATUS_DRAFT AND QC_Account__r.Name ='testspendingbonus4@coccoc.com.test'  LIMIT 1];
            System.assertEquals('amount is not integer value', failcp2.Error_Log__c);

        } catch (Exception ex) {
            
        }
        
    }

    
    public static testMethod void testFailedBatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SpendingBonusFailedHttpCalloutMock());

            Campaign testCamp = [SELECT Id FROM Campaign LIMIT 1];
            List<Coupon__c> scope = [SELECT Id, Name, Campaign__c, Campaign__r.QCCampaignId__c, 
                                    QC_Account__r.Name, QC_Account__r.QC_Account_Id__c, 
                                    ExpirationDate__c,SpendingExpirationDate__c, Amount__c, Quantity__c FROM Coupon__c WHERE Campaign__c = :testCamp.Id];

            new MassGenerateSendingBonus_Batch(testCamp.Id).execute(null,scope);   
        try {

            Test.stopTest();

            List<Coupon__c> successCoupon = [SELECT Id FROM Coupon__c WHERE Status__c = :CouponConstant.STATUS_ACTIVE];

            
            System.assertEquals(0, successCoupon.size());

            List<CalloutLog__c> logs = [SELECT id FROM CalloutLog__c ];
            System.assertEquals(1, logs.size());

            
        } catch (Exception ex) {
            
        }
        
    }
}