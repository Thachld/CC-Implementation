public class cc_MassCreateCoupon_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    private Set<String> couponIds {get;set;}

    public cc_MassCreateCoupon_Batch(Set<String> pcouponIds) {
        this.couponIds = pcouponIds == null? new Set<String>(): pcouponIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, Campaign__c, 
                                                Campaign__r.QCCampaignId__c, 
                                                Campaign__r.Required_Interval_Spending_Days__c,
                                                Transaction_Type__c,
                                                TransactionTypeId__c,   
                                                QC_Account__r.Name, 
                                                ExpirationDate__c,
                                                SpendingExpirationDate__c, 
                                                Amount__c, 
                                                Quantity__c, 
                                                CouponId__c,
                                                Interval_Spending_Days__c,
                                                Promotion_Condition_Content__c
                                        FROM Coupon__c WHERE Id IN :couponIds]);
    }

    public void execute(Database.BatchableContext bc, List<Coupon__c> scope){
        List<cc_CouponAPIWrapper.CreateCouponWrapper> coupons = new List<cc_CouponAPIWrapper.CreateCouponWrapper>();

        for(Coupon__c cp: scope){  

            if(!String.isBlank(cp.Campaign__r.QCCampaignId__c) && String.isBlank(cp.CouponId__c)){                      
                Datetime expireddt = Datetime.newInstance(cp.ExpirationDate__c.year(),cp.ExpirationDate__c.month(),cp.ExpirationDate__c.day());  
                String expiredStr = expireddt.format('yyyy-MM-dd');

                String expireSpddStr;
                Datetime expiredSpenndingdt;
                if(String.isBlank(cp.TransactionTypeId__c)){     
                    Date expSpendingDate =  cp.SpendingExpirationDate__c == null? Date.today() : cp.SpendingExpirationDate__c;
                    expiredSpenndingdt = Datetime.newInstance(expSpendingDate.year(),expSpendingDate.month(),expSpendingDate.day()); 
                    expireSpddStr = expiredSpenndingdt.format('yyyy-MM-dd'); 
                }
                
                Set<String> emails = new Set<String>();
                emails.add(cp.QC_Account__r.Name);

                cc_CouponAPIWrapper.CreateCouponWrapper coupon = new  cc_CouponAPIWrapper.CreateCouponWrapper();
                coupon.couponCampaignId = cp.Campaign__r.QCCampaignId__c;   
                coupon.expireDate = expiredStr;
                coupon.spendingExpiredDate = expireSpddStr;
                coupon.quantity = Integer.valueOf( cp.Quantity__c);
                coupon.value = cp.Amount__c;    
                coupon.emails = emails;  
                coupon.Id = cp.Id;
                coupon.qcemail = cp.QC_Account__r.Name;
                coupon.campaign = cp.Campaign__c;
                coupon.transactionType = String.isBlank(cp.Transaction_Type__c)? '' : cp.Transaction_Type__c;
                coupon.transactionTypeMappingId = String.isBlank(cp.TransactionTypeId__c)? '': cp.TransactionTypeId__c;
                coupon.intervalSpendingDays = (Integer)cp.Interval_Spending_Days__c;
                coupon.promotionConditionContent = String.isBlank(cp.Promotion_Condition_Content__c)? '': cp.Promotion_Condition_Content__c;
                
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