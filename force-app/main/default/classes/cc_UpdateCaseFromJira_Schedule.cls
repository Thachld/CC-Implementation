global class cc_UpdateCaseFromJira_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_UpdateCaseFromJira_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        
        Datetime systemdate = System.now();
        cc_Jira_Integration__c jiraintegrate =  cc_Jira_Integration__c.getInstance('coccocjira');   
        Integer caseperiod = (Integer)jiraintegrate.CasePullPeriod__c;
        Datetime lastSyncDate = systemdate.addMinutes(-caseperiod);   
        Integer batchsize = (Integer)(jiraintegrate.BatchSize__c == null? 50: jiraintegrate.BatchSize__c);  

        cc_UpdateCaseFromJira_Batch batch = new cc_UpdateCaseFromJira_Batch(lastSyncDate);
        database.executeBatch(batch,batchsize);
        
    }
}