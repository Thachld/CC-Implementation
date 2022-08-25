global class SyncMobileSpending_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        callBatch();
    }
    public SyncMobileSpending_Schedule()
    {        
        callBatch();
    }
    public void callBatch(){
        /* ------- Parameter ------------*/
        /* runtype - Running Type Daily for get daily spending -  All for get all spendings */
        /* runingIds: Sync Mobile Skin for specific QC Accounts */
        /* ------- Parameter ------------*/

        String runtype = 'Daily';
        Set<String> runingIds = null;
        Date starDate = null;
        Date endDate = null;

        SyncMobileSpending_Batch syncMobileSkin = new SyncMobileSpending_Batch(runtype, runingIds,starDate,endDate);
        database.executeBatch(syncMobileSkin,10);        
    }
}