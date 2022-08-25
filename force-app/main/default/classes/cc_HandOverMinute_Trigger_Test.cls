@isTest
public class cc_HandOverMinute_Trigger_Test {
      
    
    @TestSetup
    static void testSetup(){
        cc_setting__c setting = cc_initData.initCustomeSetting();
        insert setting;

        cc_Trigger_Control__c trg = cc_initData.initTrigger('HOM_TRIGGER',true);
        insert trg;

        String accname = 'Batch Account test';
        Account acc = cc_initData.initAccount(accname);  
        insert acc;

        String accname1 = 'Batch Account test 1';
        Account acc1 = cc_initData.initAccount(accname1);  
        insert acc1;


        Date startDate = System.today().toStartOfMonth();        
        Date endDate = startDate.addMonths(5);        
        String type = 'Master - Commitment';
        Contract__c con = cc_initData.initContract(acc.Id, startDate, endDate, type);
        insert con;    

        
        String type1 = 'Master - No Commitment';
        Contract__c con1 = cc_initData.initContract(acc1.Id, startDate, endDate, type1);
        insert con1;    
    }

    public testMethod static void testInsertMisingContractHOM(){

        try {
            Date startDate = System.today().toStartOfMonth();     
            Account acc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Batch Account test' LIMIT 1];
            HandOver_Minute__c hom = cc_initData.initHandOverMinute(acc.Id, null, startDate, startDate + 30); 
            insert hom;

        }catch (Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Select Contract') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    public testMethod static void testInsertWrongContractHOM(){

        try {
            Date startDate = System.today().toStartOfMonth();     
            Account acc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Batch Account test' LIMIT 1 ];
            Contract__c con = [SELECT Id FROM Contract__c WHERE Type__c = 'Master - No Commitment' LIMIT 1];

            HandOver_Minute__c hom = cc_initData.initHandOverMinute(acc.Id, con.Id, startDate, startDate + 30); 
            insert hom;

        }catch (Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('belong to') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }

    
    public testMethod static void updateMissingContractHOM(){   
        Date startDate = System.today().toStartOfMonth();     

        Account testacc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Batch Account test' LIMIT 1];
        Contract__c testcon = [SELECT Id, OwnerId,Current_Coupon__c, Previous_Coupon__c FROM Contract__c WHERE Type__c = 'Master - Commitment' LIMIT 1];

        HandOver_Minute__c hom = cc_initData.initHandOverMinute(testacc.Id, testcon.Id, startDate, startDate + 30); 
        insert hom;

        HandOver_Minute__c testHOM = [SELECT Id, OwnerId,Assign_to__c FROM HandOver_Minute__c LIMIT 1];

        testHOM.Custom_Contract__c = null;
        try {
           update testHOM;

        }catch (Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Select Contract') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

    }

    
    public testMethod static void updateWrongContractHOM(){   
        Date startDate = System.today().toStartOfMonth();     

        Account testacc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Batch Account test' LIMIT 1];
        Contract__c testcon = [SELECT Id, OwnerId,Current_Coupon__c, Previous_Coupon__c FROM Contract__c WHERE Type__c = 'Master - Commitment' LIMIT 1];

        Contract__c testcon1 = [SELECT Id, OwnerId,Current_Coupon__c, Previous_Coupon__c FROM Contract__c WHERE Type__c = 'Master - No Commitment' LIMIT 1];

        HandOver_Minute__c hom = cc_initData.initHandOverMinute(testacc.Id, testcon.Id, startDate, startDate + 30); 
        insert hom;

        HandOver_Minute__c testHOM = [SELECT Id, OwnerId,Assign_to__c FROM HandOver_Minute__c LIMIT 1];

        testHOM.Custom_Contract__c = testcon1.Id;
        try {
           update testHOM;

        }catch (Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('belong to') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

    }

    public testMethod static void updateHOM(){   
        Date startDate = System.today().toStartOfMonth();     

        Account testacc = [SELECT Id, OwnerId FROM Account WHERE Name = 'Batch Account test' LIMIT 1];
        Contract__c testcon = [SELECT Id, OwnerId,Current_Coupon__c, Previous_Coupon__c FROM Contract__c WHERE Type__c = 'Master - Commitment' LIMIT 1];

        HandOver_Minute__c hom = cc_initData.initHandOverMinute(testacc.Id, testcon.Id, startDate, startDate + 30); 
        insert hom;

        HandOver_Minute__c testHOM = [SELECT Id, OwnerId,Assign_to__c FROM HandOver_Minute__c LIMIT 1];

        System.assertEquals(testacc.OwnerId, testHOM.OwnerId);
        //System.assert(!String.isBlank(testHOM.Assign_to__c));
        //2021.06.23 removed by Toan Nguyen
        //reason: Logic was removed from Trigger
        /*
        testcon.Current_Coupon__c  = 10;
        testcon.Previous_Coupon__c  = 0;
        update testcon;
        System.debug('Previous_Coupon__c => ' + testcon.Previous_Coupon__c);
        System.debug('Current_Coupon__c => ' + testcon.Current_Coupon__c);

        testHOM.Status__c = 'Received';       
        update testHOM;

        Contract__c updatecon = [SELECT Id, Current_Coupon__c, Previous_Coupon__c FROM Contract__c WHERE Type__c = 'Master - Commitment' LIMIT 1];

        System.debug('Previous_Coupon__c => ' + updatecon.Previous_Coupon__c);
        System.debug('Current_Coupon__c => ' + updatecon.Current_Coupon__c);

        System.assertEquals(updatecon.Previous_Coupon__c, updatecon.Current_Coupon__c);
		*/
    }
}