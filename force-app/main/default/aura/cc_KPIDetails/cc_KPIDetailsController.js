({


    doInit :function(component,event,helper){   
        var kpitargetId = component.get("v.recordId");        
        helper.getKPIDetails(component,kpitargetId);
    },

    handlerKPITargetAction :function(component,event,helper){   
        var KPIEvtType = event.getParam("eventType");
        var kpidetais = component.get("v.kpidetails");
        if(KPIEvtType == 'Add'){
            debugger;
            var newRecord = component.get("v.newRecord");
            var recordId  = component.get("v.recordId");
            newRecord.isnew =  true;
            newRecord.KPI_Target__c = recordId;

            kpidetais.push(newRecord);
            
            component.set("v.kpidetais",kpidetais);
        }else if(KPIEvtType == 'Update'){ 
            helper.sortBy(component,'Sale__c');
            component.set("v.isdatachanged",false);
        }else if(KPIEvtType == 'Delete'){
            var idx = event.getParam("recordIdx");

            kpidetais.splice(idx-1,1);
            component.set("v.kpidetais",kpidetais);            
            helper.sortBy(component,'Sale__c');
            component.set("v.isdatachanged",false);
        }else if(KPIEvtType == 'editChange'){
            component.set("v.isdatachanged",true);
        }
    },


    handleCancel :function(component,event,helper){   
        var kpitargetId = component.get("v.recordId");        
        helper.getKPIDetails(component,kpitargetId);
        component.set("v.isdatachanged",false);
    },

    handleSave :function(component,event,helper){ 
        helper.saveRecords(component,event);
        var kpitargetId = component.get("v.recordId");        
        helper.getKPIDetails(component,kpitargetId);
        component.set("v.isdatachanged",false);
    }
})