@isTest
public class cc_UpdateQCToSF_API_Test {
    @isTest
    public static void testUpdateQCToSFtoSF(){
        cc_setting__c setting = cc_initData.initCustomeSetting();
        insert setting;
        Account acc = cc_initData.initAccount();
        insert acc;
        QC_Account__c qcAccount1 = cc_initData.initQCAccount();
        qcAccount1.Name = 'testupdate@abc.com';
        //qcAccount1.AccountOwner__c = acc.id;
        qcAccount1.QC_Account_Id__c = '641781';
        insert qcAccount1;
        
        Relationship__c relationship = cc_initData.initRelationship(qcAccount1.id, acc.id);
        insert relationship;
        User us = [select id, email,QC_Email__c from user where IsActive = true and QC_Email__c != null limit 1];
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI  = '/services/apexrest/qctosf';
        //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
        req.httpMethod = 'POST';    
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof(getJsonCase1(us));
        string str = cc_UpdateQCToSF_API.doPostAccountFromQCSystem();
       
        QC_Account__c qcAccount = cc_initData.initQCAccount();
        qcAccount.QC_Account_Id__c = '2954';
        qcAccount.name = 'mcc@abc.com';
        insert qcAccount;
        Account acc1 = cc_initData.initAccount();
        acc1.Name = 'test2';
        insert acc1;
        QC_Account__c qcAccount2 = cc_initData.initQCAccount();
        qcAccount2.QC_Account_Id__c = '29541';
        qcAccount2.name = 'mcc1@abc.com';
        insert qcAccount2;
        
        Relationship__c relationship1 = cc_initData.initRelationship(qcAccount.id, acc1.id);
        insert relationship1;
        
       
        Lead l = cc_initData.initLead();
        l.QC_Account_Id__c = '641781';
        l.Email = 'toannguye115@gmail.com';
        l.Status = 'New';
        l.Website = 'abc.com';
        insert l;
        req.requestBody = Blob.valueof(getJsonCase4(us));
        cc_UpdateQCToSF_API.doPostAccountFromQCSystem();
        
        str = cc_UpdateQCToSF_API.doPostAccountFromQCSystem();
        req.requestBody = Blob.valueof(getJsonCase2(us));
        str = cc_UpdateQCToSF_API.doPostAccountFromQCSystem();
        
        
        req.requestBody = Blob.valueof(getJsonCase3(us));
        str = cc_UpdateQCToSF_API.doPostAccountFromQCSystem();
        req.requestBody = Blob.valueof(getJsonCase5(us));
        str = cc_UpdateQCToSF_API.doPostAccountFromQCSystem();


        req.requestBody = Blob.valueof(getJsonCase6(us));
        str = cc_UpdateQCToSF_API.doPostAccountFromQCSystem();

    }
    public static string getJsonCase1(User us){
        return '{"Customer_id":2954,"Customer_industry":"Airlines","Customer_sale_email":"' + us.QC_Email__c+ '","Customer_support_email":"' +us.QC_Email__c+ '"}';
    }
    public static string getJsonCase2(User us){
        return '{"Customer_id":2954,"Customer_mcc_email": "testupdate@abc.com","Customer_industry":"Airlines","Customer_sale_email":"' + us.QC_Email__c+ '","Customer_support_email":"' +us.QC_Email__c+ '"}';
    }
    public static string getJsonCase3(User us){
        return '1{"Customer_id":2954,"Customer_mcc_email": "testupdate@abc.com","Customer_industry":"Airlines","Customer_sale_email":"' + us.QC_Email__c+ '","Customer_support_email":"' +us.QC_Email__c+ '"}';
    }
     public static string getJsonCase4(User us){
        return '{"Customer_id":641781,"Customer_mcc_email": "mcc@abc.com","Customer_industry":"Airlines","Customer_sale_email":"' + us.QC_Email__c+ '","Customer_support_email":"' +us.QC_Email__c+ '"}';
    }
    public static string getJsonCase5(User us){
        return '{"Customer_id":641781,"Customer_mcc_email": "mcc1@abc.com","Customer_industry":"Airlines","Customer_sale_email":"' + us.QC_Email__c+ '","Customer_support_email":"' +us.QC_Email__c+ '"}';
    }

    public static string getJsonCase6(User us){
        return '{"Customer_id":29541,"Customer_mcc_email": "mcc@abc.com","Customer_industry":"","Customer_sale_email":"","Customer_support_email":""}';
    }
}