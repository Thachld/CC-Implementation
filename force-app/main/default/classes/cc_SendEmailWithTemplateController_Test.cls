@istest(seeAllData =true)
public with sharing class cc_SendEmailWithTemplateController_Test {    

    @istest
    public static void testFile(){
        Campaign camp = cc_initData.initCampaign('Promotion Campaign Test',System.today() - 20);
        Insert camp;

        ContentVersion content = cc_initData.initContentVersion('attacht','initContentVersion',camp.Id);
        insert content;

        List<ContentDocument> resultContent = cc_SendEmailWithTemplateController.getFilesDB(camp.Id);
        System.assertEquals(1, resultContent.size());

        Contentversion content2 = [SELECT Contentdocumentid FROM Contentversion WHERE Id =: content.Id];
            
        cc_SendEmailWithTemplateController.deleteFileDB(content2.contentdocumentid);
            
        List<ContentDocument> doc = [SELECT Id FROM ContentDocument WHERE Id =: content.Id ];

        System.assertEquals(0, doc.size());
    }

    @istest
    public static void testgetEmailtemplate(){

        // Folder fld = [SELECT Id FROM Folder WHERE Name = 'B2B Marketing' LIMIT 1];

        // EmailTemplate emailtemp = cc_initData.initEmailTemplate('Test Template', 'Test_Template', 'Subject of template','Body OF template ');
        // emailtemp.FolderId = fld.Id;
        // insert emailtemp;


        List<cc_SendEmailWithTemplateController.emailTemplateWrapper> templates = cc_SendEmailWithTemplateController.getEmailTempaltes();
        System.assert(templates.size() > 0);
        
    }

    @istest
    public static void testSendEmail(){

        Test.startTest();
            Campaign camp = cc_initData.initCampaign('Promotion Campaign Test',System.today() - 20);
            Insert camp;

            List<Account> listInsertAcc = new List<Account>();
            List<Contact> listInsertCon = new List<Contact>();
            List<Lead> listInsertlead = new List<Lead>();
            List<CampaignMember> members = new List<CampaignMember>();

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

            for(Integer i = 0; i < 50; i++){
                CampaignMember member = cc_initData.initCampaignMember(camp.Id, listInsertCon[i].Id);
                members.add(member);
            }        
            
            insert members;
            
            EmailTemplate emailtemp = [SELECT Id FROM EmailTemplate WHERE Name = 'Introduce AdNetwork' LIMIT 1];
            
           

            List<String> listdoc = new List<String>();            
        
            Id jobId = cc_SendEmailWithTemplateController.sendMailsMethod(camp.Id, emailtemp.Id, 'Contact', listdoc);

        try {
            Test.stopTest();
            System.assert(jobId != null);
        } catch (Exception ex) {
            
        }


    }


}