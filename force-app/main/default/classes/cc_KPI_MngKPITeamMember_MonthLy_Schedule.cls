global class cc_KPI_MngKPITeamMember_MonthLy_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_MngKPITeamMember_MonthLy_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/
        cc_KPI_Setting__c kpisetting = cc_Util.getKPISetting('ccKPISetting');
        Date today ;
        if(Test.isRunningTest()){
            today =date.newInstance(System.today().year(), System.today().month(), 1); 
        }else {
            today = System.today(); 
        }  
        Date rundate;
        Integer day = today.day();
        //If rundate is first day of month, process should run for last month
        Integer Day_to_Re_run_last_kpi_period = (Integer)(kpisetting.Day_to_Re_run_last_kpi_period__c == null ? 2 : kpisetting.Day_to_Re_run_last_kpi_period__c);
        //If the first day of month, process should run for last month
        if(day <= Day_to_Re_run_last_kpi_period ){
            rundate = today.addMonths(-1);    
         
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
}