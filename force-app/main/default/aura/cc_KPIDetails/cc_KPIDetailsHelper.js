({
    getKPIDetails :function(component,kpitargetId){
        var action =component.get("c.getKPIDetailsDB");        
        action.setParams({
            'targetId': kpitargetId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                
                var result = response.getReturnValue();	
                if(result.length > 0){
                    for(let i = 0 ; i< result.length; i ++){
                        result[i].isnew = false;

                        if(result[i].KPITargetType__c === 'Sale_Manager_KPI'){
                            result[i].disabled = true;
                        }else{
                            result[i].disabled = false;                            
                        }
                    }
                }else{
                    var newRecord = component.get("v.newRecord");
                    var recordId  = component.get("v.recordId");
                    newRecord.isnew =  true;
                    newRecord.KPI_Target__c = recordId;

                    result.push(newRecord);
                }                
                
                component.set("v.kpidetails", result);               
                this.sortBy(component,'Sale__c');
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
			}
        });

        $A.enqueueAction(action);
    },

    saveRecords: function(component,event){
        var action =component.get("c.saveKPITargetdetaislDB");  
        var targetdetails = component.get("v.kpidetails");
        action.setParams({
            'targetdetails': targetdetails
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type":"success",
                    "mode": "sticky",
                    "message": "The records has been updated successfully."
                });
                toastEvent.fire();
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "mode": "sticky",
                    "message": "The records has failed to update."
                });
                toastEvent.fire();

                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
			}
        });

        $A.enqueueAction(action);
    },

    sortBy: function(component, field) {        
        var sortResult = true,            
            records = component.get("v.kpidetails"),
            fieldPath = field.split(/\./),
            fieldValue = this.fieldValue;
            // sortResult = sortField != field || !sortResult;
        records.sort(function(a,b){
            var aValue = fieldValue(a, fieldPath),
                bValue = fieldValue(b, fieldPath),
                t1 = aValue == bValue,
                t2 = (!aValue && bValue) || (aValue < bValue);
            return t1? 0: (sortResult?-1:1)*(t2?1:-1);
        });   

        component.set("v.kpidetails", records);        
    },

    fieldValue: function(object, fieldPath) {
        var result = object;
        fieldPath.forEach(function(field) {
            if(result) {
                result = result[field];
            }
        });
        return result;
    },
})