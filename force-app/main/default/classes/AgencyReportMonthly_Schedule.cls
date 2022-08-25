/**
 * @description       : Schedule class for Agency Report
 * @author            : @Thach Le
 * @group             : Data Accumulation
 * @last modified on  : 08-09-2022
 * @last modified by  : @Thach Le
**/
public with sharing class AgencyReportMonthly_Schedule implements Schedulable {
    public AgencyReportMonthly_Schedule() {
        callBatch();
    }

    public void execute(SchedulableContext sc){
        callBatch();
    }

    public void callBatch(){

        //Run for last Month
        Date rundate = Date.today().addMonths(-1); 
        String month = rundate.month() < 10?'0' + String.valueOf(rundate.month()) : String.valueOf(rundate.month());
        String year = String.valueOf(rundate.year());
        String period = month +'-' + year ;
        Boolean isOveride = true;        

        AgencyReportMonthly_Batch batch = new AgencyReportMonthly_Batch(period,isOveride, null);
        Database.executeBatch(batch, 200);

    }
}