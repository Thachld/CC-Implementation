@istest
public with sharing class MassCreateWithdrawal_Controller_Test {
    @istest
    public static void testReadfile(){
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Admin'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;    

        Mass_Withdrawal_Request__c request =  new Mass_Withdrawal_Request__c();        
        request.Default_Note__c =  'Test mass withdrawal';
        request.Effective_Date__c =  Datetime.now();
        request.Name =  'Test mass withdrawal';
        request.Note__c =  'Test ';
        request.Refund_Type__c =  PaymentConstant.REFUND_TYPE_INTERNAL_REFUND;
        request.Status__c =  'New';
        request.Assignee__c = u1.Id;
        insert request;

        String csvRFColumnHeader = 'userId, userEmail \n';
        List<String> csvRowValues = new List<String>();
        for(Integer i = 0 ; i< 50 ; i ++){
            String logRow = '1234' + String.valueOf(i) + ',' + 'testmasswithdrawal' + String.valueOf(i) + '@coccoc.com.test';
            csvRowValues.add(logRow);
        }

        cc_initData.insertCSVtoAttachfile('filedata', request.Id, csvRFColumnHeader, csvRowValues);


        Test.startTest();
            ContentDocumentLink docLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :request.Id];
            Contentversion  file = [SELECT Id FROM Contentversion WHERE ContentDocumentId = :docLink.ContentDocumentId AND FileType = 'CSV' AND IsLatest = true LIMIT 1];

            ApexPages.StandardController sc = new ApexPages.StandardController(request);
            MassCreateWithdrawal_Controller getbl = new MassCreateWithdrawal_Controller(sc);
            getbl.selectedfileId = file.Id;
            getbl.loadFile();       
        Test.stopTest();

    }

    @istest 
    public static void testGetFileSelection(){
        List<QC_Account__c> listqcAccount = new List<QC_Account__c>();
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Admin'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;  

        Mass_Withdrawal_Request__c request =  new Mass_Withdrawal_Request__c();        
        request.Default_Note__c =  'Test mass withdrawal';
        request.Effective_Date__c =  Datetime.now();
        request.Name =  'Test mass withdrawal';
        request.Note__c =  'Test ';
        request.Refund_Type__c =  PaymentConstant.REFUND_TYPE_INTERNAL_REFUND;
        request.Status__c =  'New';
        request.Assignee__c = u1.Id;
        insert request;

        String csvRFColumnHeader = 'userId, userEmail \n';
        List<String> csvRowValues = new List<String>();
        for(Integer i = 0 ; i< 50 ; i ++){
            String logRow = '1234' + String.valueOf(i) + ',' + 'testmasswithdrawal' + String.valueOf(i) + '@coccoc.com.test';
            csvRowValues.add(logRow);
        } 

        cc_initData.insertCSVtoAttachfile('filedata', request.Id, csvRFColumnHeader, csvRowValues);

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(request);
            MassCreateWithdrawal_Controller getbl = new MassCreateWithdrawal_Controller(sc);
            getbl.getFiles(request.Id);       
        Test.stopTest();

    }


    @istest
    public static void testMassConfirm(){
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Admin'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;    

        Mass_Withdrawal_Request__c request =  new Mass_Withdrawal_Request__c();        
        request.Default_Note__c =  'Test mass withdrawal';
        request.Effective_Date__c =  Datetime.now();
        request.Name =  'Test mass withdrawal';
        request.Note__c =  'Test ';
        request.Refund_Type__c =  PaymentConstant.REFUND_TYPE_INTERNAL_REFUND;
        request.Status__c =  'New';
        request.Assignee__c = u1.Id;
        insert request;

        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.Auto_Confirm_Weekend__c = true;
        qcAccount.QC_Account_Id__c = '1122334455';
        qcAccount.Need_Approval__c = false;       
        qcAccount.Real_Money_Balance__c = null;
        insert qcAccount;

        String refundRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_REFUND_PAYMENT).getRecordTypeId(); 
        Payment__c payment3 =  cc_initData.initPayment(refundRecordTypeId,'1234562d', qcAccount.id ); 
        payment3.Type__c = PaymentConstant.TYPE_WITHDRAWAL_INCOME;
        payment3.Mass_Withdrawal_Request__c = request.Id;
        payment3.Stage__c = 'New';
        insert payment3;

        Payment__c payment4 =  cc_initData.initPayment(refundRecordTypeId,'1234562d', qcAccount.id ); 
        payment4.Type__c = PaymentConstant.TYPE_WITHDRAWAL_COUPON;
        payment4.Mass_Withdrawal_Request__c = request.Id;
        payment4.Stage__c = 'New';
        insert payment4;

        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(request);
            MassCreateWithdrawal_Controller getbl = new MassCreateWithdrawal_Controller(sc);
            getbl.massConfirm();       
        Test.stopTest();

    }
}