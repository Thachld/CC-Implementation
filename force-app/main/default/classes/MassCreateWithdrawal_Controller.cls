public with sharing class MassCreateWithdrawal_Controller {
    public Id reqestId {get;set;}
    public Mass_Withdrawal_Request__c request {get;set;}
    public Boolean refreshPage {get;set;}
    public Contentversion file {get;set;}
    public List<String> logs {get;set;}
    public list<SelectOption> fileoptions {get; set;}
    public String selectedfileId {get; set;}
    
    public MassCreateWithdrawal_Controller(Apexpages.StandardController std) {
        this.reqestId = std.getId();
        getSpecialRequest();
        this.logs = new List<String>();
        this.fileoptions = this.getFiles(this.reqestId);
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

    public Pagereference loadFile(){   
        try {
            if(this.request.Status__c != 'New'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'This request already processed, please create new request!'));                
            }else{
                if(!String.isBlank(this.selectedfileId)){   
                    this.file = getAttactFile(this.selectedfileId);
                    if(this.file == null){
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'No file was found!'));                
                    }else{                     
                        processImport(this.file);                  
                        PageReference tempPage = ApexPages.currentPage();           
                        tempPage.setRedirect(true);
                        this.refreshPage = true;    
                    }
                }
            }
            return null; 
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }

    public Pagereference massConfirm(){   
        try {                
            processConfirm(this.reqestId);                  
            PageReference tempPage = ApexPages.currentPage();           
            tempPage.setRedirect(true);
            this.refreshPage = true;              
            return null; 
        } catch (Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }

    public void getSpecialRequest(){
        this.request = [SELECT Id, Name, Status__c, Is_Auto_Confirm__c ,Assignee__c,
                            Default_Note__c,Effective_Date__c,Note__c,Refund_Type__c
                        FROM Mass_Withdrawal_Request__c WHERE Id = :this.reqestId];
    }

    private void processImport(Contentversion file){        
        Blob body = (Blob)file.versiondata;

        Map<String,FileWrapper> mapfileDatas = readCsv(body.toString());
        if(mapfileDatas != null){
            MassCreateWithdrawal_Batch batch = new MassCreateWithdrawal_Batch(mapfileDatas.keySet(), this.request);
            Database.executeBatch(batch, 50);
        }
    }

    private void processConfirm(String requetId){
        List<Payment__c> pytoConfirm = [SELECT Id, Stage__c 
                                        FROM Payment__c 
                                        WHERE Mass_Withdrawal_Request__c= :requetId AND Stage__c =: PaymentConstant.STAGE_NEW];
        if(pytoConfirm != null){
            for(Payment__c py: pytoConfirm){
                py.Stage__c = PaymentConstant.STAGE_DONE;
            }
            update pytoConfirm;
        }
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

            if(!String.isBlank(row.qcId)){
                mapfileDatas.put(row.qcId, row);           
            }    
        }
        System.debug('mapfileDatas=>' + mapfileDatas);
        return mapfileDatas;
    }

    public class FileWrapper{
       public String qcId;
       public String qcEmail;    
    }
}