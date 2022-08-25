({
    doInit : function(component, event, helper) {
        helper.getIndustryPicklist(component, event);        

        var discount = component.get("v.detail");
        if(discount.isnew){
            component.set("v.editMode", true);  
        }
    },

    handleChangeData :function(component,event,helper){   
                          
        var editmode = component.get("v.editMode");
        if(editmode){
            // var valid = helper.checkValidity(component,event);
            var valid = true;
            if(valid){
                component.set("v.editMode", false);  
                component.set("v.editSpending", false);  
                component.set("v.editPayment", false);  
                
                var event = component.getEvent("KPITargetEvent");
                event.setParams({
                    'eventType':'Update'
                });
                
                event.fire();

                helper.saveKPITargetDetail(component);
            }
        }else{

            var detail = component.get("v.detail");
            if(detail.IsEdit__c === true){            
                if(detail.Sale__r.Sale_Team__c === 'Direct'){
                    component.set("v.editMode", "true"); 
                    component.set("v.editSpending", "true"); 

                }else if(detail.Sale__r.Sale_Team__c === 'Global Agency'){
                    component.set("v.editMode", "true"); 
                    component.set("v.editPayment", "true"); 
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Warning!",
                    "type":"warning",
                    "mode": "sticky",
                    "message": "You unable to change this sale target, this is manager's target of " + detail.Sale__r.Trac_Name__c + " ."
                });
                toastEvent.fire();
            }


            var event = component.getEvent("KPITargetEvent");
                event.setParams({
                    'eventType':'editChange'
                });
                event.fire();
        }
    },


    handleDelete :function(component,event,helper){   

        helper.deleteKPITargetdetail(component);     

        var event = component.getEvent("KPITargetEvent");
        var idx = component.get("v.sNo");
        event.setParams({
            'eventType':'Delete',
            'recordIdx': idx
        });
        
        event.fire();

        
    },
})