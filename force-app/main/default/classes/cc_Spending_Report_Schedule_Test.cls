@isTest
public class cc_Spending_Report_Schedule_Test {
	@isTest
     public static void testSpendingSchedule(){
          cc_setting__c settting = cc_initData.initCustomeSetting();
        insert settting;
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
        datetime dtnow = datetime.now().addMonths(-1);
        set<string> strDateSet =  cc_Util.getSetDate(1,5, dtnow.month(), dtnow.year());
        cc_Spending_Report_Schedule temp = new cc_Spending_Report_Schedule();
         temp.execute(null);
     }
}