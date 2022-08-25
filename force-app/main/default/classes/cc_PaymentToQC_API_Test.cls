/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 08-10-2022
 * @last modified by  : @Thach Le
**/
@isTest( seealldata=true)
public class cc_PaymentToQC_API_Test {
	@isTest
    public static void testPositivepaymenttoSF(){
        Test.startTest();
        //cc_setting__c setting = cc_initData.initCustomeSetting();
        //insert setting;
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Integration profile' LIMIT 1];
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.QC_Account_Id__c = '2244111111';
        insert qcAccount;

        Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.PROMOTION)
                                                .setTransactionTypeId('2')
                                                .setInternalType(TransactionTypeConstant.PROMOTION)
                                                .setAllowCoupon(true)
                                                .buildAndSave();

        String recordtypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Promotion').getRecordTypeId(); 
        Campaign camp = new CampaignTestDataBuilder()
                        .setRecordType(recordtypeId)
                        .setStatus('In Progress')
                        .setName('Campaign Test Insert')
                        .setQCCampaignId('101')
                        .setTransactionType(transtype.Id)
                        .buildAndSave();    

        Coupon__c coupon =  new CouponTestDataBuilder()
                                .setCampaign(camp.Id) 
                                .setQCAccount(qcAccount.Id)
                                .setAmount(10)
                                .setName('Coupon Test')
                                .setStatus('Active')   
                                .setCouponId('1001')
                                .buildAndSave();          

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/paymentqctosf';
        //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
        req.httpMethod = 'POST';    
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof(getSuccessJSon());
        System.runAs(u){
            string str = cc_PaymentToQC_API.doPostPaymenttoSFSystem();
            //QC_Account__c qcAccount = cc_initData.initQCAccount();
            //insert qcAccount;
            //str = cc_AccountToQC_API.doPostAccountFromQCSystem();
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }
       
       
       Test.stopTest();
    }

    @istest
    public static void testNegativepaymenttoSF(){
        Test.startTest();
        //cc_setting__c setting = cc_initData.initCustomeSetting();
        //insert setting;
        User u = [SELECT Id FROM User WHERE Profile.Name = 'Sales Profile' AND IsActive =true LIMIT 1 ];
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.QC_Account_Id__c = '2244111111';
        insert qcAccount;
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/paymentqctosf';
        //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
        req.httpMethod = 'POST';    
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof(getErrorJson());
        System.runAs(u){
            string str = cc_PaymentToQC_API.doPostPaymenttoSFSystem();
            //QC_Account__c qcAccount = cc_initData.initQCAccount();
            //insert qcAccount;
            //str = cc_AccountToQC_API.doPostAccountFromQCSystem();
            System.debug('str= >' + str);
            System.assert(str.contains('fail'));
        }      
       
       Test.stopTest();
   }



    public static string getSuccessJSon(){
         return '{"Customer_email":"buongiare.deal@gmail.com","Customer_id":"2244111111","Transaction_id":"224431","Transaction_amount":10000000,"Payment_method":"Bank Transfer","Transaction_status":"New","Transaction_type":"INCOME","Timestamp":1565581474396,"coupon_id":"1001","coupon_campaign_id":"101"}';
    }

    public static string getErrorJson(){
        // return '{"Customer_email":"buongiare.deal@gmail.com","Customer_id":"2244111111","Transaction_id":"224431","Transaction_amount":10000000,"Payment_method":"Bank Transfer","Transaction_status":"New","Transaction_type":"INCOME","Timestamp":1565581474396,"coupon_id":"1001"}';
        return '';
   }
    
}