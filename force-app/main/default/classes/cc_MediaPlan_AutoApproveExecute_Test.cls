@istest
public class cc_MediaPlan_AutoApproveExecute_Test {
	public static testMethod void test(){
        Account acc = cc_initData.initAccount();
        insert acc;
        Opportunity opp = cc_initData.initOpportunity(acc.Id);
        insert opp;
        Media_Plan__c m = cc_initData.initMediaPlan(acc.id, opp.id);
        m.Type__c = 'Plan';
        insert m;
        
        Test.startTest();
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Submitting request for approval.');
       
        req.setObjectId(m.Id);
        Approval.ProcessResult resu = Approval.process(req);
        
        
        List<Id> newWorkItemIds = resu.getNewWorkitemIds();
        system.debug('debug:id:' + newWorkItemIds);
        Approval.ProcessWorkitemRequest req2 =  new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
       
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});//UserInfo.getUserId()
       
        
        req2.setWorkitemId(newWorkItemIds.get(0));
        Approval.ProcessResult result2 =  Approval.process(req2);
      
		cc_MediaPlan_AutoApprove temp = new cc_MediaPlan_AutoApprove();		
        test.stopTest();
        
    }
    public static testMethod void test1(){
        cc_MediaPlan_AutoApprove temp = new cc_MediaPlan_AutoApprove();
    }
    
}