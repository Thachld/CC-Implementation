public with sharing class cc_SyncEmailActivitiesController {
    public Id campaignId {get;set;}
    public Campaign camp {get;set;}
    public Boolean refreshPage {get;set;}

    public cc_SyncEmailActivitiesController(ApexPages.StandardController sdtController) {
        this.campaignId = sdtController.getId();
        camp = [SELECT Id, Status, IsActive FROM Campaign WHERE Id =: this.campaignId];
    }


    public Pagereference syncEmailActivities(){
        if(camp.IsActive != true){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not calculate for Received Hom'));
            return null;
        }
        try {
            attemptsyncEmailActivities(this.campaignId);
            PageReference tempPage = ApexPages.currentPage();           
            tempPage.setRedirect(true);
            refreshPage = true;
            return null; 
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }    
    }

    public void attemptsyncEmailActivities(String campaignId){
        Map<String,CampaignMember> updateMembers = new Map<String,CampaignMember>();
        Map<String,CampaignMember> mapMembers = new Map<String,CampaignMember>();
        Set<String> templateIds = new Set<String>();

        System.debug('this.campaignId         =>' + campaignId         );
        for(CampaignMember member: [SELECT Id, FirstOpenedDate__c, LastOpenedDate__c, Recipient__c, EmailTemplateId__c , Status
                                FROM CampaignMember 
                                WHERE CampaignId = :campaignId                                                  
                                ]){
            if(!String.isBlank(member.Recipient__c)){
                if(!String.isBlank(member.EmailTemplateId__c)){
                    String recipient = member.Recipient__c;
                    String emailTemplateId = member.EmailTemplateId__c;
                    String key = emailTemplateId.trim() + '###' + recipient.trim();               
                    if(!mapMembers.containsKey(key)){
                        mapMembers.put(key, member);
                    }

                    templateIds.add(member.EmailTemplateId__c);
                }            
            } 
        }   

        System.debug('mapMembers=>' + mapMembers);
        System.debug('templateIds=>' + templateIds);
        for(EmailMessage em : [SELECT EmailTemplateId, FirstOpenedDate, LastOpenedDate, ToAddress,RelatedToId   FROM EmailMessage 
                                WHERE EmailTemplateId IN :templateIds
                                    AND IsTracked = true         
                                ORDER BY EmailTemplateId, CreatedDate ASC                                                        
                                    ]){
            if(!String.isBlank(em.EmailTemplateId) && !String.isBlank(em.ToAddress) && String.isBlank(em.RelatedToId)){
                String recipient = em.ToAddress;
                String emailTemplateId = em.EmailTemplateId;
                String key = emailTemplateId.trim() + '###' + recipient.trim();
                System.debug('key=>' + key);
                if(mapMembers.containsKey(key)){
                    CampaignMember mem = mapMembers.get(key);
    
                    mem.FirstOpenedDate__c = em.FirstOpenedDate;
                    mem.LastOpenedDate__c = em.LastOpenedDate;     
                    mem.Status = 'Opened';
    
                    updateMembers.put(key,mem);
                }
            }
        }
        
        System.debug('updateMembers=>' + updateMembers);
        if(updateMembers.size() > 0){
            Database.update(updateMembers.values(), false);
        }
    }
}