trigger cc_LeadTrigger on Lead (before update, after update) {
    if(cc_Util.checkTriggerAllowRun('LEAD_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_LeadTriggerHandler');
    }
}