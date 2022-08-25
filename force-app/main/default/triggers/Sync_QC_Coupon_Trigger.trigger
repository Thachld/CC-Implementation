trigger Sync_QC_Coupon_Trigger on Sync_QC_Coupon__e (after insert) {
    if(cc_Util.checkTriggerAllowRun('SYNC_COUPON_TRIGGER')){        
    
        List<cc_CouponAPIWrapper.ParamWrapper> listParams = new List<cc_CouponAPIWrapper.ParamWrapper>();
        for (Sync_QC_Coupon__e evt : (List<Sync_QC_Coupon__e>)Trigger.new){ 
            if(!String.isBlank(evt.Coupon_Campaign_Id__c)
                && !String.isBlank(evt.CouponId__c)
                && !String.isBlank(evt.QC_Account__c)){
                
                cc_CouponAPIWrapper.ParamWrapper param = new cc_CouponAPIWrapper.ParamWrapper();
                param.coupon_campaign_id = evt.Coupon_Campaign_Id__c;
                param.coupon_id = evt.CouponId__c;
                param.qc_account = evt.QC_Account__c;
                param.payment = evt.Payment__c;
                listParams.add(param);
            }
            

        }

        System.debug('listParams=>' + listParams);
        if(listParams.size() > 0){
            String params = JSON.serialize(listParams);
            Sync_QC_Coupon_Helper.attemptSyncCouponsFromQC(params);
        }

    }

}