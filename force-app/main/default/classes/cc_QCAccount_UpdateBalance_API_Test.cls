@isTest
public class cc_QCAccount_UpdateBalance_API_Test {
	@isTest
    public static void testUpdateBalance(){
        Test.startTest();
         //cc_setting__c setting = cc_initData.initCustomeSetting();
         //insert setting;
         QC_Account__c qcAccount = cc_initData.initQCAccount();
         qcAccount.QC_Account_Id__c = '64178';
         insert qcAccount;
        
        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
         qcAccount1.QC_Account_Id__c = '278130';
         insert qcAccount1;
        
        
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/paymentupdatebalancetosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1());
         string str = cc_QCAccount_UpdateBalance_API.updateAccountBalanceSystem();
         //QC_Account__c qcAccount = cc_initData.initQCAccount();
         //insert qcAccount;
         //str = cc_AccountToQC_API.doPostAccountFromQCSystem();
         
         Test.stopTest();
    }
    public static string getJsonCase1(){
         return '[{"Customer_id":"64178","Customer_status":"New account","Customer_balance":2000000},{"Customer_id":"278130","Customer_status":"New account11","Customer_balance":3000000},{"Customer_id":"278131","Customer_status":"New account","Customer_balance":3000000}]';
     }
}