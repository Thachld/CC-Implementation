@istest
public class cc_HOM_Controller_Test {
    @TestSetup
    static void testSetup(){    
        Test.startTest();
            cc_setting__c ccSetting = cc_initData.initCustomeSetting();
            insert ccSetting;   

            Account acc = cc_initData.initAccount('Test Account');
            insert acc;

            Account acc1 = cc_initData.initAccount('Test Account1');
            insert acc1;

            QC_Account__c qcAccount = cc_initData.initQCAccount('Test QC Account' , acc.Id);       
            insert qcAccount;

            HandOver_Minute__c hom = cc_initData.initHandOverMinute(acc.Id, null, null, null);
            hom.Status__c = 'Confirm';
            insert hom;       
            
                 

            RecordType rcType ;
            rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Real_Payment];
            Payment__c payment5 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment5.Final_Amount__c = 100;
            payment5.Stage__c = 'Done';
            payment5.HandOver_Minutes__c = hom.Id; 
            insert payment5;
            
            Payment__c payment6 =  cc_initData.initPayment(rcType.id,'1234562c', qcAccount.Id );         
            payment6.Final_Amount__c = 500;
            payment6.Stage__c = 'Done';
            payment6.HandOver_Minutes__c = hom.Id; 

            insert payment6;

        Test.stopTest();

    }

    public testMethod static void TestGetHOMs(){
        Payment__c testPY = [SELECT Id FROM Payment__c WHERE Name = '1234562d' LIMIT 1];

        List<cc_HOM_Controller.HOMwraper> result= cc_HOM_Controller.getHOMbyQcAccountDB(testPY.Id);

        System.assertEquals(1, result.size());
    }

    public testMethod static void TestSavePayment(){

        Account testacc = [SELECT Id FROM Account WHERE Name = 'Test Account1'];
        HandOver_Minute__c hom2 = cc_initData.initHandOverMinute(testacc.Id, null, null, null);
        insert hom2;  

        Payment__c PY = [SELECT Id FROM Payment__c WHERE Name = '1234562d' LIMIT 1];

        cc_HOM_Controller.savePaymentDB(PY.Id, hom2.Id);


        Payment__c testPY = [SELECT Id, HandOver_Minutes__c FROM Payment__c WHERE Id =: PY.Id LIMIT 1];

        System.assertEquals(hom2.Id, testPY.HandOver_Minutes__c);

    }
}