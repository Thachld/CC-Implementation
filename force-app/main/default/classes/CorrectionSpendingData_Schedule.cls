public with sharing class CorrectionSpendingData_Schedule implements Schedulable{
    public CorrectionSpendingData_Schedule() {
        callBatch();
    }

    public void execute(SchedulableContext sc){
        callBatch();
    }

    public void callBatch(){

        Date enddate = System.today();
        Date startdate = enddate.addDays(-30);

        CorrectionSpendingData_Batch batch = new CorrectionSpendingData_Batch(startdate, enddate);
        if(Test.isRunningTest()){
            Database.executeBatch(batch, 2000);
        }else {
            Database.executeBatch(batch, 200);
        }
        
    }
}