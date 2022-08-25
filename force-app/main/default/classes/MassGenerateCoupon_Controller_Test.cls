@istest
public with sharing class MassGenerateCoupon_Controller_Test {
    @istest 
    public static void testImportfile(){
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Admin'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;  

        String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(); 
        Campaign camp = new CampaignTestDataBuilder()
                            .setRecordType(recordtypeId)
                            .setStatus('In Progress')
                            .setName('Campaign Test Insert')
                            .setQCCampaignId('123')
                            .buildAndSave();    
        Account acc = new AccountTestDataBuilder().buildAndSave();
        List<QC_Account__c> listqcAccount = new List<QC_Account__c>();

        String csvRFColumnHeader = 'userId, userEmail, amount \n';
        List<String> csvRowValues = new List<String>();
        for(Integer i = 0 ; i< 20 ; i ++){
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                            .setAccount(acc.Id)
                            .setName('testclient@qc.coccoc.com')
                            .setQcId('1234' + String.valueOf(i))
                            .build();
            listqcAccount.add(qcacc);
            String logRow;
            if(i ==19){
                logRow = '1234' + String.valueOf(i) + ',' + 'testmasgenerateCoupon' + String.valueOf(i) + '@coccoc.com.test' + ',' + 'abc';
            }else {
                logRow = '1234' + String.valueOf(i) + ',' + 'testmasgenerateCoupon' + String.valueOf(i) + '@coccoc.com.test' + ',' + String.valueOf(100000);
            }
            
            csvRowValues.add(logRow);
        }

        String logRow = '1234' + ',' + 'testmasgenerateCoupon' + String.valueOf(20) + '@coccoc.com.test' + ',' + String.valueOf(100000);
        csvRowValues.add(logRow);  

        insert listqcAccount;

        cc_initData.insertCSVtoAttachfile('filedata', camp.Id, csvRFColumnHeader, csvRowValues);

        

        Test.startTest();
            ContentDocumentLink docLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :camp.Id];
            Contentversion  file = [SELECT Id FROM Contentversion WHERE ContentDocumentId = :docLink.ContentDocumentId AND FileType = 'CSV' AND IsLatest = true LIMIT 1];

            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            MassGenerateCoupon_Controller getbl = new MassGenerateCoupon_Controller(sc);
            getbl.selectedfileId = file.Id;
            getbl.importFile();       
        Test.stopTest();
    }

    @istest 
    public static void testGetFileSelection(){
        List<QC_Account__c> listqcAccount = new List<QC_Account__c>();

        String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(); 
        Campaign camp = new CampaignTestDataBuilder()
                            .setRecordType(recordtypeId)
                            .setStatus('In Progress')
                            .setName('Campaign Test Insert')
                            .setQCCampaignId('123')
                            .buildAndSave();    
        Account acc = new AccountTestDataBuilder().buildAndSave();

        String csvRFColumnHeader = 'userId, userEmail, amount \n';
        List<String> csvRowValues = new List<String>();
        for(Integer i = 0 ; i< 20 ; i ++){
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                            .setAccount(acc.Id)
                            .setName('testclient@qc.coccoc.com')
                            .setQcId('1234' + String.valueOf(i))
                            .build();
            listqcAccount.add(qcacc);
            String logRow;
            if(i ==19){
                logRow = '1234' + String.valueOf(i) + ',' + 'testmasgenerateCoupon' + String.valueOf(i) + '@coccoc.com.test' + ',' + 'abc';
            }else {
                logRow = '1234' + String.valueOf(i) + ',' + 'testmasgenerateCoupon' + String.valueOf(i) + '@coccoc.com.test' + ',' + String.valueOf(100000);
            }
            
            csvRowValues.add(logRow);
        }

        String logRow = '1234' + ',' + 'testmasgenerateCoupon' + String.valueOf(20) + '@coccoc.com.test' + ',' + String.valueOf(100000);
        csvRowValues.add(logRow);  

        insert listqcAccount;

        cc_initData.insertCSVtoAttachfile('filedata', camp.Id, csvRFColumnHeader, csvRowValues);

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(camp);
            MassGenerateCoupon_Controller getbl = new MassGenerateCoupon_Controller(sc);
            getbl.getFiles(camp.Id);       
        Test.stopTest();

    }


    @istest 
    public static void testMassgeneratetoQC(){
        cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
        insert trg;
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
                            .setSource('Salesforce')
                            .buildAndSave();       

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_CreateCouponHttpCalloutMock());
        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        MassGenerateCoupon_Controller getbl = new MassGenerateCoupon_Controller(sc);
        getbl.massGenerateCouponToQC();       
        
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
                            
    }

    @istest 
    public static void testGeneratetoSpendingBonus(){
        cc_Trigger_Control__c trg = cc_initData.initTrigger('COUPON_TRIGGER',true);
        insert trg;
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
                            .setSource('Salesforce')
                            .buildAndSave();       

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new SpendingBonusHttpCalloutMock());
        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        MassGenerateCoupon_Controller getbl = new MassGenerateCoupon_Controller(sc);
        getbl.GenerateSpendingBonusCoupon();       
        
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
                            
    }
}