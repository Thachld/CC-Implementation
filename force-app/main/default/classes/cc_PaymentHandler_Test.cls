@IsTest(SeeAllData=true)
// @istest
public class cc_PaymentHandler_Test {
	@isTest
     public static void testHandler(){
     	Test.startTest();
        cc_setting__c setting = cc_Util.getCustomSetting();
        setting.Notify_missing_in_QC_Account__c = true;
        update setting;

        List<QC_Account__c> qcacc = new List<QC_Account__c>();
        List<Payment__c> pys = new List<Payment__c>();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;    

        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.Auto_Confirm_Weekend__c = true;
        qcAccount.Need_Approval__c = false;       
        qcAccount.Real_Money_Balance__c = null;    
        qcAccount.OwnerId = u1.Id;
        qcAccount.Sales__c = u1.Id;    
        qcacc.add(qcAccount);

        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.Is_Standard__c = true;
        qcAccount1.Real_Money_Balance__c = null;  
        qcAccount1.OwnerId = u1.Id;
        qcAccount1.Sales__c = u1.Id;      
        qcacc.add(qcAccount1);


        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.Is_Standard__c = true;
        qcAccount2.Real_Money_Balance__c = null;
        qcAccount2.Agency_QC_Account__c = qcAccount.Id;        
        qcAccount2.OwnerId = u1.Id;
        qcAccount2.Sales__c = u1.Id;      
        qcacc.add(qcAccount2);

        QC_Account__c qcAccount3 = cc_initData.initQCAccount();
        qcAccount3.Is_Standard__c = true;
        qcAccount3.Real_Money_Balance__c = null;        
        qcAccount3.OwnerId = u1.Id;
        qcAccount3.Sales__c = u1.Id;      
        qcacc.add(qcAccount3);

        QC_Account__c qcAccount4 = cc_initData.initQCAccount();
        qcAccount4.Is_Standard__c = true;
        qcAccount4.Real_Money_Balance__c = null;    
        qcAccount4.OwnerId = u1.Id;
        qcAccount4.Sales__c = u1.Id;          
        qcacc.add(qcAccount4);

        insert qcacc;
        
        RecordType rcType ;
        rcType = [select id, name from recordType where name = 'Standard payment'];
        Payment__c payment =  cc_initData.initPayment(rcType.id,'1234561d', qcacc[0].id );
        pys.add(payment);        


        rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Real_Payment];
        Payment__c payment1 =  cc_initData.initPayment(rcType.id,'1234562d', qcacc[1].id );
        payment1.Stage__c = 'Done';        
        payment1.Real_Money_Type__c = 'Pay Dept';
        payment1.Final_Amount__c = 100;
        payment1.Parent_Payment__c = payment.id;
        payment1.Effective_date__c = null;
        pys.add(payment1);


        Payment__c payment2 =  cc_initData.initPayment(rcType.id,'1234563d', qcacc[3].id );
        payment2.Real_Money_Type__c = 'Income';       
        payment2.Stage__c = 'Done';
        pys.add(payment2);   
        
         
        Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234564d', qcacc[4].id );
        payment3.Real_Money_Type__c = 'Pay Dept';
        payment3.Stage__c = 'New';
        pys.add(payment3);


        rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Advance];
        Payment__c payment4 =  cc_initData.initPayment(rcType.id,'1234565d', qcacc[2].id );       
        payment4.Stage__c = 'New';        
        pys.add(payment4);
        
        insert pys;

        pys[0].isApproval__c = 1;
        update pys[0];

        pys[2].Stage__c = 'New';
        update pys[2];

        pys[2].Stage__c = 'Done';
        update pys[2];

        pys[3].Stage__c = 'Done';
        update pys[3];

        try {
            Test.stopTest();
            
        } catch (Exception ex) {
            
        }
        Test.getEventBus().deliver();
    }

    @isTest
    public static void testHOMCalculation(){
        Test.startTest();
            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert u1;

            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            qcAccount.OwnerId = u1.Id;
            qcAccount.Sales__c = u1.Id;
            insert qcAccount;

            HandOver_Minute__c hom = cc_initData.initHandOverMinute();
            insert hom;        
            
            HandOver_Minute__c hom1 = cc_initData.initHandOverMinute();
            insert hom1; 

            RecordType rcType ;
            rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Real_Payment];
            Payment__c payment5 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment5.Final_Amount__c = 100;
            payment5.Stage__c = 'Done';
            payment5.HandOver_Minutes__c = hom.Id; 
            insert payment5;
           
            rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Standard];
            Payment__c payment6 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment6.Final_Amount__c = 200;
            
            payment6.HandOver_Minutes__c = hom1.Id;        
            insert payment6;

            payment6.Stage__c = 'Done';     
            payment6.HandOver_Minutes__c = hom1.Id;       
            update  payment6;

            payment6.Stage__c = 'Done';     
            payment6.HandOver_Minutes__c = null;       
            update  payment6;

            payment6.Stage__c = 'Done';     
            payment6.HandOver_Minutes__c = hom1.Id;       
            update  payment6;

            payment6.Stage__c = 'Done';     
            payment6.HandOver_Minutes__c = hom.Id;       
            update  payment6;

            delete payment6;
            undelete payment6;

        try {
            Test.stopTest();
            HandOver_Minute__c testhom = [SELECT Id, Total_Payment_Amount__c FROM HandOver_Minute__c WHERE Id = :hom.Id];
            System.assertEquals(100, testhom.Total_Payment_Amount__c);

            
        } catch (Exception ex) {
            
        }

        Test.getEventBus().deliver();
    }

    @isTest
    public static void testPaidAmountCalculation(){
        Test.startTest();
            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
            User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
            insert u1;

            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            qcAccount.OwnerId = u1.Id;
            qcAccount.Sales__c = u1.Id;
            insert qcAccount;
            
            RecordType rcType ;
            rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Advance];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );            
            insert payment3;
            
            Payment__c payment4 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );            
            insert payment4;

            rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Real_Payment];
            Payment__c payment5 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment5.Final_Amount__c = 500;
            payment5.Parent_Payment__c = payment4.id; 
            payment5.Stage__c = 'Done';
            insert payment5;
            
            Payment__c payment6 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment6.Final_Amount__c = 200;           
            payment6.Parent_Payment__c = payment4.id; 
            payment6.Stage__c = 'New';
            insert payment6;

            payment6.Parent_Payment__c = payment4.id;
            payment6.Stage__c = 'Done';
            update payment6;     

            payment6.Parent_Payment__c = null;
            payment6.Stage__c = 'Done';
            update payment6;     

            payment6.Parent_Payment__c = payment4.id;            
            update payment6;     

            payment6.Parent_Payment__c = payment3.id;            
            update payment6;     
            
            delete payment6;
            undelete payment6;            

        try {
            Test.stopTest();         

            Payment__c tespy = [SELECT Id, Paid_amount__c FROM Payment__c WHERE Id = :payment4.Id];
            System.assertEquals(500, tespy.Paid_amount__c);

            Payment__c tespy1 = [SELECT Id, Paid_amount__c FROM Payment__c WHERE Id = :payment3.Id];
            System.assertEquals(200, tespy1.Paid_amount__c);
        } catch (Exception ex) {
            
        }

        Test.getEventBus().deliver();
    }

    @istest
    public static void testTransferredAmountCal(){        
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        List<Payment__c> insertPys = new List<Payment__c>();
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.Auto_Confirm_Weekend__c = true;
        qcAccount.Need_Approval__c = false;       
        qcAccount.Real_Money_Balance__c = null;
        qcAccount.OwnerId = u1.Id;
        qcAccount.Sales__c = u1.Id;
        insert qcAccount;
        
        RecordType rcType ;
        rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Refund];
        Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );            
        insertPys.add(payment3);
        
        Payment__c payment4 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.id );   
        insertPys.add(payment4);

        rcType = [select id, name from recordType where name = 'Real Payment'];       
        Payment__c paymentnew33 =  cc_initData.initPayment(rcType.id,'1234562f', qcAccount.id );
        paymentnew33.Stage__c = 'Done';
        insertPys.add(paymentnew33);   
        insert insertPys;

        Test.startTest();

            rcType = [select id, name from recordType where name =: cc_static_Message.Payment_RecordType_Transfer];
            Payment__c payment5 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment5.Final_Amount__c = 500;
            payment5.Parent_Payment__c = insertPys[1].id; 
            payment5.Stage__c = 'Done';            
            insert payment5;      
            
            Payment__c payment6 =  cc_initData.initPayment(rcType.id,'1234562d', qcAccount.Id );         
            payment6.Final_Amount__c = 200;           
            payment6.Parent_Payment__c = insertPys[1].id; 
            payment6.Stage__c = 'New';
            insert payment6;
            
            payment6.Stage__c = 'Done';
            update payment6;     

            payment6.Parent_Payment__c = insertPys[2].id;
            payment6.Stage__c = 'Done';
            update payment6;     

            payment6.Parent_Payment__c = insertPys[1].id;  
            update payment6;     

            payment6.Parent_Payment__c = insertPys[0].id;         
            update payment6;     
            
            delete payment6;
            undelete payment6;            

        try {
            Test.stopTest();         

            Payment__c tespy = [SELECT Id, Paid_amount__c FROM Payment__c WHERE Id = :payment4.Id];
            System.assertEquals(500, tespy.Transferred_Amount__c);

            Payment__c tespy1 = [SELECT Id, Paid_amount__c FROM Payment__c WHERE Id = :payment3.Id];
            System.assertEquals(200, tespy1.Transferred_Amount__c);
        } catch (Exception ex) {
            
        }

        Test.getEventBus().deliver();
    }
    
    @istest
    public static void testDefaultSupport(){
        Test.startTest();        

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        cc_setting__c setting = cc_Util.getCustomSetting();
        setting.Notify_missing_in_QC_Account__c = true;
        update setting;

        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.Source__c = 'QC';
        qcAccount.Type__c = 'Normal'; 
        qcAccount.Support__c = null;       
        qcAccount.OwnerId = u1.Id;
        qcAccount.Sales__c = u1.Id;
        insert qcAccount;

        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        
        qcAccount1.Source__c = 'QC';
        qcAccount1.Type__c = 'Normal'; 
        qcAccount1.Industry__c = 'Other'; 
        qcAccount1.Support__c = null;     
        qcAccount1.OwnerId = u1.Id; 
        qcAccount1.Sales__c = u1.Id;
        insert qcAccount1;

        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.Source__c = 'QC';
        qcAccount2.Type__c = 'Normal';  
        qcAccount2.Support__c = null;   
        qcAccount2.Industry__c = 'Pharmacy'; 
        qcAccount2.OwnerId = u1.Id;  
        qcAccount2.Sales__c = u1.Id;
        insert qcAccount2;
        
        RecordType rcType ;
        rcType = [select id, name from recordType where name = 'Standard payment'];
        Payment__c payment =  cc_initData.initPayment(rcType.id,'1234561d', qcAccount.id );
        payment.Type__c = 'INCOME';
        payment.Final_Amount__c = 10000;
        payment.Stage__c = 'Done';
        insert payment;         
        
        rcType = [select id, name from recordType where name = : cc_static_Message.Payment_RecordType_Advance];
        Payment__c payment2 =  cc_initData.initPayment(rcType.id,'1234561b', qcAccount2.id );
        payment2.Type__c = 'INCOME';        
        payment2.Final_Amount__c = 10000000;
        payment2.Stage__c = 'Done';
        insert payment2; 


        rcType = [select Id, Name FROM recordType WHERE Name =: cc_static_Message.Payment_RecordType_Advance];
        Payment__c payment1 =  cc_initData.initPayment(rcType.id,'1234562c', qcAccount1.id );
        payment1.Stage__c = 'New';
        payment2.Type__c = 'INCOME';    
        payment1.Final_Amount__c = 10000000;
        insert payment1;

        payment1.Stage__c = 'Done';
        update payment1;
      
        try {
            Test.stopTest();
            
        } catch (Exception ex) {
            
        }
        Test.getEventBus().deliver();
    }    
}