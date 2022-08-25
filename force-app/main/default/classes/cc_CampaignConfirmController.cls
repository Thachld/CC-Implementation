public class cc_CampaignConfirmController {
    
    @AuraEnabled
    public static Campaign_Confim__c saveCampaignConfirmDB(Campaign_Confim__c confirm){
        try {
            List<Campaign_Confim__c> exconfirm = new List<Campaign_Confim__c>();
            exconfirm = [SELECT Id, Campaign__c,  Campaign_Member__c, Comment__c, IsNotJoin__c, Contact__c
                        FROM Campaign_Confim__c 
                        WHERE Campaign__c =:confirm.Campaign__c AND Campaign_Member__c =:confirm.Campaign_Member__c  LIMIT 1 ];

            if(exconfirm != null && exconfirm.size() > 0){
                exconfirm[0].IsNotJoin__c = confirm.IsNotJoin__c;
                exconfirm[0].Comment__c = confirm.Comment__c;
                exconfirm[0].Contact__c = confirm.Campaign_Member__c;

                update exconfirm;
                return exconfirm[0];
            }else{
                
                confirm.Contact__c = confirm.Campaign_Member__c;
                insert confirm;
                return confirm;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
}