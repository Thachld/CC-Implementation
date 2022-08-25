/********************************************************************************************************
* @author        CocCoc - THACHLD
* @date          2022 June 10
* @description   Test class for CreateCaseFeedFromJiraRest
*********************************************************************************************************/
@istest(seeAllData=true)
public with sharing class CreateCaseFeedFromJiraRest_Test {
    
    @istest
    public static void testCreatefeed(){
        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5d42a1ad5e485d0dab01f236';
        insert u;

        Test.startTest();
            String commentId = '210190';

            Test.setMock(HttpCalloutMock.class, new CreateCaseFeedHttpCalloutMock(commentId));
            Case testcs = [SELECT Id, JiraId__c,OwnerId FROM Case WHERE CreateJiraTicket__c = true AND Subject = 'Subject Test Feed' LIMIT 1];           

            System.debug('testcs=>' + testcs);
           

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse(); 
            req.requestURI  = '/services/apexrest/jiratocaseaddfeed/';
            req.addParameter('jiraId', testcs.JiraId__c);

            req.httpMethod = 'POST';    
            RestContext.request = req;
            RestContext.response= res; 
            req.requestBody = Blob.valueof(generateJson(commentId));
            string str = CreateCaseFeedFromJiraRest.doAddCaseFeed();         
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
                   
        
        Test.stopTest();        
    }


    @istest
    public static void testCreatefeed_negative(){
        Test.startTest();
            String commentId = '210190';
            Test.setMock(HttpCalloutMock.class, new CreateCaseFeedHttpCalloutMock(commentId));
            Case testcs = [SELECT Id, JiraId__c,OwnerId FROM Case WHERE CreateJiraTicket__c = true AND Subject = 'Subject Test Feed' LIMIT 1];           

            System.debug('testcs=>' + testcs);

            Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
            User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
            u.JiraaccountId__c = '5d42a1ad5e485d0dab01f236';
            insert u;

            testcs.OwnerId = u.Id;
            update testcs;

            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse(); 
            req.requestURI  = '/services/apexrest/jiratocaseaddfeed/';
            req.addParameter('jiraId', '1111');

            req.httpMethod = 'POST';    
            RestContext.request = req;
            RestContext.response= res; 
            req.requestBody = Blob.valueof(generateJson(commentId));
            System.runAs(u){
                string str = CreateCaseFeedFromJiraRest.doAddCaseFeed();           
                System.debug('str= >' + str);
                System.assert(str.contains('fail'));
            }       
        
        Test.stopTest();        
    }

    public static String generateJson(String commentId){
        return '{"commentId": ' +commentId + ',"authorId": "5d42a1ad5e485d0dab01f236"}';
    }
}