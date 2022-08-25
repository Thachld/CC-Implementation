@istest(seeAllData=true)
public with sharing class cc_SyncEmailActivitiesController_Test {
    
    @istest
    public static void testSync(){
        List<Account> listInsertAcc = new List<Account>();
        List<Contact> listInsertCon = new List<Contact>();
        List<Lead> listInsertlead = new List<Lead>();
        List<CampaignMember> members = new List<CampaignMember>();
        List<EmailMessage> ems = new List<EmailMessage>();

        Campaign camp = cc_initData.initCampaign('Promotion Campaign Test',System.today() - 20);
        Insert camp;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        for(Integer i = 0; i < 50; i++){
            Account acc = cc_initData.initAccount('Test Account - ' + String.valueOf(i));
            listInsertAcc.add(acc);
        }
        insert listInsertAcc;

        for(Integer i = 0; i < 50; i++){
            Contact con  = cc_initData.initContact('Test Contact - ' + String.valueOf(i), listInsertAcc[i].Id);
            con.Email = 'vnacapa' + String.valueOf(i) + '@gmail.com';

            listInsertCon.add(con);
        }        
        insert listInsertCon;
        
        EmailTemplate emailtemp = [SELECT Id FROM EmailTemplate WHERE Name = 'New Ads Campaign' LIMIT 1];

        for(Integer i = 0; i < 50; i++){
            CampaignMember member = cc_initData.initCampaignMember(camp.Id, listInsertCon[i].Id);
            member.EmailTemplateId__c = emailtemp.Id;
            members.add(member);
        }        
        
        insert members;


        for(Integer i = 0; i < 50; i++){
            
            EmailMessage em = new EmailMessage();
            em.EmailTemplateId = emailtemp.Id;
            em.FirstOpenedDate = System.now();
            em.LastOpenedDate = System.now();
            em.ToAddress = listInsertCon[i].Email;
            em.IsTracked = true;

            ems.add(em);
        }

        insert ems;




        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        cc_SyncEmailActivitiesController ctrl = new cc_SyncEmailActivitiesController(sc);
        ctrl.syncEmailActivities();

    }

    @istest
    public static void testError(){
        Campaign camp = cc_initData.initCampaign('Promotion Campaign Test',System.today() - 20);
        Insert camp;

        camp.IsActive = false;
        update camp;

        ApexPages.StandardController sc = new ApexPages.StandardController(camp);
        cc_SyncEmailActivitiesController ctrl = new cc_SyncEmailActivitiesController(sc);
        ctrl.syncEmailActivities();

    }
}