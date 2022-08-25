@istest
public class cc_KPI_ManagerKPITeamMember_Sch_Test {
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

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(0), null, 'All', 'HN',false);
        insert u0;

        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        User u11 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines', 'HN',false);
        u11.ManagerId = u1.Id;

        insert u11;

        User u12 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Real Estate', 'HN',false);        
        
        insert u12;


        Date startDate = today.toStartOfMonth();
        Date endate = startDate.addMonths(1) - 1;
        String salerecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String MngrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId();    
        
        KPI__c kpi = cc_initData.initKPI(u1.alias + '-' + period, u1.Id, period, startDate, endate, u1.KPI_Category__c, u1.Id, MngrecordtypeId);    
        insert kpi;

        KPI__c kpi0 = cc_initData.initKPI(u1.alias + '-' + period, u1.Id, period, startDate, endate, u1.KPI_Category__c, u1.Id, salerecordtypeId);    
        insert kpi0;

        KPI__c kpi1 = cc_initData.initKPI(u11.alias + '-' + period, u11.Id, period, startDate, endate, u1.KPI_Category__c, u1.ManagerId, salerecordtypeId);
        kpi1.Sale_Manager_KPI__c = kpi.Id;
        insert kpi1;

        KPI__c kpi2 = cc_initData.initKPI(u12.alias + '-' + period, u12.Id, period, startDate, endate, u1.KPI_Category__c, u1.Id, salerecordtypeId);
        kpi2.Sale_Manager_KPI__c = kpi1.Id;
        insert kpi2;       

    }

    public testmethod static void testKPITeammember(){        

        Test.startTest();
            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            cc_KPI_ManagerKPITeamMember_Batch batch = new cc_KPI_ManagerKPITeamMember_Batch(period);
            Database.executeBatch(batch);

        try {
            test.stopTest();

            // List<KPI__c> kpis = [SELECT Id FROM KPI__c LIMIT 3];
            // System.assertEquals(3, kpis.size());

        } catch (Exception ex) {
            
        }
    }

    public testmethod static void testKPITeammemberSchedule(){        

        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('ManagerKPITeamMember_Test', CRON_EXP, new cc_KPI_ManagerKPITeamMember_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }
    

    public testmethod static void testKPITeammemberSchedule2(){        

        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('ManagerKPITeamMember2_Test', CRON_EXP, new cc_KPI_MngKPITeamMember_MonthLy_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }
    
}