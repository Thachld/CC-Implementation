@isTest
public class cc_QCAccountRealCouponAPITest {
	@isTest
      public static void testQCtoSF(){
          cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
            QC_Account__c qcAccount = cc_initData.initQCAccount();
         qcAccount.name = 'test@gmail.com';
         qcAccount.QC_Account_Id__c = '42855716';
         insert qcAccount;
         Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/qcaccountrealcoupontosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1());
         
         
         string str = cc_QCAccountRealCouponAPI.updateRealCouponSystem();
      }
     public static string getJsonCase1(){
         return '[{"customer_id":42855716,"coupon_spending":1.4,"real_spending":1.6,"syndate":"12/2019"},{"customer_id":42855723,"coupon_spending":2,"real_spending":2,"syndate":"12/2019"}]';
     }
}