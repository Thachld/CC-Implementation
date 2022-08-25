global class cc_KPI_RolloverKPIPeriod_Schedule implements Schedulable{
    
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_RolloverKPIPeriod_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isDeleteOldKPI - Delete Old KPI before roll-over- Make sure no KPI record has duplicate */
        /* ------- Parameter ------------*/

        Date rundate = System.today();        
        String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
        String year = String.valueOf(rundate.year());
        String period = month +'-' + year ;
        Boolean isDeleteOldKPI = true;

        cc_KPI_RolloverKPIPeriod_Batch autoHOMs = new cc_KPI_RolloverKPIPeriod_Batch(period,isDeleteOldKPI);
        if(!Test.isRunningTest()){
            database.executeBatch(autoHOMs,20);
        }else{
            database.executeBatch(autoHOMs);
        }
        
        
    }
}