@istest
public with sharing class SpendingMasterReport_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting; 
        
        cc_KPI_Setting__c kpisetting = cc_initData.initKPISetting('ccKPISetting');
        insert kpisetting;

        List<Account> listAcc = new List<Account>();        
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();     
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();

        Date today = System.today();

        for(Integer i = 0; i < 100 ; i++){
            String name = 'Batch Account test ' + String.valueOf(i);     
            Account acc = cc_initData.initAccount(name);
            if(i< 50){
                String clientrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Client').getRecordTypeId(); 
                acc.RecordtypeId = clientrecordtypeId;        
            }else {
                String agencyrecordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency').getRecordTypeId();
                acc.RecordtypeId = agencyrecordtypeId;
                acc.Area__c = 'Global';
            }
                   
            listAcc.add(acc);
        }

        insert listAcc;

        Integer j = 0;
        for(Account acc: listAcc){    
            for(Integer k = 0 ; k < 2; k++){
                String name = 'qcAccount' + String.valueOf(j) + String.valueOf(k) + '@qcCococ.com';
                QC_Account__c qcacc = cc_initData.initQCAccount(name, acc.Id);              

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
                    datanormal.Agency__c = 'Global Agency';

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
                    dataPromo.Agency__c = 'Client';

                    listQCAccountData.add(dataPromo);
                }
            }
        }

        insert listQCAccountData;


        Spending_Schedule_Params__mdt batchparam = new Spending_Schedule_Params__mdt();
        batchparam.DeveloperName ='SpendingMasterReport_Batch';
        batchparam.Type__c = 'Day';
        batchparam.Number_Of_Time_frame__c = 10;
        batchparam.Batch_Size__c = 200;

    }   


    public testMethod static void TestBatch(){
        Test.startTest();
            Date startdate = System.today().toStartOfMonth();
            Date enndate = startdate.addDays(30);

            SpendingMasterReport_Batch batch = 
            new SpendingMasterReport_Batch(startdate,enndate);
            Id jobId = Database.executeBatch(batch,500);


       try {
           Test.stopTest();
       } catch (Exception ex) {
           
       }
    }

    public testMethod static void TestSchedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('AccountSpendingReport_TEST', CRON_EXP, new SpendingMasterReport_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);

       try {
           Test.stopTest();
       } catch (Exception ex) {
           
       }
    }
}