/**
 * @description       : Test class AccountSpendingReport_Batch
 * @author            : @Thach Le
 * @group             : Data Accumulation
 * @last modified on  : 08-09-2022
 * @last modified by  : @Thach Le
**/
@istest
public with sharing class AgencyReportMonthly_Batch_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;             

        List<Account> listAcc = new List<Account>();        
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();     
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();

        Date today = System.today();

        for(Integer i = 0; i < 100 ; i++){
            String name = 'Batch Account test ' + String.valueOf(i);

            Account acc = cc_initData.initAccount(name);
            listAcc.add(acc);
        }

        insert listAcc;

        QC_Account__c agencyAcc = cc_initData.initQCAccount('Agency QC Account', listAcc[0].Id);
        agencyAcc.Type__c = 'Agency';
        agencyAcc.Source__c = 'QC';
        Insert agencyAcc;


        Integer j = 0;
        for(Account acc: listAcc){    
            for(Integer k = 0 ; k < 2; k++){
                String name = 'qcAccount' + String.valueOf(j) + String.valueOf(k) + '@qcCococ.com';
                QC_Account__c qcacc = cc_initData.initQCAccount(name, acc.Id);
                qcacc.Agency_QC_Account__c = agencyAcc.Id;
                qcacc.Source__c = 'QC';

                listQCAcc.add(qcacc);    
            }            

            j = j + 1;
        }      

        insert listQCAcc;
        
        for (qc_Account__c qc: listQCAcc){
            Date startDate = today.toStartOfMonth();
            for(Integer d = 0; d < 5; d++){
                Date dt = startDate.addDays(d);                
                Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                if(d < 3){    
                    Integer qty = 10 * d;
                    Decimal val = 1000 * d;                
                    QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty , 'Normal');
                    datanormal.native_content_ad_external_show__c = 1;
                    datanormal.native_content_ad_external_click__c = 1;
                    datanormal.native_content_ad_external_spending__c = 1;

                    datanormal.native_content_ad_show__c = 1;
                    datanormal.native_content_ad_click__c = 1;
                    datanormal.native_content_ad_spending__c = 1;

                    datanormal.double_zen_cards_show__c = 1;
                    datanormal.double_zen_cards_click__c = 1;
                    datanormal.double_zen_cards_spending__c = 1;

                    datanormal.masthead_show__c = 1;
                    datanormal.masthead_click__c = 1;
                    datanormal.masthead_spending__c = 1;

                    datanormal.video_masthead_show__c = 1;
                    datanormal.video_masthead_click__c = 1;
                    datanormal.video_masthead_spending__c = 1;

                    datanormal.new_tab_show__c = 1;
                    datanormal.new_tab_click__c = 1;
                    datanormal.new_tab_spending__c = 1;

                    datanormal.new_tab_js_code_show__c = 1;
                    datanormal.new_tab_js_code_click__c = 1;
                    datanormal.new_tab_js_code_spending__c = 1;

                    listQCAccountData.add(datanormal);
                }else{
                    Integer qty = 20 * d;
                    Decimal val = 1500 * d;        

                    QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
                    dataPromo.native_content_ad_external_show__c = 1;
                    dataPromo.native_content_ad_external_click__c = 1;
                    dataPromo.native_content_ad_external_spending__c = 1;

                    dataPromo.native_content_ad_show__c = 1;
                    dataPromo.native_content_ad_click__c = 1;
                    dataPromo.native_content_ad_spending__c = 1;

                    dataPromo.double_zen_cards_show__c = 1;
                    dataPromo.double_zen_cards_click__c = 1;
                    dataPromo.double_zen_cards_spending__c = 1;

                    dataPromo.masthead_show__c = 1;
                    dataPromo.masthead_click__c = 1;
                    dataPromo.masthead_spending__c = 1;

                    dataPromo.video_masthead_show__c = 1;
                    dataPromo.video_masthead_click__c = 1;
                    dataPromo.video_masthead_spending__c = 1;

                    dataPromo.new_tab_show__c = 1;
                    dataPromo.new_tab_click__c = 1;
                    dataPromo.new_tab_spending__c = 1;

                    dataPromo.new_tab_js_code_show__c = 1;
                    dataPromo.new_tab_js_code_click__c = 1;
                    dataPromo.new_tab_js_code_spending__c = 1;

                    listQCAccountData.add(dataPromo);
                }
            }
        }

        insert listQCAccountData;
    }   


    public testMethod static void TestBatch(){
        Test.startTest();          

            Date rundate = System.today(); 
            String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
            String year = String.valueOf(rundate.year());
            String period = month +'-' + year ;
            Boolean isOveride = true;

            AgencyReportMonthly_Batch batch = 
            new AgencyReportMonthly_Batch(period, isOveride,null);
            Id jobId = Database.executeBatch(batch,2000 );


       try {
           Test.stopTest();
       } catch (Exception ex) {
           
       }
    }

    public testMethod static void TestSchedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('AgencyReportMonthly_Test', CRON_EXP, new AgencyReportMonthly_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

       try {
           Test.stopTest();
       } catch (Exception ex) {
           
       }
    }
    
}