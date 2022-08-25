trigger cc_KPITargetTrigger on KPI_Target__c (after update) {
    if(cc_Util.checkTriggerAllowRun('KPITARGET_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_KPITargetHandler');
    }
}