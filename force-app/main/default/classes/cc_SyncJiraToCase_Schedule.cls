global with sharing class cc_SyncJiraToCase_Schedule implements Schedulable{    

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_SyncJiraToCase_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        cc_Jira_Integration__c jirasetting = cc_Jira_Integration__c.getInstance('jirasynctosf');  
        if(jirasetting != null){
            Integer batchsize = (jirasetting.BatchSize__c == null || jirasetting.BatchSize__c == 0)? 50 : Integer.valueOf(jirasetting.BatchSize__c);
            cc_SyncJiraToCase_Batch syncJiraBatch = new cc_SyncJiraToCase_Batch(jirasetting);   
            database.executeBatch(syncJiraBatch,batchsize);
        }
        
    }
}