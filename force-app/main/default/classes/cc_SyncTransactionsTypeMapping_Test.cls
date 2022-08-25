@istest
public with sharing class cc_SyncTransactionsTypeMapping_Test {
    @TestSetup
    static void testSetup(){
        // QC_Integration__c qcinte = cc_initData.initQcIntegrationSetting('qccampaignInternal');
        // insert qcinte;
        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
        
        CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                            .setName('gettransactiontype')
                                            .setUri('https://api.qc.coccoc.com/salesforce/transactions/types-mapping')
                                            .setMethod('GET')
                                            .setTimeout(10000)
                                            .buildAndSave();
        

        Transactions_Type__c ty = new Transactions_Type__c();
        ty.Name = 'Test';
        ty.TransactionTypeId__c = '1';
        insert ty;    
    }

    public testMethod static void Testbatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new GetTransactionTypeHttpCalloutMock());                 
            
            List<Transactions_Type__c> scope = new List<Transactions_Type__c>();        
            scope = [SELECT Id, TransactionTypeId__c FROM Transactions_Type__c WHERE TransactionTypeId__c != null]  ;
            new cc_SyncTransactionsTypeMapping_Batch().execute(null,scope);   
            
        try {
            Test.stopTest();
        } catch (Exception ex) {
            System.debug( 'Sync Transaction Type Test ' + ex.getMessage());
        }    
    }

    public testMethod static void TestFailedCallOutbatch(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new FailGetTransactionTypeHttpCalloutMock());                 
            
            List<Transactions_Type__c> scope = new List<Transactions_Type__c>();        
            scope = [SELECT Id, TransactionTypeId__c FROM Transactions_Type__c WHERE TransactionTypeId__c != null]  ;
            new cc_SyncTransactionsTypeMapping_Batch().execute(null,scope);   
            
        try {
            Test.stopTest();

        } catch (Exception ex) {
            System.debug( 'Sync Transaction Type Test ' + ex.getMessage());
        }    
    }


    @istest
    public static void testSchedule(){
        
        Test.startTest();
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();            
            Test.setMock(HttpCalloutMock.class, new GetTransactionTypeHttpCalloutMock());    
            String scjobId = System.Schedule('cc_SyncTransactionsTypeMapping_Schedule_Test', CRON_EXP, new cc_SyncTransactionsTypeMapping_Schedule());
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :scjobId];
                
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

        try {
            Test.stopTest();
            
            
        } catch (Exception ex) {
            
        }
    }
}