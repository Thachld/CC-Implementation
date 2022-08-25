@istest
public with sharing class BalanceServiceHelper_Test {
    @istest
    public static void testGetBalance(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());

            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                .setName('balancebervice_v2')
                                .setUri('https://api.qc.coccoc.com/salesforce/balance')
                                .setMethod('GET')
                                .setTimeout(10000)
                                .buildAndSave();


            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where name =: cc_static_Message.Payment_RecordType_Refund];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );            
            payment3.Type__c = PaymentConstant.TYPE_WITHDRAWAL_INCOME;

            insert payment3;
            Set<String> testIds = new Set<String>();
            testIds.add(payment3.Id);

            BalanceServiceHelper.attemptgetBalanceService(testIds);

        Test.stopTest();

    }
}