({
    doSave : function(component, event) {       
        var confirm = component.get("v.confirm");
        var campaign = component.get("v.campaign");
        var memberid = component.get("v.memberid");       

        confirm.Campaign__c = campaign;
        confirm.Campaign_Member__c = memberid;

        var action = component.get("c.saveCampaignConfirmDB");
        action.setParams({
            'confirm': confirm
        });

		action.setCallback(this, function(response){
			var state = response.getState();
           
			if (state === "SUCCESS"){				        
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    mode: 'sticky',
                    type : 'success',
                    message: "Your submition has been updated successfully."
                });
                toastEvent.fire();

                this.goThanksPage(component, event);
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Failed!",
                    mode: 'sticky',
                    type : 'error',
                    message: "Your submition has been failed to updated."
                });
                toastEvent.fire();

                var error = response.getError();
                var js = JSON.stringify(error);
                console.log(js);

			}
		});

		$A.enqueueAction(action);
    },

    goThanksPage : function(component, event) {
        let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url" : '/thanks' });
            urlEvent.fire();
    },

    goErrorPage : function(component, event) {
        let urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({ "url" : '/error' });
            urlEvent.fire();
    }
})