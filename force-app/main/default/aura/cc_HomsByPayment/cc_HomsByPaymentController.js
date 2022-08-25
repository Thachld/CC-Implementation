({
    doInit : function(component, event, helper) {
        var limitrec = component.get("v.limitRec");
        helper.getdata(component);
    },


    onCheckboxChange :function (component, event, helper) {
        
        helper.resetSelection(component);

        var result = component.get("v.result");
        var index = event.getSource().get("v.name");  
        for(var i = 0; i< result.length; i++){
            if(i == index){
                result[i].Selected = true;
            }else{
                result[i].Selected = false;
            }
        }
        component.set("v.result",result);
        component.set("v.isdatachanged",true);
        
        event.getSource().set("v.value",true);        
        
    },

    directtoAccount : function (component, event, helper) {
        var AccountId = event.target.getAttribute('data-AccountId');  
        var result = component.get("v.result");
        var baseurl = result[0].BaseURL;
        
        if(baseurl != null && baseurl != undefined & AccountId != null & AccountId != undefined){
            baseurl = baseurl + '/' + AccountId;
            window.open(baseurl);
        }

    },

    directtoContract : function (component, event, helper) {
        var ContractId = event.target.getAttribute('data-ContractId');  
        var result = component.get("v.result");
        var baseurl = result[0].BaseURL;
        
        if(baseurl != null && baseurl != undefined & ContractId != null & ContractId != undefined){
            baseurl = baseurl + '/' + ContractId;
            window.open(baseurl);
        }

    },

    directtoHom : function (component, event, helper) {
        var HOMId = event.target.getAttribute('data-HOMId');  
        var result = component.get("v.result");
        var baseurl = result[0].BaseURL;
        
        if(baseurl != null && baseurl != undefined & HOMId != null & HOMId != undefined){
            baseurl = baseurl + '/' + HOMId;
            window.open(baseurl);
        }

    }, 


    handleSave :function (component, event, helper) {
        helper.savePayment(component);
    },

    handleCancel :function (component, event, helper) {
        helper.getdata(component);   
    },

    handleViewMore :function (component, event, helper) {
       
        var limitRec = component.get("v.limitRec");
        var baseresult =  component.get("v.baseresult");
        var result =  component.get("v.result");

        if(baseresult.length > result.length){
            if(baseresult.length >= result.length + limitRec){
                limitRec = result.length + limitRec;
            }else{
                limitRec = baseresult.length;
            }            
        }

        helper.showResult(component, baseresult, limitRec);       
    },
})