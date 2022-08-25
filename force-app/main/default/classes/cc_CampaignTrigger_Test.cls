@istest
public with sharing class cc_CampaignTrigger_Test {
    @istest
    public static void testDeleteCampaign(){
        Test.startTest();
            cc_Trigger_Control__c trg = cc_initData.initTrigger('CAMPAIGN_TRIGGER',true);
            insert trg;
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();


            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus( CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave(); 

            try {
                delete camp;
            } catch (Exception ex) {
                Boolean valid = ex.getMessage().contains('You can not delete this Campaign')?true:false;
                System.assertEquals(true, valid);
            }

        Test.stopTest();    
    }
   
    @istest
    public static void testInsertCampaign(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CampaignHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('CAMPAIGN_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponcampaignapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons/campaigns')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> campIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();


            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus( CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')                                
                                .setTransactionType(transtype.Id)
                                .buildAndSave();         
                            
            campIds.add(camp.Id);
            cc_CampaignHelper.attemptCreateCampaignToQC(campIds);
                             
        try {
            Test.stopTest();

            Campaign testcamp = [SELECT QCCampaignId__c FROM Campaign WHERE Id = :camp.Id LIMIT 1];
            System.assert(!String.isBlank(testcamp.QCCampaignId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testUpdateCampaign(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CampaignHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('CAMPAIGN_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('updatecouponcampaignapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons/campaigns')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> campIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus( CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')
                                .setQCCampaignId('123')
                                .setTransactionType(transtype.Id)
                                .buildAndSave();                   
                    
            camp.Name = 'Campaign Test Update';
            update camp;

            campIds.add(camp.Id);
            cc_CampaignHelper.attemptUpdateCampaignToQC(campIds);
                             
        try {
            Test.stopTest();

            Campaign testcamp = [SELECT QCCampaignId__c FROM Campaign WHERE Id = :camp.Id LIMIT 1];
            System.assert(!String.isBlank(testcamp.QCCampaignId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testUpdateTranstypeCampaign(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CampaignHttpCalloutMock());
            cc_Trigger_Control__c trg = cc_initData.initTrigger('CAMPAIGN_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('updatecouponcampaignapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons/campaigns')
                                                .setMethod('PUT')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Set<String> campIds = new Set<String>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

             Transactions_Type__c transtype2 = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.COMPENSATION   )
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.COMPENSATION   )
                                                .setAllowCoupon(true)
                                                .buildAndSave();       
                                                                          

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId(); 
            Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus( CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')                                
                                .setTransactionType(transtype2.Id)
                                .buildAndSave();                   
                    
            camp.Transactions_Type__c = transtype.Id;
            update camp;

            campIds.add(camp.Id);
            cc_CampaignHelper.attemptUpdateCampaignToQC(campIds);
                             
        try {
            Test.stopTest();

            Campaign testcamp = [SELECT QCCampaignId__c FROM Campaign WHERE Id = :camp.Id LIMIT 1];
            System.assert(!String.isBlank(testcamp.QCCampaignId__c));
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }

    }

    @istest
    public static void testBulkCreateCampaign(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_CampaignHttpCalloutMock());
            List<Campaign> listInsertCamp = new List<Campaign>();
            Set<String> campIds = new Set<String>();
            cc_Trigger_Control__c trg = cc_initData.initTrigger('CAMPAIGN_TRIGGER',true);
            insert trg;
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('createcouponcampaignapi')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons/campaigns')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

            String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get(CampaignConstant.RECORDTYPE_PROMOTION).getRecordTypeId();                                   
            for(Integer i = 0; i< 100 ; i++){ 
                Campaign camp = new CampaignTestDataBuilder()
                                .setRecordType(recordtypeId)
                                .setStatus( CampaignConstant.STATUS_IN_PROGRESS)
                                .setName('Campaign Test Insert')                                
                                .setTransactionType(transtype.Id)
                                .build();                 

                listInsertCamp.add(camp); 
            }

            insert listInsertCamp;
            

            for(Campaign camp: listInsertCamp ){
                campIds.add(camp.Id);
            }            
           
            cc_CampaignHelper.attemptCreateCampaignToQC(campIds);
                             
        try {
            Test.stopTest();

            List<Campaign> testcamp = [SELECT Id, QCCampaignId__c FROM Campaign WHERE QCCampaignId__c != '' LIMIT 1];
            System.assertNotEquals(100, testcamp.size(), 'false');
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
    }

}