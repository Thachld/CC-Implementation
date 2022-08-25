trigger cc_paymentTrigger on Payment__c (before insert, before update, after insert, after update, after delete, after undelete) {   

    if(cc_Util.checkTriggerAllowRun('PAYMENT_TRIGGER')){
        cc_TriggerFactory.createHandler('cc_PaymentHandler');
    }
    
}