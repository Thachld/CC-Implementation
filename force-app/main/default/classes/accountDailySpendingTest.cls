@isTest
private class accountDailySpendingTest {
    public static String CRON_EXP = '0 0 0 15 3 ? 2022';
    static testmethod void testScheduledJob() {
        cc_setting__c settting = cc_initData.initCustomeSetting();
        insert settting;
        Account acc = cc_initData.initAccount();
        insert acc;
        QC_account__c qc = cc_initData.initQCAccount();
        qc.AccountOwner__c = acc.id;
        insert qc;
        datetime ytd = datetime.now().adddays(-1);
        datetime beforeytd = datetime.now().adddays(-2);
        QC_account_data__c qcdata1 = new QC_account_data__c(QC_account__c = qc.id, double_zen_cards_spending__c = 100000, syn_date__c = ytd );
        QC_account_data__c qcdata2 = new QC_account_data__c(QC_account__c = qc.id, double_zen_cards_spending__c = 200000, syn_date__c = beforeytd );
        insert qcdata1;
        insert qcdata2;
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new accountDailySpending());
        Test.stopTest();
    }
}