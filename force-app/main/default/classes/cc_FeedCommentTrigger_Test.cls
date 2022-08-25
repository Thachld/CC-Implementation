@istest
public class cc_FeedCommentTrigger_Test {
    @TestSetup
    static void testSetup(){
        cc_Trigger_Control__c trg = cc_initData.initTrigger('FEEDCOMMENT_TRIGGER',true);
        insert trg;

        String jiraAccountId = '123456789';
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = jiraAccountId;
        insert u;

        String jiraId = '10000';
        String jiraKey = 'FS-01';        

        System.runAs(u){
            Case cs = cc_initData.initJiraCase('Subject Test Feed Comment' , 'Description Test Feed Comment' , u.Id);    
            cs.Origin = 'Email';        
            cs.OwnerId = u.Id;
            insert cs;
            
            FeedItem feed = cc_initData.initFeedItem(cs.Id, 'Subject Test Feed', '<i>Jira CommentId[186792] from jira by @Lê Đình Thạch</i><p>Test create Comment from Jira @luuhoang</p><ul><li>Tassk 1</li><li>Task 2</li></ul>');
            insert feed;            
            
            FeedComment fc = cc_initData.initFeedComment(feed.Id, 'Feed Comment Testing delete');
            insert fc;
        }
        
    }



    public testmethod static void testComment(){   
        try {
            User u = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1 ];
            String jiraId = '10000';
            String jiraKey = 'FS-01';        

            Case cs = cc_initData.initJiraCase('Subject Test Feed Comment' , 'Description Test Feed Comment' , u.Id);
            cs.Origin = 'Jira';
            cs.JiraId__c = jiraId;
            cs.JiraKey__c = jiraKey;
            cs.OwnerId = u.Id;
            insert cs;
            
            FeedItem feed = cc_initData.initFeedItem(cs.Id, 'Subject Test Feed', '<i>Jira CommentId[186792] from jira by @Lê Đình Thạch</i><p>Test create Comment from Jira @luuhoang</p><ul><li>Tassk 1</li><li>Task 2</li></ul>');
            insert feed; 

            FeedComment fc = cc_initData.initFeedComment(feed.Id, 'Feed Comment Testing');
            insert fc;
        } catch (Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Unable to create comment on Case linked')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }


    public testmethod static void testDelete(){   
        try {

            User u = [SELECT Id FROM User WHERE LastName = 'User1' LIMIT 1 ];
            FeedComment fm = [SELECT Id FROM FeedComment WHERE CommentBody =  'Feed Comment Testing delete' LIMIT 1];
            System.runAs(u){
                delete fm;
            }
            
        } catch (Exception ex) {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Your administrator has disabled')? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
}