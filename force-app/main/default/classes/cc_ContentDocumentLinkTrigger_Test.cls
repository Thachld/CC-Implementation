@isTest
public class cc_ContentDocumentLinkTrigger_Test {
    @isTest
    public static void preventFileDeletion(){
        User us = [select id from user where isActive = true and profile.name = 'Sales Profile' and Department = 'Direct Business' limit 1];
        Account acc = cc_initData.initAccount();
        acc.Area__c = 'Local';
        acc.ownerId = us.id;
        insert acc;
        //get simple design recordtypeid to insert new design record later
        //Recordtype designrec = [select id from Recordtype where developername = 'Simple_design'];
        
        system.runAs(us){
            //2021-05-14 removed by Toan Nguyen, reason: feature was requested but not being used by Design team
            /*//insert opportunity for media plan
            Opportunity oppty = cc_initData.initOpportunity (acc.id);
        	insert oppty;            
        	//insert media plan for make design
            Media_plan__c mediaplan = cc_initData.initMediaPlan (acc.id, oppty.id);
        	insert mediaplan;
            //insert parent design
            Make_design__c parentdesign = cc_initData.initDesign (mediaplan.id,designrec.id);
            insert parentdesign;
            //insert child design
            Make_design__c childdesign = parentdesign.clone();
            childdesign.Parent_request__c = parentdesign.Id;
            insert childdesign; */
            
            date dtToday = date.today();
            String type = 'Master - Commitment';
            Contract__c ctr = cc_initData.initContract(acc.id, dtToday, dtToday, type);
            ctr.status__c = 'Done';
            insert ctr;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test Document';
            cv.PathOnClient = 'TestDocument.pdf';
            cv.VersionData = Blob.valueOf('Test Content');
            cv.IsMajorVersion = true;
            Insert cv;
            
            List<ContentVersion> cvList = [SELECT Id, Title, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];
            List<ContentDocument> cdList = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument limit 1];
            System.assertEquals(cvList.size(), 1);
            //database.delete(cdList,false);
            
            //prepare a list of contentdocument link to insert
            List<ContentDocumentLink> linklist = new List<ContentDocumentLink>();
            
            //create sObject Link for Contract
            ContentDocumentLink contentlink=new ContentDocumentLink();
            contentlink.LinkedEntityId=ctr.id;          
            contentlink.ContentDocumentId=cdList[0].Id;
            contentlink.Visibility = 'AllUsers';
            linklist.add(contentlink);
            
            //2021-05-14 removed by Toan Nguyen, reason: feature was requested but not being used by Design team
            /*//create sObject Link for Design
            ContentDocumentLink contentlinkdesign=new ContentDocumentLink();
            contentlinkdesign.LinkedEntityId=childdesign.id;            
            contentlinkdesign.ContentDocumentId=cdList[0].Id;
            contentlinkdesign.Visibility = 'AllUsers';
            linklist.add(contentlinkdesign);*/

            //insert Content document links
            insert linklist;
            //try to delete link
            database.delete(contentlink,false);
        }
    }
}