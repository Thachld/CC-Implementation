({
    getCampaign : function(component, event, recordId){
        var action = component.get("c.getCampaign");
        action.setParams({
            'campId':recordId            
        });

		action.setCallback(this, function(response){
			var state = response.getState();
           
			if (state === "SUCCESS"){
				var result = response.getReturnValue();							
                component.set("v.campaign", result);               

			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){

			}
		});

		$A.enqueueAction(action);
    },
})