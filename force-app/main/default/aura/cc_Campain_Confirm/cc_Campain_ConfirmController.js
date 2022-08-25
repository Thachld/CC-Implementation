({
    doInit : function(component, event, helper) {
       
        var campaign = component.get("v.campaign");
        var memberid = component.get("v.memberid");

        if(campaign == '' || campaign ==  undefined ||  memberid == '' || memberid ==  undefined){
            helper.goErrorPage(component, event);         
        }
    },

    handleSubmit : function(component, event, helper) {
        
        var isJoinAUID = component.find("isJoinAUID");
        var expired_date = new Date(2020,10,18,23,59,59);
        var today = new Date();

        if(today > expired_date){
            component.set("v.showexpired",true);
        }else{
            component.set("v.showexpired",false);

            if(!isJoinAUID.get("v.checked")){                
                component.set("v.showRequired",true);
            }else{
                helper.doSave(component, event);
            }
        }

        

        
    },

    handleChangeOption : function(component, event, helper) {
        var checked = checkAll.get("v.checked");   
        if(checked){
            component.set("v.showRequired",false);
        }else{
            component.set("v.showRequired",true);
        }
        
    }
})