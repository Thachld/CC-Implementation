@isTest
public class cc_ContentDocumentTrigger_Test {
	@isTest
    public static void preventFileDeletion(){
        Account acc = cc_initData.initAccount();
        insert acc;
       ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
		System.assertEquals(cvList.size(), 1);
        
		List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];
        database.delete(cdList,false);
		
    }
}