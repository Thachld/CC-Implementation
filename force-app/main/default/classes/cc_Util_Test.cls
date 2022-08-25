@isTest
public class cc_Util_Test {

    @istest
    public static void testcustomSetting(){
        cc_Trigger_Control__c trg = cc_initData.initTrigger('TRANSFER_TRIGGER',true);
        insert trg;

        Boolean bl = cc_Util.checkTriggerAllowRun('TRANSFER_TRIGGER');

        cc_Profile__c profile = cc_initData.initProfileSetting('Sales Profile', '00e0o000003Ewa5');
        insert profile;

        cc_Profile__c testPf = cc_Util.getProfile('Sales Profile');

        QC_Integration__c qcinte = cc_initData.initQcIntegrationSetting('qccampaignInternal');
        insert qcinte;

        cc_Payment_Setting__c pysetting = cc_initData.initPaymentSetting('ccpaymentsetting');
        insert pysetting;


        Date fromdt = Date.newInstance(2020, 1, 1);
        String clause1 = '';
        String clause2 = 'Type__c NOT IN (\'Internal\',\'External\')';      
        String pFieldTotal = 'Total_Payment__c';       
        String pObjectAccum = 'QC_Account__c'; 
        String pFieldAccum = 'AccountOwner__c';
        String pFieldAccumAlias = 'AccountOwner';
        String pAgregateField = 'Total_Payment__c';        
        String pAggregateFunc = 'SUM';  
        Integer BatchSize = 500; 

        cc_Batch_Parameter__c params = cc_initData.initbatchParamSetting('AccountPaymentAccum', fromdt, null, clause1, clause2, pFieldTotal, 
                                                                        pFieldAccum, pFieldAccumAlias,pObjectAccum, pAgregateField, pAggregateFunc, BatchSize);
        insert params;

        cc_KPI_Setting__c kpisetting = cc_initData.initKPISetting('ccKPISetting');
        insert kpisetting;

        cc_Batch_Parameter__c testparams = cc_Util.getBatchParameter('AccountPaymentAccum');


        QC_Integration__c testqcinte = cc_Util.getQCIntergrationInfo('qccampaignInternal');

        cc_KPI_Setting__c kpist = cc_Util.getKPISetting('ccKPISetting');

        cc_Payment_Setting__c testpysetting = cc_Util.getPaymentSetting('ccpaymentsetting');
        
        System.assert(testparams != null);
        System.assert(testPf != null);
        System.assert(testqcinte != null);
        System.assert(kpist != null);
        System.assert(testpysetting != null);

        System.assertEquals(true, bl);
      

    }
    @isTest
    public static void testUtil(){
        Test.startTest();
        User us = [select id, email,QC_Email__c from user where IsActive = true and QC_Email__c != null limit 1];
         cc_Util.writeLog('test', 'description', 'inputData');
        Account acc = cc_initData.initAccount();
        insert acc;
        cc_Util.initSharing(acc.id, us.id);
        cc_Util.initTeamAccount(acc.id, us.id, 'test');
        List<Id> userIdList = new List<Id>();
        userIdList.add(us.id);
        cc_Util.initChatter(userIdList, acc.id,'test');   
        
        ConnectApi.FeedItemInput feed = cc_Util.genChatterwithMetion(us.Id, acc.id,'test');     
        
        Test.stopTest();
    }
    
    @isTest
    public static void testUtil1(){
        
        Account acc = cc_initData.initAccount();
        insert acc;
        User us = [select id from user where profile.Name = 'System Administrator' and isactive = true limit 1];
        cc_ChatterBatchWrapper fItem = new cc_ChatterBatchWrapper();
        fItem.idList.add(us.id);
        fItem.recordid = acc.id;
        List<cc_ChatterBatchWrapper> fItemList = new List<cc_ChatterBatchWrapper>();
        fItemList.add(fItem);
        //cc_initData.initFeedItem(us.id, acc.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
        cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(fItemList);
        database.executeBatch(batch,1);
       // cc_Util.initChatter(fItem.ParentId, fItem.RelatedRecordId, fItem.Body);
        Test.stopTest();
    }
	
    @isTest
    public static void testUtil2(){
        
        Account acc = cc_initData.initAccount();
        insert acc;
        User us = [select id from user where profile.Name = 'System Administrator' and isactive = true limit 1];
        cc_ChatterBatchWrapper fItem = new cc_ChatterBatchWrapper();
        fItem.idList.add(us.id);
        fItem.recordid = acc.id;
        List<cc_ChatterBatchWrapper> fItemList = new List<cc_ChatterBatchWrapper>();
        fItemList.add(fItem);
        //cc_initData.initFeedItem(us.id, acc.id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
       
        cc_Util.initChatter(fItem.idList.get(0), fItem.recordid, fItem.message);
        Test.stopTest();
    }
    
    @isTest
    public static void testUtil3(){
        cc_setting__c setting = cc_initData.initCustomeSetting();
        insert setting;
        // cc_Profile__c profile = cc_initData.initProfileSetting('Sales Profile', '00e0o000003Ewa5');
        // insert profile;

        String recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId(); 
        Account acc = cc_initData.initAccount();
        acc.RecordTypeId = recordtypeId;
        insert acc;

        QC_Account__c qcAccount0 = cc_initData.initQCAccount();
        qcAccount0.Name = 'testupdate0@abc.com';        
        qcAccount0.QC_Account_Id__c = '0';
        insert qcAccount0;

        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.Name = 'testupdate1@abc.com';
        qcAccount1.AccountOwner__c = acc.id;
        qcAccount1.QC_Account_Id__c = '1';
        insert qcAccount1;
        
        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.Name = 'testupdate2@abc.com';
        qcAccount2.AccountOwner__c = acc.id;
        qcAccount2.QC_Account_Id__c = '2';
        insert qcAccount2;
        
        QC_Account__c qcAccount3 = cc_initData.initQCAccount();
        qcAccount3.Name = 'testupdate3@abc.com';
        qcAccount3.AccountOwner__c = acc.id;
        qcAccount3.QC_Account_Id__c = '3';
        insert qcAccount3;
        
        QC_Account__c qcAccount4 = cc_initData.initQCAccount();
        qcAccount4.Name = 'testupdate4@abc.com';
        qcAccount4.AccountOwner__c = acc.id;
        qcAccount4.QC_Account_Id__c = '4';
        insert qcAccount4;
        QC_Account__c qcAccount5 = cc_initData.initQCAccount();
        qcAccount5.Name = 'testupdate5@abc.com';
        qcAccount5.AccountOwner__c = acc.id;
        qcAccount5.QC_Account_Id__c = '5';
        insert qcAccount5;

        QC_Account__c qcAccount6 = cc_initData.initQCAccount();
        qcAccount6.Name = 'testupdate6@abc.com';
        qcAccount6.AccountOwner__c = acc.id;
        qcAccount6.QC_Account_Id__c = '6';
        insert qcAccount6;
        
        List<QC_Account_Data__c> qcAccountDataList =  cc_initData.initQCAccountData('1', '2', '3', '4','5', '6' ,
                                                             qcAccount1.id, qcAccount2.id,qcAccount3.id,  qcAccount4.id, qcAccount5.id, qcAccount6.id);
        insert qcAccountDataList;

        Relationship__c rel = cc_initData.initRelationship(qcAccount0.Id,acc.Id);
        insert rel;

        String combine = (String)acc.Id + (String)qcAccount1.Id;
        List<String> compileList = new List<String>{combine};        
        Map<string,boolean> maprl = cc_Util.checkRelationship(compileList);

        datetime dtnow = datetime.now().addMonths(-1);
        set<string> strDateSet =  cc_Util.getSetDate(1,5, dtnow.month(), dtnow.year());
        cc_Util.insertQcAccountSpendingReport(strDateSet );
       // cc_initData.initQCAccountData(id qc1, id qc2, id qc3, id qc4,id qc5, id qc6)
    }
    

    @isTest
    public static void testUtil4(){
        String quarter = '4-2020';

        List<String> periods = cc_Util.getPeriodbyQuarter(quarter);

        Map<String,String> headers = new Map<String,String>();
        CalloutLog__c calloutLog = new CalloutLog__c();        
        calloutLog = cc_Util.parseCallOutLog('Update Campaign Callout', '','cc_CampaignHelper', 'asyncCreateCouponsToQC', 'method', 'endpoint', headers, '', 'Token is null or blank', '', UserInfo.getUserId());



        System.assert(calloutLog != null);
        System.assertEquals(3, periods.size());
    }
}