trigger cc_ContractlinkTrigger on Contract_link__c (before insert) {    
    if(cc_Util.checkTriggerAllowRun('CONTRACTLINK_TRIGGER')){
        cc_ContractLinkHandler.bulkBefore();
    }
}