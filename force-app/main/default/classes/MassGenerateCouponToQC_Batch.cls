public with sharing class MassGenerateCouponToQC_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    private String campId {get;set;}
    
    public MassGenerateCouponToQC_Batch(String pCampId) {
        this.campId = pCampId;
    }


    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, Campaign__c, Campaign__r.QCCampaignId__c, QC_Account__r.Name, 
                                        ExpirationDate__c,SpendingExpirationDate__c, Amount__c, Quantity__c
                                        FROM Coupon__c 
                                        WHERE Campaign__c = :this.campId
                                            AND Status__c = 'Draft'
                                        ]);
    }

    public void execute(Database.BatchableContext bc, List<Coupon__c> scope){
        List<cc_CouponAPIWrapper.CreateCouponWrapper> coupons = new List<cc_CouponAPIWrapper.CreateCouponWrapper>();    

        for(Coupon__c cp: scope){
            if(!String.isBlank(cp.Campaign__r.QCCampaignId__c)){    
                Datetime expireddt = Datetime.newInstance(cp.ExpirationDate__c.year(),cp.ExpirationDate__c.month(),cp.ExpirationDate__c.day());  
                Datetime expiredSpenndingddt = Datetime.newInstance(cp.SpendingExpirationDate__c.year(),cp.SpendingExpirationDate__c.month(),cp.SpendingExpirationDate__c.day());                            
                String expiredStr = expireddt.format('yyyy-MM-dd');
                String expireSpddStr = expiredSpenndingddt.format('yyyy-MM-dd'); 
                Set<String> emails = new Set<String>();
                emails.add(cp.QC_Account__r.Name);

                cc_CouponAPIWrapper.CreateCouponWrapper coupon = new  cc_CouponAPIWrapper.CreateCouponWrapper();
                coupon.couponCampaignId = cp.Campaign__r.QCCampaignId__c;   
                coupon.expireDate = expiredStr;
                coupon.spendingExpiredDate = expireSpddStr;
                coupon.quantity = Integer.valueOf(cp.Quantity__c) ;
                coupon.value = cp.Amount__c;    
                coupon.emails = emails;  
                coupon.Id = cp.Id;
                coupon.qcemail = cp.QC_Account__r.Name;
                coupon.campaign = cp.Campaign__c;
                
                coupons.add(coupon);
            }
        }

        if(coupons.size() > 0){
            cc_CouponHelper.syncCreateCouponsToQC(coupons);
        }
    }

    public void finish(Database.BatchableContext bc){
        
    }
}