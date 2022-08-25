global class cc_KPI_ManagerKPITeamMember_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_ManagerKPITeamMember_Schedule()
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
        if(rundate == firstdayOfMonth){
            rundate = today - 1;
        }else {
            rundate = today;
        }
         
        String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
        String year = String.valueOf(rundate.year());
        String period = month +'-' + year ;

        cc_KPI_ManagerKPITeamMember_Batch autoHOMs = new cc_KPI_ManagerKPITeamMember_Batch(period);
        if(!Test.isRunningTest()){
            database.executeBatch(autoHOMs,200);
        }else{
            database.executeBatch(autoHOMs);
        }
        
        
    }
}