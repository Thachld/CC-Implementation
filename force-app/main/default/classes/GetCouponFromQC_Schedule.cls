global with sharing class GetCouponFromQC_Schedule implements Schedulable{

    global void execute(SchedulableContext SC) {
        callBatch();
    }

    global GetCouponFromQC_Schedule()
    {        
        callBatch();
    }
    global void callBatch(){
        /* ------- Parameter ------------*/
        /* period - Month-Year need to be calculation */
        /* isUpdateToPreviousCoupond  */
        /* ------- Parameter ------------*/

        Datetime rundate = System.now(); 

        GetCouponFromQC_Batch campaignBatch = new GetCouponFromQC_Batch();
        database.executeBatch(campaignBatch,50);
        
    }
}