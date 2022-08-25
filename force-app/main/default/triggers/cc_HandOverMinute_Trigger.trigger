trigger cc_HandOverMinute_Trigger on HandOver_Minute__c ( before insert, before update, after update) {
    if(cc_Util.checkTriggerAllowRun('HOM_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_HandOverMinute_Handler');
    }
}