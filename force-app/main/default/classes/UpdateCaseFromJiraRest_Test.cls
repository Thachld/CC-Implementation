@istest
public with sharing class UpdateCaseFromJiraRest_Test {
 
    @istest
    public static void TestdoUpdateCase_Status(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 

        req.requestBody = Blob.valueof(generateChangeStatus());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_Priority(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangePriority());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_Summary(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangeSummary());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_Labels(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        req.requestBody = Blob.valueof(generateChangeLabel());
        RestContext.request = req;
       
        RestContext.response= res; 
        System.debug('generateChangeLabel()=>' + generateChangeLabel());
       
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_issuetype(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangeIssuetype());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_duedate(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangeDuedate());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_assignee(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangeAssignee());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }

    @istest
    public static void TestdoUpdateCase_Severity(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;


        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.CreateJiraTicket__c = true;
        cs.Assignee__c = u.Id;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', jiraId);

        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangeSeverity());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('success'));
        }       
       
       Test.stopTest();
    }



    @istest
    public static void TestdoUpdateCase_Negative(){ 
        Test.startTest();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Support Profile'];
        User u = cc_initData.initUser(pf.Id, 'Sales' ,'User' + String.valueOf(1), null);
        u.JiraaccountId__c = '5be28ed5042c0320792e9cf0';
        insert u;

        String jiraId = '10001';
        String jiraKey = 'FS-01';

        Case cs = cc_initData.initJiraCase('Subject Test Update' , 'Description Test Update' , u.Id);
        cs.JiraId__c = jiraId;
        cs.JiraKey__c = jiraKey;
        cs.Assignee__c = u.Id;
        cs.CreateJiraTicket__c = true;
        cs.OwnerId = u.Id;
        insert cs;

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        //Passing not existing jira Id 
        req.requestURI  = '/services/apexrest/jiratocase/';
        req.addParameter('jiraId', '10002');
        req.httpMethod = 'PUT';    
        RestContext.request = req;
        RestContext.response= res; 
        req.requestBody = Blob.valueof(generateChangeStatus());
        System.runAs(u){
            string str = UpdateCaseFromJiraRest.doUpdateCase();           
            System.debug('str= >' + str);
            System.assert(str.contains('fail'));
        }
       
       
       Test.stopTest();
    }

    


    public static string generateChangeStatus(){
        return '{"fieldId":"status","field":"status","fieldType":"","fromValue":"10000","fromString":"Backlog","toValue":"3","toString":"In Progress"}';
    }

    public static string generateChangePriority(){
        return '{"fieldId":"priority","field":"priority","fieldType":"","fromValue":"1","fromString":"Highest","toValue":"4","toString":"Low"}';
    }

    public static string generateChangeSummary(){
        return '{"fieldId":"summary","field":"summary","fieldType":"","fromValue":"","fromString":"Test web hook update 3d","toValue":"","toString":"Test web hook"}';
    }

    public static string generateChangeLabel(){
        return '{"fieldId":"labels","field":"labels","fieldType":"","fromValue":"","fromString":"data fixbug sss test","toValue":"","toString":"data fixbug"}';
    }

    public static string generateChangeIssuetype(){
        return '{"fieldId":"issuetype","field":"issuetype","fieldType":"","fromValue":"10001","fromString":"Story","toValue":"10002","toString":"Task"}';
    }

    public static string generateChangeDuedate(){
        return '{"fieldId":"duedate","field":"duedate","fieldType":"","fromValue":"2022-07-31","fromString":"2022-07-31 00:00:00.0","toValue":"2022-07-25","toString":"2022-07-25 00:00:00.0"}';
    }

    public static string generateChangeSeverity(){
        return '{"fieldId":"customfield_10049","field":"customfield_10049","fieldType":"","fromValue":"","fromString":"Blocker","toValue":"","toString":"Major"}';
    }

    public static string generateChangeAssignee(){
        return '{"fieldId":"assignee","field":"assignee","fieldType":"","fromValue":"5be28ed5042c0320792e9cfs","fromString":"","toValue":"5be28ed5042c0320792e9cf0","toString":""}';
    }

}