global class cc_TF_TransferUser_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_TF_TransferUser_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/       
        Set<String>  prqIds= new Set<String>();
        cc_TF_TransferUser_Batch transfer = new cc_TF_TransferUser_Batch(prqIds);
        database.executeBatch(transfer,10);
        
    }
}