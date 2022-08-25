global class cc_KPI_Calculation_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_Calculation_Schedule()
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
        //If the first day of month, process should run for last month
        if(rundate == firstdayOfMonth){
            rundate = today - 1;
        }else {
            rundate = today;
        }
        
        String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
        String year = String.valueOf(rundate.year());
        String period = month +'-' + year ;

        cc_KPI_Calculation_batch autoHOMs = new cc_KPI_Calculation_batch(period);
        database.executeBatch(autoHOMs,20);
        
    }
}