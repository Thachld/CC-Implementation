global class cc_KPI_ApplySaleTarget_Schedule implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_ApplySaleTarget_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        Date rundate = System.today();        
        String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
        String year = String.valueOf(rundate.year());
        String period = month +'-' + year ;

        cc_KPI_ApplySaleTarget_Batch autoHOMs = new cc_KPI_ApplySaleTarget_Batch(period);
        if(!Test.isRunningTest()){
            database.executeBatch(autoHOMs,20);
        }else{
            database.executeBatch(autoHOMs);
        }
        
        
    }
}