({
    getDiscounts : function(component, contractId) {        
        var action =component.get("c.getDiscountByContractDB");        
        action.setParams({
            'conId': contractId
        });

        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();	
                
                if(result.length >0){
                    for(let i = 0 ; i< result.length; i ++){
                        result[i].isnew = false;
                    }
                }else{
                    var newRecord = component.get("v.newRecord");
                    var recordId  = component.get("v.recordId");
                    newRecord.isnew =  true;
                    newRecord.Custom_Contract__c = recordId;

                    result.push(newRecord);
                }
                
                component.set("v.discounts", result);               
                this.sortBy(component,'Discount_rate__c');
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var err = response.getError();
                console.log('Error => ' + JSON.stringify(err));
			}
        });

        $A.enqueueAction(action);
    },

    sortBy: function(component, field) {        
        var sortResult = true,            
            records = component.get("v.discounts"),
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

        component.set("v.discounts", records);        
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

    displaySection : function(component, event, auraId){
        var section = component.find(auraId);
        if($A.util.hasClass(section,"slds-is-open")){
            $A.util.addClass(section,"slds-is-close");
            $A.util.removeClass(section,"slds-is-open");
        }else if($A.util.hasClass(section,"slds-is-close")){
            $A.util.addClass(section,"slds-is-open");
            $A.util.removeClass(section,"slds-is-close");
        }
    },    

})