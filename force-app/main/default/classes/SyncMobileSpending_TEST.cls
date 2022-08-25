@istest
public with sharing class SyncMobileSpending_TEST {
    
    @TestSetup
    static void makeData(){
        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();       
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();

        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
        CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                                .setName('mobileskindata')
                                                .setUri('https://api.qc.coccoc.com/salesforce/report/v2/campaigns/mobile-skin?fields=details.campaign_type,details.spending,details.campaign_name,details.campaign_id,details.date,stats.shows,stats.clicks,stats.ctr,details.client_id')
                                                .setMethod('POST')
                                                .setTimeout(10000)
                                                .buildAndSave();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Other;Real Estate', 'HN',false);
        insert u1;

        Profile pf2 = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u2 = cc_initData.initUser(pf2.Id, 'Support' ,' User' + String.valueOf(2), null, 'Other;Real Estate', 'HN',false);
        insert u2;

        Account acc = new AccountTestDataBuilder().buildAndSave();

        QC_Account__c qcacc = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setIndustry('Other')
                                .setSale(u1.id)
                                .setSupport(u2.Id)
                                .setQcId('75')
                                .setSource(QCAccountConstant.SOURCE_MOBILESKIN)
                                .setStatus(QCAccountConstant.STATUS_ACTIVE)
                                .buildAndSave();

        QC_Account__c qcacc1 = new QCAccountTestDataBuilder()
                                .setAccount(acc.Id)
                                .setIndustry('Other')
                                .setSale(u1.id)
                                .setSupport(u2.Id)
                                .setQcId('76')
                                .setSource(QCAccountConstant.SOURCE_MOBILESKIN)
                                .setStatus(QCAccountConstant.STATUS_ACTIVE)
                                .buildAndSave();                

        Date dt = Date.valueOf('2022-03-15');                
        Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);                               
        Integer qty = 10 ;
        Decimal val = 1000 ;                
        QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qcacc.Id,acc.Id, dtime, val, qty , 'Other', 'Local Agency', 'Normal', u1.Id);
        insert datanormal; 

    }

    public static testMethod void testBatchSync(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SyncMobileSpendingHttpCalloutMock());
            Set<String> runingIds = null;
            SyncMobileSpending_Batch syncMobileSkin = new SyncMobileSpending_Batch('All', runingIds, null,null);
            database.executeBatch(syncMobileSkin,10);  
        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }

    public static testMethod void testScheduleSync(){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new SyncMobileSpendingHttpCalloutMock());
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('SyncMobileSpending_Schedule_TEST', CRON_EXP, new SyncMobileSpending_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();

    }

}