trigger cc_CampaignTrigger on Campaign (after insert, after update, before delete) {
    if(cc_Util.checkTriggerAllowRun('CAMPAIGN_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_CampaignHandler');
    }
}