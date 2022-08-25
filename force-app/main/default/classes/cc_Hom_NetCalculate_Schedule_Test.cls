@istest
public  class cc_Hom_NetCalculate_Schedule_Test {
    @TestSetup
    static void testSetup(){        
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;        

        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();
        List<Contract__c> listCons = new List<Contract__c>();
        List<Contract_Link__c> listConLinks = new List<Contract_Link__c>();
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();


        Date today = System.today().addMonths(-1);

        for(Integer i = 0; i < 50 ; i++){
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

            if (j < 30){
                Date startDate = today.toStartOfMonth();
                Date endDate = startDate.addMonths(5);
                String type = '';
                if (j < 10){                   
                    type = 'Master - Commitment';
                }else if ( j >= 10 && j < 20){                    
                    type = 'Master - No Commitment';
                }else if ( j >= 20 && j < 30){
                    type = 'Fixed price Contract';
                }

                Contract__c con = cc_initData.initContract(acc.Id, startDate, endDate, type);
                listCons.add(con);
            }

            j = j + 1;
        }

        String name = 'qcAccount' + String.valueOf(j) + '@qcCococ.com';
        QC_Account__c blank = cc_initData.initQCAccount(name, null);  
        listQCAcc.add(blank);

        insert listQCAcc;
        insert listCons;

        for(Contract__c con :listCons){            
            for(QC_Account__c qc: listQCAcc){
                if(con.Account__c == qc.AccountOwner__c){
                    Contract_link__c conLink = cc_initData.initContractLink(con.Id, qc.Id);
                    listConLinks.add(conLink);
                }
            }  
        }

        listConLinks.remove(10);
        listConLinks.remove(15);
        listConLinks.remove(25);
        
        insert listConLinks;

        
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

            
            String jobId = System.schedule('CalGrossToNet', CRON_EXP, new cc_Hom_NetCalculate_Schedule());

            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
            
            System.assertEquals(CRON_EXP, ct.CronExpression); 
            System.assertEquals(0, ct.TimesTriggered);
            

        Test.stopTest();
    }
}