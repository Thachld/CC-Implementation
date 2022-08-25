@istest
public class cc_CampaignConfirmController_Test {
    @TestSetup
    static void testSetup(){
        Account acc = cc_initData.initAccount('Test Account');
        insert acc;

        Contact con = cc_initData.initContact('Test Contact', acc.Id);
        insert con;

        Campaign camp = cc_initData.initCampaign('Test Campaign', System.today());
        insert camp;

        CampaignMember member = cc_initData.initCampaignMember(camp.Id, con.id);
        insert member;

    }

    public testmethod static void testSaveConfirmation(){

        Campaign camp = [SELECT Id FROM Campaign WHERE name = 'Test Campaign' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Test Contact' LIMIT 1];

        Campaign_Confim__c confirm = new Campaign_Confim__c();
        confirm.Campaign__c = camp.id;
        confirm.Campaign_Member__c = con.Id;
        confirm.IsNotJoin__c = false;

        Campaign_Confim__c testconfimr = cc_CampaignConfirmController.saveCampaignConfirmDB(confirm);

        System.assert(testconfimr != null);

        Campaign_Confim__c  slectConfirm = [SELECT Id,IsNotJoin__c, Comment__c  FROM Campaign_Confim__c WHERE Campaign__c =: camp.id AND Campaign_Member__c = : con.Id LIMIT 1];


        System.assertEquals(testconfimr.Id, slectConfirm.Id);

        slectConfirm.IsNotJoin__c = true;
        slectConfirm.Comment__c = 'Test Comment';

        Campaign_Confim__c updateconfimr = cc_CampaignConfirmController.saveCampaignConfirmDB(confirm);


    }
}