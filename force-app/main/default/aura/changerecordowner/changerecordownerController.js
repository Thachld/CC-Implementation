({
	myAction : function(component, event, helper) {
		
	},
    init : function (cmp) {
        var flowAccount = cmp.find("flowAccount");
        flowAccount.startFlow("Account_change_owner");
        
         var flowQCAccount = cmp.find("flowQCAccount");
        flowQCAccount.startFlow("qc_account_change_owner");
        
        var flowQCAccountSupport = cmp.find("flowQCAccountSupport");
        flowQCAccountSupport.startFlow("QC_Account_change_support");
        
         var flowContact = cmp.find("flowContact");
        flowContact.startFlow("Contact_change_owner");
        
        var flowCase = cmp.find("flowCase");
        flowCase.startFlow("Case_change_owner");
        
        var flowTask = cmp.find("flowTask");
        flowTask.startFlow("Task_change_owner");
        
         var flowOpportunity = cmp.find("flowOpportunity");
        flowOpportunity.startFlow("Opportunity_change_owner");
        
         var flowAccountTeammember = cmp.find("flowAccountTeammember");
        flowAccountTeammember.startFlow("Team_Accounts_change_owner");
        
         var flowCampaign = cmp.find("flowCampaign");
        flowCampaign.startFlow("Campaign_change_owner");
        
           var flowMediaPlan = cmp.find("flowMediaPlan");
        flowMediaPlan.startFlow("Media_Plan_change_owner");
        
        
        //Task_change_owner
    }
})