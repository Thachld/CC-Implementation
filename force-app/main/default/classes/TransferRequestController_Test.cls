@istest
public with sharing class TransferRequestController_Test {
    @TestSetup
    static void makeData(){
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
        urs.add(u1);
        urs.add(u2); 

        Profile pfsp = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u3 = cc_initData.initUser(pfsp.Id, 'Support' ,' User' + String.valueOf(3), null, 'Airlines;Real Estate', 'HN',false);
        User u4 = cc_initData.initUser(pfsp.Id, 'Support' ,' User' + String.valueOf(4), null, 'Game', 'HN',false);  
        
        urs.add(u3);
        urs.add(u4); 

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
        qcacc1.Support__c =  urs[2].Id; 

        String name4 = 'qcAccount' + String.valueOf(2) + String.valueOf(4) + '@qcCococ.com';
        QC_Account__c qcacc2 = cc_initData.initQCAccount(name4, listAcc[1].Id, 'Real Estate', false, false, false, urs[0].Id);  
        qcacc2.Support__c =  urs[2].Id; 

        String name2 = 'qcAccount' + String.valueOf(3) + String.valueOf(2) + '@qcCococ.com';
        QC_Account__c qcacc3 = cc_initData.initQCAccount(name2, listAcc[2].Id, 'Game', false, false, false, urs[0].Id);  
        qcacc3.Support__c =  urs[2].Id; 

        String name1 = 'qcAccount' + String.valueOf(4) + String.valueOf(1) + '@qcCococ.com';
        QC_Account__c qcacc4 = cc_initData.initQCAccount(name1, listAcc[2].Id, 'Game', false, true, false, urs[0].Id);  
        qcacc4.Support__c =  urs[2].Id;         

        String name5 = 'qcAccount' + String.valueOf(5) + String.valueOf(5) + '@qcCococ.com';
        QC_Account__c qcacc5 = cc_initData.initQCAccount(name5, listAcc[4].Id, 'Other', true, false, false, urs[0].Id);    
        qcacc5.Support__c =  urs[2].Id;         
       
        String name6 = 'qcAccount' + String.valueOf(6) + String.valueOf(6) + '@qcCococ.com';
        QC_Account__c qcacc6 = cc_initData.initQCAccount(name6, listAcc[3].Id, 'Other', false, false, true, urs[0].Id);  
        qcacc6.Support__c =  urs[2].Id;        

        String name7 = 'qcAccount' + String.valueOf(7) + String.valueOf(7) + '@qcCococ.com';
        QC_Account__c qcacc7 = cc_initData.initQCAccount(name7, listAcc[3].Id, 'Other', false, true, false, urs[0].Id);
        qcacc7.Support__c =  urs[2].Id;          
        
        String name8 = 'qcAccount' + String.valueOf(8) + String.valueOf(7) + '@qcCococ.com';
        QC_Account__c qcacc8 = cc_initData.initQCAccount(name7, listAcc[3].Id, 'Other', false, false, false, urs[0].Id);  
        qcacc8.Support__c =  urs[2].Id;        


        listQCAcc.add(qcacc1);
        listQCAcc.add(qcacc2);
        listQCAcc.add(qcacc3);
        listQCAcc.add(qcacc4);
        listQCAcc.add(qcacc5);
        listQCAcc.add(qcacc6);
        listQCAcc.add(qcacc7);
        listQCAcc.add(qcacc8);
        
        insert listQCAcc;   

        TransferSpendingCash__c rq = cc_initData.initTransferSpendingCash('test request transfer Owner', urs[0].Id, urs[1].Id, today-30, today-1, TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_OWNER, '' ,'');            
        rq.Transfer_Immediately__c =false; 
        rq.Schedule_Transfer_Date__c = Date.today().addDays(1);           
        insert rq; 
        Transfer_Account__c tfacc = new Transfer_Account__c();
        tfacc.Transfer_Request__c = rq.Id;
        tfacc.QC_Account__c = listQCAcc[0].Id;
        insert tfacc;


        TransferSpendingCash__c rq2 = cc_initData.initTransferSpendingCash('test request transfer Ads Op', urs[2].Id, urs[3].Id, today-30, today-1, TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_ADS_OP, '' ,'');            
        rq2.Transfer_Immediately__c =false;    
        rq2.Schedule_Transfer_Date__c = Date.today().addDays(1);        
        insert rq2;  

        Transfer_Account__c tfacc1 = new Transfer_Account__c();
        tfacc1.Transfer_Request__c = rq2.Id;
        tfacc1.QC_Account__c = listQCAcc[0].Id;
        insert tfacc1;

        TransferSpendingCash__c rq3 = cc_initData.initTransferSpendingCash('test request transfer Data1', urs[1].Id, urs[0].Id, today-30, today-1, TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA, TransferRequestConstant.TRANSFER_TYPE_SALE ,'Spending');            
        rq3.Transfer_Immediately__c =false;  
        rq3.Schedule_Transfer_Date__c = Date.today().addDays(1);          
        insert rq3;  

        Transfer_Account__c tfacc2 = new Transfer_Account__c();
        tfacc2.Transfer_Request__c = rq3.Id;
        tfacc2.QC_Account__c = listQCAcc[0].Id;
        insert tfacc2;


        TransferSpendingCash__c rq4 = cc_initData.initTransferSpendingCash('test request transfer Data2', urs[3].Id, urs[2].Id, today-30, today-1, TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA, TransferRequestConstant.TRANSFER_TYPE_SUPPORT ,'Spending');            
        rq4.Transfer_Immediately__c =false;    
        rq4.Schedule_Transfer_Date__c = Date.today().addDays(1);        
        insert rq4;  

        Transfer_Account__c tfacc3 = new Transfer_Account__c();
        tfacc3.Transfer_Request__c = rq4.Id;
        tfacc3.QC_Account__c = listQCAcc[0].Id;
        insert tfacc3;
        
    }

    public static testMethod void testgetQCAccount(){

        Test.startTest();
            List<String> exceptIds = new List<String>();
            TransferSpendingCash__c testrq = [SELECT Id FROM TransferSpendingCash__c LIMIT 1];
            for(Transfer_Account__c tfacc: [SELECT Id,QC_Account__c FROM Transfer_Account__c WHERE Transfer_request__c = :testrq.Id]){
                exceptIds.add(tfacc.QC_Account__c);
            }

            List<QC_Account__c> result = TransferRequestController.getQCAccounts(testrq.Id, '' , exceptIds);
            System.assertEquals(7, result.size());

        Test.stopTest();

    }

    public static testMethod void testgetQCAccountByRequest1(){

        Test.startTest();
            List<String> exceptIds = new List<String>();
            TransferSpendingCash__c testrq = [SELECT Id FROM TransferSpendingCash__c WHERE Transfer_purpose__c= :TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_OWNER LIMIT 1];
            for(Transfer_Account__c tfacc: [SELECT Id,QC_Account__c FROM Transfer_Account__c WHERE Transfer_request__c = :testrq.Id]){
                exceptIds.add(tfacc.QC_Account__c);
            }

            List<QC_Account__c> result = TransferRequestController.getQCAccountByRequest(testrq.Id);
            System.assertEquals(7, result.size());

        Test.stopTest();

    }

    public static testMethod void testgetQCAccountByRequest2(){

        Test.startTest();
            List<String> exceptIds = new List<String>();
            TransferSpendingCash__c testrq = [SELECT Id FROM TransferSpendingCash__c WHERE Transfer_purpose__c= :TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_ADS_OP LIMIT 1];
            for(Transfer_Account__c tfacc: [SELECT Id,QC_Account__c FROM Transfer_Account__c WHERE Transfer_request__c = :testrq.Id]){
                exceptIds.add(tfacc.QC_Account__c);
            }

            List<QC_Account__c> result = TransferRequestController.getQCAccountByRequest(testrq.Id);
            System.assertEquals(7, result.size());

        Test.stopTest();

    }

    public static testMethod void testgetQCAccountByRequest3(){

        Test.startTest();
            List<String> exceptIds = new List<String>();
            TransferSpendingCash__c testrq = [SELECT Id FROM TransferSpendingCash__c 
                                                WHERE Transfer_purpose__c= :TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA 
                                                AND Transfer_Type__c =: TransferRequestConstant.TRANSFER_TYPE_SALE  LIMIT 1];
            for(Transfer_Account__c tfacc: [SELECT Id,QC_Account__c FROM Transfer_Account__c WHERE Transfer_request__c = :testrq.Id]){
                exceptIds.add(tfacc.QC_Account__c);
            }

            List<QC_Account__c> result = TransferRequestController.getQCAccountByRequest(testrq.Id);
            System.assertEquals(7, result.size());

        Test.stopTest();

    }

    public static testMethod void testgetQCAccountByRequest4(){

        Test.startTest();
            List<String> exceptIds = new List<String>();
            TransferSpendingCash__c testrq = [SELECT Id FROM TransferSpendingCash__c 
                                                WHERE Transfer_purpose__c= :TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA 
                                                AND Transfer_Type__c =: TransferRequestConstant.TRANSFER_TYPE_SUPPORT  LIMIT 1];
            for(Transfer_Account__c tfacc: [SELECT Id,QC_Account__c FROM Transfer_Account__c WHERE Transfer_request__c = :testrq.Id]){
                exceptIds.add(tfacc.QC_Account__c);
            }

            List<QC_Account__c> result = TransferRequestController.getQCAccountByRequest(testrq.Id);
            System.assertEquals(7, result.size());

        Test.stopTest();

    }



    public static testMethod void testaddTransferAccounts(){

        Test.startTest();
            List<String> selectIds = new List<String>();
            TransferSpendingCash__c testrq = [SELECT Id, From_Sale__c FROM TransferSpendingCash__c LIMIT 1];
            for(QC_Account__c tfacc: [SELECT Id,Name FROM QC_Account__c WHERE Sales__c =:testrq.From_Sale__c  LIMIT 5]){
                selectIds.add(tfacc.Id);
            }

            List<Transfer_Account__c> result = TransferRequestController.addTransferAccounts(testrq.Id, selectIds);


            List<Transfer_Account__c> testtfAcc = [SELECT Id FROM Transfer_Account__c WHERE Transfer_request__c = :testrq.Id];
            System.assertEquals(6, testtfAcc.size());

        Test.stopTest();

    }
}