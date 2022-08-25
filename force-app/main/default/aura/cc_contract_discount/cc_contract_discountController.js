({
    doInit : function(component, event, helper) {
        var contractId = component.get("v.recordId");
        helper.getDiscounts(component,contractId);
    },


    handlerDiscountAction : function(component, event, helper) {
      
        var discountType = event.getParam("eventType");
        var discounts = component.get("v.discounts");
        if(discountType == 'Add'){
            var newRecord = component.get("v.newRecord");
            var recordId  = component.get("v.recordId");
            newRecord.isnew =  true;
            newRecord.Custom_Contract__c = recordId;

            discounts.push(newRecord);
            
            component.set("v.discounts",discounts);
        }else if(discountType == 'Update'){ 
            helper.sortBy(component,'Discount_rate__c');
        }else if(discountType == 'Delete'){
            var idx = event.getParam("recordIdx");

            discounts.splice(idx-1,1);
            component.set("v.discounts",discounts);
            helper.sortBy(component,'Discount_rate__c');
        }
    },

    handlediscountByRange : function(component, event, helper) {
        var section = "discountByRangeSection";

        helper.displaySection(component, event, section);
    }
})