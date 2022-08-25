({


	saveKPITargetDetail : function(component, event){        
		var action =component.get("c.saveKPITargetdetailDB");
        var detail =  component.get("v.detail");
        console.log(detail.Id);
		action.setParams({
            'targetdetail': detail
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();	                
                component.set("v.detail", result);               

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


	deleteKPITargetdetail : function(component) {
        
        var action =component.get("c.deleteKPITargetdetaiDB");        
        var detail = component.get("v.detail")
        action.setParams({
            'recId': detail.Id
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
        
        var allValid = component.find('detailfield').reduce(function (validFields, inputCmp) {
            inputCmp.showHelpMessageIfInvalid();
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        
        return allValid;        
    },

    //Init Case Sub category piclist
    getIndustryPicklist : function(component, event){
        var action = component.get("c.getCategoryPicklistDB");            
		action.setCallback(this, function(response){
			var state = response.getState();            
			if (state === "SUCCESS"){
                var result = response.getReturnValue();			
                
                var js = JSON.stringify(result);
                
                component.set("v.industryPick", result);               

			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){

			}
		});

		$A.enqueueAction(action);
    },
})