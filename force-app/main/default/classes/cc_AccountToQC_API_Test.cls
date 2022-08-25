@isTest
public class cc_AccountToQC_API_Test {
    @isTest
     public static void testQCtoSF(){
        
        
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         User us = [select id, email,QC_Email__c from user where IsActive = true and QC_Email__c != null limit 1];
         
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/qctosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1(us));
         string str = '';
         /*try{
             str = cc_AccountToQC_API.doPostAccountFromQCSystem();
         }
         catch( Exception ex){
             
         }*/
        List<QC_Account__c> qcaccs = new List<QC_Account__c>();
        List<Lead> leads = new List<Lead>();

        Account acc = cc_initData.initAccount();
        insert acc;
         
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.QC_Account_Id__c = '123454544';
        qcaccs.add(qcAccount);
         
        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.QC_Account_Id__c = 'test';
        qcaccs.add(qcAccount1); 
         
        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.QC_Account_Id__c = 'test1';
        qcAccount2.name = 'toannguye1110@gmail.com';
        qcAccount2.AccountOwner__c = acc.id;
        qcaccs.add(qcAccount2);
         
        QC_Account__c qcAccount3 = cc_initData.initQCAccount();
        qcAccount3.QC_Account_Id__c = 'test3';
        qcAccount3.name = 'toannguye1113@gmail.com';
        qcaccs.add(qcAccount3);
         //qcAccount2.AccountOwner__c = acc.id;
        insert qcaccs; 
         
          /*try{
             str = cc_AccountToQC_API.doPostAccountFromQCSystem();
         }
         catch( Exception ex){
             
         }*/
         
        Lead l = cc_initData.initLead();
        l.QC_Account_Id__c = null;
        l.Email = 'toannguye115@gmail.com';
        l.Status = 'New';
        l.Website = 'abc.com';
        leads.add(l);
         
        Lead l1 = cc_initData.initLead();
        l1.QC_Account_Id__c = null;
        l1.Email = 'toannguye116@gmail.com';
        l1.Status = 'New';
        leads.add(l1);

        Lead l2 = cc_initData.initLead();
        l2.Website = 'test website';
        l2.QC_Account_Id__c = null;
        l2.Email = 'toannguye118@gmail.com';
        l2.Status = 'New';
        leads.add(l2);

        insert leads;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leads[0].Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        
       
        Contact ct = new contact();
        ct.Lastname = 'test';
        ct.Email = 'toannguye114@gmail.com';
        ct.AccountId = acc.id;
        insert ct;
        Database.LeadConvertResult lcr = Database.convertLead(lc);
		
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());   
         
        req.requestBody = Blob.valueof(getJsonCase5(us));
        cc_AccountToQC_API.doPostAccountFromQCSystem();
        req.requestBody = Blob.valueof(getJsonCase6(us));
        cc_AccountToQC_API.doPostAccountFromQCSystem();
        req.requestBody = Blob.valueof(getJsonCase7(us));
        cc_AccountToQC_API.doPostAccountFromQCSystem();
			
        req.requestBody = Blob.valueof(getJsonCase8(us));
        cc_AccountToQC_API.doPostAccountFromQCSystem();
         
        req.requestBody = Blob.valueof(getJsonCase9(us));
        cc_AccountToQC_API.doPostAccountFromQCSystem();
         
        req.requestBody = Blob.valueof(getJsonCase10(us));
        cc_AccountToQC_API.doPostAccountFromQCSystem();
        Test.stopTest();
         
         
     }   
    

	@isTest
     public static void testQCtoSF2(){
        
        
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         User us = [select id, email,QC_Email__c from user where IsActive = true and QC_Email__c != null limit 1];
         
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/qctosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1(us));
         string str = '';
         /*try{
             str = cc_AccountToQC_API.doPostAccountFromQCSystem();
         }
         catch( Exception ex){
             
         }*/
        List<QC_Account__c> qcaccs = new List<QC_Account__c>();
        List<Lead> leads = new List<Lead>();

        Account acc = cc_initData.initAccount();
        insert acc;
         
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.QC_Account_Id__c = '123454544';
        qcaccs.add(qcAccount);
         
        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.QC_Account_Id__c = 'test';
        qcaccs.add(qcAccount1); 
         
        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.QC_Account_Id__c = 'test1';
        qcAccount2.name = 'toannguye1110@gmail.com';
        qcAccount2.AccountOwner__c = acc.id;
        qcaccs.add(qcAccount2);
         
        QC_Account__c qcAccount3 = cc_initData.initQCAccount();
        qcAccount3.QC_Account_Id__c = 'test3';
        qcAccount3.name = 'toannguye1113@gmail.com';
        qcaccs.add(qcAccount3);
         //qcAccount2.AccountOwner__c = acc.id;
        insert qcaccs; 
         
          /*try{
             str = cc_AccountToQC_API.doPostAccountFromQCSystem();
         }
         catch( Exception ex){
             
         }*/
         
        Lead l = cc_initData.initLead();
        l.QC_Account_Id__c = null;
        l.Email = 'toannguye115@gmail.com';
        l.Status = 'New';
        l.Website = 'abc.com';
        leads.add(l);
         
        Lead l1 = cc_initData.initLead();
        l1.QC_Account_Id__c = null;
        l1.Email = 'toannguye116@gmail.com';
        l1.Status = 'New';
        leads.add(l1);

        Lead l2 = cc_initData.initLead();
        l2.Website = 'test website';
        l2.QC_Account_Id__c = null;
        l2.Email = 'toannguye118@gmail.com';
        l2.Status = 'New';
        leads.add(l2);

        insert leads;

        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(leads[0].Id);
        lc.setDoNotCreateOpportunity(true);
        lc.setConvertedStatus('Converted');
        
       
         Contact ct = new contact();
         ct.Lastname = 'test';
         ct.Email = 'toannguye114@gmail.com';
         ct.AccountId = acc.id;
         insert ct;
        Database.LeadConvertResult lcr = Database.convertLead(lc);
		
          Test.startTest();
         Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
         
          req.requestBody = Blob.valueof(getJsonCase1(us));
         cc_AccountToQC_API.doPostAccountFromQCSystem();
         
         req.requestBody = Blob.valueof(getJsonCase2(us));
         cc_AccountToQC_API.doPostAccountFromQCSystem();
         
         req.requestBody = Blob.valueof(getJsonCase3(us));
         cc_AccountToQC_API.doPostAccountFromQCSystem();
         req.requestBody = Blob.valueof(getJsonCase4(us));
         cc_AccountToQC_API.doPostAccountFromQCSystem();         
        
         Test.stopTest();         
         
     }

     public static string getJsonCase1(User us){
         return '{"Name":"test","Website": "abc.com","Customer_email":"toannguye114@gmail.com","Phone_Number":"4451","Customer_id":"123454543","Register_time":1565581474396,"Sale_email":"' +us.QC_Email__c+'"}';
     }
    public static string getJsonCase2(User us){
         return '{"Name":"test1","Website": "abc.com","Customer_email":"toannguye115@gmail.com","Phone_Number":"4452","Customer_id":"12345","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'"}';
     }
    public static string getJsonCase3(User us){
         return '{"Name":"test1", "Website": "abc.com","Customer_email":"toannguye116@gmail.com","Phone_Number":"4453","Customer_id":"123456","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'"}';
     }
    public static string getJsonCase4(User us){
         return '{"Name":"test1"fd, "Website": "abc.com","Customer_email":"toannguye116@gmail.com","Phone_Number":"4454","Customer_id":"1234567","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'","agency_email":"toannguye115@gmail.com"}';
     }
    
    public static string getJsonCase5(User us){
         return '{"Name":"test","Website": "abc.com", "Customer_email":"toannguye117@gmail.com","Phone_Number":"4455","Customer_id":"567893","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'", "Sale_email":"' +us.QC_Email__c+'", "agency_email":"toannguye115@gmail.com"}';
     }
     public static string getJsonCase6(User us){
         return '{"Name":"test12","Website": "abc.com","Customer_email":"toannguye118@gmail.com","Phone_Number":"4456","Customer_id":"567893","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'", "Sale_email":"' +us.QC_Email__c+'", "agency_email":"toannguye115@gmail.com"}';
     }
    public static string getJsonCase7(User us){
        return '{"Name":"test12","Website": "abc.com","Customer_email":"toannguye119@gmail.com","Phone_Number":"4457","Customer_id":"4457","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'", "Sale_email":"' +us.QC_Email__c+'", "agency_email":"toannguye1110@gmail.com"}';
     }
     public static string getJsonCase8(User us){
        return '{"Name":"test12","Website": "abc.com","Customer_email":"toannguye114@gmail.com","Phone_Number":"4457","Customer_id":"4457","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'", "Sale_email":"' +us.QC_Email__c+'", "agency_email":"toannguye1110@gmail.com"}';
     }
     public static string getJsonCase9(User us){
        return '{"Name":"test12","Website": "abc.com","Customer_email":"toannguye114444@gmail.com","Phone_Number":"4457","Customer_id":"4457","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'", "Sale_email":"' +us.QC_Email__c+'", "agency_email":"toannguye1110@gmail.com" }';
     }
     public static string getJsonCase10(User us){
        return '{"Name":"test12","Website": "","Customer_email":"toannguye114443@gmail.com","Phone_Number":"4457","Customer_id":"4457","Register_time":1565581474396,"Support_email":"' +us.QC_Email__c+'", "Sale_email":"' +us.QC_Email__c+'", "agency_email":"toannguye1113@gmail.com" }';
     }
}