@istest(seeAllData = true)
public with sharing class cc_PullJiraIssueController_Test {   
    
    @istest
    public static void testSyncJiraComment(){
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new cc_AsyncCaseFeedHttpCalloutMock());
            
            Case cs = [SELECT Id, JiraId__c, JiraKey__c, Subject, JiraStatus__c,
                                        Assignee__c, JiraProject__c,Priority,Description,Severity__c,IssueType__c,duedate__c, CreatedDate
                                FROM Case WHERE CreateJiraTicket__c = true AND Subject = 'Subject Test Feed' LIMIT 1];
           
            ApexPages.StandardController sc = new ApexPages.StandardController(cs);
            cc_PullJiraIssueController jiractrol = new cc_PullJiraIssueController(sc);
            jiractrol.getInfo();   
            jiractrol.pullJiraComment();    
            jiractrol.updateData();

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    @istest
    public static void testSyncJiraIssue(){
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new cc_UpdateCaseHttpCalloutMock());
            
            Case cs = [SELECT Id, JiraId__c, JiraKey__c, Subject, JiraStatus__c,
                                        Assignee__c, JiraProject__c,Priority,Description,Severity__c,IssueType__c,duedate__c, CreatedDate
                                FROM Case WHERE CreateJiraTicket__c = true AND Subject = 'Subject Test Feed' LIMIT 1];

            ApexPages.StandardController sc = new ApexPages.StandardController(cs);
            cc_PullJiraIssueController jiractrol = new cc_PullJiraIssueController(sc);
            jiractrol.getInfo();   
            jiractrol.pullJiraIssue();
            jiractrol.updateData();    

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }


    @istest
    public static void testPagereference(){

        Case cs = [SELECT Id, JiraId__c, JiraKey__c, Subject, JiraStatus__c,
                                        Assignee__c, JiraProject__c,Priority,Description,Severity__c,IssueType__c,duedate__c, CreatedDate
                                FROM Case WHERE CreateJiraTicket__c = true AND Subject = 'Subject Test Feed' LIMIT 1];

        Test.startTest();

        PageReference pageRef = Page.cc_PullJiraIssuePage;

        Test.setCurrentPage(pageRef);
            pageRef.getParameters().put('id',cs.Id);
            ApexPages.StandardController sc = new ApexPages.standardController(cs);
            cc_PullJiraIssueController  controller = new cc_PullJiraIssueController(sc);
            controller.pullInformation();
            //System.assertNotEquals(null,controller.pullInformation());
            
        Test.stopTest();
    }

}