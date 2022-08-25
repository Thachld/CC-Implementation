global class cc_SyncTransactionsTypeMapping_Schedule implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        callBatch();
    }

    global cc_SyncTransactionsTypeMapping_Schedule()
    {        
        callBatch();
    }
    global void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        Datetime rundate = System.now(); 
        cc_SyncTransactionsTypeMapping_Batch syncTransType = new cc_SyncTransactionsTypeMapping_Batch();
        database.executeBatch(syncTransType,100);
        
    }
}