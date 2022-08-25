@istest
public with sharing class MassCreateWithdrawal_Test {
    @istest
    public static void testGenerateWithDrawal(){

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Admin'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;    

        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  
        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );

        CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('balancebervice_v2')
                                                .setUri('https://api.qc.coccoc.com/salesforce/coupons')
                                                .setMethod('GET')
                                                .setTimeout(10000)
                                                .buildAndSave();

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


        List<Payment__c> insertPayment = new List<Payment__c>();
        RecordType rcType = [SELECT id, name FROM recordType WHERE DeveloperName =: PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
        Payment__c payment1 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );       
        payment1.Stage__c = 'Done';        
        insertPayment.add(payment1);
        
        rcType = [SELECT id, name FROM recordType WHERE DeveloperName =: PaymentConstant.RECORDTYPE_STANDARD_PAYMENT];
        Payment__c payment2 =  cc_initData.initPayment(rcType.id,'1258d', qcAccount.id );       
        payment2.Stage__c = 'Done';       
        payment2.Type__c = PaymentConstant.TYPE_COUPON; 
        insertPayment.add(payment2);

        Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258f', qcAccount.id );       
        payment3.Stage__c = 'Done';       
        payment3.Type__c = PaymentConstant.TYPE_COUPON; 
        insertPayment.add(payment3);

        insert insertPayment;

        Test.startTest();
        Set<String> pqcIds = new Set<String>();
        pqcIds.add('1122334455');
        pqcIds.add('123452');

        Test.setMock(HttpCalloutMock.class, new BalanceServiceHttpCalloutMock());
        List<QC_Account__c> scope = [SELECT Id, QC_Account_Id__c , Name, Type__c  FROM QC_Account__c WHERE QC_Account_Id__c IN : pqcIds];
        new MassCreateWithdrawal_Batch(pqcIds, request).execute(null, scope);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    @istest
    public static void testGenerateLogfile(){
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
       
        Test.startTest();
        List<LogFileWrapper.FileWrapper> logs = new List<LogFileWrapper.FileWrapper>();
        LogFileWrapper.FileWrapper log = new LogFileWrapper.FileWrapper();
        log.Id = '123452';
        log.message = 'QC Accounts do not exists in SF';
        logs.add(log);

        LogFileWrapper.FileWrapper log2 = new LogFileWrapper.FileWrapper();
        log2.Id = '123453';
        log2.message = 'QC Account has type is Agency or MCC';
        logs.add(log2); 
        
        List<Mass_Withdrawal_Request__c> scope = [SELECT Id, Name, Status__c, OwnerId FROM Mass_Withdrawal_Request__c WHERE Id = :request.Id];
        new MassCreateWithdrawalLog_Batch(request.Id, logs).execute(null, scope);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}