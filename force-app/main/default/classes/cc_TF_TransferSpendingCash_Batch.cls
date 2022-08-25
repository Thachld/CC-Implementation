global class cc_TF_TransferSpendingCash_Batch implements Database.Batchable<SObject>{
    public Set<String> rqIds  {get;set;}     
    public String soqlStr {get;set;}

    public cc_TF_TransferSpendingCash_Batch(Set<String> prqIds) {
        this.rqIds = prqIds== null? new Set<String>() : prqIds;        

        if(prqIds !=null && prqIds.size() > 0){
            this.soqlStr = 'SELECT Id, Transfer_Request__c, Transfer_Request__r.From_Sale__c , Transfer_Request__r.To_Sale__c,';
            this.soqlStr += ' Transfer_Request__r.ToIndustry__c,Transfer_Request__r.FromIndustry__c, Transfer_Request__r.Schedule_Transfer_Date__c, ';
            this.soqlStr += ' Transfer_Request__r.From_Date__c, Transfer_Request__r.To_Date__c, QC_Account__c,  ';
            this.soqlStr += ' Transfer_Request__r.Transfer_Purpose__c, Transfer_Request__r.Transfer_Type__c, Transfer_Request__r.TransferObject__c,  ';
            this.soqlStr += ' Transfer_Request__r.Approval_Status__c, Transfer_Request__r.Status__c,  Transfer_Request__r.isIncludeIndustry__c  ';
            this.soqlStr += ' FROM Transfer_Account__c ';
            this.soqlStr += ' WHERE Transfer_Request__r.Status__c != \'Completed\' ';
            this.soqlStr += ' AND Transfer_Request__r.Approval_Status__c = \'Approved\' ';
            this.soqlStr += ' AND Transfer_Request__c IN :rqIds ';
        }else {
            this.soqlStr = 'SELECT Id, Transfer_Request__c, Transfer_Request__r.From_Sale__c , Transfer_Request__r.To_Sale__c,';
            this.soqlStr += ' Transfer_Request__r.ToIndustry__c,Transfer_Request__r.FromIndustry__c, Transfer_Request__r.Schedule_Transfer_Date__c, ';
            this.soqlStr += ' Transfer_Request__r.From_Date__c, Transfer_Request__r.To_Date__c, QC_Account__c,  ';
            this.soqlStr += ' Transfer_Request__r.Transfer_Purpose__c, Transfer_Request__r.Transfer_Type__c, Transfer_Request__r.TransferObject__c,  ';
            this.soqlStr += ' Transfer_Request__r.Approval_Status__c, Transfer_Request__r.Status__c,  Transfer_Request__r.isIncludeIndustry__c  ';
            this.soqlStr += ' FROM Transfer_Account__c ';
            this.soqlStr += ' WHERE Transfer_Request__r.Status__c != \'Completed\' ';
            this.soqlStr += ' AND Transfer_Request__r.Approval_Status__c = \'Approved\' ';
        }
    }   

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(this.soqlStr);
    }

    global void execute (Database.BatchableContext bc, List<Transfer_Account__c> scope){         
        System.debug('scope=>' + scope.size());
        List<Transfer_Account__c> processRecs = new List<Transfer_Account__c>();
        for(Transfer_Account__c tf: scope){
            if( tf.Transfer_Request__r.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_OWNER
                 || tf.Transfer_Request__r.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_ADS_OP){
                    if (tf.Transfer_Request__r.Schedule_Transfer_Date__c <= Date.today()){
                        processRecs.add(tf);
                    }
            }else {
                processRecs.add(tf);
            }
        }

        if(processRecs .size() > 0){
            cc_TransferSpendingCashHelper.doTransfer(processRecs);
        }
         
    }

    global void finish (Database.BatchableContext bc){
        
    }
    
}