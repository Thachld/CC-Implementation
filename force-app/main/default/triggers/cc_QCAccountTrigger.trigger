trigger cc_QCAccountTrigger on QC_Account__c (before insert,  before update, after insert, after update) {    
    if(cc_Util.checkTriggerAllowRun('QC_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_QC_AccountHandler');
    }
}