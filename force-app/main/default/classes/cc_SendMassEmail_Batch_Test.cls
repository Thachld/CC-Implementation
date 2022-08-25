@istest
public with sharing class cc_SendMassEmail_Batch_Test {
    @TestSetup
    static void testsetup(){
        Campaign camp = cc_initData.initCampaign('Promotion Campaign Test',System.today() - 20);
        Insert camp;
        List<Account> listInsertAcc = new List<Account>();
        List<Contact> listInsertCon = new List<Contact>();
        List<Lead> listInsertlead = new List<Lead>();
        List<CampaignMember> members = new List<CampaignMember>();

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        insert u1;

        for(Integer i = 0; i < 150; i++){
            Account acc = cc_initData.initAccount('Test Account - ' + String.valueOf(i));
            listInsertAcc.add(acc);
        }
        insert listInsertAcc;


        for(Integer i = 0; i < 150; i++){
            Contact con  = cc_initData.initContact('Test Contact - ' + String.valueOf(i), listInsertAcc[i].Id);
            con.Email = 'vnacapa' + String.valueOf(i) + '@gmail.com';

            listInsertCon.add(con);
        }
        
        insert listInsertCon;


        for(Integer i = 0; i < 150; i++){
            Lead ld  = cc_initData.initLead('Test Lead - ' + String.valueOf(i), 'vnacapa' + String.valueOf(i) + '@gmail.com', 'https://www.facebook' + String.valueOf(i)+ '.com');            
            ld.OwnerId = u1.Id;
            listInsertlead.add(ld);
        }
        insert listInsertlead;


        for(Integer i = 0; i < 70; i++){
            CampaignMember member = cc_initData.initCampaignMember(camp.Id, listInsertCon[i].Id);
            members.add(member);
        }

        for(Integer i = 0; i < 70; i++){
            CampaignMember member = cc_initData.initCampaignMember(camp.Id, listInsertlead[i].Id, '');

            members.add(member);
        }
        
        insert members;


        

    }


    public testMethod static void testSendemailtoContact(){
        EmailTemplate emailtemp = cc_initData.initEmailTemplate('Test Template', 'Test_Template', 'Subject of template','Body OF template ');
        insert emailtemp;

        Test.startTest();

            Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Promotion Campaign Test' LIMIT 1];

            cc_SendMassEmail_Batch batch = new cc_SendMassEmail_Batch(emailtemp.Id, 'Contact', camp.Id, null);
            Database.executeBatch(batch,150);


        Test.stopTest();

    }


    public testMethod static void testSendemailtoLead(){
        EmailTemplate emailtemp = cc_initData.initEmailTemplate('Test Template', 'Test_Template', 'Subject of template','Body OF template ');
        insert emailtemp;

        Test.startTest();

            Campaign camp = [SELECT Id FROM Campaign WHERE Name = 'Promotion Campaign Test' LIMIT 1];

            cc_SendMassEmail_Batch batch = new cc_SendMassEmail_Batch(emailtemp.Id, 'Lead', camp.Id, null);
            Database.executeBatch(batch,150);


        Test.stopTest();

    }
}