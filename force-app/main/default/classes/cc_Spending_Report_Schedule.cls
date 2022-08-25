global class cc_Spending_Report_Schedule implements Schedulable{
	global void execute(SchedulableContext SC) {
        callBatch();
    }
    public cc_Spending_Report_Schedule()
    {
        callBatch();
    }
    public void callBatch(){
        //cc_Spending_Report_Batch temp = new cc_Spending_Report_Batch('');
        cc_Spending_Report_GetQCAccount_Batch temp = new cc_Spending_Report_GetQCAccount_Batch('');
		database.executeBatch(temp);
    }
}