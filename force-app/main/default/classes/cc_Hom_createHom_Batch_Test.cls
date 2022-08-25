@istest
public class cc_Hom_createHom_Batch_Test {
    
   
	@isTest
    public static void test1(){
        setupTest();
        cc_Hom_NetCalculate_Schedule temp = new cc_Hom_NetCalculate_Schedule();
        temp.execute(null);
        
        //ctr.DiscountBonus_as_Policy__c = true;
        
        //update ctr;
        //cc_Hom_NetCalculate_Schedule temp1 = new cc_Hom_NetCalculate_Schedule();
    }
    @isTest
    public static void test2(){
        setupTest();
        
        Contract__c ctr = [select id,DiscountBonus_as_Policy__c from Contract__c limit 1 ];
        ctr.DiscountBonus_as_Policy__c = true;
        
        update ctr;
        cc_Hom_NetCalculate_Schedule temp1 = new cc_Hom_NetCalculate_Schedule();
    }
    
     @isTest
    public static void test3(){
        setupTest();
        
        Contract__c ctr = [select id,DiscountBonus_as_Policy__c from Contract__c limit 1 ];
        ctr.DiscountBonus_as_Policy__c = true;
        ctr.Payment_method__c = 'Postpaid';
        update ctr;
        cc_Hom_NetCalculate_Schedule temp1 = new cc_Hom_NetCalculate_Schedule();
    }
     @isTest
    public static void test4(){
        setupTest1();
        cc_Hom_NetCalculate_Schedule temp1 = new cc_Hom_NetCalculate_Schedule();
    }
    public static void setupTest(){
        cc_setting__c settting = cc_initData.initCustomeSetting();
        insert settting;
        datetime dtnow = datetime.now().addMonths(-1);
        integer noOfDays = Date.daysInMonth(dtnow.year(), dtnow.month());
        // Discount__c dc = new Discount__c();
        // dc.Max_spending__c = 1000;
        // dc.Year__c = string.valueOf(dtnow.year());
        // dc.Policy__c = true;
        // dc.Discount_rate__c = 10;
        // insert dc;
       
        
        Account acc = cc_initData.initAccount();
        insert acc;
       
        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.Name = 'testupdate1@abc.com';
        qcAccount1.AccountOwner__c = acc.id;
        qcAccount1.QC_Account_Id__c = '1';
        insert qcAccount1;
        
        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.Name = 'testupdate2@abc.com';
        qcAccount2.AccountOwner__c = acc.id;
        qcAccount2.QC_Account_Id__c = '2';
        insert qcAccount2;
        
        QC_Account__c qcAccount3 = cc_initData.initQCAccount();
        qcAccount3.Name = 'testupdate3@abc.com';
        qcAccount3.AccountOwner__c = acc.id;
        qcAccount3.QC_Account_Id__c = '3';
        insert qcAccount3;
        
        QC_Account__c qcAccount4 = cc_initData.initQCAccount();
        qcAccount4.Name = 'testupdate4@abc.com';
        qcAccount4.AccountOwner__c = acc.id;
        qcAccount4.QC_Account_Id__c = '4';
        insert qcAccount4;
        QC_Account__c qcAccount5 = cc_initData.initQCAccount();
        qcAccount5.Name = 'testupdate5@abc.com';
        qcAccount5.AccountOwner__c = acc.id;
        qcAccount5.QC_Account_Id__c = '5';
        insert qcAccount5;
        QC_Account__c qcAccount6 = cc_initData.initQCAccount();
        qcAccount6.Name = 'testupdate6@abc.com';
        qcAccount6.AccountOwner__c = acc.id;
        qcAccount6.QC_Account_Id__c = '6';
        insert qcAccount6;
        
        List<QC_Account_Data__c> qcAccountDataList =  cc_initData.initQCAccountData('1', '2', '3', '4','5', '6' ,
                                                             qcAccount1.id, qcAccount2.id,qcAccount3.id,  qcAccount4.id, qcAccount5.id, qcAccount6.id);
        insert qcAccountDataList;
        
        
        
        
        
        
        //set<string> strDateSet =  cc_Util.getSetDate(1,5, dtnow.month(), dtnow.year());
        //cc_Spending_Report_Schedule temp = new cc_Spending_Report_Schedule();
         //temp.execute(null);
        date startDate = date.newInstance(dtnow.year(), dtnow.month(), dtnow.day());
        date endDate = date.newInstance(dtnow.year(), dtnow.month(), noOfDays);
        Contract__c ctr =  cc_initData.initContract(acc.id, startDate, endDate);
        ctr.Is_Monthly__c = true;
        ctr.Active__c = true;
        insert ctr;
        List<Contract_link__c> contractLinkList = new List<Contract_link__c>();
        Contract_link__c cl1 = cc_initData.initContractLink(ctr.id, qcAccount1.id);
        contractLinkList.add(cl1);
        Contract_link__c cl2 = cc_initData.initContractLink(ctr.id, qcAccount2.id);
        contractLinkList.add(cl2);
        Contract_link__c cl3 = cc_initData.initContractLink(ctr.id, qcAccount3.id);
        contractLinkList.add(cl3);
        Contract_link__c cl4 = cc_initData.initContractLink(ctr.id, qcAccount4.id);
        contractLinkList.add(cl4);
        Contract_link__c cl5 = cc_initData.initContractLink(ctr.id, qcAccount5.id);
        contractLinkList.add(cl5);
        Contract_link__c cl6 = cc_initData.initContractLink(ctr.id, qcAccount6.id);
        contractLinkList.add(cl6);
        insert contractLinkList;
    }
    public static void setupTest1(){
        cc_setting__c settting = cc_initData.initCustomeSetting();
        insert settting;
        datetime dtnow = datetime.now().addMonths(-1);
        integer noOfDays = Date.daysInMonth(dtnow.year(), dtnow.month());
        // Discount__c dc = new Discount__c();
        // dc.Max_spending__c = 1000;
        // dc.Year__c = string.valueOf(dtnow.year());
        // dc.Policy__c = true;
        // dc.Discount_rate__c = 10;
        // insert dc;
       
        
        Account acc = cc_initData.initAccount();
        insert acc;
       
        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.Name = 'testupdate7@abc.com';
        qcAccount1.AccountOwner__c = acc.id;
        qcAccount1.QC_Account_Id__c = '7';
        insert qcAccount1;
        
        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.Name = 'testupdate8@abc.com';
        qcAccount2.AccountOwner__c = acc.id;
        qcAccount2.QC_Account_Id__c = '8';
        insert qcAccount2;
        
        QC_Account__c qcAccount3 = cc_initData.initQCAccount();
        qcAccount3.Name = 'testupdate9@abc.com';
        qcAccount3.AccountOwner__c = acc.id;
        qcAccount3.QC_Account_Id__c = '9';
        insert qcAccount3;
        
        QC_Account__c qcAccount4 = cc_initData.initQCAccount();
        qcAccount4.Name = 'testupdate10@abc.com';
        qcAccount4.AccountOwner__c = acc.id;
        qcAccount4.QC_Account_Id__c = '10';
        insert qcAccount4;
        QC_Account__c qcAccount5 = cc_initData.initQCAccount();
        qcAccount5.Name = 'testupdate11@abc.com';
        qcAccount5.AccountOwner__c = acc.id;
        qcAccount5.QC_Account_Id__c = '11';
        insert qcAccount5;
        QC_Account__c qcAccount6 = cc_initData.initQCAccount();
        qcAccount6.Name = 'testupdate12@abc.com';
        qcAccount6.AccountOwner__c = acc.id;
        qcAccount6.QC_Account_Id__c = '12';
        insert qcAccount6;
        
        List<QC_Account_Data__c> qcAccountDataList =  cc_initData.initQCAccountData('7', '8', '9', '10','11', '12' ,
                                                             qcAccount1.id, qcAccount2.id,qcAccount3.id,  qcAccount4.id, qcAccount5.id, qcAccount6.id);
        for(QC_Account_Data__c item:qcAccountDataList )
            item.Accounts__c = acc.id;
        insert qcAccountDataList;
    }
}