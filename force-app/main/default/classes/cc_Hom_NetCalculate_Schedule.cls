global class cc_Hom_NetCalculate_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_Hom_NetCalculate_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/
        String period = '';
        cc_Hom_GetActiveAccount_Batch autoHOMs = new cc_Hom_GetActiveAccount_Batch(period, false);
        database.executeBatch(autoHOMs,1000);
        
    }
}