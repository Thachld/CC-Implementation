global class AccountSpendingReport_Schedule implements Schedulable {   
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public AccountSpendingReport_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        Spending_Schedule_Params__mdt batchparam = Spending_Schedule_Params__mdt.getInstance('AccountSpendingReport_Batch');
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
            
            AccountSpendingReport_Batch spendingBatch = new AccountSpendingReport_Batch(fromdt, todt);
            database.executeBatch(spendingBatch, (batchsize==null?500: batchsize) );
        }        
    }
}