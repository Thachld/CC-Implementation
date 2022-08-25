public class cc_CorrectionData_Schedule implements Schedulable{  

    public cc_CorrectionData_Schedule() {
        callBatch();
    }

    public void execute(SchedulableContext sc){
        callBatch();
    }

    public void callBatch(){
        Date todt = System.today();
        Date fromdt = todt-30;
        cc_Payment_CorrectionData_Batch paymentbatch = new cc_Payment_CorrectionData_Batch(fromdt,todt);
        Database.executeBatch(paymentbatch, 200);
    }
}