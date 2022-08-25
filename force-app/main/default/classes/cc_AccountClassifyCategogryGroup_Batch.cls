global class cc_AccountClassifyCategogryGroup_Batch implements Database.Batchable<SObject>{
    private Date rundate {get;set;}
    private Date startclassifyDate {get;set;}
    private String industry {get;set;}
    private Boolean isManual {get;set;}
    private List<ClientCategoryDetail__mdt> catdetail {get;set;}
    private String agency{get;set;}

    public cc_AccountClassifyCategogryGroup_Batch(Date prundate, Date pstartclassifyDate, String pindustry, String pagency, Boolean pisManual , List<ClientCategoryDetail__mdt> pcatdetail) {
        this.rundate = prundate ==null? System.today(): prundate;
        this.isManual = pisManual;
        this.startclassifyDate = pstartclassifyDate;
        this.industry = pindustry;
        this.catdetail = pcatdetail;
        this.agency = pagency;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, DeveloperName, Industry__c, PeriodNumber__c,PeriodType__c, StartClassifyDate__c,
                                        RecipientId__c,EmailTemplate__c, Agency__c
                                        FROM ClientCategory__mdt WHERE Active__c = true]);         

    }

    public void execute(Database.BatchableContext bc, List<ClientCategory__mdt> scope){  
        List<ClientCategoryDetail__mdt> catDetail = new List<ClientCategoryDetail__mdt>();
        Set<String> processedAccIds = new Set<String>();
        List<Account> listUpdateAccs = new List<Account>();   
        Map<String,AccountCategoryhistory__c> mapHis = new Map<String,AccountCategoryhistory__c>();
        ClientCategory__mdt catg = new ClientCategory__mdt();
        Date fromDT;
        Date toDT;
        String period_type;
        Date startCountDate;
        String industry;
        String agency;
        String reciepentId;
        Integer period_num;
        String emailtemplateId;

        if(this.isManual){            
            period_type =  'Manual';
            startCountDate = this.startclassifyDate;
            industry = this.industry;  
            agency  = this.agency;
            catDetail = this.catdetail;            
        }else{
        //run only one Category per batch (Batch size must equal 1)
            catg = scope[0];        

            period_num =  (Integer)catg.PeriodNumber__c;
            period_type =  (String)catg.PeriodType__c;
            startCountDate = (Date)catg.StartClassifyDate__c;
            industry = (String)catg.Industry__c;    
            agency = (String)catg.Agency__c;    
            reciepentId = (String)catg.RecipientId__c;
            emailtemplateId = (String)catg.EmailTemplate__c;
            catDetail = [SELECT CategoryGroup__c, RangeFrom__c, RangeTo__c FROM ClientCategoryDetail__mdt WHERE ClientCategory__c =:catg.Id ];   
        }

        Boolean isValidSchedule  = false; 
        String classified_Period; 
        //Check valid schedule date
        //System.debug('Math.mod(days, 7)' + Math.mod(days, 7));
        if(period_type == 'Day' && this.rundate >= startCountDate){
            isValidSchedule = true;

            toDT = this.rundate - 1;
            fromDT = this.rundate.addDays(-period_num);
            classified_Period = String.valueOf(period_num) + ' ' + period_type;

        }else if(period_type == 'Week' && this.rundate >= startCountDate){
            Integer days =  this.rundate.daysBetween(startCountDate);   
            
            System.debug('Math.mod(days, 7)' + Math.mod(days, 7));
            if(Math.mod(days, 7) == 0){
                isValidSchedule = true;

                toDT = this.rundate - 1;
                fromDT = this.rundate - ( period_num * 7);
                classified_Period = String.valueOf(period_num) + ' ' + period_type;
            }
        }else if(period_type == 'Month'){
            Integer startday =  startCountDate.day();
            Integer runday =  this.rundate.day();
            if(startday == runday && startCountDate.month() != this.rundate.month()){
                isValidSchedule = true;

                toDT = this.rundate - 1;
                fromDT = this.rundate.addMonths(-period_num);
                classified_Period = String.valueOf(period_num) + ' ' + period_type;
            }
        }else if(period_type == 'Manual'){
            isValidSchedule = true;
            toDT = this.rundate - 1;
            fromDT = this.startclassifyDate;
            Integer days = this.rundate.daysBetween(this.startclassifyDate);
            classified_Period = String.valueOf(days) + ' ' + period_type;
        }
        
        String[] agency_arr = agency.split(',');

        System.debug('period_type => ' + period_type); 
        System.debug('isValidSchedule => ' + isValidSchedule); 
        System.debug('toDT => ' + toDT);
        System.debug('fromDT => ' + fromDT);
        System.debug('industry => ' + industry);
        System.debug('catDetail => ' + catDetail);
        
        if(isValidSchedule && toDT != null && fromDT !=null && toDT > fromDT  && !String.isBlank(industry) && catDetail != null && agency_arr != null){                  

            Datetime fromDateTime = Datetime.newInstance(fromDT.year(), fromDT.month(), fromDT.day(), 0,0,0);       
            Datetime toDateTime = Datetime.newInstance(toDT.year(), toDT.month(), toDT.day(), 23,59,59); 

            for(AggregateResult arr : [SELECT Accounts__c Account, SUM(Total_Spending__c) Total_Spending__c
                                        FROM QC_Account_Data__c
                                        WHERE Industry__c = :industry
                                            AND syn_date__c >=: fromDateTime
                                            AND syn_date__c <=: toDateTime
                                            AND Total_Spending__c > 0
                                            AND Agency__c IN :agency_arr
                                        GROUP BY Accounts__c
                                        ]){
                Decimal spending =  (Decimal)arr.get('Total_Spending__c');
                String accId = (String)arr.get('Account');                              

                if(!String.isBlank(accId)){
                    for(ClientCategoryDetail__mdt con : catDetail){
                        if(spending > con.RangeFrom__c && spending <= con.RangeTo__c && !String.isBlank(con.CategoryGroup__c)){
                            Account acc = new Account();
                            acc.Id = accId;
                            acc.CategoryGroup__c = con.CategoryGroup__c;
                            acc.ClassifyPeriod__c = classified_Period;
                            acc.LastSpending__c = spending;
                            
                            listUpdateAccs.add(acc);
                            processedAccIds.add(accId);


                            AccountCategoryhistory__c his = new AccountCategoryhistory__c();
                            his.CategoryGroup__c = con.CategoryGroup__c;
                            his.ClassifyPeriod__c = classified_Period;
                            his.LastSpending__c = spending;
                            his.Account__c = accId;
                            his.RunningDate__c = this.rundate;
                            if(!mapHis.containsKey(accId)){
                                mapHis.put(accId,his);
                            }
                            
                        }
                    }
                }                
            }

            //Account not Spending in runing period
            for(Account acc: [SELECT Id, CategoryGroup__c, ClassifyPeriod__c  FROM Account WHERE Id NOT IN : processedAccIds AND Industry__c = :industry] ){            
                acc.CategoryGroup__c = 'Stop Spending';
                acc.ClassifyPeriod__c = classified_Period;
                acc.LastSpending__c = 0;
                listUpdateAccs.add(acc);

                AccountCategoryhistory__c his = new AccountCategoryhistory__c();
                his.CategoryGroup__c = 'Stop Spending';
                his.ClassifyPeriod__c = classified_Period;
                his.LastSpending__c = 0;
                his.Account__c = acc.Id;
                his.RunningDate__c = this.rundate;     
                if(!mapHis.containsKey(acc.Id)){
                    mapHis.put(acc.Id,his);
                }  
            }
        }

        

        System.debug('listUpdateAccs.size()=>' + listUpdateAccs.size());
        if(listUpdateAccs.size() > 0){
            Database.update(listUpdateAccs, false);               
            
            EmailTemplate template = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :emailtemplateId LIMIT 1];

            if(!String.isBlank(reciepentId) && !String.isBlank(template.Id)){
                SendEmail(reciepentId, template.Id);
            }  
            
            if(mapHis.values().size() > 0){
                Database.insert(mapHis.values(), false);   
            }
        }

    }

    public void finish(Database.BatchableContext bc){

    }


    public static void SendEmail(String userId, String templateId){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
        mail = Messaging.renderStoredEmailTemplate(templateId, userId, userId);

        Messaging.SingleEmailMessage newmail = new Messaging.SingleEmailMessage();          
        
        String senderName = 'SF Team';
        String senderEmail = 'salesforce@coccoc.com';
        EmailMessage em = new EmailMessage ();                        

        newmail.setTemplateId(mail.getTemplateId());
        newmail.setToAddresses(mail.getToAddresses());                       
        newmail.setTargetObjectId(mail.getTargetObjectId());
        newmail.setHtmlBody(mail.getHtmlBody());
        newmail.setSubject(mail.getSubject());
        newmail.setReplyTo(senderEmail);
        newmail.setSenderDisplayName(senderName);                   
        newmail.setSaveAsActivity(false);
        newmail.setUseSignature(false);                       
                
        emails.add(newmail);

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