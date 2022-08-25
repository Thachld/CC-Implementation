@istest
public class cc_KPI_CaculateController_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  

        cc_KPI_Setting__c kpisetting = cc_initData.initKPISetting('ccKPISetting');
        insert kpisetting;

        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();       
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();
        List<Payment__c> listPayment = new List<Payment__c>();
        List<User> urs = new List<User>();
        List<KPI__c> kpis = new List<KPI__c>();
        List<Sale_Spending_Payment__c> sps = new List<Sale_Spending_Payment__c>();


        List<Lead> leads = new List<Lead>();
        List<Opportunity> opps = new List<Opportunity>();
        List<Task> tasks = new List<Task>();
        List<Event> events = new List<Event>();

        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(2), null, 'Game', 'HN',false);
        User u3 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(3), null, 'Game-Special', 'HN',false);
        User u4 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(4), null, 'Local agency HN', 'HN',false);
        User u5 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(5), null, 'Local Agency HN-Special Client', 'HN',false);
        User u6 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(6), null, 'Global Agency', 'HN',false);
        User u7 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(7), null, 'Global Agency', 'HN',true);
        User u8 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(8), null, 'Local Agency HCM', 'HN',false);
        
        urs.add(u1);
        urs.add(u2);
        urs.add(u3);
        urs.add(u4);
        urs.add(u5);
        urs.add(u6);
        urs.add(u7);
        urs.add(u8);

        insert urs;
        
        String clientrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId(); 
        String agencyrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();     

        Account acc1 = cc_initData.initAccount('Batch Account test ' + String.valueOf(1), clientrecordtypeId, 'Local' , 'Airlines');
        Account acc2 = cc_initData.initAccount('Batch Account test ' + String.valueOf(2), clientrecordtypeId, 'Local', 'Real Estate');
        Account acc3 = cc_initData.initAccount('Batch Account test ' + String.valueOf(3), clientrecordtypeId, 'Local', 'Game');
        Account acc4 = cc_initData.initAccount('Batch Account test ' + String.valueOf(4), agencyrecordtypeId, 'Local' , 'Airlines');
        Account acc5 = cc_initData.initAccount('Batch Account test ' + String.valueOf(5), agencyrecordtypeId, 'Global' , 'Airlines');   

        listAcc.add(acc1);
        listAcc.add(acc2);
        listAcc.add(acc3);
        listAcc.add(acc4);
        listAcc.add(acc5);

        insert listAcc;


        String name3 = 'qcAccount' + String.valueOf(1) + String.valueOf(3) + '@qcCococ.com';
        QC_Account__c qcacc1 = cc_initData.initQCAccount(name3, listAcc[0].Id, 'Airlines', false, false, false, urs[0].Id);  

        String name4 = 'qcAccount' + String.valueOf(2) + String.valueOf(4) + '@qcCococ.com';
        QC_Account__c qcacc2 = cc_initData.initQCAccount(name4, listAcc[1].Id, 'Real Estate', false, false, false, urs[0].Id);  

        String name2 = 'qcAccount' + String.valueOf(3) + String.valueOf(2) + '@qcCococ.com';
        QC_Account__c qcacc3 = cc_initData.initQCAccount(name2, listAcc[2].Id, 'Game', false, false, false, urs[1].Id);  

        String name1 = 'qcAccount' + String.valueOf(4) + String.valueOf(1) + '@qcCococ.com';
        QC_Account__c qcacc4 = cc_initData.initQCAccount(name1, listAcc[2].Id, 'Game', false, true, false, urs[2].Id);          

        String name5 = 'qcAccount' + String.valueOf(5) + String.valueOf(5) + '@qcCococ.com';
        QC_Account__c qcacc5 = cc_initData.initQCAccount(name5, listAcc[4].Id, 'Other', true, false, false, urs[6].Id);            
       
        String name6 = 'qcAccount' + String.valueOf(6) + String.valueOf(6) + '@qcCococ.com';
        QC_Account__c qcacc6 = cc_initData.initQCAccount(name6, listAcc[3].Id, 'Other', false, false, true, urs[3].Id);         

        String name7 = 'qcAccount' + String.valueOf(7) + String.valueOf(7) + '@qcCococ.com';
        QC_Account__c qcacc7 = cc_initData.initQCAccount(name7, listAcc[3].Id, 'Other', false, true, false, urs[4].Id);         
        
        String name8 = 'qcAccount' + String.valueOf(8) + String.valueOf(7) + '@qcCococ.com';
        QC_Account__c qcacc8 = cc_initData.initQCAccount(name7, listAcc[3].Id, 'Other', false, false, false, urs[7].Id);         


        listQCAcc.add(qcacc1);
        listQCAcc.add(qcacc2);
        listQCAcc.add(qcacc3);
        listQCAcc.add(qcacc4);
        listQCAcc.add(qcacc5);
        listQCAcc.add(qcacc6);
        listQCAcc.add(qcacc7);
        listQCAcc.add(qcacc8);
        
        insert listQCAcc;       


        

        for(User us: urs){
            Date startDate = today.toStartOfMonth();
            Date endate = startDate.addMonths(1) - 1;
            String SaleKPIrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
            KPI__c kpi = cc_initData.initKPI(us.alias + '-' + period, us.Id, period, startDate, endate, us.KPI_Category__c);
            kpi.RecordTypeId = SaleKPIrecordtypeId;
            kpis.add(kpi);
        }

        insert kpis;


        for(KPI__c kpi : kpis){
            String[] kpicat;
            if(!String.isBlank(kpi.KPI_Category__c)){
                kpicat = kpi.KPI_Category__c.split(';');
            }

            for(String cat: kpicat){
                Sale_Spending_Payment__c saleKPI = new Sale_Spending_Payment__c();                           
                saleKPI.KPI__c = kpi.Id;
                saleKPI.KPI_Category__c = cat;
                saleKPI.Name = cat;                
                sps.add(saleKPI);
            }
        }

        insert sps;


        Integer k = 0;
        for (qc_Account__c qc: listQCAcc){
            Date startDate = today.toStartOfMonth();

            if(k == 0 || k == 1){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency', 'Normal', urs[0].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency','Promo', urs[0].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }else if(k == 2){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency', 'Normal', urs[1].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency','Promo', urs[1].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }else if(k == 3){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency', 'Normal', urs[2].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency','Promo', urs[2].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }else if(k == 4){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Global Agency', 'Normal', urs[6].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Global Agency' ,'Promo', urs[6].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }else if(k == 5){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency', 'Normal', urs[3].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency','Promo', urs[3].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }else if(k == 6){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency', 'Normal', urs[4].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency','Promo', urs[4].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }else if(k == 7){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                        Integer qty = 10 * d;
                        Decimal val = 1000 * d;                
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency', 'Normal', urs[7].Id);
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , qc.Industry__c, 'Local Agency','Promo', urs[7].Id);
                        listQCAccountData.add(dataPromo);
                    }
                }
            }

            k = k + 1;
            
        }

        insert listQCAccountData;


        String Normal_payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Normal_payment').getRecordTypeId(); 
        String Real_Payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Real_Payment').getRecordTypeId();     
        String Standard_payment = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get('Standard_payment').getRecordTypeId();  
        

        Integer h = 0;
        for (qc_Account__c qc: listQCAcc){
            Date startDate = today.toStartOfMonth();
            String transId = 'abcxyz' + String.valueOf(h);

            if(h == 0 || h == 1){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);        
                    
                    Payment__c py = cc_initData.initPayment(Normal_payment, transId, qc.Id, dt, urs[0].Id, qc.Industry__c, 'Local Agency');    
                    listPayment.add(py);
                    
                }
            }else if(h == 2){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d); 

                    Payment__c py = cc_initData.initPayment(Normal_payment, transId, qc.Id, dt, urs[1].Id, qc.Industry__c, 'Local Agency');    
                    listPayment.add(py);
                }
            }else if(h == 3){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);    
                    Payment__c py = cc_initData.initPayment(Real_Payment, transId, qc.Id, dt, urs[2].Id, qc.Industry__c, 'Local Agency') ;   
                    listPayment.add(py);                    
                }
            }else if(h == 4){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d); 
                    Payment__c py = cc_initData.initPayment(Real_Payment, transId, qc.Id, dt, urs[6].Id, qc.Industry__c, 'Global Agency')  ;  
                    listPayment.add(py);  
                                        
                }
            }else if(h == 5){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);    
                    
                    Payment__c py = cc_initData.initPayment(Normal_payment, transId, qc.Id, dt, urs[3].Id, qc.Industry__c, 'Local Agency') ;   
                    listPayment.add(py); 
                }
            }else if(h == 6){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);   
                    
                    Payment__c py = cc_initData.initPayment(Standard_payment, transId, qc.Id, dt, urs[4].Id, qc.Industry__c, 'Local Agency') ;   
                    listPayment.add(py); 

                }
            }else if(h == 7){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d); 
                    
                    Payment__c py = cc_initData.initPayment(Standard_payment, transId, qc.Id, dt, urs[7].Id, qc.Industry__c, 'Local Agency')  ;  
                    listPayment.add(py);                     
                }
            }

            h = h + 1;
            
        }

        insert listPayment;

        User u = urs[0];
        for(Integer i =0; i< 1; i++){
            String web = 'https://cococ' + String.valueOf(i) + '.com.vn';
            Lead ld = cc_initData.initLead(u.id,web);
            leads.add(ld);
        }

        insert leads;

        Account acc = listAcc[0];
        for(Integer i =0; i< 20; i++){
            Opportunity opp = new Opportunity();
            if(i<5){
                opp = cc_initData.initOpportunity(acc.Id, u.Id, 'Closed Won', today + i);
            }else if(i <10){
                opp = cc_initData.initOpportunity(acc.Id, u.Id, 'Closed Lost', today + i);
            }else{
                opp = cc_initData.initOpportunity(acc.Id, u.Id, 'New', today + i);
            }
            
            opps.add(opp);
        }

        insert opps;

        for(Integer i =0; i< 10; i++){
            Task newtk = new Task();

            if(i<5){
                newtk = cc_initData.initTask('Call ' + String.valueOf(i), 'Call', u.Id);
            }else{
                newtk = cc_initData.initTask('Email ' + String.valueOf(i), 'Email', u.Id);
            }

            tasks.add(newtk);
        }

        insert tasks;


        for(Integer i =0; i< 10; i++){
            Event evt = new Event();
            evt = cc_initData.initEvent('Meeting ' + String.valueOf(i), 'Meeting', u.Id);            

            events.add(evt);
        }

        insert events;
    }

    public testmethod static void GlobalAgencyTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User7-' + period;

        KPI__c kpi = [SELECT Id FROM KPI__c WHERE Name = :name LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
        kpictrol.calculateKPI();       
    }   

    public testmethod static void MessageTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User6-' + period;

        KPI__c kpi = [SELECT Id, Status__c, To_Date__c, From_Date__c, Sales__c FROM KPI__c WHERE Name = :name LIMIT 1];
        kpi.Status__c = 'Confirmed';
        update kpi;

        ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
        kpictrol.calculateKPI();   
        
        
        kpi.Status__c = 'New';
        kpi.From_Date__c = null;
        kpi.To_Date__c = null;
        update kpi;

        ApexPages.StandardController sc2 = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol2 = new cc_KPI_CaculateController(sc);
        kpictrol2.calculateKPI();  
       
    } 


    public testmethod static void IndustryTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User1-' + period;

        KPI__c kpi1 = [SELECT Id FROM KPI__c WHERE Name =  :name LIMIT 1];

        ApexPages.StandardController sc1 = new ApexPages.StandardController(kpi1);
        cc_KPI_CaculateController kpictrol1 = new cc_KPI_CaculateController(sc1);
        kpictrol1.calculateKPI();
    }

    public testmethod static void IndustrySpecialTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User2-' + period;

        KPI__c kpi0 = [SELECT Id FROM KPI__c WHERE Name = :name LIMIT 1];

        ApexPages.StandardController sc0 = new ApexPages.StandardController(kpi0);
        cc_KPI_CaculateController kpictrol0 = new cc_KPI_CaculateController(sc0);
        kpictrol0.calculateKPI();

        String name2 = 'User3-' + period;
        KPI__c kpi = [SELECT Id FROM KPI__c WHERE Name = :name2 LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
        kpictrol.calculateKPI();
    }

    public testmethod static void LocalAgencyTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User4-' + period;

        KPI__c kpi = [SELECT Id FROM KPI__c WHERE Name = :name LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
        kpictrol.calculateKPI();
    }
    
    public testmethod static void LocalAgencySpecialTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User5-' + period;

        KPI__c kpi = [SELECT Id FROM KPI__c WHERE Name = :name LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
        kpictrol.calculateKPI();
    }

    
    public testmethod static void LocalAgencyHCMTest(){
        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        String name = 'User8-' + period;

        KPI__c kpi = [SELECT Id FROM KPI__c WHERE Name = :name LIMIT 1];

        ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
        cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
        kpictrol.calculateKPI();
    }

    public testmethod static void testBatchGendile(){
        Test.startTest();
            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;
            String name = 'User4-' + period;

            KPI__c kpi = [SELECT Id FROM KPI__c WHERE Name = :name LIMIT 1];

            ApexPages.StandardController sc = new ApexPages.StandardController(kpi);
            cc_KPI_CaculateController kpictrol = new cc_KPI_CaculateController(sc);
            kpictrol.calculateKPI();

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}