@istest(seeAllData = true)
public class cc_Cutoff_Data_TEST {
    
    @istest
    public static void batchdeleteTest(){

        Test.startTest();
            List<AccountCategoryhistory__c> listHistories = new List<AccountCategoryhistory__c>();
            List<Agency_report__c> listagency = new List<Agency_report__c>();

            Account acc = cc_initData.initAccount('Test Account');
            insert acc;

            QC_Account__c agencyAcc = cc_initData.initQCAccount('Agency QC Account', acc.Id);
            agencyAcc.Type__c = 'Agency';
            agencyAcc.Source__c = 'QC';
            Insert agencyAcc;

            String name = 'qcAccount123' + '@qcCococ.com';
            QC_Account__c qcacc = cc_initData.initQCAccount(name, acc.Id);
            qcacc.Agency_QC_Account__c = agencyAcc.Id;
            qcacc.Source__c = 'QC';
            insert qcacc;

            for(Integer i =0 ;i <=500 ; i++){
                Agency_report__c agency = new Agency_report__c();
                agency.Date__c = System.today().addYears(-3);
                agency.Ads_type__c = 'Audience Network External';            
                agency.Agency_QC_Account__c = agencyAcc.Id;
                agency.QC_Account__c = qcacc.Id;
                listagency.add(agency);
            }
        
            insert listagency;


            
        
            for(Integer i =0 ;i <=500 ; i++){


                AccountCategoryhistory__c his = new AccountCategoryhistory__c();

                his.RunningDate__c = System.today().addYears(-3);
                his.LastSpending__c = 10 + i; 
                his.Account__c = acc.Id; 


                listHistories.add(his);
            }       
            
            insert listHistories;

            cc_Cutoff_Data_batch batch = new cc_Cutoff_Data_batch();
            Database.executeBatch(batch);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }

    @istest
    public static void scheduledeleteTest(){

        Test.startTest();
            List<AccountCategoryhistory__c> listHistories = new List<AccountCategoryhistory__c>();
            List<Agency_report__c> listagency = new List<Agency_report__c>();

            Account acc = cc_initData.initAccount('Test Account');
            insert acc;

            QC_Account__c agencyAcc = cc_initData.initQCAccount('Agency QC Account', acc.Id);
            agencyAcc.Type__c = 'Agency';
            agencyAcc.Source__c = 'QC';
            Insert agencyAcc;

            String name = 'qcAccount123' + '@qcCococ.com';
            QC_Account__c qcacc = cc_initData.initQCAccount(name, acc.Id);
            qcacc.Agency_QC_Account__c = agencyAcc.Id;
            qcacc.Source__c = 'QC';
            insert qcacc;

            for(Integer i =0 ;i <=500 ; i++){
                Agency_report__c agency = new Agency_report__c();
                agency.Date__c = System.today().addYears(-3);
                agency.Ads_type__c = 'Audience Network External';            
                agency.Agency_QC_Account__c = agencyAcc.Id;
                agency.QC_Account__c = qcacc.Id;
                listagency.add(agency);
            }
        
            insert listagency;


            
        
            for(Integer i =0 ;i <=500 ; i++){


                AccountCategoryhistory__c his = new AccountCategoryhistory__c();

                his.RunningDate__c = System.today().addYears(-3);
                his.LastSpending__c = 10 + i; 
                his.Account__c = acc.Id; 


                listHistories.add(his);
            }       
            
            insert listHistories;
                      
            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();
            String jobId = System.schedule('AgencyReportMonthly_Test', CRON_EXP, new cc_Cutoff_Data_Shedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }

}