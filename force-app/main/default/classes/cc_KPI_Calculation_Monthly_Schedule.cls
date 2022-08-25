global class cc_KPI_Calculation_Monthly_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_KPI_Calculation_Monthly_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/
        cc_KPI_Setting__c kpisetting = cc_Util.getKPISetting('ccKPISetting');
        Date today;
        if(Test.isRunningTest()){
            today =date.newInstance(System.today().year(), System.today().month(), 1); 
        }else {
            today = System.today(); 
        }
       
        Integer day = today.day();

        Date rundate;
        Integer Day_to_Re_run_last_kpi_period = (Integer)(kpisetting.Day_to_Re_run_last_kpi_period__c == null ? 2 : kpisetting.Day_to_Re_run_last_kpi_period__c);
        //If the first day of month, process should run for last month
        if(day <= Day_to_Re_run_last_kpi_period ){
            rundate = today.addMonths(-1);        
        
            String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
            String year = String.valueOf(rundate.year());
            String period = month +'-' + year ;

            cc_KPI_Calculation_batch saleKPIs = new cc_KPI_Calculation_batch(period);
            database.executeBatch(saleKPIs,20);

            cc_KPI_Calculation_Support_Batch supportKPIs = new cc_KPI_Calculation_Support_Batch(period, true);
            database.executeBatch(supportKPIs,20);
        }
    }
}