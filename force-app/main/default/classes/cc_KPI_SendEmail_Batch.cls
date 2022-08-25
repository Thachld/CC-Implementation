public class cc_KPI_SendEmail_Batch implements Database.Batchable<SObject>{
    private String kpiPeriod {get;set;}
    private Set<String> kpireporttypes {get;set;}
    private Set<String> runinkpis {get;set;}
    private String sqlStr {get;set;}
    

    public cc_KPI_SendEmail_Batch(String pperiod, Set<String> pkpireporttypes, Set<String> pkpi) {
        this.kpiPeriod = pperiod;
        this.kpireporttypes = pkpireporttypes;
        this.runinkpis = pkpi;

        if(pkpi != null && pkpi.size() > 0){
            this.sqlStr = 'SELECT Name, Id, RecordType.DeveloperName, OwnerId ';            
            this.sqlStr = this.sqlStr + ' FROM KPI__c WHERE Period__c =:kpiPeriod';
            this.sqlStr = this.sqlStr + ' AND  RecordType.DeveloperName IN :kpireporttypes';
            this.sqlStr = this.sqlStr + ' AND Status__c != \'Confirmed\'';
            this.sqlStr = this.sqlStr + ' AND Id IN :runinkpis';
        }else{
            this.sqlStr = 'SELECT Name, Id, RecordType.DeveloperName, OwnerId ';            
            this.sqlStr = this.sqlStr + ' FROM KPI__c WHERE Period__c =:kpiPeriod';
            this.sqlStr = this.sqlStr + ' AND  RecordType.DeveloperName IN :kpireporttypes';
            this.sqlStr = this.sqlStr + ' AND Status__c != \'Confirmed\'';
        }

        System.debug('this.sqlStr=>' + this.sqlStr);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(this.sqlStr);
    }

    public void execute(Database.BatchableContext bc, List<KPI__c> scope){
        System.debug('scope=>' + scope.size());
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Map<String,List<Attachment>> mapAttachfiles = new Map<String,List<Attachment>>();
        Map<String,List<Messaging.EmailFileAttachment>> mapEfas = new Map<String,List<Messaging.EmailFileAttachment>>();
        String saleemailtemplateId;
        String supportemailtemplateId;
        Boolean isSendSaleEmail;

        cc_KPI_Setting__c kpisetting = cc_KPI_Setting__c.getInstance('ccKPISetting');
        EmailTemplate saletemplate = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName =: kpisetting.SaleEmailtemplate__c LIMIT 1];
        EmailTemplate supporttemplate = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName =: kpisetting.SupportEmailTemplate__c LIMIT 1];

        saleemailtemplateId = saletemplate.Id;
        supportemailtemplateId = supporttemplate.Id;
        isSendSaleEmail = kpisetting.SendEmailToSale__c;

        
        Set<String> kpiIds = new Set<String>();
        for(KPI__c kpi: scope){
            kpiIds.add(kpi.Id);
        }

        if(kpiIds.size() > 0){
            for(Attachment att: [SELECT Name, Body, ContentType, ParentId FROM Attachment WHERE ParentId IN :kpiIds] ){
                if(mapAttachfiles.containsKey(att.ParentId)){
                    mapAttachfiles.get(att.ParentId).add(att);
                }else {
                    mapAttachfiles.put(att.ParentId, new List<Attachment>{att});
                }
            }
        }

        if(isSendSaleEmail){
            //get attachment files
            if(mapAttachfiles.size() > 0){
                for(String kpiId : mapAttachfiles.keySet() ){
                    List<Attachment> atts = mapAttachfiles.get(kpiId);

                    for(Attachment att : atts){
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        Blob body = (Blob)att.Body;               
                        efa.setFileName(att.Name);
                        efa.setContentType(att.ContentType);
                        efa.setInline(false);
                        efa.setBody(body);

                        if(mapEfas.containsKey(kpiId)){
                            mapEfas.get(kpiId).add(efa);
                        }else{
                            mapEfas.put(kpiId, new List<Messaging.EmailFileAttachment>{efa});
                        }
                    }

                }
            }


            //Generate Single email message
            for(KPI__c kpi: scope){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                if(kpi.RecordType.DeveloperName== 'Sale_KPI' && !String.isBlank(saleemailtemplateId)){                
                    mail = Messaging.renderStoredEmailTemplate(saleemailtemplateId, kpi.OwnerId, kpi.Id);
                }else if(kpi.RecordType.DeveloperName== 'Support_KPI' && !String.isBlank(supportemailtemplateId)){                         
                    mail = Messaging.renderStoredEmailTemplate(supportemailtemplateId, kpi.OwnerId, kpi.Id);
                }            

                if(mail !=null ){ 
                    String subject = mail.getSubject() + kpi.Name;   
                    mail.setSubject(subject);
                    mail.setReplyTo('salesforce@coccoc.com');
                    mail.setSenderDisplayName('Cốc Cốc Salesforce');                   
                    mail.setSaveAsActivity(false);
                    mail.setUseSignature(false);                       
                    mail.setBccSender(false);    
                    
                    if(mapEfas.containsKey(kpi.Id)){
                        mail.setFileAttachments(mapEfas.get(kpi.Id));
                    }

                    emails.add(mail);

                }
            }

            System.debug('emails' + emails.size());
            if(emails.size() > 0){
                try { 
                    Messaging.sendEmail(emails,true);   
        
                } catch (Exception e) {
                    System.debug(e.getMessage());
                }    
            }
        }    
    }

    public void finish(Database.BatchableContext bc){
        
    }
}