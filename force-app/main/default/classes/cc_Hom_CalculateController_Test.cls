@istest
public class cc_Hom_CalculateController_Test {
	@TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;

        List<Account> listAcc = new List<Account>();
        List<QC_Account__c> listQCAcc = new List<QC_Account__c>();
        List<Contract__c> listCons = new List<Contract__c>();
        List<Contract_Link__c> listConLinks = new List<Contract_Link__c>();
        List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();
        List<HandOver_Minute__c> homs = new List<HandOver_Minute__c>();

        Date today = System.today();

      
        String accname = 'Batch Account test 1';
        Account acc = cc_initData.initAccount(accname);   
        listAcc.add(acc);


        String accname2 = 'Batch Account test 2';
        Account acc2 = cc_initData.initAccount(accname2);   
        listAcc.add(acc2);
        insert listAcc;

        Integer j = 1;
        for(Account ac: listAcc){
            for(Integer k = 0 ; k < 3; k++){
                String name = 'qcAccount' + String.valueOf(j) + '_' + String.valueOf(k) + '@qcCococ.com';
                QC_Account__c qcacc = cc_initData.initQCAccount(name, ac.Id);            
                listQCAcc.add(qcacc);    
            } 
            
            j = j + 1;
        }        

        insert listQCAcc;

        Date constartDate = today.toStartOfMonth();
        Date conendDate = constartDate.addMonths(5);
        String type = 'Master - Commitment';
        Contract__c con = cc_initData.initContract(acc.Id, constartDate, conendDate, type);        
        insert con;

        for(QC_Account__c qc: listQCAcc){
            if(con.Account__c == qc.AccountOwner__c){
                Contract_link__c conLink = cc_initData.initContractLink(con.Id, qc.Id);
                listConLinks.add(conLink);
            }
        }          
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

        Date endDate = constartDate.addDays(Date.daysInMonth(constartDate.year(), constartDate.month()) - 1);   
        HandOver_Minute__c hom1 = cc_initData.initHandOverMinute(listAcc[0].Id, con.Id, constartDate, endDate);
        homs.add(hom1);
        HandOver_Minute__c hom2 = cc_initData.initHandOverMinute(listAcc[1].Id, null, constartDate, endDate);
        homs.add(hom2);

        insert homs;
    }
   
    public testmethod static void homWithoutContractTest(){  
       
        HandOver_Minute__c hom = [SELECT Id, Account__r.Account_number__c, HOM_Number__c,
                                    Start_Date__c, End_Date__c , Name, Status__c 
                                FROM HandOver_Minute__c WHERE Custom_Contract__c = null LIMIT 1];
        hom.HOM_Number__c = 'HOM test';
        update hom;

        ApexPages.StandardController sc = new ApexPages.StandardController(hom);
        cc_Hom_CalculateController homctrol = new cc_Hom_CalculateController(sc);
        homctrol.calculateHom();

        HandOver_Minute__c homAfter = [SELECT Id, Name, Account__r.Account_number__c,
                                            Status__c, HOM_Number__c, Net_spending__c,
                                            Start_Date__c, End_Date__c 
                                        FROM HandOver_Minute__c 
                                        WHERE Id = :hom.Id LIMIT 1];



        Datetime fromDTime = Datetime.newInstance(homAfter.Start_Date__c.year(), homAfter.Start_Date__c.month(), homAfter.Start_Date__c.day(), 0,0,0);       
        Datetime toDTime = Datetime.newInstance(homAfter.End_Date__c.year(), homAfter.End_Date__c.month(), homAfter.End_Date__c.day(), 23,59,59); 
                                
        String HOMNumber = homAfter.Account__r.Account_number__c + '_' + fromDTime.format('yyyyMMdd') + '_' + toDTime.format('yyyyMMdd');
        System.assertEquals(HOMNumber, homAfter.HOM_Number__c);
        System.assert(homAfter.HOM_Number__c != hom.HOM_Number__c);
        System.assert(homAfter.Net_spending__c > 0);



        HandOver_Minute__c homRerun = [SELECT Id, Name, Account__r.Account_number__c,
                                            Status__c, HOM_Number__c, Net_spending__c,
                                            Start_Date__c, End_Date__c 
                                        FROM HandOver_Minute__c 
                                        WHERE Id = :homAfter.Id LIMIT 1];
        
        Date newEndDt = homRerun.End_Date__c.addDays(-5);
        homRerun.End_Date__c =  newEndDt;
        homRerun.HOM_Number__c = '';
        update homRerun;
        
        ApexPages.StandardController newsc = new ApexPages.StandardController(homRerun);
        cc_Hom_CalculateController newhomctrol = new cc_Hom_CalculateController(newsc);
        newhomctrol.calculateHom();


        HandOver_Minute__c homAfterRerun = [SELECT Id, Name, Account__r.Account_number__c,
                                            Status__c, HOM_Number__c, Net_spending__c,
                                            Start_Date__c, End_Date__c 
                                        FROM HandOver_Minute__c 
                                        WHERE Id = :homAfter.Id LIMIT 1];
        
        Datetime newfromDTime = Datetime.newInstance(homAfterRerun.Start_Date__c.year(), homAfterRerun.Start_Date__c.month(), homAfterRerun.Start_Date__c.day(), 0,0,0);    
        Datetime newtoDTime = Datetime.newInstance(homAfterRerun.End_Date__c.year(), homAfterRerun.End_Date__c.month(), homAfterRerun.End_Date__c.day(), 23,59,59); 
        String newHOMNumber = homAfterRerun.Account__r.Account_number__c + '_' + newfromDTime.format('yyyyMMdd') + '_' + newtoDTime.format('yyyyMMdd');

        System.assertEquals(newHOMNumber, homAfterRerun.HOM_Number__c);

    }


    public testmethod static void homWithContractPrepaidTest(){  
       
        HandOver_Minute__c hom = [SELECT Id, Account__r.Account_number__c, HOM_Number__c,
                                        Start_Date__c, End_Date__c , Name, Status__c  
                                FROM HandOver_Minute__c WHERE Custom_Contract__c != null LIMIT 1];
        
        ApexPages.StandardController sc = new ApexPages.StandardController(hom);
        cc_Hom_CalculateController homctrol = new cc_Hom_CalculateController(sc);
        homctrol.calculateHom();


        HandOver_Minute__c homAfter = [SELECT Id, Name, Account__r.Account_number__c,
                                        Status__c, HOM_Number__c, Net_spending__c, 
                                        Custom_Contract__r.Contract_Number__c,
                                        Start_Date__c, End_Date__c 
                                        FROM HandOver_Minute__c 
                                        WHERE Id = :hom.Id LIMIT 1];

        Datetime fromDTime = Datetime.newInstance(homAfter.Start_Date__c.year(), homAfter.Start_Date__c.month(), homAfter.Start_Date__c.day(), 0,0,0);       
        Datetime toDTime = Datetime.newInstance(homAfter.End_Date__c.year(), homAfter.End_Date__c.month(), homAfter.End_Date__c.day(), 23,59,59); 

        String HOMNumber =  homAfter.Custom_Contract__r.Contract_Number__c + '_'
                            + homAfter.Account__r.Account_number__c 
                            + '_' + fromDTime.format('yyyyMMdd') 
                            + '_' + toDTime.format('yyyyMMdd');

        System.assertEquals(HOMNumber, homAfter.HOM_Number__c);
        System.assert(homAfter.HOM_Number__c != hom.HOM_Number__c);
        System.assert(homAfter.Net_spending__c > 0);

    }


    
    public testmethod static void homWithStatusRecievedTest(){  
        HandOver_Minute__c hom = [SELECT Id, Status__c
                                    FROM HandOver_Minute__c WHERE Custom_Contract__c = null LIMIT 1];
        hom.Status__c = 'Received';
        update hom;

        ApexPages.StandardController sc = new ApexPages.StandardController(hom);
        cc_Hom_CalculateController homctrol = new cc_Hom_CalculateController(sc);
        homctrol.calculateHom();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        boolean b = false;
        for(Apexpages.Message msg:msgs){
            if (msg.getDetail().contains('Can not calculate for Received Hom')) {
                b = true;
            }
        }
        system.assert(b);

    }
}