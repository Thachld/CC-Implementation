({
    closeQA : function(component, event, helper) {

        let recordId = event.getParam('newrecordid'); 
        var homeEvt = $A.get("e.force:navigateToObjectHome");
            homeEvt.setParams({
                "scope": "Coupon__c"
            });
            homeEvt.fire(); 

        // if(recordId){
        //     var navEvt = $A.get("e.force:navigateToSObject");
        //         navEvt.setParams({
        //             "recordId": recordId,
        //             "slideDevName": "related"
        //         });
        //     navEvt.fire();
        // }else{
        //     var homeEvt = $A.get("e.force:navigateToObjectHome");
        //     homeEvt.setParams({
        //         "scope": "Coupon__c"
        //     });
        //     homeEvt.fire();            
        // }
    }

        
})