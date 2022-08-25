global class cc_AsyncCaseFeed_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_AsyncCaseFeed_Schedule()
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
        Integer feedperiod = (Integer)jiraintegrate.FeedPullPeriod__c;
        Datetime lastSyncDate = systemdate.addMinutes(-feedperiod);   
        Integer batchsize = (Integer)(jiraintegrate.BatchSize__c == null? 50: jiraintegrate.BatchSize__c);

        cc_AsyncCaseChatterFrJiraComment_Batch batch = new cc_AsyncCaseChatterFrJiraComment_Batch(lastSyncDate);
        database.executeBatch(batch,batchsize);
        
    }
}