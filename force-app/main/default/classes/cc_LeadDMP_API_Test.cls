@istest//(seeAllData=true)
public class cc_LeadDMP_API_Test {

    @istest
    public static void testPositiveInsertAPI(){
        // cc_setting__c setting = cc_initData.initCustomeSetting();
        // insert setting;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/dmpleadtosf';
        req.httpMethod = 'POST';
        String testDomain = 'domain' + String.valueOf(System.today().year()) + String.valueOf(System.today().month()) + String.valueOf(System.today().day()) + '.com.vn';
        req.requestBody = Blob.valueOf(JSONInit(testDomain));
		System.debug(JSONInit(testDomain));
        
        RestContext.request = req;
        RestContext.response = res;

        String message = cc_LeadDMP_API.postDMPLeads();

        Date today = System.today();
        String campaignName= 'Lead DMP-' + String.valueOf(today.year())+ '-' + String.valueOf(today.month())  + '-' + String.valueOf(today.day());
        List<Lead> leads = [SELECT Id FROM Lead WHERE LeadSource = 'DMP' AND Campaign_Name__c = :campaignName];

        System.assertEquals(1, leads.size());

    }

    @istest
    public static void testPositiveUpdateAPI(){       
        Date today = System.today();
        String campaignName= 'Lead DMP-' + String.valueOf(today.year())+ '-' + String.valueOf(today.month())  + '-' + String.valueOf(today.day());
        String testDomain = 'domain' + String.valueOf(System.today().year()) + String.valueOf(System.today().month()) + String.valueOf(System.today().day()) + '.com.vn';
        Lead newld = new Lead(LastName = testDomain, LeadSource = 'DMP', Website = testDomain, Status = 'New', Campaign_Name__c = campaignName);
        Insert newld;

        Test.startTest();
            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/dmpleadtosf';
            req.httpMethod = 'POST';
            
            req.requestBody = Blob.valueOf(JSONUpdate(testDomain, newld.Id));  
            RestContext.request = req;
            RestContext.response = res;

            String message = cc_LeadDMP_API.postDMPLeads();                       
            Lead lead = [SELECT Id, Google_Click__c, Google_Impression__c FROM Lead WHERE LeadSource = 'DMP' AND Campaign_Name__c = :campaignName LIMIT 1];

            System.assertEquals(1550, lead.Google_Click__c);
            System.assertEquals(453, lead.Google_Impression__c);
        Test.stopTest();

    }
    
    @istest
    public static void testDuplicateAPI(){      
        Date today = System.today();
        String campaignName= 'Lead DMP-' + String.valueOf(today.year())+ '-' + String.valueOf(today.month())  + '-' + String.valueOf(today.day());
        String testDomain = 'domain' + String.valueOf(System.today().year()) + String.valueOf(System.today().month()) + String.valueOf(System.today().day()) + '.com.vn';
        Lead newld = new Lead(LastName = testDomain, LeadSource = 'DMP', Website = testDomain, Status = 'New', Campaign_Name__c = campaignName);
        Insert newld;

        Test.startTest();

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();

            req.requestURI = '/services/apexrest/dmpleadtosf';
            req.httpMethod = 'POST';            
            req.requestBody = Blob.valueOf(JSONInit(testDomain));

            RestContext.request = req;
            RestContext.response = res;

            String message = cc_LeadDMP_API.postDMPLeads();
            
             List<Lead> leads = [SELECT Id FROM Lead WHERE LeadSource = 'DMP' AND Campaign_Name__c = :campaignName];

            // System.assertEquals(1, leads.size());
        Test.stopTest();
    }

    @istest
    public static void testNegativeAPI(){
        // cc_setting__c setting = cc_initData.initCustomeSetting();
        // insert setting;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/dmpleadtosf';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf('[{"metrics_30d":{"google_serp":{}},"domain":"ztestshop.vn","phone":"0979186277","industry":["E-COMMERCE"],"topics":["SHOPPING"],"user_preferred_categories":["E -commerce","ELECTRONICS","Technical","SHOPPING","CAMERA","TM"],"event_date":"2021-08-07","id":"domain:ztestshop.vn"}]');

        RestContext.request = req;
        RestContext.response = res;

        String message = cc_LeadDMP_API.postDMPLeads();
        System.assert(message.contains('fail'));

        System.debug('message');

    }

    @istest
    public static void testWraper(){

        cc_DMPLeadWrapper.google_serp google_serp = new cc_DMPLeadWrapper.google_serp();
        google_serp.ads_click = 1;
        google_serp.ads_impression = 1;
        google_serp.ads_median_pos = 1;
        google_serp.ads_unique_user = 1;
        google_serp.ads_unique_user_click = 1;
        google_serp.serp_click = 1;
        google_serp.serp_impression = 1;
        google_serp.serp_median_pos = 1;
        google_serp.serp_unique_user = 1;
        google_serp.serp_unique_user_click = 1;

        cc_DMPLeadWrapper.metrics_30d data30 = new cc_DMPLeadWrapper.metrics_30d();
        data30.google_serp = google_serp;

        cc_DMPLeadWrapper test = new cc_DMPLeadWrapper();
        test.id = 'domain:zshop.vn';
        test.industry  =  new List<String>{'SHOPPING'};
        test.topics = new List<String>{'E-COMMERCE'};
        test.metrics_30d = data30;
        test.domain = 'zshop.vn';
        test.event_date = '2021-08-07';
        test.phone = '099848384';

    }


    public static String JSONInit(String domain){
        return '[{"metrics_30d":{"google_serp":{"ads_unique_user":1484,"ads_median_pos":2,"ads_impression":3142,"serp_unique_user":277,"serp_median_pos":3,"serp_impression":453,"ads_click":172,"ads_unique_user_click":148,"serp_click":1550,"serp_unique_user_click":1074}},"domain":"'+ domain +'","phone":"0979186277","industry":["E-COMMERCE"],"topics":["SHOPPING"],"user_preferred_categories":["E -commerce","ELECTRONICS","Technical","SHOPPING","CAMERA","TM"],"event_date":"2021-08-07","id":"domain:zshop.vn"}]'; 
    }

    public static String JSONUpdate(String domain, String sfid){
        return '[{"metrics_30d":{"google_serp":{"ads_unique_user":1484,"ads_median_pos":2,"ads_impression":3142,"serp_unique_user":277,"serp_median_pos":3,"serp_impression":453,"ads_click":172,"ads_unique_user_click":148,"serp_click":1550,"serp_unique_user_click":1074}},"domain":"'+ domain +'","sfid":"'+ sfid +'","phone":"0979186277","industry":["E-COMMERCE"],"topics":["SHOPPING"],"user_preferred_categories":["E -commerce","ELECTRONICS","Technical","SHOPPING","CAMERA","TM"],"event_date":"2021-08-07","id":"domain:zshop.vn"}]'; 
    }

}