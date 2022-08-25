@istest
public class cc_KPI_Calculation_MngKPI_Batch_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;         
        cc_KPI_Setting__c kpisetting = cc_initData.initKPISetting('ccKPISetting');
        insert kpisetting;

        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;

        List<User> urs = new List<User>();
        List<Sale_Spending_Payment__c> listSps = new List<Sale_Spending_Payment__c>();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(0), null, 'Airlines;Real Estate;Global Agency', 'HN',false);
        u0.Manager_level__c = 'Level 1';
        insert u0;

        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate;Global Agency', 'HN',false);
        u1.ManagerId = u0.Id;    
        u1.Manager_level__c = 'Level 2';
        insert u1;


        User u11 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Airlines;Real Estate;Global Agency-Non Xaxis', 'HN',false);
        u11.ManagerId = u1.Id;
        u11.Manager_level__c = 'Level 3';
        insert u11;

        User u111 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(3), null, 'Global Agency-Non Xaxis', 'HN',false);        
        u111.ManagerId = u11.Id;
        insert u111;

        User u112 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(4), null, 'Global Agency-Xaxis', 'HN',false);        
        u112.ManagerId = u1.Id;
        insert u112;


        Date startDate = today.toStartOfMonth();
        Date endate = startDate.addMonths(1) - 1;
        String salerecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String MngrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId();    
        
        KPI__c kpi0 = cc_initData.initKPI(u0.alias + '-' + period, u0.Id, period, startDate, endate, u0.KPI_Category__c, u0.Id, MngrecordtypeId);    
        insert kpi0;

        Sale_Spending_Payment__c sp01 = cc_initData.initSaleSpendingPayment('Real Estate', kpi0.Id, 'Real Estate');
        listSps.add(sp01);
        Sale_Spending_Payment__c sp02 = cc_initData.initSaleSpendingPayment('Airlines', kpi0.Id, 'Airlines');
        listSps.add(sp02);
        Sale_Spending_Payment__c sp03 = cc_initData.initSaleSpendingPayment('Global Agency', kpi0.Id, 'Global Agency');
        listSps.add(sp03);

        KPI__c kpi1 = cc_initData.initKPI(u1.alias + '-' + period, u1.Id, period, startDate, endate, u1.KPI_Category__c, u0.Id, MngrecordtypeId);    
        kpi1.Sale_Manager_KPI__c = kpi0.Id;
        insert kpi1;

        Sale_Spending_Payment__c sp11 = cc_initData.initSaleSpendingPayment('Real Estate', kpi1.Id, 'Real Estate');
        listSps.add(sp11);
        Sale_Spending_Payment__c sp12 = cc_initData.initSaleSpendingPayment('Airlines', kpi1.Id, 'Airlines');
        listSps.add(sp12);
        Sale_Spending_Payment__c sp13 = cc_initData.initSaleSpendingPayment('Global Agency', kpi1.Id, 'Global Agency');
        listSps.add(sp13);


        KPI__c kpi11 = cc_initData.initKPI(u11.alias + '-' + period, u11.Id, period, startDate, endate, u11.KPI_Category__c, u1.Id, MngrecordtypeId);    
        kpi11.Sale_Manager_KPI__c = kpi11.Id;
        insert kpi11;

        Sale_Spending_Payment__c sp111 = cc_initData.initSaleSpendingPayment('Real Estate', kpi11.Id, 'Real Estate');
        listSps.add(sp111);
        Sale_Spending_Payment__c sp112 = cc_initData.initSaleSpendingPayment('Airlines', kpi11.Id, 'Airlines');
        listSps.add(sp112);
       

        KPI__c salekpi11 = cc_initData.initKPI(u11.alias + '-' + period, u11.Id, period, startDate, endate, u11.KPI_Category__c, u11.Id, salerecordtypeId);    
        salekpi11.Sale_Manager_KPI__c = kpi11.Id;
        insert salekpi11;

        Sale_Spending_Payment__c sp1111 = cc_initData.initSaleSpendingPayment('Real Estate', salekpi11.Id, 'Real Estate');
        listSps.add(sp1111);
        Sale_Spending_Payment__c sp1112 = cc_initData.initSaleSpendingPayment('Airlines', salekpi11.Id, 'Airlines');
        listSps.add(sp1112);


        KPI__c kpi111 = cc_initData.initKPI(u111.alias + '-' + period, u111.Id, period, startDate, endate, u111.KPI_Category__c, u11.Id, salerecordtypeId);
            kpi111.Sale_Manager_KPI__c = kpi11.Id;
        insert kpi111;
        Sale_Spending_Payment__c sp11111 = cc_initData.initSaleSpendingPayment('Global Agency-Non Xaxis', kpi111.Id, 'Global Agency-Non Xaxis');
        listSps.add(sp11111);


        KPI__c kpi112 = cc_initData.initKPI(u112.alias + '-' + period, u112.Id, period, startDate, endate, u112.KPI_Category__c, u1.Id, salerecordtypeId);
        kpi112.Sale_Manager_KPI__c = kpi1.Id;
        insert kpi112;  
        
        Sale_Spending_Payment__c sp11121 = cc_initData.initSaleSpendingPayment('Global Agency-Xaxis', kpi112.Id, 'Global Agency-Xaxis');
        listSps.add(sp11121);

        insert listSps;

    }

    public testmethod static void testcalculationRollup(){
        Test.startTest();
            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            cc_KPI_Calculation_MngKPI_Batch batch = new cc_KPI_Calculation_MngKPI_Batch(period);
            Database.executeBatch(batch);

        try {
            test.stopTest();

        } catch (Exception ex) {
            
        }
    }
}