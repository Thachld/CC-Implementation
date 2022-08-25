@istest
public  class cc_QCRefreshToken_API_Test {

    @istest
    public static void testpositiveAPI() {
        RestRequest rq = new RestRequest();
        RestResponse res = new RestResponse();

        QC_Integration__c setting = cc_initData.initQcIntegrationSetting('qccampaignInternal');        
        insert setting;

        coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
        String resbody = '{ "token": "UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu","time_expire": "2021-02-28 10:20:10" }';

        rq.requestURI = '/services/apexrest/qcrefeshtoken';
        rq.httpMethod = 'POST';
        rq.requestBody= Blob.valueOf(resbody);
        RestContext.request = rq;
        RestContext.response =res;
       

        String message = cc_QCRefreshToken_API.postToken();

        QC_Integration__c settingafter = [SELECT EncryptToken__c FROM QC_Integration__c WHERE Name = 'qccampaignInternal'];

        System.assert(!String.isBlank(settingafter.EncryptToken__c));
        
    }


    @istest
    public static void testnegativeAPI() {
        RestRequest rq = new RestRequest();
        RestResponse res = new RestResponse();

        QC_Integration__c setting = cc_initData.initQcIntegrationSetting('qccampaignInternal1');        
        insert setting;

        String resbody = '{ "token": "V5RO1HZGVgZpUfoq96P3zP7s9pnh1Kb9B31ZI0GF","time_expire": "2021-02-28 10:20:10" }';

        rq.requestURI = '/services/apexrest/qcrefeshtoken';
        rq.httpMethod = 'POST';
        rq.requestBody= Blob.valueOf(resbody);
        RestContext.request = rq;
        RestContext.response =res;
       

        String message = cc_QCRefreshToken_API.postToken();

        System.debug(message);
        
    }

    @istest
    public static void testnegativeAPI1() {
        RestRequest rq = new RestRequest();
        RestResponse res = new RestResponse();

        QC_Integration__c setting = cc_initData.initQcIntegrationSetting('qccampaignInternal');        
        insert setting;

        String resbody = '{  }';

        rq.requestURI = '/services/apexrest/qcrefeshtoken';
        rq.httpMethod = 'POST';
        rq.requestBody= Blob.valueOf(resbody);
        RestContext.request = rq;
        RestContext.response =res;
       

        String message = cc_QCRefreshToken_API.postToken();

        System.debug(message);
        
    }    
}