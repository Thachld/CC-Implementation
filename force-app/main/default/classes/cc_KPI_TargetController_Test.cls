@istest
public class cc_KPI_TargetController_Test {
    @TestSetup
    static void testSetup(){
        List<User> urs = new List<User>();
        List<KPI__c> kpis = new List<KPI__c>();
        list<KPI_Target__c> targets = new List<KPI_Target__c>();
        list<KPI_Target_Detail__c> details = new List<KPI_Target_Detail__c>();

        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;       
        String quarter = '';
        if( today.month() > = 1 && today.month() <=3 ){
            quarter = '1-' + year;
        }else if( today.month() > = 4 && today.month() <=7 ){
            quarter = '2-' + year;
        }else if( today.month() > = 8 && today.month() <=10 ){
            quarter = '3-' + year;
        }else{
            quarter = '4-' + year;
        } 


        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Game', 'HN',false);
        User u3 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(3), null, 'Game-Special', 'HN',false);
        User u4 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(4), null, 'Local agency HN', 'HN',false);
        User u5 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(5), null, 'Local Agency HN-Special Client', 'HN',false);
        User u6 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(6), null, 'Global Agency', 'HN',false);
        User u7 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(7), null, 'Global Agency', 'HN',true);
        User u8 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(8), null, 'Local Agency HCM', 'HN',false);

        User u9 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(8), null,
                                         'Local Agency HCM;Airlines;Real Estate;Game;Game-Special;Local agency HN;Local Agency HN-Special Client;Global Agency', 'HN',false);
        
        
        urs.add(u1);
        urs.add(u2);
        urs.add(u3);
        urs.add(u4);
        urs.add(u5);
        urs.add(u6);
        urs.add(u7);
        urs.add(u8);       

        insert urs;        
        insert u9;

        String kpisalerecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String kpimngrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 
        Date startDate = today.toStartOfMonth();
        Date endate = startDate.addMonths(1) - 1;
        for(User us: urs){            
            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c, u9.Id, kpisalerecordtypeId );
            kpis.add(kpi);
        }
        KPI__c mngkpi = cc_initData.initKPI(u9.alias + '-' + period, u9.Id, period, startDate, endate, u9.KPI_Category__c, u9.Id, kpimngrecordtypeId );
        kpis.add(mngkpi);

        insert kpis;

        
        String salerecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        KPI_Target__c target = cc_initData.initKPITarget('Target Sales Tesst', u9.Id, salerecordtypeId, quarter);
        insert target;        

        String mngrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 
        KPI_Target__c mngtarget = cc_initData.initKPITarget('Target Sales Tesst', u9.Id, mngrecordtypeId, quarter);
        insert mngtarget;

        for(User us: urs){            
            String[] kpicat;
            if(!String.isBlank(us.KPI_Category__c)){
                kpicat = us.KPI_Category__c.split(';');
            }

            for(String cat: kpicat){
                KPI_Target_Detail__c detail = cc_initData.initKPITargetdetail(us.Alias, us.Id, target.Id, quarter, period, cat);
                details.add(detail);
            }
        }

        String[] kpicat;
        if(!String.isBlank(u9.KPI_Category__c)){
            kpicat = u9.KPI_Category__c.split(';');
        }

        for(String cat: kpicat){
            KPI_Target_Detail__c mngdetail = cc_initData.initKPITargetdetail(u9.Alias, u9.Id, mngtarget.Id, quarter, period, cat);
            details.add(mngdetail);
        }

        insert details;

    }


    public testmethod static void testPicklist(){
        List<cc_KPI_TargetController.PickListWraper> cats = cc_KPI_TargetController.getCategoryPicklistDB();

        System.assert(cats.size() > 0);
    }

    public testmethod static void testGettargetDetail(){
        KPI_Target__c target = [SELECT Id FROM KPI_Target__c WHERE Name = 'Target Sales Tesst' LIMIT 1];

        List<KPI_Target_Detail__c> testRS = cc_KPI_TargetController.getKPIDetailsDB(target.Id);

        System.assertEquals(9, testRS.size());
    }

    public testmethod static void testSavetargetDetail(){
        KPI_Target__c target = [SELECT Id FROM KPI_Target__c WHERE Name = 'Target Sales Tesst' LIMIT 1];

        List<KPI_Target_Detail__c> testRS = cc_KPI_TargetController.getKPIDetailsDB(target.Id);
        cc_KPI_TargetController.saveKPITargetdetaislDB(testRS);

        KPI_Target_Detail__c detail = [SELECT Id, Sale__c, Month__c, KPI_Category__c, 
                                        SpendingKPI__c, PaymentKPI__c, Sale__r.Name , Sale__r.Trac_Name__c, CurrencyIsoCode 
                                        FROM KPI_Target_Detail__c LIMIT 1];

        detail.SpendingKPI__c = 450;
        
        KPI_Target_Detail__c testDetail = cc_KPI_TargetController.saveKPITargetdetailDB(detail);

        System.assertEquals(450, testDetail.SpendingKPI__c);
    }

    public testmethod static void testDeletetargetDetail(){
        KPI_Target_Detail__c detail = [SELECT Id, Sale__c, Month__c, KPI_Category__c, 
                                        SpendingKPI__c, PaymentKPI__c, Sale__r.Name , Sale__r.Trac_Name__c, CurrencyIsoCode 
                                        FROM KPI_Target_Detail__c LIMIT 1];        
        
        cc_KPI_TargetController.deleteKPITargetdetaiDB(detail.Id);

    }
}