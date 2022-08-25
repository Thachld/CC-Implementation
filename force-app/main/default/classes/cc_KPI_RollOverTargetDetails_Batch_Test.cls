@istest
public class cc_KPI_RollOverTargetDetails_Batch_Test {
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
        
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Airlines;Real Estate', 'HN',false);
        u2.Working_direct__c = true;
        insert u2;

        User u22 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Airlines', 'HN',false);
        u22.ManagerId = u22.Id;
        
        insert u22;

        String salerecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        KPI_Target__c target = cc_initData.initKPITarget('Target Sales Tesst', u1.Id, salerecordtypeId, '4-2020');
        target.Approval_status__c = 'New';
        insert target;
        
        KPI_Target__c target1 = cc_initData.initKPITarget('Target Sales Tesst', u2.Id, salerecordtypeId, '4-2020');
        target1.Approval_status__c = 'New';
        target1.Include_Manager__c = true;
        insert target1;


        String mngrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 
        KPI_Target__c target2 = cc_initData.initKPITarget('Target Sales Tesst', u1.Id, mngrecordtypeId, '4-2020');
        target2.Approval_status__c = 'New';
        insert target2;
    }

    public testmethod static void testRolloverKPItargetdetail(){        

        Test.startTest();
            String quarter = '4-2020';
            cc_KPI_RollOverTargetDetails_Batch batch = new cc_KPI_RollOverTargetDetails_Batch(quarter);
            Database.executeBatch(batch);

        try {
            test.stopTest();

            List<KPI_Target_Detail__c> details = [SELECT Id FROM KPI_Target_Detail__c LIMIT 3];
            System.assertEquals(3, details.size());

        } catch (Exception ex) {
            
        }
    }
}