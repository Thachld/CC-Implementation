({
    doInit: function(component, event, helper) {     
       
        helper.getDiscountByPicklist(component, event);
        helper.getDiscountTypePicklist(component, event);

        var discount = component.get("v.singleRec");
        if(discount.isnew){
            component.set("v.editMode", true);  
        }
    },


    handleChangeData :function(component,event,helper){             
        var editmode = component.get("v.editMode");
        if(editmode){
            var valid = helper.checkValidity(component,event);

            if(valid){
                component.set("v.editMode", false);  
                
                var event = component.getEvent("discountEvent");
                event.setParams({
                    'eventType':'Update'
                });
                
                event.fire();

                helper.saveDiscount(component);
            }
        }else{
            component.set("v.editMode", true);    
        }
    },
      
    handleAddDiscount :function(component,event,helper){    
            
        var event = component.getEvent("discountEvent");
        event.setParams({
            'eventType':'Add'
        });
        
        event.fire();
    },


    handleDelete :function(component,event,helper){   

        helper.deleteDiscount(component);     

        var event = component.getEvent("discountEvent");
        var idx = component.get("v.sNo");
        event.setParams({
            'eventType':'Delete',
            'recordIdx': idx
        });
        
        event.fire();

        
    },


    handleSelectDiscountBy: function(component,event,helper){     
        var discountBy =  component.find("discountByAUID").get("v.value");
        

        component.set("v.discountByEditMode", false);         
    },

    handleSelectDiscountType: function(component,event,helper){   
        component.set("v.typeEditMode", false); 
    },
})