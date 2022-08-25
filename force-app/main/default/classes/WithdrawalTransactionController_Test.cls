@istest
public with sharing class WithdrawalTransactionController_Test {
    @TestSetup
    static void testSetup(){        

        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
        CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                            .setName('balancebervice_v2')
                            .setUri('https://api.qc.coccoc.com/salesforce/balance')
                            .setMethod('GET')
                            .setTimeout(10000)
                            .buildAndSave();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        QC_Account__c qcAccount = cc_initData.initQCAccount();       
        qcAccount.OwnerId = u1.Id;
        qcAccount.Sales__c = u1.Id;
        qcAccount.QC_Account_Id__c = '1122334455';
        insert qcAccount;

        RecordType rcType ;
        rcType = [SELECT id, name FROM recordType WHERE DeveloperName =: PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
        Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );  
        payment3.Stage__c = PaymentConstant.STAGE_DONE;
        payment3.Name = '1258e';          
        insert payment3;


        rcType = [SELECT id, name FROM recordType WHERE DeveloperName =: PaymentConstant.RECORDTYPE_REFUND_PAYMENT];
        Payment__c payment4 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id ); 
        payment4.Stage__c = PaymentConstant.STAGE_NEW;
        payment4.Withdrawal_Payment__c = payment3.Id;
        payment4.Withdrawal_From_TransId__c = '1258e';
        payment4.Final_Amount__c = 4700000;
        insert payment4;
    }

    
    public static testMethod void testPositiveConfirmWithdraw(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());

        Payment__c py = [SELECT Id, Withdrawal_Payment__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];

        Boolean result = WithdrawalTransactionController.confirmPayment(py.Id);


        Payment__c testpy = [SELECT Id, Withdrawal_Payment__c, Stage__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];

        System.assertEquals(PaymentConstant.STAGE_DONE, testpy.Stage__c);

        Test.stopTest();
    }


    public static testMethod void testNegativeConfirmWithdraw1(){
        

        Payment__c py = [SELECT Id, Withdrawal_Payment__c,Withdrawal_From_TransId__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
        py.Withdrawal_From_TransId__c = null;
        update py;
        Exception capturedException;

        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
            Boolean result = WithdrawalTransactionController.confirmPayment(py.Id);

        } catch (Exception ex) {
            capturedException= ex;
            System.debug('ex.getMessage()' + ex.getMessage());
            System.debug('capturedException=>' + capturedException);
            System.assertNotEquals(null, capturedException, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals(Label.NotExistsWithdrawalTransd, capturedException.getMessage(), 'Specific error message is expected');

            Payment__c testpy = [SELECT Id, Withdrawal_Payment__c, Stage__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
            System.assertEquals(PaymentConstant.STAGE_NEW, testpy.Stage__c);
        }        

        Test.stopTest();
    }

    public static testMethod void testNegativeConfirmWithdraw2(){
        

        Payment__c py = [SELECT Id, Withdrawal_Payment__c, Final_Amount__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
        py.Final_Amount__c = 4900000;
        update py;
        Exception capturedException;

        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
            Boolean result = WithdrawalTransactionController.confirmPayment(py.Id);

        } catch (Exception ex) {
            capturedException= ex;
            System.debug('ex.getMessage()' + ex.getMessage());
            System.debug('capturedException=>' + capturedException);
            System.assertNotEquals(null, capturedException, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals(Label.BalanceIsnotEnough, capturedException.getMessage(), 'Specific error message is expected');

            Payment__c testpy = [SELECT Id, Withdrawal_Payment__c, Stage__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
            System.assertEquals(PaymentConstant.STAGE_NEW, testpy.Stage__c);
        }
        

        

        Test.stopTest();
    }

    public static testMethod void testNegativeConfirmWithdraw3(){
        

        Payment__c py = [SELECT Id, Withdrawal_Payment__c, Final_Amount__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
        py.Final_Amount__c = 4900000;
        update py;
        Exception capturedException;

        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new FailedBalanceServiceHttpCalloutMock());
            Boolean result = WithdrawalTransactionController.confirmPayment(py.Id);

        } catch (Exception ex) {
            capturedException= ex;
            System.debug('ex.getMessage()' + ex.getMessage());
            System.debug('capturedException=>' + capturedException);
            System.assertNotEquals(null, capturedException, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals(Label.BalanceIsZero, capturedException.getMessage(), 'Specific error message is expected');

            Payment__c testpy = [SELECT Id, Withdrawal_Payment__c, Stage__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
            System.assertEquals(PaymentConstant.STAGE_NEW, testpy.Stage__c);
        }
        

        

        Test.stopTest();
    }

    public static testMethod void testNegativeConfirmWithdraw4(){

        Payment__c py = [SELECT Id, Withdrawal_Payment__c, Final_Amount__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
        py.Final_Amount__c = 4900000;
        update py;
        Exception capturedException;

        try {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new NoBalanceServiceHttpCalloutMock());
            Boolean result = WithdrawalTransactionController.confirmPayment(py.Id);

        } catch (Exception ex) {
            capturedException= ex;
            System.debug('ex.getMessage()' + ex.getMessage());
            System.debug('capturedException=>' + capturedException);
            System.assertNotEquals(null, capturedException, 'Exception should be thrown');
            System.assertEquals(AuraHandledException.class.getName(), capturedException.getTypeName(), 'AuraHandledException is expected');
            System.assertEquals(Label.NoBalance, capturedException.getMessage(), 'Specific error message is expected');

            Payment__c testpy = [SELECT Id, Withdrawal_Payment__c, Stage__c FROM Payment__c WHERE Name = '1234562d' LIMIT 1];
            System.assertEquals(PaymentConstant.STAGE_NEW, testpy.Stage__c);
        }
        

        Test.stopTest();
    }


    public static testMethod void testcreateWithdrawalRequest(){
        Test.startTest();

        User u1 = [SELECT Id FROM User WHERE FirstName = '' LIMIT 1];

        QC_Account__c qcAccount = cc_initData.initQCAccount();       
        qcAccount.OwnerId = u1.Id;
        qcAccount.Sales__c = u1.Id;
        qcAccount.QC_Account_Id__c = '1122334456';
        insert qcAccount;

        QC_Account__c testqc = [SELECT Id FROM QC_Account__c LIMIT 1];

        Payment__c avdpy = [SELECT Id, Withdrawal_Payment__c, Final_Amount__c FROM Payment__c WHERE Name = '1258e' LIMIT 1];
        
        Id refundRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_REFUND_PAYMENT).getRecordTypeId();   
        WithdrawalTransactionController.PaymentWrapper withrawalrequest = new WithdrawalTransactionController.PaymentWrapper();
        withrawalrequest.recordtypeid =  refundRecordTypeId;
        withrawalrequest.allowcreate = true;        
        withrawalrequest.withdrawalfromqc = 'Yes';
        withrawalrequest.assignee = u1.Id;
        withrawalrequest.qcaccountid = testqc.Id;

        List<WithdrawalTransactionController.WithdrawalPaymentWrapper> wdPayments = new List<WithdrawalTransactionController.WithdrawalPaymentWrapper>();
        WithdrawalTransactionController.WithdrawalPaymentWrapper wdPayment = new WithdrawalTransactionController.WithdrawalPaymentWrapper();
        wdPayment.transid = '1258e';
        wdPayment.balance = 10;
        wdPayment.amount = 10;
        wdPayment.name = 'Test Withdrawal';
        wdPayment.note = 'Test Withdrawal Note';
        wdPayment.type = 'INCOME';
        wdPayment.pyid = avdpy.Id;
        wdPayment.iscreatetransfer = true;
        wdPayment.transfertouserid = qcAccount.Id;
        wdPayment.transfername = 'Auto Transfer';
        wdPayment.refundtype = PaymentConstant.REFUND_TYPE_REFUND_FOR_TRANSFER;

        wdPayments.add(wdPayment);

        List<Payment__c> result = WithdrawalTransactionController.createWithdrawalRequest(withrawalrequest, wdPayments);


        System.assertEquals(1, result.size());

        Test.stopTest();

    }
}