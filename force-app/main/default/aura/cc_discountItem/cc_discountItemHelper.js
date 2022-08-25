({
    getDiscountByPicklist : function(component, event) {
        var action = component.get("c.getDiscountByDB");

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
				var result = response.getReturnValue();							
                component.set("v.discountByVal", result);               

			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
			}
        });

        $A.enqueueAction(action);
    },

    getDiscountTypePicklist : function(component, event) {
        var action = component.get("c.getDiscountTypeDB");

        action.setCallback(this,function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
				var result = response.getReturnValue();							
                component.set("v.discountTypeVal", result);               

			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
			}
        });

        $A.enqueueAction(action);
    },

    saveDiscount : function(component) {
       
        var action =component.get("c.saveDiscountDB");        
        var discount = component.get("v.singleRec")
        if(discount.Discout_Bonus_By__c == 'Spending'){
            discount.Min_Payment__c = 0;
            discount.Max_payment__c = 0;
        }else if(discount.Discout_Bonus_By__c == 'Payment'){
            discount.Min_spending__c =  0;
            discount.Max_spending__c = 0;
        }

        action.setParams({
            'dis': discount
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();	                
                component.set("v.singleRec", result);               

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "mode": "sticky",
                    "message": "The record has been updated successfully."
                });
                toastEvent.fire();
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "mode": "sticky",
                    "message": "The record has failed to update."
                });
                toastEvent.fire();
			}
        });

        $A.enqueueAction(action);
    },


    deleteDiscount : function(component) {
        
        var action =component.get("c.deleteDiscountDB");        
        var discount = component.get("v.singleRec")
        action.setParams({
            'recId': discount.Id
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){                

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "mode": "sticky",
                    "message": "The record has been delete successfully."
                });
                toastEvent.fire();
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "mode": "sticky",
                    "message": "The record has failed to delete."
                });
                toastEvent.fire();
			}
        });

        $A.enqueueAction(action);
    },


    checkValidity : function (component, event){
        
        var valid = true;

        var discountBy = component.find("discountByAUID");
        var discountType = component.find("discountTypeAUID");
        var minPayment = component.find("minPaymentAUID");
        var maxPayment = component.find("maxPaymentAUID");
        var minSpending = component.find("minSpendingAUID");
        var maxSpending = component.find("maxSpendingAUID");
        var rate = component.find("discountRateAUID");

        if(discountBy.get("v.value") == 'Payment'){        
            if(!discountBy.checkValidity()){
                valid = false;                
            }  
            
            if(!discountType.checkValidity()){
                valid = false;                
            } 

            if(!minPayment.checkValidity()){
                valid = false;               
            } 

            if(!maxPayment.checkValidity()){
                valid = false;                
            } 

            if(!rate.checkValidity()){
                valid = false;                
            }             
        }else if(discountBy.get("v.value") == 'Spending'){
            if(!discountBy.checkValidity()){
                valid = false; 
                discountBy.focus();                
            }  
            
            if(!discountType.checkValidity()){
                valid = false;    
                discountType.focus();                
            } 

            if(!minSpending.checkValidity()){
                valid = false; 
                minSpending.focus();                      
            } 

            if(!maxSpending.checkValidity()){
                valid = false;
                maxSpending.focus();                
            } 

            if(!rate.checkValidity()){
                valid = false;
                rate.focus();
            }             
        }

        return valid;
    },
})