public with sharing class cc_MassCreateCoupon_Queueable implements Queueable, Database.AllowsCallouts{
    public Set<String> couponIds {get;set;}
    public cc_MassCreateCoupon_Queueable(Set<String> pcouponIds) {
        this.couponIds = pcouponIds == null? new Set<String>(): pcouponIds;
    }

    public void execute(QueueableContext qc){
        cc_MassCreateCoupon_Batch batch = new cc_MassCreateCoupon_Batch(this.couponIds);
        if(Test.isRunningTest()){
            Database.executeBatch(batch);
        }else {
            Database.executeBatch(batch, 50);
        }
        
    }
}