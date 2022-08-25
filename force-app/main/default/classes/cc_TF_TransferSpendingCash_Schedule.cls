global class cc_TF_TransferSpendingCash_Schedule implements Schedulable{   

    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_TF_TransferSpendingCash_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* List requestID = null that mean run all Request */        
        /* ------- Parameter ------------*/   
        Set<String> prqIds = new Set<String>();
        cc_TF_TransferSpendingCash_Batch transfer = new cc_TF_TransferSpendingCash_Batch(prqIds);
        database.executeBatch(transfer,10);        
    }
}