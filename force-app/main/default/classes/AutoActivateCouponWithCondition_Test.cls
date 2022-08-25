/**
 * @description       : Test class for batch AutoActivateCouponWithCondition_Batch
 * @author            : @Thach Le
 * @group             : Promotion With Condition
 * @last modified on  : 07-29-2022
 * @last modified by  : @Thach Le
**/
@istest
public with sharing class AutoActivateCouponWithCondition_Test {
    @TestSetup
    static void makeData(){

        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();
        List<Payment__c> listPayment = new List<Payment__c>();

        cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
        insert trg;
        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
        
        cc_setting__c setting = cc_initData.initCustomeSetting();
        insert setting;
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;    

        CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                            .setName('activatecouponapi')
                                            .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                            .setMethod('POST')
                                            .setTimeout(10000)
                                            .buildAndSave();              
        CouponIntegration__c cpsetting2 = new CouponIntegrationTestDataBuilder()
                                            .setName('disablecouponapi')
                                            .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                            .setMethod('POST')
                                            .setTimeout(10000)
                                            .buildAndSave();                                            
        
        CouponIntegration__c cpsetting3 = new CouponIntegrationTestDataBuilder()
                                            .setName('updatecouponapi')
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

        Campaign spendcamp = new CampaignTestDataBuilder()
                            .setRecordType(recordtypeId)
                            .setStatus(CampaignConstant.STATUS_IN_PROGRESS)
                            .setName('Campaign Test PROMOTION_WITH_CONDITION Spending')
                            .setQCCampaignId('1234')
                            .setTransactionType(transtype.Id)
                            .setConditionType(CampaignConstant.CONDITION_TYPE_SPENDING)
                            .setCampaignContent('Test Content')
                            .buildAndSave();

        Account acc = new AccountTestDataBuilder().buildAndSave();
        QC_Account__c qcacc = new QCAccountTestDataBuilder()
                            .setName('cococTestdata1@coccoc.com')
                            .setApplyTransactionType(true)
                            .setAccount(acc.Id)                            
                            .build();
        qcacc.QC_Account_Id__c = '1103';
        qcacc.OwnerId = u1.Id;
        qcacc.Sales__c = u1.Id;    
        insert qcacc;         
        
        QC_Account__c qcacc2 = new QCAccountTestDataBuilder()
                            .setName('cococTestdata2@coccoc.com')
                            .setApplyTransactionType(true)
                            .setAccount(acc.Id)                            
                            .build();
        qcacc2.QC_Account_Id__c = '1104';
        qcacc2.OwnerId = u1.Id;
        qcacc2.Sales__c = u1.Id;    
        insert qcacc2;       

        List<Coupon__c> coupons = new List<Coupon__c>();
        Coupon__c pycoupon =  new CouponTestDataBuilder()
                            .setCampaign(pycamp.Id) 
                            .setQCAccount(qcacc.Id)
                            .setAmount(10)
                            .setCouponId('11')
                            .setName('Coupon PROMOTION_WITH_CONDITION Payment Test')
                            .setStatus(CouponConstant.STATUS_ACTIVE)   
                            .setSource(CouponConstant.SOURCE_SALESFORCE) 
                            .setStartDate(System.today().AddDays(-5))  
                            .setEndDate(System.today().AddDays(5))
                            .setIntervalSpendingDays(365)
                            .setConditionAmount(1000)
                            .build();     
        coupons.add(pycoupon);
        Coupon__c pycouponf =  new CouponTestDataBuilder()
                            .setCampaign(pycamp.Id) 
                            .setQCAccount(qcacc2.Id)
                            .setAmount(10)
                            .setCouponId('12')
                            .setName('Coupon PROMOTION_WITH_CONDITION Payment Test')
                            .setStatus(CouponConstant.STATUS_ACTIVE)   
                            .setSource(CouponConstant.SOURCE_SALESFORCE) 
                            .setStartDate(System.today().AddDays(-25))  
                            .setEndDate(System.today().AddDays(-10))
                            .setIntervalSpendingDays(365)
                            .setConditionAmount(1000)
                            .build();     
        coupons.add(pycouponf);
        Coupon__c spendcoupon =  new CouponTestDataBuilder()
                            .setCampaign(spendcamp.Id) 
                            .setQCAccount(qcacc.Id)
                            .setAmount(10)
                            .setCouponId('13')
                            .setName('Coupon PROMOTION_WITH_CONDITION Spending Test')
                            .setStatus(CouponConstant.STATUS_ACTIVE)   
                            .setSource(CouponConstant.SOURCE_SALESFORCE) 
                            .setStartDate(System.today().AddDays(-5))  
                            .setEndDate(System.today().AddDays(5))
                            .setIntervalSpendingDays(365)
                            .setConditionAmount(1000)
                            .build();     
        coupons.add(spendcoupon);
        Coupon__c spendcouponf =  new CouponTestDataBuilder()
                            .setCampaign(spendcamp.Id) 
                            .setQCAccount(qcacc2.Id)
                            .setAmount(10)
                            .setCouponId('14')
                            .setName('Coupon PROMOTION_WITH_CONDITION Spending Test')
                            .setStatus(CouponConstant.STATUS_ACTIVE)   
                            .setSource(CouponConstant.SOURCE_SALESFORCE) 
                            .setStartDate(System.today().AddDays(-25))  
                            .setEndDate(System.today().AddDays(-10))
                            .setIntervalSpendingDays(365)
                            .setConditionAmount(1000)
                            .build();     
        coupons.add(spendcouponf);
        insert coupons;

        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qcacc.Id,acc.id, System.now(), 1000, 1 , 'Normal');
        listQCAccountData.add(datanormal);
        QC_Account_Data__c datanormal1 = cc_initData.initQCAccountData(qcacc.Id,acc.id, System.now().AddDays(1), 2000, 1 , 'Normal');
        listQCAccountData.add(datanormal1);

        QC_Account_Data__c datanormal2 = cc_initData.initQCAccountData(qcacc2.Id,acc.id, System.now().AddDays(1), 10, 1 , 'Normal');
        listQCAccountData.add(datanormal2);
        insert listQCAccountData;

        String Standard_payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Standard_payment').getRecordTypeId();  
        Payment__c py1 = cc_initData.initPayment(Standard_payment, '100000df', qcacc.Id);
        py1.Final_Amount__c = 1000;
        py1.Effective_Date__c = System.now();
        py1.Stage__c = PaymentConstant.STAGE_DONE;
        listPayment.add(py1);

        Payment__c py11 = cc_initData.initPayment(Standard_payment, '100000dg', qcacc2.Id);
        py11.Final_Amount__c = 10;
        py11.Effective_Date__c = System.now();
        py11.Stage__c = PaymentConstant.STAGE_DONE;
        listPayment.add(py11);

        String real_payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Real_Payment').getRecordTypeId();  
        Payment__c payment5 =  cc_initData.initPayment(real_payment,'1234562d', qcacc.Id );     
        payment5.Stage__c = PaymentConstant.STAGE_DONE;
        insert payment5;

        String transfer_payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Transfer_payment').getRecordTypeId();  
        Payment__c py2 = cc_initData.initPayment(transfer_payment, '100001df', qcacc.Id);
        py2.Parent_Payment__c = payment5.id;
        py2.Final_Amount__c = 1000;
        py2.Effective_Date__c = System.now();
        py2.Stage__c = PaymentConstant.STAGE_DONE;
        listPayment.add(py2);
        insert listPayment;

    }


    public  testMethod static void testBatchActivatePayment(){
        Test.startTest();

            QC_Account__c testqc = [SELECT Id FROM QC_Account__c WHERE Name = 'cococTestdata1@coccoc.com' ];
            Date rundate = Date.today();    
            List<Coupon__c> scope = [SELECT Id, Campaign__r.QCCampaignId__c, 
                                            Transaction_Type__c,
                                            TransactionTypeId__c,   
                                            Condition_Type__c,
                                            CouponId__c,
                                            QC_Account__c, 
                                            QC_Account__r.QC_Account_Id__c,
                                            Start_Date__c,
                                            End_Date__c, 
                                            Condition_Amount__c,
                                            CreatedById,
                                            CreatedBy.QCuserId__c
                                    FROM Coupon__c
                                    WHERE Status__c = :CouponConstant.STATUS_ACTIVE
                                        AND CouponId__c != null
                                        AND Start_Date__c <= :rundate
                                        AND QC_Account__c = :testqc.Id
                                        AND CouponId__c = '11'
                                        AND Condition_Type__c = :CampaignConstant.CONDITION_TYPE_PAYMENT ];

        try {
            Test.setMock(HttpCalloutMock.class, new ActivateCouponHttpCalloutMock());   

            new AutoActivateCouponWithCondition_Batch(rundate).execute(null,scope);     
        } catch (Exception ex) {
            Test.stopTest();
        }
    } 


    public  testMethod static void testAutoActivateSpending(){
        Test.startTest();

            QC_Account__c testqc = [SELECT Id FROM QC_Account__c WHERE Name = 'cococTestdata1@coccoc.com' ];
            Date rundate = Date.today();    
            List<Coupon__c> scope = [SELECT Id, Campaign__r.QCCampaignId__c, 
                                            Transaction_Type__c,
                                            TransactionTypeId__c,   
                                            Condition_Type__c,
                                            CouponId__c,
                                            QC_Account__c, 
                                            QC_Account__r.QC_Account_Id__c,
                                            Start_Date__c,
                                            End_Date__c, 
                                            Condition_Amount__c,
                                            CreatedById,
                                            CreatedBy.QCuserId__c
                                    FROM Coupon__c
                                    WHERE Status__c = :CouponConstant.STATUS_ACTIVE
                                        AND CouponId__c != null
                                        AND Start_Date__c <= :rundate
                                        AND QC_Account__c = :testqc.Id
                                        AND CouponId__c = '13'
                                        AND Condition_Type__c = :CampaignConstant.CONDITION_TYPE_SPENDING ];

        try {
            Test.setMock(HttpCalloutMock.class, new ActivateCouponHttpCalloutMock());   

            new AutoActivateCouponWithCondition_Batch(rundate).execute(null,scope);     
        } catch (Exception ex) {
            Test.stopTest();
        }
    } 

    public  testMethod static void testAutoDisableSpending(){
        Test.startTest();

            QC_Account__c testqc = [SELECT Id FROM QC_Account__c WHERE Name = 'cococTestdata2@coccoc.com' ];
            Date rundate = Date.today();    
            List<Coupon__c> scope = [SELECT Id, Campaign__r.QCCampaignId__c, 
                                        Campaign__r.Transactions_Type__r.Internal_Type__c,
                                        Campaign__r.Transactions_Type__r.TransactionTypeId__c,
                                        Condition_Type__c,
                                        CouponId__c,
                                        QC_Account__c, 
                                        QC_Account__r.QC_Account_Id__c,
                                        Start_Date__c,
                                        End_Date__c, 
                                        Condition_Amount__c,
                                        CreatedById,
                                        CreatedBy.QCuserId__c
                                    FROM Coupon__c
                                    WHERE Status__c = :CouponConstant.STATUS_ACTIVE
                                        AND CouponId__c != null
                                        AND Start_Date__c <= :rundate
                                        AND QC_Account__c = :testqc.Id
                                        AND CouponId__c = '14'
                                        AND Condition_Type__c = :CampaignConstant.CONDITION_TYPE_SPENDING ];

        try {
            Test.setMock(HttpCalloutMock.class, new cc_DisableCouponHttpCalloutMock());   

            new AutoActivateCouponWithCondition_Batch(rundate).execute(null,scope);     
        } catch (Exception ex) {
            Test.stopTest();
        }
    }

    public  testMethod static void testAutoDisablePayment(){
        Test.startTest();

            QC_Account__c testqc = [SELECT Id FROM QC_Account__c WHERE Name = 'cococTestdata2@coccoc.com' ];
            Date rundate = Date.today();    
            List<Coupon__c> scope = [SELECT Id, Campaign__r.QCCampaignId__c, 
                                        Campaign__r.Transactions_Type__r.Internal_Type__c,
                                        Campaign__r.Transactions_Type__r.TransactionTypeId__c,
                                        Condition_Type__c,
                                        CouponId__c,
                                        QC_Account__c, 
                                        QC_Account__r.QC_Account_Id__c,
                                        Start_Date__c,
                                        End_Date__c, 
                                        Condition_Amount__c,
                                        CreatedById,
                                        CreatedBy.QCuserId__c
                                    FROM Coupon__c
                                    WHERE Status__c = :CouponConstant.STATUS_ACTIVE
                                        AND CouponId__c != null
                                        AND Start_Date__c <= :rundate
                                        AND QC_Account__c = :testqc.Id
                                        AND CouponId__c = '12'
                                        AND Condition_Type__c = :CampaignConstant.CONDITION_TYPE_PAYMENT ];

        try {
            Test.setMock(HttpCalloutMock.class, new cc_DisableCouponHttpCalloutMock());   

            new AutoActivateCouponWithCondition_Batch(rundate).execute(null,scope);     
        } catch (Exception ex) {
            Test.stopTest();
        }
    }

    public  testMethod static void testSchedule(){
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();            
            Test.setMock(HttpCalloutMock.class, new ActivateCouponHttpCalloutMock());    
            String scjobId = System.Schedule('AutoActivateCouponWithCondition_BatchTEST', CRON_EXP, new AutoActivateCouponWithCondition_Schedule());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :scjobId];
                
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

        try {
            Test.stopTest();
            
            
        } catch (Exception ex) {
            
        }
    }
}