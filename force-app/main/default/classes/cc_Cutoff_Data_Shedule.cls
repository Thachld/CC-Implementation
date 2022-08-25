public class cc_Cutoff_Data_Shedule implements Schedulable {
    public cc_Cutoff_Data_Shedule() {
        callBatch();
    }

    public void execute(SchedulableContext sc){
        callBatch();
    }


    public void callBatch(){
        if(Test.isRunningTest()){
            cc_Cutoff_Data_batch batch = new cc_Cutoff_Data_batch();
            Database.executeBatch(batch);
        }else {
            cc_Cutoff_Data_batch batch = new cc_Cutoff_Data_batch();
            Database.executeBatch(batch, 1);
        }
       
    }
}