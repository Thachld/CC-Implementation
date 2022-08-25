public class GetCouponFromQC_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public GetCouponFromQC_Batch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,CouponId__c, CampaignId__c , QC_Account__c  
                                            FROM Payment__c 
                                            WHERE CouponId__c != null
                                            AND Id NOT IN (SELECT Payment__c FROM Coupon__c WHERE Payment__c != null) ]);
    }

    public void execute(Database.BatchableContext bc,List<Payment__c> scope){
        List<cc_CouponAPIWrapper.ParamWrapper> listParams = new List<cc_CouponAPIWrapper.ParamWrapper>();
        for(Payment__c py: scope){
            if( !String.isBlank(py.CouponId__c)
                && !String.isBlank(py.CampaignId__c)
                && !String.isBlank(py.Qc_Account__c) ){

                cc_CouponAPIWrapper.ParamWrapper param = new cc_CouponAPIWrapper.ParamWrapper();
                param.coupon_id = py.CouponId__c;
                param.coupon_campaign_id = py.CampaignId__c;
                param.qc_account = py.Qc_Account__c;
                param.payment = py.Id;

                listParams.add(param);
            }
        }

        if(listParams.size() > 0){
            Sync_QC_Coupon_Helper.syncSyncCouponsFromQC(listParams);
        }
    }

    public void finish(Database.BatchableContext bc){

    }
}