@istest
public class cc_ManualSyncKPITargetController_Test {
    @TestSetup    
    static void testSetup(){
        List<User> urs = new List<User>();
        List<KPI__c> kpis = new List<KPI__c>();
        list<KPI_Target__c> targets = new List<KPI_Target__c>();
        list<KPI_Target_Detail__c> details = new List<KPI_Target_Detail__c>();
        List<Sale_Spending_Payment__c> sps = new List<Sale_Spending_Payment__c>();

        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  

        cc_Trigger_Control__c trg = cc_initData.initTrigger('KPITARGET_TRIGGER',true);
        insert trg;


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
        User us1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);  
        User u9 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(8), null,
                                         'Airlines;Real Estate;Game', 'HN',false);
        
        insert us1;        
        insert u9;

        String kpisalerecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String kpimngrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 
        Date startDate = today.toStartOfMonth();
        Date endate = startDate.addMonths(1) - 1;
        KPI__c kpi = cc_initData.initKPI(us1.alias + '-' + period, us1.Id, period, startDate, endate, us1.KPI_Category__c, u9.Id, kpisalerecordtypeId );            
        insert kpi;

        KPI__c mngkpi = cc_initData.initKPI(u9.alias + '-' + period, u9.Id, period, startDate, endate, u9.KPI_Category__c, u9.Id, kpimngrecordtypeId );
        insert mngkpi;
        
        String salerecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        KPI_Target__c target = cc_initData.initKPITarget('Target Sales Tesst', u9.Id, salerecordtypeId, quarter);
        insert target;  
        
        

        String mngrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 
        KPI_Target__c mngtarget = cc_initData.initKPITarget('Target Manager Sales Tesst', u9.Id, mngrecordtypeId, quarter);
        insert mngtarget;
        

        String[] kpicat;
        if(!String.isBlank(us1.KPI_Category__c)){
            kpicat = us1.KPI_Category__c.split(';');
        }

        for(String cat: kpicat){
            KPI_Target_Detail__c detail = cc_initData.initKPITargetdetail(us1.Alias, us1.Id, target.Id, quarter, period, cat);
            Sale_Spending_Payment__c sp = cc_initData.initSaleSpendingPayment(cat + '-' + period + 'test' , kpi.Id, cat);
            sps.add(sp);
            details.add(detail);
        }
        

        String[] mngkpicat;
        if(!String.isBlank(u9.KPI_Category__c)){
            mngkpicat = u9.KPI_Category__c.split(';');
        }

        for(String cat: mngkpicat){
            KPI_Target_Detail__c mngdetail = cc_initData.initKPITargetdetail(u9.Alias, u9.Id, mngtarget.Id, quarter, period, cat);
            details.add(mngdetail);

            Sale_Spending_Payment__c sp = cc_initData.initSaleSpendingPayment('MNG' + cat + '-' + period + 'test' , mngkpi.Id, cat);
            sps.add(sp);
        }

        insert details;
        insert sps;

    }


    public testMethod static void TestGetKPItargets(){

        KPI_Target__c kpi = [SELECT Id FROM KPI_Target__c  WHERE Name = 'Target Sales Tesst' LIMIT 1];
        List<KPI_Target_Detail__c> kpitargetdetails = new List<KPI_Target_Detail__c>();


        kpitargetdetails = cc_ManualSyncKPITargetController.getKPItargetDetails(kpi.Id);


        KPI_Target__c kpi1 = [SELECT Id FROM KPI_Target__c  WHERE Name = 'Target Manager Sales Tesst' LIMIT 1];
        List<KPI_Target_Detail__c> kpitargetdetails1 = new List<KPI_Target_Detail__c>();

        kpitargetdetails1 = cc_ManualSyncKPITargetController.getKPItargetDetails(kpi1.Id);

    }


    public testMethod static void TestSyncSaleKPItargets(){

        KPI_Target__c salekpi = [SELECT Id FROM KPI_Target__c WHERE Name = 'Target Sales Tesst' LIMIT 1 ];
        List<KPI_Target_Detail__c> kpitargetdetails = new List<KPI_Target_Detail__c>();
        kpitargetdetails = [SELECT Id FROM KPI_Target_Detail__c WHERE KPI_Target__c= :salekpi.Id ];

        System.debug('kpitargetdetails=>' + kpitargetdetails.size());
        Boolean rs = cc_ManualSyncKPITargetController.syncKpiTarget(kpitargetdetails, salekpi.Id);
        
    }


    public testMethod static void TestSyncSaleManagerKPItargets(){

        KPI_Target__c salekpi = [SELECT Id FROM KPI_Target__c WHERE Name = 'Target Manager Sales Tesst' LIMIT 1 ];
        List<KPI_Target_Detail__c> kpitargetdetails = new List<KPI_Target_Detail__c>();
        kpitargetdetails = [SELECT Id FROM KPI_Target_Detail__c WHERE KPI_Target__c= :salekpi.Id ];

        System.debug('kpitargetdetails=>' + kpitargetdetails.size());
        Boolean rs = cc_ManualSyncKPITargetController.syncKpiTarget(kpitargetdetails, salekpi.Id);
        
    }
}