public with sharing class MassGenerateCoupon_Controller {
    public Id campId {get;set;}
    public Campaign camp {get;set;}
    public Boolean refreshPage {get;set;}
    public Contentversion file {get;set;}
    public List<String> logs {get;set;}
    public list<SelectOption> fileoptions {get; set;}
    public String selectedfileId {get; set;}
    
    public MassGenerateCoupon_Controller(Apexpages.StandardController std) {
        this.campId = std.getId();
        getCampaign();
        this.logs = new List<String>();
        this.fileoptions = this.getFiles(this.campId);
        this.refreshPage = false;
    }


    public list<SelectOption> getFiles(String campId){
        List<SelectOption> options = new List<SelectOption>();
        Set<String> conttentIds = new Set<String>();

        for (ContentDocumentLink docLink : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :campId]){
            conttentIds.add(docLink.ContentDocumentId);
        }
        
        if(conttentIds.size() > 0 ){
            for(Contentversion  file: [SELECT Id, Title, PathOnClient, FileType, versiondata, ContentDocumentId FROM Contentversion WHERE ContentDocumentId IN :conttentIds AND FileType = 'CSV' AND IsLatest = true]){
                options.add(new SelectOption(file.Id,file.Title));
            }
        }

        return options;
    }


    public Pagereference importFile(){
        if(this.camp.Status != 'In Progress'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not import coupon with status not equal In Progress'));
            return null;
        }       

        try {            
            
            if(!String.isBlank(this.selectedfileId)){   
                this.file = getAttactFile(this.selectedfileId);
                if(this.file == null){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No file was found!'));  
                    return null;              
                }else{
                    PageReference tempPage;
                    processImport(this.file);
                    sendEmail(this.logs);
                    tempPage = ApexPages.currentPage();           
                    tempPage.setRedirect(true); 
                    this.refreshPage = true;
                    return null;
                }
            }else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please select file for upload!'));
                return null;    
            }      
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }

    public Pagereference massGenerateCouponToQC(){        
        
        if(String.isBlank(this.camp.QCCampaignId__c) && this.camp.Transactions_Type__r.Internal_Type__c == TransactionTypeConstant.PROMOTION){
            
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This campaign is not existing in QC'));
            return null;
        }  

        try {
            MassGenerateCouponToQC_Batch batch = new MassGenerateCouponToQC_Batch(this.camp.Id);
            Database.executeBatch(batch, 50);
            this.refreshPage = true;            
            return null; 
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }

    public Pagereference GenerateSpendingBonusCoupon(){        
        
        if(this.camp.Transactions_Type__r.Internal_Type__c == TransactionTypeConstant.MONTHLY_SPENDING_BONUS){

            try {
                MassGenerateSendingBonus_Batch batch = new MassGenerateSendingBonus_Batch(this.camp.Id);
                Database.executeBatch(batch, 50);           
                this.refreshPage = true;
            } catch (Exception ex) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                
            }
        }

        return null;
    }

    public void getCampaign(){
        this.camp = [SELECT Id, Status, Name, 
                    Owner.Email, OwnerId, CouponExpired__c , Interval_Spending_Days__c, QCCampaignId__c,
                    IsSpendingBonusCampaign__c, SpendingBonusPeriod__c, ImportLog__c,
                    Transactions_Type__r.Internal_Type__c
                    FROM Campaign WHERE Id = :this.campId];
    }

    private void processImport(Contentversion file){        
        Blob body = (Blob)file.versiondata;
        Map<String,FileWrapper> mapfileDatas = readCsv(body.toString());

        insertCoupon(mapfileDatas);
    }


    public Contentversion getAttactFile(String contentversionId){

        try {            
            Contentversion file = new Contentversion();
            file = [SELECT Id, Title, PathOnClient, FileType, versiondata FROM Contentversion WHERE Id = :contentversionId AND FileType = 'CSV' AND IsLatest = true LIMIT 1 ];
                        
            return file;
        } catch (Exception ex) {
            return null;            
        }
        
    }

    private Map<String,FileWrapper> readCsv(String csvAsString ){
        Map<String,FileWrapper> mapfileDatas = new Map<String,FileWrapper>();

        String[] csvFileRow;

        csvFileRow = csvAsString.split('\n');
        for(Integer i = 1; i< csvFileRow.size() ; i++){
            FileWrapper row = new FileWrapper();
            String[] rowData = csvFileRow[i].split(',');

            row.qcId = (String)rowData[0];
            row.qcEmail = (String)rowData[1];            
            row.Amount = (String)rowData[2];  

            if(!String.isBlank(row.qcId) && !String.isBlank(row.qcEmail) && !String.isBlank(row.Amount)){
                mapfileDatas.put(row.qcId, row);           
            }else if(String.isBlank(row.qcId) && String.isBlank(row.qcEmail) && String.isBlank(row.Amount)) {
                continue;
            }else {
                String logrow = '';  
                logrow += (String)rowData[0]==null? '':(String)rowData[0] + ',';
                logrow += (String)rowData[1]==null? '': (String)rowData[1] + ','; 
                logrow += (String)rowData[2]==null? '':  (String)rowData[2] + ',';               
                logrow += ' Missing colum value' + ',';
                logrow += String.valueOf(i);

                this.logs.add(logrow);
            }            
        }
        System.debug('mapfileDatas=>' + mapfileDatas);
        return mapfileDatas;
    }

    public void insertCoupon(Map<String,FileWrapper> mapfileDatas){
        List<Coupon__c> couponInsert = new List<Coupon__c>();
        Map<String, QC_Account__c> mapQC = new Map<String, QC_Account__c>();
            
        for (QC_Account__c qc: [SELECT QC_Account_Id__c, Id, Name FROM QC_Account__c WHERE QC_Account_Id__c IN :mapfileDatas.keyset()]){
            if(!String.isBlank(qc.QC_Account_Id__c)){
                mapQC.put(qc.QC_Account_Id__c, qc);
            }            
        }        
       
        for(FileWrapper row : mapfileDatas.values()){
            QC_Account__c qcAcc = mapQC.get(row.qcId.trim());

            if(qcAcc != null){
                Coupon__c cp = new Coupon__c();
                cp.Name = row.qcEmail.trim();          
                cp.Status__c = 'Draft';          
                cp.QC_Account__c = qcAcc.Id;
                cp.Campaign__c = this.campId;
                cp.ExpirationDate__c = Date.today().addDays(Integer.valueOf(this.camp.CouponExpired__c));
                cp.Quantity__c = 1;
                cp.IsSpendingBonusCoupon__c = this.camp.IsSpendingBonusCampaign__c;
                cp.SpendingExpirationDate__c = Date.today().addDays(Integer.valueOf(this.camp.Interval_Spending_Days__c));         

                if(row.Amount.trim().isNumeric()){
                    cp.Amount__c = Decimal.valueOf(row.Amount.trim()) ;
                    couponInsert.add(cp);
                }else {
                    String logrow = '';  

                    logrow += row.qcId == null?'' : row.qcId + ',';
                    logrow += row.qcEmail== null?'' : row.qcEmail + ',';                 
                    logrow += row.Amount == null?'' : row.Amount + ',';
                    logrow += ' Amount invalid value';                 

                    this.logs.add(logrow);                    
                }      
                
            }else {
                String logrow = '';  

                logrow += row.qcId == null?'' : row.qcId + ',';
                logrow += row.qcEmail== null?'' : row.qcEmail + ',';              
                logrow += row.Amount == null?'' : row.Amount + ',';
                logrow += 'Cannot found QC Account in Salesforce';                    

                this.logs.add(logrow); 
            }              

        }

        System.debug('couponInsert=>' + couponInsert.size());
        if(couponInsert.size() > 0){
            insert couponInsert;
        } 
    }

    public void sendEmail(List<String> logs){     
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();   
        List<String> toemails = new List<String>();  
        List<String> bccemails = new List<String>();  
        toemails.add(UserInfo.getUserEmail());   

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
        mail.setSaveAsActivity(false);  
        mail.setReplyTo('noreply@coccoc.com');
        mail.setSenderDisplayName('Cốc Cốc Salesforce');   
        mail.setSubject('[SF] - Import Coupon - '+  this.camp.Name);
        mail.setHtmlBody(              
                  '<br/><br/><b>Dear ' + UserInfo.getName() + '</b>'
				+ '<br/><br/>  Your request for import coupon has completed successfully' 
                + '<br/>Please refresh access to your campaign for checking result'                     
                + '<br/>Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.campId
                + '<br/><br/><p><i>This is an automated message, please do not reply directly to this email!</i></p>'       
                + '<br/>Thank you!'                
                );

        if(UserInfo.getUserId() != this.camp.OwnerId){
            bccemails.add(this.camp.Owner.Email);
            mail.setBccAddresses(bccemails);
        }                
        mail.setToAddresses(toemails);

        if(logs.size() > 0){
            mail.setHtmlBody(              
                  '<br/><br/><b>Dear ' + UserInfo.getName() + '</b>'
				+ '<br/><br/>  Your request for import coupon has completed, But we found some issues durring the process please find attached file for detail.' 
                + '<br/>Please refresh access to your campaign for checking result'                     
                + '<br/>Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + this.campId
                + '<br/><br/><p><i>This is an automated message, please do not reply directly to this email!</i></p>' 
                + '<br/>Thank you!'                
                );

            String csvColumnHeader = 'Id, Account,  $bonus, Message Log, Row Number\n';
            String csvStr = csvColumnHeader + String.join(logs, '\n');
            String fileName = 'Upload Log.csv';
            String contentType='application/vnd.ms-excel';

            List<Messaging.EmailFileAttachment> efas = new List<Messaging.EmailFileAttachment>();
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

            efa.setFileName(fileName);
            efa.setInline(false);
            efa.setContentType(contentType);
            efa.setBody(Blob.valueOf(csvStr));

            efas.add(efa);

            mail.setFileAttachments(efas);
        }

        emails.add(mail);

        try {
            Messaging.sendEmail(emails);
        } catch (Exception ex) {
            System.debug('Error message send email =>' + ex.getMessage());
        }
        
    }


    public class FileWrapper{
       public String qcId;
       public String qcEmail;
       public String spendingAmount;  
       public String percent;     
       public String Amount;       
    }
}