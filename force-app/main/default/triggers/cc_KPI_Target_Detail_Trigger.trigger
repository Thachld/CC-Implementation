trigger cc_KPI_Target_Detail_Trigger on KPI_Target_Detail__c (before insert, before update, after update) {
    System.debug('KPITARGET_TRIGGER =>' + cc_Util.checkTriggerAllowRun('KPITARGET_TRIGGER'));
    if(cc_Util.checkTriggerAllowRun('KPITARGET_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_KPITargetDetailHandler');
    }
}