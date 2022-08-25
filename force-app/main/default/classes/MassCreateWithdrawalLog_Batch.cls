public with sharing class MassCreateWithdrawalLog_Batch implements Database.Batchable<SObject>{
    private List<LogFileWrapper.FileWrapper> logs {get;set;}    
    private String requestId {get;set;}

    public MassCreateWithdrawalLog_Batch(String pRequestId, List<LogFileWrapper.FileWrapper> plogs) {
        this.logs = plogs;
        this.requestId = pRequestId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, Status__c, OwnerId FROM Mass_Withdrawal_Request__c WHERE Id = :this.requestId]);
    }

    public void execute(Database.BatchableContext bc, List<Mass_Withdrawal_Request__c> scope){
        List<Attachment> attachs = new List<Attachment>();
        Mass_Withdrawal_Request__c reqest = scope[0];
        if(scope.size() > 0 && this.logs.size() > 0){
            List<String> csvRowValues = new List<String>();
            String csvRFColumnHeader = 'QC Account Id, Error Message \n';

            for(LogFileWrapper.FileWrapper log : this.logs){
                String logRow = (log.Id == null? '' : log.Id) + ',' + (log.message == null? '' : log.message);
                csvRowValues.add(logRow);
            }

            String csvFile = csvRFColumnHeader + String.join(csvRowValues, '\n');
            String filename = (reqest.Name == null?'': reqest.Name) + ' - Error Log - ' + String.valueOfGmt(Datetime.now()) + '.csv';
            Attachment att = new Attachment(Name = filename, Body = Blob.valueOf(csvFile), ParentId = this.requestId, ContentType='application/vnd.ms-excel', OwnerId = reqest.OwnerId);
            attachs.add(att);   
        }

        if(attachs.size() > 0){
            insert attachs;
            reqest.Status__c = 'Completed With Error';

            update reqest;
        }else {
            reqest.Status__c = 'Completed';
            update reqest;
        }
    }

    public void finish(Database.BatchableContext bc){
        
    }
}