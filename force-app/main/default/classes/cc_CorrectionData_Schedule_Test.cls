@istest
public class cc_CorrectionData_Schedule_Test {
    
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;          
        
        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();       
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();
        List<Payment__c> listPayment = new List<Payment__c>();
        List<User> urs = new List<User>();    
        
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
        qcacc1.Support__c = urs[0].Id;

        String name4 = 'qcAccount' + String.valueOf(2) + String.valueOf(4) + '@qcCococ.com';
        QC_Account__c qcacc2 = cc_initData.initQCAccount(name4, listAcc[1].Id, 'Real Estate', false, false, false, urs[0].Id);  
        qcacc2.Support__c = urs[0].Id;

        String name2 = 'qcAccount' + String.valueOf(3) + String.valueOf(2) + '@qcCococ.com';
        QC_Account__c qcacc3 = cc_initData.initQCAccount(name2, listAcc[2].Id, 'Game', false, false, false, urs[1].Id);  
        qcacc3.Support__c = urs[0].Id;

        String name1 = 'qcAccount' + String.valueOf(4) + String.valueOf(1) + '@qcCococ.com';
        QC_Account__c qcacc4 = cc_initData.initQCAccount(name1, listAcc[2].Id, 'Game', false, true, false, urs[2].Id);          
        qcacc4.Support__c = urs[0].Id;

        String name5 = 'qcAccount' + String.valueOf(5) + String.valueOf(5) + '@qcCococ.com';
        QC_Account__c qcacc5 = cc_initData.initQCAccount(name5, listAcc[4].Id, 'Other', true, false, false, urs[6].Id);            
        qcacc5.Support__c = urs[1].Id;

        String name6 = 'qcAccount' + String.valueOf(6) + String.valueOf(6) + '@qcCococ.com';
        QC_Account__c qcacc6 = cc_initData.initQCAccount(name6, listAcc[3].Id, 'Other', false, false, true, urs[3].Id);         
        qcacc6.Support__c = urs[1].Id;

        String name7 = 'qcAccount' + String.valueOf(7) + String.valueOf(7) + '@qcCococ.com';
        QC_Account__c qcacc7 = cc_initData.initQCAccount(name7, listAcc[3].Id, 'Other', false, true, false, urs[4].Id);         
        qcacc7.Support__c = urs[1].Id;

        String name8 = 'qcAccount' + String.valueOf(8) + String.valueOf(7) + '@qcCococ.com';
        QC_Account__c qcacc8 = cc_initData.initQCAccount(name7, listAcc[3].Id, 'Other', false, false, false, urs[7].Id);         
        qcacc8.Support__c = urs[1].Id;

        listQCAcc.add(qcacc1);
        listQCAcc.add(qcacc2);
        listQCAcc.add(qcacc3);
        listQCAcc.add(qcacc4);
        listQCAcc.add(qcacc5);
        listQCAcc.add(qcacc6);
        listQCAcc.add(qcacc7);
        listQCAcc.add(qcacc8);
        
        insert listQCAcc;   

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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , 'Normal');
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , 'Normal');
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , 'Normal');
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,null, dtime, val, qty , 'Normal');

                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty, 'Normal');
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , 'Normal');
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , 'Normal');
                        listQCAccountData.add(datanormal);
                    }else{
                        Integer qty = 20 * d;
                        Decimal val = 1500 * d;        
    
                        QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
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
                    
                    Payment__c py = cc_initData.initPayment(Normal_payment, transId, qc.Id, dt, null, null, null);    
                    listPayment.add(py);
                    
                }
            }else if(h == 2){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d); 

                    Payment__c py = cc_initData.initPayment(Normal_payment, transId, qc.Id, dt, null, null, null);    
                    listPayment.add(py);
                }
            }else if(h == 3){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);    
                    Payment__c py = cc_initData.initPayment(Real_Payment, transId, qc.Id, dt, null, null, null);    
                    listPayment.add(py);                    
                }
            }else if(h == 4){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d); 
                    Payment__c py = cc_initData.initPayment(Real_Payment, transId, qc.Id, dt, null, null, null);    
                    listPayment.add(py);  
                                        
                }
            }else if(h == 5){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);    
                    
                    Payment__c py = cc_initData.initPayment(Normal_payment, transId, qc.Id, dt, null, null, null);      
                    listPayment.add(py); 
                }
            }else if(h == 6){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d);   
                    
                    Payment__c py = cc_initData.initPayment(Standard_payment, transId, qc.Id, dt, null, null, null);    
                    listPayment.add(py); 

                }
            }else if(h == 7){
                for(Integer d = 0; d < 5; d++){
                    Date dt = startDate.addDays(d); 
                    
                    Payment__c py = cc_initData.initPayment(Standard_payment, transId, qc.Id, dt, null, null, null);    
                    listPayment.add(py);                     
                }
            }

            h = h + 1;            
        }

        insert listPayment;

    }

    public testMethod static void testShedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('CorrectionData_Schedule_Test', CRON_EXP, new cc_CorrectionData_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }

    public testMethod static void testPaymentBatch(){
        Test.startTest();
            Date todt = System.today();
            Date fromdt = todt-30;
            cc_Payment_CorrectionData_Batch batch = new cc_Payment_CorrectionData_Batch(fromdt, todt);
            
            Database.executeBatch(batch, 200);

        try {
            Test.stopTest();

            List<Payment__c> fultestPys = [SELECT Id
                                        FROM Payment__c 
                                        WHERE Stage__c = 'Done'];

            List<Payment__c> testPys = [SELECT Id
                                        FROM Payment__c 
                                        WHERE (Sale__c = '' OR Industry__c = '' OR Agency__c = '')
                                            AND Stage__c = 'Done'];

            System.assertEquals(0, testPys.size());       
            System.debug('fultestPys =>' + fultestPys.size());                            

        } catch (Exception ex) {
            
        }
        
    }   

    public testMethod static void testSpendingBatch(){
        Test.startTest();
            Date todt = System.today();
            Date fromdt = todt-30;
            cc_Spending_CorrectionData_Batch batch = new cc_Spending_CorrectionData_Batch(fromdt, todt);
            
            Database.executeBatch(batch, 200);

        try {
            Test.stopTest();

            List<QC_Account_data__c> testData = [SELECT Id
                                                    FROM QC_Account_data__c 
                                                    WHERE (Sale__c = '' OR Industry__c = '' OR Agency__c = '' OR Accounts__c = '' OR Support__c = '')];

            System.assertEquals(0, testData.size());                           

        } catch (Exception ex) {
            
        }
    }
}