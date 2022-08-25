@istest
public with sharing class cc_ContractLinkHandler_Test {


    @TestSetup
    static void testSetup(){
        cc_setting__c setting = cc_initData.initCustomeSetting();
        insert setting;

        cc_Trigger_Control__c trg = cc_initData.initTrigger('CONTRACTLINK_TRIGGER',true);
        insert trg;

        Date today = System.today();

        String accname = 'Batch Account test';
        Account acc = cc_initData.initAccount(accname);  
        insert acc;

        accname = 'Batch Account test1';
        Account acc1 = cc_initData.initAccount(accname);  
        insert acc1;

        String qcname = 'qcAccount123@qcCococ.com';
        QC_Account__c qcacc = cc_initData.initQCAccount(qcname, acc.Id);          
        insert qcacc;

        qcname = 'qcAccount1234@qcCococ.com';
        QC_Account__c qcacc1 = cc_initData.initQCAccount(qcname, acc.Id);          
        insert qcacc1;

        qcname = 'qcAccount12345@qcCococ.com';
        QC_Account__c qcacc2 = cc_initData.initQCAccount(qcname, acc.Id);          
        insert qcacc2;

        Date startDate = today.toStartOfMonth();        
        Date endDate = startDate.addMonths(5);        
        String type = 'Master - Commitment';
        Contract__c con = cc_initData.initContract(acc.Id, startDate, endDate, type);
        con.Agency_for_signing_direct_Contract__c =  acc1.Id;
        insert con; 

        Relationship__c rl = cc_initData.initRelationship(qcacc.Id, acc.Id);
        insert rl;

        Relationship__c rl2 = cc_initData.initRelationship(qcacc2.Id, acc.Id);
        insert rl2;

        Relationship__c rl1 = cc_initData.initRelationship(qcacc1.Id, acc1.Id);
        insert rl1;
    }
   
    public testmethod static void testinsertHandler(){
        Contract__c testcon = [SELECT Id FROM Contract__c LIMIT 1];
        QC_Account__c testqc = [SELECT Id FROM QC_Account__c WHERE Name = 'qcAccount1234@qcCococ.com' LIMIT 1];

        try{
            Contract_Link__c lk1 = cc_initData.initContractLink(testcon.id, testqc.Id);
            insert lk1;
        }catch (Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('owner not same') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
        
    }


}