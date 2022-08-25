global class cc_KPI_Calculation_Support_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_Calculation_Support_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        Date today = System.today();   
        Date firstdayOfMonth  = today.toStartOfMonth();
        Date rundate;
        //If rundate is first day of month, process should run for last month
        rundate = today;
        
        String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
        String year = String.valueOf(rundate.year());
        String period = month +'-' + year ;

        if(Test.isRunningTest()){
            cc_KPI_Calculation_Support_Batch autoHOMs = new cc_KPI_Calculation_Support_Batch(period, true);
            database.executeBatch(autoHOMs,20);
        }else {
            cc_KPI_Calculation_Support_Batch autoHOMs = new cc_KPI_Calculation_Support_Batch(period, false);
            database.executeBatch(autoHOMs,20);
        }
        
        
    }
}