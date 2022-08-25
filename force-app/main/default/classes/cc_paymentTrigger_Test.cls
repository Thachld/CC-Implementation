@isTest
public class cc_paymentTrigger_Test {
	@isTest
     public static void testQCAccount(){
     	Test.startTest();
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
		 QC_Account__c qcAccount = cc_initData.initQCAccount();
         insert qcAccount;
          QC_Account__c qcAccount1 = cc_initData.initQCAccount();
         qcAccount1.Is_Standard__c = true;
         insert qcAccount1;
        
         RecordType rcType ;
         rcType = [select id, name from recordType where name = 'Standard payment'];
         Payment__c payment =  cc_initData.initPayment(rcType.id,'1234561d', qcAccount.id );
         insert payment;
         payment.isApproval__c = 1;
         update payment;
         rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Real_Payment];
         Payment__c payment1 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount1.id );
         payment1.Stage__c = 'Done';
         payment1.Real_Money_Type__c = 'Pay Dept';
         insert payment1;
         Payment__c payment2 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount1.id );
         payment2.Real_Money_Type__c = 'Income';
         payment2.Stage__c = 'New';
         insert payment2;
         payment2.Stage__c = 'Done';
         update payment2;
         
         Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount1.id );
         payment3.Real_Money_Type__c = 'Pay Dept';
         payment3.Stage__c = 'New';
         insert payment3;
         payment3.Stage__c = 'Done';
         update payment3;
         
		 rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_BankTransfer];
         Payment__c payment4 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount1.id );
         payment4.Real_Money_Type__c = 'Pay Dept';
         payment4.Stage__c = 'New';
         insert payment4;
         payment4.Stage__c = 'Done';
         update payment4;
         
         Test.stopTest();
     }
}