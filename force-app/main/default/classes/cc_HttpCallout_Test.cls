@istest
public with sharing class cc_HttpCallout_Test {
    
    @istest
    public static void testSetupRequest(){
        Test.startTest();

        cc_Callout callout = new cc_Callout('{}', 'https://www.exampleendpoint.com', 'GET', 10000, null);                  
        cc_HttpCallout.setupHttpRequest(callout);

        coccoc.ManageQCCredential.insertQCCredentialByProfileOrUser('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3, UserInfo.getProfileId());

        cc_HttpCallout.setupHttpRequestToQCByProfileOrUser(callout, UserInfo.getProfileId());

        Test.stopTest();
    }




}