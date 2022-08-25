/**
 * Author: Marcus Ericsson - mericsson@salesforce.com
 */
trigger DisableFeedCommentDeletes on FeedComment (before delete, before insert) 
{
    if(cc_Util.checkTriggerAllowRun('FEEDCOMMENT_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_FeedCommentHandler');
    }
}