@istest
public class cc_KPITargetDetailHandler_Test {
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
        target.Status__c ='Approved';
        insert target;  
        
        

        String mngrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId(); 
        KPI_Target__c mngtarget = cc_initData.initKPITarget('Target Sales Tesst', u9.Id, mngrecordtypeId, quarter);
        mngtarget.Status__c ='Approved'; 
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

    public testmethod static void testInsertTrigger(){
        Test.startTest();
            KPI_Target_Detail__c mngdetail = [SELECT Id, Name, KPI_Target__c, Sale__c,
                                                Period__c, KPI_Category__c, Quarter__c,
                                                SpendingKPI__c, PaymentKPI__c 
                                                FROM KPI_Target_Detail__c WHERE KPITargetType__c = 'Sale_Manager_KPI' LIMIT 1];
            KPI_Target_Detail__c newmg = new KPI_Target_Detail__c();

            newmg.Name = mngdetail.Name;
            newmg.KPI_Target__c = mngdetail.KPI_Target__c;
            newmg.Sale__c = mngdetail.Sale__c;
            newmg.Period__c = mngdetail.Period__c;
            newmg.KPI_Category__c = mngdetail.KPI_Category__c;       
            newmg.Quarter__c = mngdetail.Quarter__c;
            newmg.SpendingKPI__c = 333; 
            newmg.PaymentKPI__c = 555;

            insert newmg;

            KPI_Target_Detail__c saledetail = [SELECT Id, Name, KPI_Target__c, Sale__c,
                                                Period__c, KPI_Category__c, Quarter__c,
                                                SpendingKPI__c, PaymentKPI__c  
                                                FROM KPI_Target_Detail__c WHERE KPITargetType__c = 'Sale_KPI' LIMIT 1];
            
            KPI_Target_Detail__c newsale = new KPI_Target_Detail__c();
            newsale.Name = saledetail.Name;
            newsale.KPI_Target__c = saledetail.KPI_Target__c;
            newsale.Sale__c = saledetail.Sale__c;
            newsale.Period__c = saledetail.Period__c;
            newsale.KPI_Category__c = saledetail.KPI_Category__c;       
            newsale.Quarter__c = saledetail.Quarter__c;
            newsale.SpendingKPI__c = 333; 
            newsale.PaymentKPI__c = 555;

            insert newsale;

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    public testmethod static void testupdateTrigger(){
        Test.startTest();
            KPI_Target_Detail__c mngdetail = [SELECT Id, SpendingKPI__c, PaymentKPI__c FROM KPI_Target_Detail__c WHERE KPITargetType__c = 'Sale_Manager_KPI' LIMIT 1];
            mngdetail.SpendingKPI__c = 333; 
            mngdetail.PaymentKPI__c = 555;

            update mngdetail;

            KPI_Target_Detail__c saledetail = [SELECT Id, SpendingKPI__c, PaymentKPI__c FROM KPI_Target_Detail__c WHERE KPITargetType__c = 'Sale_KPI' LIMIT 1];
            saledetail.SpendingKPI__c = 222; 
            saledetail.PaymentKPI__c = 444;

            update saledetail;

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }
}