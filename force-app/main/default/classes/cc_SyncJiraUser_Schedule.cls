global with sharing class cc_SyncJiraUser_Schedule implements Schedulable{    

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_SyncJiraUser_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        cc_SyncJiraUser_Batch syncJiraBatch = new cc_SyncJiraUser_Batch();   
        if(!Test.isRunningTest()){
            database.executeBatch(syncJiraBatch,2000);
        }else {
            database.executeBatch(syncJiraBatch,2000);
        }
        
    }
}