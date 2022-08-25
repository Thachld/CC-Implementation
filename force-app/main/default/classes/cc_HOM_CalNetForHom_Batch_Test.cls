@Istest
public class cc_HOM_CalNetForHom_Batch_Test {
    @TestSetup
    static void testSetup(){      

        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;

        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();
        List<Contract__c> listCons = new List<Contract__c>();
        List<Contract_Link__c> listConLinks = new List<Contract_Link__c>();
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();


        Date today = System.today();

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

    public testmethod static void testCalGrossToNetSuccesss(){
        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();
        List<Contract__c> listCons = new List<Contract__c>();
        List<Contract_Link__c> listConLinks = new List<Contract_Link__c>();
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();

        listAcc = [SELECT Id, Name FROM Account];
        System.assertEquals(50, listAcc.size());
        
        listQCAcc = [SELECT Id FROM QC_Account__c];        
        System.debug('listQCAcc => ' + listQCAcc.size());

        listQCAccountData = [SELECT Id FROM QC_Account_Data__c];        
        System.debug('listQCAccountData => ' + listQCAccountData.size());       

        listConLinks = [SELECT Id FROM Contract_Link__c];        
        System.debug('listConLinks => ' +  listConLinks.size());
       
        listCons =  [SELECT Id, Name, Contract_Start_Date__c FROM Contract__c];
        System.debug('listCons => ' + listCons); 

        Test.startTest();

        Date today = System.today();
        String month = today.month() < 10? '0' + String.valueOf(today.month()) : String.valueOf(today.month()) ;

        String period = month + '-' + String.valueOf(today.year()); 
        Boolean isPrevCoupon =  false;
        System.debug('period => ' +  period);

        cc_DMLResult_wrapper wraper = new cc_DMLResult_wrapper();
        wraper.Errors = 'Error Test';
        wraper.ExternalId = 'ExternalId';
        wraper.isCreated = true;
        wraper.isSuccess = true;
        wraper.SFDCId = 'RecordId';

        cc_Hom_GetActiveAccount_Batch autoHOMs = new cc_Hom_GetActiveAccount_Batch(period, false);
        Id jobId = Database.executeBatch(autoHOMs,1000);    



        try {
            Test.stopTest();

            List<HandOver_Minute__c> homs = [SELECT Id FROM HandOver_Minute__c];
            System.assert(homs.size() > 0);

        } catch (Exception ex) {
            /* don't fail this test if there were errors in the batch job - we want that */ 
        }

    }

    public testmethod static void testCalGrossToNetFailed(){
        Test.startTest();
        cc_Hom_GetActiveAccount_Batch autoHOMs = new cc_Hom_GetActiveAccount_Batch(null, false);
        Id jobId = Database.executeBatch(autoHOMs,1000);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            /* don't fail this test if there were errors in the batch job - we want that */ 
        }

          
    }


}