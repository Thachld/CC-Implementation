@isTest
public class cc_UpdateAddressQCToSF_API_Test {
	@isTest
    public static void testBatch(){
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         QC_Account__c qcAccount = cc_initData.initQCAccount();
         qcAccount.QC_Account_Id__c = '64178';
         insert qcAccount;
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/updateaddressqctosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1());
         string str = cc_UpdateAddressQCToSF_API.doPostAddressFromQCSystem();
         req.requestBody = Blob.valueof(getJsonCase2());
         str = cc_UpdateAddressQCToSF_API.doPostAddressFromQCSystem();
         req.requestBody = Blob.valueof(getJsonCase3());
         str = cc_UpdateAddressQCToSF_API.doPostAddressFromQCSystem();
    }
    public static string getJsonCase1(){
         return '{"Customer_id":64178,"customer_type":"COMPANY","name":"name 1","phone":"1234890","position":"postion1","representative":"test 11","company_type":"Công ty trách nhiệm hữu hạn một thành viên","company_name":"Goship","tax_code":"123456","official_address":"80 Kim Giang, Thanh Xuan, Ha Noi","shipping_address":"122 Ba Trieu, Hai Ba Trung, Ha Noi"}';
     }
    
    public static string getJsonCase2(){
         return '{"Customer_id":64178,11"customer_type":"COMPANY","name":"name 1","phone":"1234890","position":"postion1","representative":"test 11","company_type":"Công ty trách nhiệm hữu hạn một thành viên","company_name":"Goship","tax_code":"123456","official_address":"80 Kim Giang, Thanh Xuan, Ha Noi","shipping_address":"122 Ba Trieu, Hai Ba Trung, Ha Noi"}';
     }
    public static string getJsonCase3(){
         return '{"Customer_id":641789,"customer_type":"COMPANY","name":"name 1","phone":"1234890","position":"postion1","representative":"test 11","company_type":"Công ty trách nhiệm hữu hạn một thành viên","company_name":"Goship","tax_code":"123456","official_address":"80 Kim Giang, Thanh Xuan, Ha Noi","shipping_address":"122 Ba Trieu, Hai Ba Trung, Ha Noi"}';
     }
}