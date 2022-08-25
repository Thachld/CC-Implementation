trigger cc_TransferRequest_Trigger on Transfer_Request__c (after delete, after insert, after update, after undelete, before delete, before insert, before update) {
    if(cc_Util.checkTriggerAllowRun('TRANSFER_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_TransferRequestHandler');
    }
}