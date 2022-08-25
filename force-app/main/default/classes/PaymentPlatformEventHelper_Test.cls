@istest(SeeAllData=true)
public with sharing class PaymentPlatformEventHelper_Test {
    @istest
    public static void testCreatedPaymentPlaformEvent_Insert(){

        Test.Starttest();
            List<Payment__c> newPYs = new List<Payment__c>();
            cc_setting__c setting = cc_Util.getCustomSetting();
            setting.Notify_missing_in_QC_Account__c = true;
            update setting;
            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert u1; 

            String clientrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
            Account acc = cc_initData.initAccount('Account test ' + String.valueOf(1), clientrecordtypeId, 'Local' , 'Airlines');
            insert acc;

            String name3 = 'qcAccount' + String.valueOf(1) + String.valueOf(3) + '@qcCococ.com';
            QC_Account__c qcAccount = cc_initData.initQCAccount(name3, acc.Id);  
            qcAccount.Type__c = QCAccountConstant.TYPE_NORMAL; 
            qcAccount.OwnerId = u1.Id;
            qcAccount.Sales__c = u1.Id;    
            insert qcAccount;
            
            RecordType rcType ;

            rcType = [select id, name from recordType where name = 'Refund payment'];          
            Payment__c paymentnew1 =  cc_initData.initPayment(rcType.id,'1234563rf', qcAccount.id );
            paymentnew1.Stage__c = 'Done';
            paymentnew1.Type__c = PaymentConstant.TYPE_WITHDRAWAL_INCOME;
            paymentnew1.Withdrawal_from_QC__c = PaymentConstant.WITHDRAWAL_FROM_QC_YES;            
            newPYs.add(paymentnew1);

            rcType = [select id, name from recordType where name = 'Advance Payment'];       
            Payment__c paymentnew2 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );
            paymentnew2.Stage__c = 'Done';            
            newPYs.add(paymentnew2);

         
            rcType = [select id, name from recordType where name = 'Real Payment'];       
            Payment__c paymentnew33 =  cc_initData.initPayment(rcType.id,'1234562f', qcAccount.id );
            paymentnew33.Stage__c = 'Done'; 
            insert paymentnew33 ;

            rcType = [select id, name from recordType where name = 'Transfer payment'];       
            Payment__c paymentnew3 =  cc_initData.initPayment(rcType.id,'1234562g', qcAccount.id );
            paymentnew3.Stage__c = 'Done';     
            paymentnew3.Parent_Payment__c = paymentnew33.Id;         
            newPYs.add(paymentnew3);
          

            rcType = [select id, name from recordType where name = 'Normal payment'];       
            Payment__c paymentnew4 =  cc_initData.initPayment(rcType.id,'1234562h', qcAccount.id );
            paymentnew4.Stage__c = 'Done';            
            newPYs.add(paymentnew4);

            insert newPYs;

        try{
            Test.Stoptest();



        }catch(Exception ex){

        }    

        Test.getEventBus().deliver();

    }

    @istest
    public static void testCreatedPaymentPlaformEvent_Update(){

        Test.Starttest();
            List<Payment__c> newPYs = new List<Payment__c>();
            cc_setting__c setting = cc_Util.getCustomSetting();
            setting.Notify_missing_in_QC_Account__c = true;
            update setting;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert u1; 

            String clientrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId();
            Account acc = cc_initData.initAccount('Account test ' + String.valueOf(1), clientrecordtypeId, 'Local' , 'Airlines');
            insert acc;

            String name3 = 'qcAccount' + String.valueOf(1) + String.valueOf(3) + '@qcCococ.com';
            QC_Account__c qcAccount = cc_initData.initQCAccount(name3, acc.Id);  
            qcAccount.Type__c = QCAccountConstant.TYPE_NORMAL; 
            qcAccount.OwnerId = u1.Id;
            qcAccount.Sales__c = u1.Id;    
            insert qcAccount;
            
            RecordType rcType ;

            rcType = [select id, name from recordType where name = 'Refund payment'];          
            Payment__c paymentnew1 =  cc_initData.initPayment(rcType.id,'1234563rf', qcAccount.id );
            paymentnew1.Stage__c = 'New';
            paymentnew1.Type__c = PaymentConstant.TYPE_WITHDRAWAL_INCOME;
            paymentnew1.Withdrawal_from_QC__c = PaymentConstant.WITHDRAWAL_FROM_QC_YES;
            paymentnew1.State_temp__c = '';           
            newPYs.add(paymentnew1);

            rcType = [select id, name from recordType where name = 'Advance Payment'];       
            Payment__c paymentnew2 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );
            paymentnew2.Stage__c = 'New';
            paymentnew2.State_temp__c = '';            
            newPYs.add(paymentnew2);               

            rcType = [select id, name from recordType where name = 'Real Payment'];       
            Payment__c paymentnew33 =  cc_initData.initPayment(rcType.id,'1234562f', qcAccount.id );
            paymentnew33.Stage__c = 'Done';
            insert paymentnew33;  

            rcType = [select id, name from recordType where name = 'Transfer payment'];       
            Payment__c paymentnew3 =  cc_initData.initPayment(rcType.id,'1234562g', qcAccount.id );
            paymentnew3.Stage__c = 'New';
            paymentnew3.State_temp__c = '';     
            paymentnew3.Parent_Payment__c = paymentnew33.Id;       
            newPYs.add(paymentnew3);               


            rcType = [select id, name from recordType where name = 'Normal payment'];       
            Payment__c paymentnew4 =  cc_initData.initPayment(rcType.id,'1234562h', qcAccount.id );
            paymentnew4.Stage__c = 'New';
            paymentnew4.State_temp__c = '';            
            newPYs.add(paymentnew4);          

            insert newPYs;

            for(Payment__c py:newPYs){
                py.Stage__c = 'Done';
            }

            update newPYs;

        try{
            Test.Stoptest();
        }catch(Exception ex){

        }    

        Test.getEventBus().deliver();

    }


    @istest
    public static void testConfirmPaymentPlaformEvent(){

        Test.Starttest();
            cc_setting__c setting = cc_Util.getCustomSetting();
            setting.Notify_missing_in_QC_Account__c = true;
            update setting;

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert u1; 

            QC_Account__c qcAccount = cc_initData.initQCAccount();         
            qcAccount.OwnerId = u1.Id;
            qcAccount.Sales__c = u1.Id;     
            insert qcAccount;
            
            RecordType rcType ;
            rcType = [select id, name from recordType where name = 'Standard payment'];       
            Payment__c paymentnew =  cc_initData.initPayment(rcType.id,'1234551d', qcAccount.id );
            paymentnew.Stage__c = 'New';
            paymentnew.State_temp__c = '';
            insert paymentnew;

            paymentnew.Stage__c = 'Done';
            update paymentnew;
        try{
            Test.Stoptest();
        }catch(Exception ex){

        }    

        Test.getEventBus().deliver();

    }
}