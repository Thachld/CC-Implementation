({
    getdata : function(component) {
        //debugger;
        var recordId = component.get("v.recordId");
        var limitRec = component.get("v.limitRec");

        var action  = component.get("c.getHOMbyQcAccountDB");
        action.setParams({
            'paymentId': recordId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){

                
                var result = response.getReturnValue();
                component.set("v.baseresult", result);
                console.log(result.length);
                
                var baseresult = result;
                if(baseresult.length >= limitRec){
                    this.showResult(component, baseresult, limitRec) 
                }else{                    
                    component.set("v.result", baseresult); 
                } 
                
                
                
                
            }else{
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
            }
        });


        $A.enqueueAction(action);
    },


    showResult : function(component, baseresult, limitRec){
        debugger;
        var result;

        for(var i = 0; i< baseresult.length; i++){
            if(baseresult[i].Selected === true){
                result = baseresult[i];
                baseresult.splice(i,1);
            }
        }

        
        if(result != null && result != undefined){
            var showressult = baseresult.slice(0, limitRec); 
            showressult.push(result);
            component.set("v.result", showressult);   
        }else{
            component.set("v.result", baseresult);   
        }
        
              
    },

    savePayment :function(component){
        var recordId = component.get("v.recordId");
        var result = component.get("v.result");
        var homId;

        for(var i = 0; i< result.length; i++){
            if(result[i].Selected === true){
                homId = result[i].HOMId;  
            }
        }

        if(homId != null && homId != undefined){
            var action  = component.get("c.savePaymentDB");
            action.setParams({
                'recordId': recordId,
                'homId': homId,
            });

            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type":"success",
                        "mode": "sticky",
                        "message": "The Payment has been updated successfully."
                    });
                    toastEvent.fire();

                    location.reload();
                }else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "type":"error",
                        "mode": "sticky",
                        "message": "The Payment has failed to update."
                    });
                    toastEvent.fire();

                    var err = response.getError();
                    console.log('Error => ' + JSON.stringify(err));
                }
            });


            $A.enqueueAction(action);

        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Warning!",
                "type":"warning",
                "mode": "sticky",
                "message": "You're not select any HOM."
            });
            toastEvent.fire();        
        }
    },

    resetSelection : function(component){

        var selections = component.find("rowSelectionCheckboxId");
        var resetCheckbox = false;
        if(Array.isArray(selections)){
            selections.forEach(function(checkbox){
                checkbox.set("v.value", resetCheckbox);
            });
        }else{
            selections.set("v.value", resetCheckbox);
        }
    }
})