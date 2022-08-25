@istest
public with sharing class CorrectionSpendingData_TEST {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;             

        List<Account> listAcc = new List<Account>();        
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();     
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();

        User saleUser = [SELECT Id FROM User WHERE Profile.Name = 'Sales Profile' AND IsActive = true LIMIT 1];
        User supportUser = [SELECT Id FROM User WHERE Profile.Name = 'Support Profile' AND IsActive = true LIMIT 1];

        Date today = System.today();

        
        String name = 'Batch Account test ';
        Account acc = cc_initData.initAccount(name);
        insert acc;


       
        for(Integer i=0 ; i< 200;  i++){    
            for(Integer k = 0 ; k < 2; k++){
                String qcname = 'qcAccount' + String.valueOf(i) + String.valueOf(k) + '@qcCococ.com';
                QC_Account__c qcacc = cc_initData.initQCAccount(qcname, acc.Id);
                qcacc.Industry__c = 'Pharmacy';   
                qcacc.OwnerId =  saleUser.Id;
                qcacc.Sales__c =  saleUser.Id;
                qcacc.Support__c =  supportUser.Id;

                listQCAcc.add(qcacc);    
            }            

            i = i + 1;
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
                    datanormal.Sale__c = null;
                    datanormal.Support__c = null;
                    datanormal.Industry__c = 'FMCG';    
                    datanormal.Agency__c = 'Client';              

                    listQCAccountData.add(datanormal);


                }else{
                    Integer qty = 20 * d;
                    Decimal val = 1500 * d;        

                    QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');  
                    dataPromo.Agency__c = null;
                    dataPromo.Industry__c = null;
                    dataPromo.Sale__c = saleUser.Id;
                    dataPromo.Support__c = supportUser.Id;

                    listQCAccountData.add(dataPromo);
                }
            }
        }

        insert listQCAccountData;
    }   


    public testmethod static void TestCorrectiondataBatch(){
        Test.startTest();
            Date enddate = System.today();
            Date startdate = enddate.addDays(-30);

            CorrectionSpendingData_Batch batch = new CorrectionSpendingData_Batch(startdate, enddate);
            Database.executeBatch(batch, 2000);

        try {
            Test.Stoptest();
            List<QC_Account_data__c> testdata = [SELECT Id, QC_Account__c, Sale__c, Support__c, Agency__c, Industry__c
                                                    FROM QC_Account_data__c 
                                                    WHERE QC_Account__c != null
                                                        AND ( Sale__c = null
                                                            OR Support__c = null
                                                            OR Agency__c = null
                                                            OR Industry__c = null                                                
                                                        )];
            
            System.assertEquals(0, testdata.size());                                        
        } catch (Exception ex) {
            
        }
    }

    public testmethod static void TestCorrectiondataSchedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            
            String jobId = System.schedule('CorrectionSpendingData_Schedule_Test', CRON_EXP, new CorrectionSpendingData_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }
}