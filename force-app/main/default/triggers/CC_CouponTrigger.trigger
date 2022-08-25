trigger CC_CouponTrigger on Coupon__c (before insert, after insert, before update, after update, before delete) {    
    if(cc_Util.checkTriggerAllowRun('COUPON_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_CouponHandler');
    }

}