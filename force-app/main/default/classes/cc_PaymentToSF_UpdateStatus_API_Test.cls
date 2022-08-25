@isTest
public class cc_PaymentToSF_UpdateStatus_API_Test {
	@isTest
    public static void testUpdateStatus(){
        Test.startTest();
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         QC_Account__c qcAccount = cc_initData.initQCAccount();
         insert qcAccount;
        
         RecordType rcType ;
         rcType = [select id, name from recordType where name = 'Standard payment'];
         Payment__c payment =  cc_initData.initPayment(rcType.id,'1234561d', qcAccount.id );
         insert payment;
        
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/paymentupdatestatussf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1(payment.id));
         string str = cc_PaymentToSF_UpdateStatus_API.doPostStatusToSF();
         req.requestBody = Blob.valueof(getJsonCase2(payment.id));
         str = cc_PaymentToSF_UpdateStatus_API.doPostStatusToSF();
         req.requestBody = Blob.valueof(getJsonCase3(payment.id));
         str = cc_PaymentToSF_UpdateStatus_API.doPostStatusToSF();
         Test.stopTest();
     }
     public static string getJsonCase1(string paymentId){
         return '{"Salesforce_id":"a020k000009recs","Transaction_id":"1234561d","Transaction_status":"Done","Note":"test abc"}';
     }
    public static string getJsonCase2(string paymentId){
         return '{"Salesforce_id":"a020k000009recs","Transaction_id":"1234567","Transaction_status":"Done","Note":"test abc"}';
     }
    public static string getJsonCase3(string paymentId){
        return '{"Salesforce_id":"a020k000009recs","Transaction_id":"1234567","Transaction_status":{},"Note":"test abc"}';
     }
}