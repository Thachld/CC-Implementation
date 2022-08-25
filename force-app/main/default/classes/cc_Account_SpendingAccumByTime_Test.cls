@istest
public class cc_Account_SpendingAccumByTime_Test {
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
        String pFieldTotal = 'Spending_Oct_2020__c';
        String pTotalWhereClause = 'Industry__c = \'Airlines\'';
        String pObjectAccum = 'QC_Account_Data__c';
        String pFieldAccum = 'Accounts__c';
        String pFieldAccumAlias = 'AccountOwner';
        String pAgregateField = 'Total_Spending__c';
        String pAccumWhereClause = '';
        String pAggregateFunc = 'SUM'; 
        Date pFromDate = System.today().toStartOfMonth();
        Date pToDate = pFromDate.addDays(30);

        cc_Account_SpendingAccumByTime_Batch accum = 
                                            new cc_Account_SpendingAccumByTime_Batch(
                                                pFieldTotal,
                                                pTotalWhereClause,
                                                pObjectAccum, 
                                                pFieldAccum,
                                                pFieldAccumAlias,
                                                pAgregateField,
                                                pAccumWhereClause,
                                                pAggregateFunc,
                                                pFromDate,
                                                pToDate
                                            );

        Id jobId = Database.executeBatch(accum,200);    

        try {
            Test.stopTest();

            List<Account> listAcc = [SELECT Id FROM Account WHERE Spending_Oct_2020__c > 0];

            System.assertEquals(100, listAcc.size());
        } catch (Exception ex) {
            
        }

    }
}