trigger cc_TransferSpendingCashTrigger on TransferSpendingCash__c (after insert, after update) {
    if(cc_Util.checkTriggerAllowRun('TRANSFERDATA_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_TransferSpendingCashHandler');
    }
}