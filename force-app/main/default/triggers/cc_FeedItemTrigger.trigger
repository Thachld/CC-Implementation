trigger cc_FeedItemTrigger on FeedItem (before delete, before insert,before update, after insert, after update) {
    if(cc_Util.checkTriggerAllowRun('FEEDITEM_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_FeedItemHandler');
    }
}