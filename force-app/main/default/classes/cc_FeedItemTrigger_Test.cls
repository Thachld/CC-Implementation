@istest(seeAllData=true)
public  class cc_FeedItemTrigger_Test {   

    
    @istest 
    public static void testNomalCreateFeedByAPI(){    
        Test.startTest();      

            Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject Test Feed' LIMIT 1];
            
            FeedItem feed = cc_initData.initFeedItem(cs.Id, 'Subject Test Feed', '<i>Jira CommentId[186792] from jira by @Lê Đình Thạch</i><p>Test create Comment from Jira @luuhoang</p><ul><li>Tassk 1</li><li>Task 2</li></ul>');
            insert feed;

            Set<String> feedIds = new Set<String>();
            feedIds.add(feed.Id);
            cc_static_Message.isCreateCaseFeedViaAPI = true;
            cc_FeedItemHelper.attemptCreatePostViaAPI(feedIds);

        try {
            Test.stopTest();
            JiraCommentMapping__c mapping = [SELECT Id FROM JiraCommentMapping__c WHERE CaseId__c = :cs.Id AND FeedItemId__c =:feed.Id  LIMIT 1];
            System.assert(mapping!=null);
        } catch (Exception ex) {
                
        }
        
    }
    
    @istest 
    public static void testUpdateFeed(){          
        Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject Test Feed' LIMIT 1];
        Jira_Intergration_Test__c testdata = [SELECT JiraId__c,FeedId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
        FeedItem feed = [SELECT Id , Title FROM FeedItem WHERE Id =: testdata.FeedId__c];
        feed.Body = 'Subject Test Feed Body update';
        update feed;

        delete feed;
    }

    @istest
    public static void testAPICaloutUpdateFeed(){        
            
        Test.startTest();
            Jira_Intergration_Test__c testdata = [SELECT JiraId__c,FeedId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
            Test.setMock(HttpCalloutMock.class, new cc_UpdateFeedItemHttpCalloutMock());
            Set<String> feedIds = new Set<String>();
            feedIds.add(testdata.FeedId__c);

            cc_FeedItemHelper.attemptUpdatePosttoJira(feedIds);


        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }

    }

    @istest
    public static void testAPICaloutCreateFeed(){
        

        Test.startTest();
        Jira_Intergration_Test__c testdata = [SELECT JiraId__c,FeedId__c FROM Jira_Intergration_Test__c WHERE Name = 'initTest'];
            Case cs = [SELECT Id FROM Case WHERE Subject = 'Subject Test Feed' LIMIT 1];
            Test.setMock(HttpCalloutMock.class, new cc_CreateFeedItemHttpCalloutMock());
           
            FeedItem feed = cc_initData.initFeedItem(cs.Id, 'Subject Test', 'Subject Test Feed Body');
            insert feed;

            Set<String> feedIds = new Set<String>();
            feedIds.add(testdata.FeedId__c);

            cc_FeedItemHelper.attemptCreatePosttoJira(feedIds);


        try {
            Test.stopTest();

            JiraCommentMapping__c mapping = [SELECT Id FROM JiraCommentMapping__c WHERE CaseId__c = :cs.Id LIMIT 1];
            System.assert(mapping!=null);
            System.assert(mapping.JiraCommentId__c!=null);

        } catch (Exception ex) {
            
        }
        
    }




}