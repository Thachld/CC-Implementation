@istest
public class GGDriveServiceControllerTest {
    @isTest
	public static void test(){
         Google_Service_Setting__mdt settings = [SELECT Id, DeveloperName, MasterLabel, Folder_Id__c, Scopes__c, Service_Account_Id__c, 
                                                   	Token_Endpoint__c, JWT_Auth__c
                                                    FROM Google_Service_Setting__mdt Limit 1];
        Account acc = new Account();
        acc.name = 'test';
        insert acc;
       
        
        string body =  '{ "title" : "' + acc.id + '",' 
            + ' "parents": [{"id":"'+settings.Folder_Id__c+'"}], '
            + ' "mimeType" : "application/vnd.google-apps.folder" }'; 
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.headers.put('Content-Type','application/json');
        req.httpMethod = 'POST';    
        req.requestBody = Blob.valueOf(body);   
        
        RestContext.request = req;
        RestContext.response= res;

        Test.startTest();
      	
        Test.setMock(HttpCalloutMock.class, new GGDriveService_mock_test());
        GGDriveServiceController.getAccessToken();
        string forderId =  GGDriveServiceController.createFolder(acc.id);
        GGDriveServiceController.addToDocuments(acc.id, 'Account', 'test.pdf', 'test');
        Test.stopTest();
        
    }
}