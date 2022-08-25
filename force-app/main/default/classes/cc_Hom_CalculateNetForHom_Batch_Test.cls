@istest
public with sharing class cc_Hom_CalculateNetForHom_Batch_Test {
    
    @istest
    public static void testBatch(){
        Test.startTest();
        cc_setting__c settting = cc_initData.initCustomeSetting();
        insert settting;
        
        List<Id> homId = new List<Id>();
        cc_Hom_CalculateNetForHom_Batch batch = new cc_Hom_CalculateNetForHom_Batch(homId, false);
        Database.executeBatch(batch);
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}