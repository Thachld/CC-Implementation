trigger ClientSharingTrigger on Client_Sharing__c (before insert, before update, after update) {
    if(cc_Util.checkTriggerAllowRun('CLIENT_SHARING_TRIGGER')){
        cc_TriggerFactory.createHandler('ClientSharingTriggerHandler');
    }
}