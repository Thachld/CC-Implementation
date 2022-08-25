({
    doInit : function(component, event, helper) {
        var contractId = component.get("v.recordId");
        helper.getDiscounts(component,contractId);
    },

    handleCloseWarning : function(component, event, helper) {
        component.set("v.showwarning",false);
    },

})