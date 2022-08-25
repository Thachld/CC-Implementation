global with sharing class AutoActivateCouponWithCondition_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public AutoActivateCouponWithCondition_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        Date today = Date.today();
        AutoActivateCouponWithCondition_Batch autoActiveBatch = new AutoActivateCouponWithCondition_Batch(today);
        database.executeBatch(autoActiveBatch,50);
        
    }
}