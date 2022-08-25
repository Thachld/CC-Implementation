({
    getDiscounts : function(component, contractId) { 
        debugger;
        var action =component.get("c.getDiscountByContractDB");        
        action.setParams({
            'conId': contractId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();	
                if(result.length == 0 || result.length == undefined){
                    component.set("v.showwarning",true);   
                    // var toastEvent = $A.get("e.force:showToast");
                    // toastEvent.setParams({
                    //     "title": "Error!",
                    //     "type":"error",
                    //     "mode": "sticky",
                    //     "message": "The record has missing value."
                    // });
                    // toastEvent.fire();                 
                }                   
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
			}
        });

        $A.enqueueAction(action);
    },
})