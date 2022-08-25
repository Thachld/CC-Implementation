@istest(seeallData=true)
public with sharing class cc_GetBalanceController_Test {
   
    @istest
    public static void testGetBlance(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where name =: cc_static_Message.Payment_RecordType_Refund];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );            
            payment3.Is_Withdraw_from_QC__c = true;

            insert payment3;            

            ApexPages.StandardController sc = new ApexPages.StandardController(payment3);
            cc_GetBalanceController getbl = new cc_GetBalanceController(sc);
            getbl.getBalance();
            getbl.getBalanceinfo();


        Test.stopTest();
    }

    @istest
    public static void testNegativeGetBlance(){       
        User u = [SELECT Id,Name FROM User Where Profile.Name = 'Sales Profile' and IsActive=true LIMIT 1];     
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.Auto_Confirm_Weekend__c = true;
        qcAccount.QC_Account_Id__c = '1122334455';
        qcAccount.Need_Approval__c = false;       
        qcAccount.Real_Money_Balance__c = null;
        insert qcAccount;
        
        RecordType rcType ;
        rcType = [select Id, Name FROM recordType where name =: cc_static_Message.Payment_RecordType_Refund];
        Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );            
        payment3.Is_Withdraw_from_QC__c = true;
        insert payment3;

        Test.startTest();
        System.runAs(u){
            ApexPages.StandardController sc = new ApexPages.StandardController(payment3);
            cc_GetBalanceController getbl = new cc_GetBalanceController(sc);
            getbl.getBalance();                
            // System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));            
        }
        Test.stopTest();
    }
}