public with sharing class KPIBatchController {
    public class BatchWrapper{
        @AuraEnabled
        public string batchName; 

        @AuraEnabled
        public string batchDevepopName; 

        @AuraEnabled
        public string status;    
        
        @AuraEnabled
        public Datetime completionDate;    

        @AuraEnabled
        public Datetime submittedDate;    

        @AuraEnabled
        public string jobId;    

        @AuraEnabled
        public string submittedBy;    
    }


    public class CustomSettingWrapper{
        @AuraEnabled
        public string paymentmethod; 

        @AuraEnabled
        public string paymentRecordType; 

        @AuraEnabled
        public string saleEmailtemplate; 

        @AuraEnabled
        public string saleMngEmailtemplate; 

        @AuraEnabled
        public string supportEmailTemplate; 

        @AuraEnabled
        public string supportMngEmailTemplate; 

        @AuraEnabled
        public Boolean sendEmailToSale; 

        @AuraEnabled
        public Boolean sendEmailToManager; 
    }

    @AuraEnabled(cacheable=true)
    public static List<BatchWrapper> runBatchJob(String jobName, String periodorQuater){
        List<BatchWrapper> jobs =  new List<BatchWrapper>();
        try {
            if(jobName == 'runKPICalculation'){
                jobs = runKPICalculation(periodorQuater);
            }else if(jobName == 'runKPIMngCalculation'){
                jobs = runKPIMngCalculation(periodorQuater);
            }else if(jobName == 'runApplySaleTarget'){
                jobs = runApplySaleTarget(periodorQuater);
            }else if(jobName == 'runRollOverSaleTarget'){
                jobs = runRollOverSaleAndMngTarget(periodorQuater);
            }


            return jobs;
        } catch (Exception ex) {
            throw new AuraHandledException('exceptionText:' + ex.getMessage());
        }
    }

    
    public static List<BatchWrapper> runKPICalculation(String period){
        try {           

            List<String> jobIds = new List<String>();
            List<BatchWrapper> jobs =  new List<BatchWrapper>();

            cc_KPI_Calculation_batch saletBatch = new cc_KPI_Calculation_batch(period);
            Id saleJobId =database.executeBatch(saletBatch,40);
            jobIds.add(saleJobId);

            cc_KPI_Calculation_Support_Batch supportBatch = new cc_KPI_Calculation_Support_Batch(period, false);
            Id suportJobId = database.executeBatch(supportBatch,40);
            jobIds.add(suportJobId);

            jobs = getJobs(jobIds);
            return jobs;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    public static List<BatchWrapper> runKPIMngCalculation(String period){
        try {
            List<String> jobIds = new List<String>();
            List<BatchWrapper> jobs =  new List<BatchWrapper>();

            cc_KPI_ManagerKPITeamMember_Batch mngBatch = new cc_KPI_ManagerKPITeamMember_Batch(period);
            Id saleJobId =database.executeBatch(mngBatch,200);
            jobIds.add(saleJobId);          

            jobs = getJobs(jobIds);
            return jobs;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
   
    public static List<BatchWrapper> runApplySaleTarget(String period){
        try {
            List<String> jobIds = new List<String>();
            List<BatchWrapper> jobs =  new List<BatchWrapper>();

            cc_KPI_ApplySaleTarget_Batch autoHOMs = new cc_KPI_ApplySaleTarget_Batch(period);
            Id saleJobId =database.executeBatch(autoHOMs,50);
            jobIds.add(saleJobId);          

            jobs = getJobs(jobIds);
            return jobs;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }


    public static List<BatchWrapper> runRollOverSaleAndMngTarget(String quarter){
        try {
            List<String> jobIds = new List<String>();
            List<BatchWrapper> jobs =  new List<BatchWrapper>();

            cc_KPI_RollOverSaleTarget_Batch autoHOMs = new cc_KPI_RollOverSaleTarget_Batch(quarter);
            Id rollOverJobId =database.executeBatch(autoHOMs,500);
            jobIds.add(rollOverJobId);          

            jobs = getJobs(jobIds);
            return jobs;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }


    @AuraEnabled
    public static List<BatchWrapper> getJobs(List<String> jobIds){
        try {
            System.debug('jobIds =>' + jobIds);

            List<BatchWrapper> jobs =  new List<BatchWrapper>();
            for (AsyncApexJob job:[SELECT Id, ApexClass.Name, CompletedDate, Status, CreatedBy.Name, CreatedDate  
                                            FROM AsyncApexJob WHERE JobType = 'BatchApex' and Id IN :jobIds]){
                BatchWrapper batch = new BatchWrapper();
                batch.batchName = job.ApexClass.Name;
                batch.status = job.Status;
                batch.completionDate = job.CompletedDate;                
                batch.submittedDate = job.CreatedDate;
                batch.jobId = job.Id;
                batch.submittedBy =  job.CreatedBy.Name;

                jobs.add(batch);
            }
            
            
            System.debug('jobs =>' + jobs);

            return jobs;
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static cc_KPI_Setting__c getKPISetting(String setingName){
        try {           
            cc_KPI_Setting__c setting = cc_KPI_Setting__c.getInstance(setingName);

            return setting;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static cc_KPI_Setting__c updateKPISetting(String setingName, Boolean isAllowEmailToSale, Boolean isAllowEmailToMng){
        try {
            cc_KPI_Setting__c setting = cc_KPI_Setting__c.getInstance(setingName);
            setting.SendEmailToSale__c = isAllowEmailToSale;
            setting.SendEmailToManager__c = isAllowEmailToMng;

            update setting;
            return setting;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        

    }
}