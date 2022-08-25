public with sharing class SpendingMasterReport_Schedule implements Schedulable {
    public SpendingMasterReport_Schedule() {
        callBatch();
    }

    public void execute(SchedulableContext sc){
        callBatch();
    }

    public void callBatch(){

        //Run daily
        Spending_Schedule_Params__mdt batchparam = Spending_Schedule_Params__mdt.getInstance('SpendingMasterReport_Batch');
        Date today = System.today(); 
        Date todt = today;
        Date fromdt;
        Integer batchsize;
        if(batchparam !=null){
            batchsize = (Integer)batchparam.Batch_Size__c;
            Integer daynumbers = (Integer)batchparam.Number_Of_Time_frame__c;
            String type = (String)batchparam.Type__c;
            
            if(type == 'Day'){
                fromdt = todt.addDays(-1*daynumbers);
            }else if(type == 'Month'){
                fromdt = todt.addMonths(-1*daynumbers);
            }
        }else {
            fromdt = todt.addDays(-7);
        }
        
        if(fromdt != null && todt != null && fromdt < todt){            

            SpendingMasterReport_Batch batch = new SpendingMasterReport_Batch(fromdt, todt);
            Database.executeBatch(batch,(batchsize==null?200: batchsize));

        }

    }   
}