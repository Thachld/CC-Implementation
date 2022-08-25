@isTest
public class cc_PaymentToQC_UpdateTSId_API_Test {
	@isTest
    public static void testUpdateTSId(){
        Test.startTest();
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         QC_Account__c qcAccount = cc_initData.initQCAccount();
         insert qcAccount;
        
         RecordType rcType ;
         rcType = [select id, name from recordType where name = 'Standard payment'];
         Payment__c payment =  cc_initData.initPayment(rcType.id,'p123456', qcAccount.id );
         insert payment;
        
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/paymentuptransactionidqctosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1(payment.id));
         string str = cc_PaymentToQC_UpdateTransactionId_API.doPostAccountFromQCSystem();
         
         req.requestBody = Blob.valueof(getJsonCase2('a020k000009s3St'));
         str = cc_PaymentToQC_UpdateTransactionId_API.doPostAccountFromQCSystem();
         req.requestBody = Blob.valueof(getJsonCase3('a020k000009s3St'));
         str = cc_PaymentToQC_UpdateTransactionId_API.doPostAccountFromQCSystem();
         Test.stopTest();
     }
     public static string getJsonCase1(string paymentId){
         return '{"Salesforce_id":"' + paymentId+ '","Transaction_id":"123456"}';
     }
    public static string getJsonCase2(string paymentId){
         return '{"Salesforce_id":"' + paymentId+ '","Transaction_id":"123456"}';
     }
    public static string getJsonCase3(string paymentId){
        return '{"Salesforce_id":"' + paymentId+ '","Transaction_id":{}}';
     }
}