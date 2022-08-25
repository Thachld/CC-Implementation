@istest
public class cc_Account_SpendingAccum_Schedule_Test {
    @TestSetup
    static void testSetup(){        
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;             
       
        String clause1 = '';
        String clause2 = '';
        String pFieldTotal = 'Spending_2020__c';       
        String pObjectAccum = 'QC_Account__c'; 
        String pFieldAccum = 'AccountOwner__c';
        String pFieldAccumAlias = 'AccountOwner';
        String pAgregateField = 'Spending_2020__c';        
        String pAggregateFunc = 'SUM';  
        Integer BatchSize = 500; 

        cc_Batch_Parameter__c params = cc_initData.initbatchParamSetting('AccountSpemdingByYearAccum', null, null, clause1, clause2, pFieldTotal, 
                                                                        pFieldAccum, pFieldAccumAlias,pObjectAccum, pAgregateField, pAggregateFunc, BatchSize);
        insert params;

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
                    listQCAccountData.add(datanormal);
                }else{
                    Integer qty = 20 * d;
                    Decimal val = 1500 * d;        

                    QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qc.Id,qc.AccountOwner__c, dtime, val, qty ,'Promo');
                    listQCAccountData.add(dataPromo);
                }
            }
        }

        insert listQCAccountData;
    }   

    public testMethod static void testSchedule(){
        Test.startTest();

            Datetime dt = Datetime.now().addMinutes(2);
            String CRON_EXP = '0 '+ dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ? ' + dt.year();

            String sheduleNume = 'AccountSpemdingByYearAccum' + String.valueOf(dt.day());
            String jobId = System.schedule(sheduleNume, CRON_EXP, new cc_Account_SpendingAccum_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }
}