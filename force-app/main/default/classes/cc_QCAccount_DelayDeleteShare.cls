global class cc_QCAccount_DelayDeleteShare implements Schedulable{
    List<QC_Account__Share> qcAccountShareDeleteFinalList {get;set;}
	global void execute(SchedulableContext SC) {
        deleteSharing();
    }
    public cc_QCAccount_DelayDeleteShare(List<QC_Account__Share> qcAccountShareDeleteFinalListTemp){
        qcAccountShareDeleteFinalList = qcAccountShareDeleteFinalListTemp;
        //deleteSharing();
    }
    public void deleteSharing()
    {
        if(qcAccountShareDeleteFinalList.size() >0)
        	delete qcAccountShareDeleteFinalList;
    }
}