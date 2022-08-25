@istest
public class cc_QCAccount_DelayDeleteShare_Test {
	public static testMethod void test(){
        List<QC_Account__Share> qcAccountShareDeleteFinalListTemp = new List<QC_Account__Share>();
        cc_QCAccount_DelayDeleteShare temp = new cc_QCAccount_DelayDeleteShare(qcAccountShareDeleteFinalListTemp);
        temp.execute(null);
    }
}