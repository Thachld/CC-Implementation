global class cc_SendMassEmail_Batch implements Database.Batchable<sObject>{
    public String emailtemplateId {get;set;}
    public String reciepenttype {get;set;}
    public String campaignId {get;set;}
    public Set<String> docIds {get;set;}


    public cc_SendMassEmail_Batch(String pemailtemplateId, String preciepenttype, String pcampaignId, Set<String> pdocIds) {
        this.emailtemplateId = pemailtemplateId;
        this.reciepenttype = preciepenttype;
        this.campaignId = pcampaignId;        
        this.docIds = pdocIds == null? new Set<String>(): pdocIds;
    }


    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, ContactId,LeadId, EmailTemplateId__c FROM CampaignMember WHERE CampaignId = :this.campaignId]);
    }


    public void execute(Database.BatchableContext bc, List<CampaignMember> scope){
        Set<String> conIds = new Set<String>();
        Set<String> leadIds = new Set<String>();
        Map<String, Contact> mapCon ;
        Map<String, Lead> mapLead ;
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<CampaignMember> listMembers = new List<CampaignMember>();
        EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE Id =: this.emailtemplateId LIMIT 1];
        Map<String,String> mapMember = new Map<String,String>();
        List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
        Boolean isHasAttachment = false;


        for(CampaignMember member: scope){
            if(this.reciepenttype == 'Contact' && !String.isBlank(member.ContactId)){
                conIds.add(member.ContactId);   
                mapMember.put(member.ContactId, member.Id);
            }else if(this.reciepenttype == 'Lead' && !String.isBlank(member.LeadId)){
                leadIds.add(member.LeadId);
                mapMember.put(member.LeadId, member.Id);
            }
        }



        //Get Document attacht ment
        List<Contentversion> cversions = [SELECT Title, PathOnClient, FileType, versiondata FROM Contentversion WHERE ContentDocumentId IN :this.docIds];

        if(cversions.size() > 0){
            for(Contentversion cversion : cversions){
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                Blob body = (Blob)cversion.versiondata;               
                efa.setFileName(cversion.PathOnClient);
                efa.setInline(false);
                efa.setBody(body);

                efas.add(efa);

                isHasAttachment = true;
            }
        }
        


        //Contact
        if(conIds.size() > 0){

            mapCon = new Map<String,Contact>([SELECT Id, Name, Email, Owner.FirstName , Owner.LastName, Owner.Email FROM Contact WHERE Id IN: conIds]);

            for(String conId : conIds){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                mail = Messaging.renderStoredEmailTemplate(this.emailtemplateId, conId, conId);
                Contact con = mapCon.get(conId);
                if(con != null){
                    if(mail !=null && !String.isBlank(con.Owner.Email) ){
                        CampaignMember member = new CampaignMember();
                        Messaging.SingleEmailMessage newmail = new Messaging.SingleEmailMessage();   
                        String senderName = con.Owner.LastName;
                        String senderEmail = con.Owner.Email;
                        EmailMessage em = new EmailMessage ();                        

                        newmail.setTemplateId(mail.getTemplateId());
                        newmail.setToAddresses(mail.getToAddresses());                       
                        newmail.setTargetObjectId(mail.getTargetObjectId());
                        newmail.setHtmlBody(mail.getHtmlBody());
                        newmail.setSubject(mail.getSubject());
                        newmail.setReplyTo(senderEmail);
                        newmail.setSenderDisplayName(senderName);                   
                        newmail.setSaveAsActivity(true);
                        newmail.setUseSignature(false);                       
                        newmail.setBccSender(true);    
                        
                        
                        if(isHasAttachment && efas.size() > 0){
                            newmail.setFileAttachments(efas);
                        }
    
                        emails.add(newmail);

                        if(mapMember.get(conId) != null){
                            member.EmailTemplateId__c = this.emailtemplateId;   
                            member.EmailTemplate__c = template.Name==null?'':template.Name;                         
                            member.Id = mapMember.get(conId);
                            member.Status = 'Sent';

                            listMembers.add(member);
                        }
                        
                       
                    }
                }                
            }
        }

        //Lead
        if(leadIds.size() > 0){

            mapLead = new Map<String,Lead>([SELECT Id, Name, Email, Owner.FirstName , Owner.LastName, Owner.Email FROM Lead WHERE Id IN: leadIds]);

            for(String leadId : leadIds){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                mail = Messaging.renderStoredEmailTemplate(this.emailtemplateId, leadId, leadId);
                Lead lead = mapLead.get(leadId);
                if(lead != null){
                    System.debug('mail => ' + mail);
                    System.debug('lead.Owner.Email => ' + lead.Owner.Email);
                    if(mail !=null && !String.isBlank(lead.Owner.Email) ){
                        CampaignMember member = new CampaignMember();
                        Messaging.SingleEmailMessage newmail = new Messaging.SingleEmailMessage();   
                        String senderName = lead.Owner.LastName;
                        String senderEmail = lead.Owner.Email;

                        newmail.setTemplateId(mail.getTemplateId());
                        newmail.setToAddresses(mail.getToAddresses());
                        newmail.setTargetObjectId(mail.getTargetObjectId());
                        newmail.setHtmlBody(mail.getHtmlBody());
                        newmail.setSubject(mail.getSubject());
                        newmail.setReplyTo(senderEmail);
                        newmail.setSenderDisplayName(senderName);  
                        newmail.setBccSender(true); 

                        newmail.setSaveAsActivity(true);
                        newmail.setUseSignature(false);
                        if(isHasAttachment && efas.size() > 0){
                            newmail.setFileAttachments(efas);
                        }                                               
    
                        emails.add(newmail);
    
                        if(mapMember.get(leadId) != null){
                            member.EmailTemplateId__c = this.emailtemplateId;  
                            member.EmailTemplate__c = template.Name==null?'':template.Name;                             
                            member.Id = mapMember.get(leadId);
                            member.Status = 'Sent';

                            listMembers.add(member);
                        }
                    }
                }
            }
        }



        System.debug('emails' + emails.size());
        if(emails.size() > 0){
            try {            

                Messaging.sendEmail(emails,true);    
                Database.update(listMembers,false);
    
            } catch (Exception e) {
                System.debug(e.getMessage());
            }    
        }
       
    }


    public void finish(Database.BatchableContext bc){

    }
}