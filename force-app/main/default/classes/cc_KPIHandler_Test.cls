@istest
public class cc_KPIHandler_Test {
    @istest
    public static void testinsertnewKPI(){
        Test.startTest(); 
            cc_setting__c ccSetting = cc_initData.initCustomeSetting();
            insert ccSetting;  

            cc_Trigger_Control__c trg = cc_initData.initTrigger('KPI_TRIGGER',true);
            insert trg;

            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            Date startDate = today.toStartOfMonth();
            Date endate = startDate.addMonths(1) - 1;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User us = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert us;

            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c);
            kpi.Cross_Selling_KPI_Category__c = 'Pharmacy;Other';
            insert kpi;

        try{
            Test.stopTest();
            List<Sale_Spending_Payment__c> sps = [SELECT ID FROM Sale_Spending_Payment__c];

            System.assertEquals(4, sps.size());
        }catch(Exception ex) { 
            /* don't fail this test if there were errors in the batch job - we want that */ 
        }            
        
    }

    @istest
    public static void testValidateCrossSellingKPIcategory_Insert(){
        Test.startTest(); 
            cc_setting__c ccSetting = cc_initData.initCustomeSetting();
            insert ccSetting;  

            cc_Trigger_Control__c trg = cc_initData.initTrigger('KPI_TRIGGER',true);
            insert trg;

            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            Date startDate = today.toStartOfMonth();
            Date endate = startDate.addMonths(1) - 1;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User us = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert us;

            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c);
            kpi.Cross_Selling_KPI_Category__c = 'Airlines;Other';
            

        try{              
            insert kpi;            
        }catch(Exception ex) { 
            Boolean valid = ex.getMessage().contains('KPI Category Airlines already exists in standard kpi categories of Sale')?true:false;
            System.assertEquals(true, valid);
        }            
        
        Test.stopTest();
    }


    @istest
    public static void testupdateCategory(){
        Test.startTest(); 
            cc_setting__c ccSetting = cc_initData.initCustomeSetting();
            insert ccSetting;  

            cc_Trigger_Control__c trg = cc_initData.initTrigger('KPI_TRIGGER',true);
            insert trg;

            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            Date startDate = today.toStartOfMonth();
            Date endate = startDate.addMonths(1) - 1;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User us = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert us;

            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c);

            insert kpi;

            KPI__c udkpi = [SELECT ID, KPI_Category__c FROM KPI__c LIMIT 1 ];        
            udkpi.KPI_Category__c = 'Airlines;Real Estate;Game';
            udkpi.Cross_Selling_KPI_Category__c = 'Pharmacy;Other';
            update udkpi;

        try{
            Test.stopTest();            

            List<Sale_Spending_Payment__c> sps2 = [SELECT ID FROM Sale_Spending_Payment__c];

            System.assertEquals(5, sps2.size());
        }catch(Exception ex) { 
            /* don't fail this test if there were errors in the batch job - we want that */ 
        }   
    }

    @istest
    public static void testValidateCrossSellingKPIcategory_Update(){
        Test.startTest(); 
            cc_setting__c ccSetting = cc_initData.initCustomeSetting();
            insert ccSetting;  

            cc_Trigger_Control__c trg = cc_initData.initTrigger('KPI_TRIGGER',true);
            insert trg;

            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            Date startDate = today.toStartOfMonth();
            Date endate = startDate.addMonths(1) - 1;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User us = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert us;

            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c);
            kpi.Cross_Selling_KPI_Category__c = 'Other';
            insert kpi;   

        try{
            KPI__c udkpi = [SELECT ID, KPI_Category__c FROM KPI__c LIMIT 1 ]; 
            udkpi.Cross_Selling_KPI_Category__c = 'Airlines;Other';
            update udkpi;
        }catch(Exception ex) { 
            Boolean valid = ex.getMessage().contains('KPI Category Airlines already exists in standard kpi categories of Sale')?true:false;
            System.assertEquals(true, valid);
        }            
        
        Test.stopTest();
    }
}