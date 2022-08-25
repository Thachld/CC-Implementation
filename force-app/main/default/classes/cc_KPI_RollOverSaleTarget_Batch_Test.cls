@istest
public class cc_KPI_RollOverSaleTarget_Batch_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  

        List<User> urs = new List<User>();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        User u11 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines', 'HN',false);
        u11.ManagerId = u1.Id;
        
        insert u11;
    }

    public testmethod static void testRolloverKPItarget(){        

        Test.startTest();
            String quarter = '4-2020';
            cc_KPI_RollOverSaleTarget_Batch batch = new cc_KPI_RollOverSaleTarget_Batch(quarter);
            Database.executeBatch(batch);

        try {
            test.stopTest();

            List<KPI_Target__c> targets = [SELECT Id FROM KPI_Target__c LIMIT 1];
            System.assertEquals(1, targets.size());

        } catch (Exception ex) {
            
        }
    }
}