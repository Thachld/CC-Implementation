trigger cc_CaseTrigger on Case (after insert, after update, before update, before insert) {
    if(cc_Util.checkTriggerAllowRun('CASE_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_CaseTriggerHander');
    }
}