global class cc_QCCampaignIntegration_Schedule implements Schedulable {   
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_QCCampaignIntegration_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        Datetime rundate = System.now(); 

        cc_QCCampaignIntegration_Batch campaignBatch = new cc_QCCampaignIntegration_Batch(rundate, null);
        database.executeBatch(campaignBatch,50);
        
    }
}