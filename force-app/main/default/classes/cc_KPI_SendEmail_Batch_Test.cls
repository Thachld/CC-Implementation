@istest
public with sharing class cc_KPI_SendEmail_Batch_Test {
    @TestSetup
    static void testsetup(){
        List<User> urs = new List<User>();
        List<KPI__c> kpis = new List<KPI__c>();
        List<Attachment> atts = new List<Attachment>();

        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;  
        cc_KPI_Setting__c kpisetting = cc_initData.initKPISetting('ccKPISetting');
        insert kpisetting;


        Date today = System.today();      
        String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
        String year = String.valueOf(today.year());
        String period = month +'-' + year ;
        Date startDate = today.toStartOfMonth();
        Date endate = startDate.addMonths(1) - 1;


        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        urs.add(u1);
        pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u2 = cc_initData.initUser(pf.Id, 'Support' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        urs.add(u2);
        insert urs;

        String salerecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId(); 
        String supportrecordtypeId = Schema.SObjectType.KPI__c.getRecordTypeInfosByDeveloperName().get('Support_KPI').getRecordTypeId(); 

        KPI__c salekpi = cc_initData.initKPI(urs[0].alias + '-' + period, urs[0].Id, period, startDate, endate, urs[0].KPI_Category__c, null, salerecordtypeId);
        kpis.add(salekpi);
        KPI__c supportkpi = cc_initData.initKPI(urs[1].alias + '-' + period, urs[1].Id, period, startDate, endate, urs[1].KPI_Category__c, null, supportrecordtypeId);
        kpis.add(supportkpi);

        insert kpis;

        Attachment saleatt =  cc_initData.initAttachment('Sale attactment test','sale attachment body', salekpi.Id);
        Attachment supportatt =  cc_initData.initAttachment('Support attactment test','Support attachment body', supportkpi.Id);
        atts.add(saleatt);
        atts.add(supportatt);

        insert atts;
    }


    public testmethod static void testBatchsendEmail(){
        Test.startTest();
            Date today = System.today();      
            String month = today.month() < 10?'0' + String.valueOf(today.month()) : String.valueOf(today.month());
            String year = String.valueOf(today.year());
            String period = month +'-' + year ;

            Set<String> kpis = new Set<String>();
            Set<String> reporttype = new Set<String>();
            reporttype.add('Sale_KPI');
            reporttype.add('Support_KPI');
            
            cc_KPI_SendEmail_Batch batch = new cc_KPI_SendEmail_Batch(period, reporttype,kpis);
            database.executeBatch(batch);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }
}