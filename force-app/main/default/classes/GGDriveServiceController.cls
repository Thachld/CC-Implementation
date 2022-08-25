public class GGDriveServiceController {
    static string ACCOUNT_OBJECT_TYPE = 'Account';
    static string OPPORTUNITY_OBJECT_TYPE = 'Opportunity';
    static string ADS_CAMPAIGN_OBJECT_TYPE = 'Ads_Campaign__c';
    static string MAKE_DESIGN_OBJECT_TYPE = 'Make_Design__c';
    static string MEDIA_PLAN_OBJECT_TYPE = 'Media_Plan__c';
    
    static string ACCESS_TOKEN = '';
    static string FOLDER_ID = '';
    
    @AuraEnabled
	public string accessToken{get; set;}
    @AuraEnabled
	public string folderID{get; set;}
    @AuraEnabled
	public string prefixURL{get; set;}
	
	
	public GGDriveServiceController() {

	}
    
	
    @AuraEnabled
    public static GGDriveServiceController getAccessToken(){
        //Getting access token from google
        //Google_Settings__c settings = Google_Settings__c.getOrgDefaults();
        Google_Service_Setting__mdt settings = [SELECT Id, DeveloperName, MasterLabel, Folder_Id__c, Scopes__c, Service_Account_Id__c, 
                                                   	Token_Endpoint__c, JWT_Auth__c,	Prefix_URL__c
                                                    FROM Google_Service_Setting__mdt Limit 1];
        string folderID = settings.Folder_Id__c;
        string prefixURL = settings.Prefix_URL__c;
        Auth.JWT jwt = new Auth.JWT();
        jwt.setAud( settings.Token_Endpoint__c );
        jwt.setIss( settings.Service_Account_Id__c );
        jwt.setAdditionalClaims( new Map<String, Object>{ 'scope' => settings.Scopes__c } );
        
        string jwtSetting = settings.JWT_Auth__c;
        Auth.JWS jws = new Auth.JWS( jwt, jwtSetting );
        
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange( settings.Token_Endpoint__c, jws );
        
		GGDriveServiceController ggDriveSetting = new GGDriveServiceController();
        if( Test.isRunningTest()){
            ggDriveSetting.accessToken = 'test';
        }
        else{
            ggDriveSetting.accessToken = bearer.getAccessToken();
        }
		
		ggDriveSetting.folderID = folderID;
		ggDriveSetting.prefixURL = prefixURL;
        ACCESS_TOKEN = ggDriveSetting.accessToken;
        FOLDER_ID = folderID;
        system.debug('ggDriveSetting: '+ggDriveSetting);
        return ggDriveSetting;
    }
    
    @AuraEnabled
    public static String addToDocuments(string recordId, string ojectType, string fileName, string fileUrl){
        string result = 'File has been added successfully.';
        
        Document__c doc = new Document__c();
        doc.Document_external_URL__c = fileUrl;
        doc.File_Name__c = fileName;
        system.debug('#####recordId:'+recordId);
        system.debug('#####ojectType:'+ojectType);
        //Insert to Document
        if(ojectType == ACCOUNT_OBJECT_TYPE){            
            doc.Account__c = recordId;            
        }
        if(ojectType == MEDIA_PLAN_OBJECT_TYPE){
            doc.Media_Plan__c = recordId; 
            //Media_Plan__c media = [SELECT ID, Name, Opportunity__c FROM Media_Plan__c WHERE ID = :recordId limit 1] ;
            //if(media.Opportunity__c != null){
            //doc.Opportunity__c = media.Opportunity__c;}
            
        }
        if(ojectType == MAKE_DESIGN_OBJECT_TYPE){
            doc.Make_Design__c = recordId; 
            //Make_Design__c design = [SELECT ID, Name, Ads_Campaign__c, Ads_Campaign__r.Opportunity__c FROM Make_Design__c WHERE ID = :recordId limit 1] ;
            //if(design.Ads_Campaign__r.Opportunity__c != null){
            //doc.Opportunity__c = design.Ads_Campaign__r.Opportunity__c;}
            
        }
        if(ojectType == ADS_CAMPAIGN_OBJECT_TYPE){
            doc.Ads_Campaign__c = recordId; 
            //Ads_Campaign__c adsCmp = [SELECT ID, Name, Opportunity__c FROM Ads_Campaign__c WHERE ID = :recordId limit 1] ;
            //if(adsCmp.Opportunity__c != null){
            //doc.Opportunity__c = adsCmp.Opportunity__c;}
            
        }
        if(ojectType == OPPORTUNITY_OBJECT_TYPE){
            doc.Opportunity__c = recordId; 
        }
        
        try{
            insert doc;
        }catch(Exception ex){
            result = ex.getMessage();
            system.debug('#####Error result:'+result);
        }
        system.debug('#####result:'+result);
        return result;
    }
    
    @AuraEnabled
    public static String createFolder(String recordId) {
        Google_Service_Setting__mdt settings = [SELECT Id, DeveloperName, MasterLabel, Folder_Id__c, Scopes__c, Service_Account_Id__c, 
                                                   	Token_Endpoint__c, JWT_Auth__c
                                                    FROM Google_Service_Setting__mdt Limit 1];
        string folderID = settings.Folder_Id__c;
        Auth.JWT jwt = new Auth.JWT();
        jwt.setAud( settings.Token_Endpoint__c );
        jwt.setIss( settings.Service_Account_Id__c );
        jwt.setAdditionalClaims( new Map<String, Object>{ 'scope' => settings.Scopes__c } );
        
        string jwtSetting = settings.JWT_Auth__c;
        Auth.JWS jws = new Auth.JWS( jwt, jwtSetting );
        
        Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange( settings.Token_Endpoint__c, jws );
        

        
        String url = 'https://www.googleapis.com/drive/v2/files';
        string authorizationHeader = 'Bearer ' + 'test';
        if(Test.isRunningTest()){
            authorizationHeader = 'Bearer ' + 'test';
        }
        else{
            authorizationHeader = 'Bearer ' + bearer.getAccessToken(); 
        }

        string body =  '{ "title" : "' + recordId + '",' 
            + ' "parents": [{"id":"'+folderID+'"}], '
            + ' "mimeType" : "application/vnd.google-apps.folder" }'; 
        //Get the folder ID having file
        
        HttpRequest req = new HttpRequest();
        req.setheader('Authorization',authorizationHeader);
        req.setheader('Content-Type','application/json');
        req.setMethod('POST'); 
        req.setEndpoint(url); 
        req.setBody(body); 
        Http h = new Http(); 
        Httpresponse resp = h.send(req);

        system.debug('####resp####' + resp);
        system.debug('####resp.getBody()####' + resp.getBody()	);
        Map<String, Object> mResBody =  (Map<String, Object>)JSON.deserializeUntyped(resp.getBody());
		
		string createdFolderId = string.valueOf(mResBody.get('id'));
        
        return createdFolderId;
    }
}