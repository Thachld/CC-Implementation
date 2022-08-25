public class cc_ChatterQueueable implements Queueable{
    List<cc_ChatterBatchWrapper> feedItemInsertList {get;set;}
    public cc_ChatterQueueable (List<cc_ChatterBatchWrapper> feedItemInsertTempList){
        feedItemInsertList = feedItemInsertTempList;
    }
	public void execute(QueueableContext context){
         cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(feedItemInsertList);
         database.executeBatch(batch,1);
    }
}