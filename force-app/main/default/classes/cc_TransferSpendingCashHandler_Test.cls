@istest
public class cc_TransferSpendingCashHandler_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  
        cc_Trigger_Control__c trg = cc_initData.initTrigger('TRANSFERDATA_TRIGGER',true);
        insert trg;
        
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
    }

   
    public testMethod static void testTriggerHandler(){

        Test.startTest();
            Date today = System.today();    
            List<QC_Account_data__c>  updatedatas = new List<QC_Account_data__c>();
            List<Payment__c>  updatepys = new List<Payment__c>();
            User fromus = [SELECT Id FROM User WHERE lastName = 'User1' LIMIT 1];
            User tous = [SELECT Id FROM User WHERE lastName = 'User2' LIMIT 1];

            QC_Account__c qcacc = [SELECT Id,Sales__c FROM QC_Account__c WHERE Name = 'qcAccount13@qcCococ.com' LIMIT 1];
            for(QC_Account_data__c data: [SELECT Id, Sale__c FROM QC_Account_data__c WHERE QC_Account__c=: qcacc.Id]){
                data.Sale__c = fromus.Id;
                updatedatas.add(data);
            }
            update updatedatas;

            for(Payment__c py: [SELECT Id, Sale__c FROM Payment__c WHERE QC_Account__c=: qcacc.Id]){
                py.Sale__c = fromus.Id;
                updatepys.add(py);
            }
            update updatepys;
            

            TransferSpendingCash__c rq = cc_initData.initTransferSpendingCash('test request', fromus.Id, tous.Id, today-30, today-1, TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA , TransferRequestConstant.TRANSFER_TYPE_SALE,'Spending;Payment'); 
            rq.Transfer_Immediately__c = true;   
            insert rq;           

            Transfer_Account__c tfacc = new Transfer_Account__c();
            tfacc.Transfer_Request__c = rq.Id;
            tfacc.QC_Account__c = qcacc.Id;
            insert tfacc;

            rq.Approval_Status__c = 'New';
            update rq;

            rq.Approval_Status__c = 'Approved';
            update rq;
        try {
            Test.stopTest();

            QC_Account_Data__c testqcdata = [SELECT Id , Sale__c FROM QC_Account_Data__c WHERE QC_Account__c =: qcacc.Id LIMIT 1];
            Payment__c testpydata = [SELECT Id , Sale__c FROM Payment__c WHERE QC_Account__c =: qcacc.Id LIMIT 1];

            System.assertEquals(tous.Id, testqcdata.Sale__c);
            System.assertEquals(tous.Id, testpydata.Sale__c);
        } catch (Exception ex) {
            
        }
        
        
    }

    public testMethod static void testBulkTriggerHandler(){
        User fromus = [SELECT Id FROM User WHERE lastName = 'User1' LIMIT 1];
        User tous = [SELECT Id FROM User WHERE lastName = 'User2' LIMIT 1];

        Test.startTest();
            
            Date today = System.today();    
            
            
            List<QC_Account__c> qctoInsert = new List<QC_Account__c>();
            
            Account acc = [SELECT Id FROM Account LIMIT 1];
            for(Integer i= 0; i<200 ; i++){
                String name = 'qcAccount' + String.valueOf(i) + String.valueOf(i+1) + '@qcCococ.test.com';
                QC_Account__c qcacc = cc_initData.initQCAccount(name, acc.Id, 'Airlines', false, false, false, fromus.Id);
                qcacc.OwnerId = fromus.Id;

                qctoInsert.add(qcacc);
            }
            
            insert qctoInsert; 
            
            List<TransferSpendingCash__c> requests = new List<TransferSpendingCash__c>();
            for(Integer i= 0; i< 200 ; i++){
                TransferSpendingCash__c rq = cc_initData.initTransferSpendingCash('test request transfer Owner', fromus.Id, tous.Id, today-30, today-1, TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_OWNER, '' ,'');            
                rq.Transfer_Immediately__c = false;
                rq.Status__c = TransferRequestConstant.STATUS_NEW;
                rq.Approval_Status__c = TransferRequestConstant.APPROVAL_STATUS_SENT; 
                rq.Schedule_Transfer_Date__c = Date.today();           
                requests.add(rq);
            }

            insert requests; 


            List<Transfer_Account__c> tfaccs = new List<Transfer_Account__c>();
            for(Integer i= 0; i<200 ; i++){
                Transfer_Account__c tfacc = new Transfer_Account__c();
                tfacc.Transfer_Request__c = requests[i].Id;
                tfacc.QC_Account__c = qctoInsert[i].Id;
                tfaccs.add(tfacc);
            }

            insert tfaccs;

            List<TransferSpendingCash__c> updateRq = new List<TransferSpendingCash__c>();
            for(TransferSpendingCash__c rq : [SELECT Id, Approval_Status__c FROM TransferSpendingCash__c]){
                rq.Approval_Status__c = TransferRequestConstant.APPROVAL_STATUS_APPROVED;
                updateRq.add(rq);
            }

            update updateRq;
           
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
        
        
    }
}