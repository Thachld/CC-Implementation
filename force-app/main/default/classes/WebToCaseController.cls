public with sharing class WebToCaseController {
    @AuraEnabled  
    public static string saveCase(Case newCs, string file, string fileName) {  
        string caseId;  
        try{  

            Group webque = [SELECT Id FROM Group WHERE DeveloperName = 'High_Priority_Cases' and Type = 'Queue' LIMIT 1];
            if(webque != null){
                newCs.OwnerId = webque.Id;
            }

            insert newCs;         
            System.debug('newCs.Id=>' + newCs.Id);    
            caseId = newCs.Id;           
            // ContentVersion cv = createContentVersion(file, filename);
            // ContentDocumentLink cdl = createContentLink(cv.Id, caseId);

        } catch(Exception ex){  
            throw new AuraHandledException(ex.getMessage());
        }  
        return caseId;  
    }   

    // private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
    //     if (contentVersionId == null || recordId == null) { return null; }
    //         ContentDocumentLink cdl = new ContentDocumentLink();
    //         ContentVersion cvs = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId];
    //         System.debug('cvs=>' + cvs);
    //         cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =: contentVersionId].ContentDocumentId;
    //         cdl.LinkedEntityId = recordId;
    //         cdl.ShareType = 'V';
    //     try {
    //         insert cdl;
    //         return cdl;
    //     } catch(DMLException e) {
    //         System.debug('createContentLink=>' + e.getMessage());
    //         return null;
    //     }
    // }

    // private static ContentVersion createContentVersion(String base64, String filename) {
    //     ContentVersion cv = new ContentVersion();
    //     String base64File = EncodingUtil.urlDecode(base64, 'UTF-8');     
    //     cv.VersionData = EncodingUtil.base64Decode(base64File);
    //     cv.Title = filename;
    //     cv.IsMajorVersion = true;        
    //     cv.PathOnClient = '/' + fileName;  
    //     try {
    //         insert cv;
    //         return cv;
    //     } catch(DMLException e) {
    //         System.debug('createContentVersion=>' + e.getMessage());
    //         return null;
    //     }
    // }
}