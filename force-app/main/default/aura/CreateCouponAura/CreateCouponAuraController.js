({

    doInit : function(component, event, helper) {        
        var recordId = component.get("v.recordId");       
        helper.getCampaign(component, event, recordId);       
    },


    closeQA : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }


})