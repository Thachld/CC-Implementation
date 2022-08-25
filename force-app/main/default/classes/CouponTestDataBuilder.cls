@istest
public with sharing class CouponTestDataBuilder {

    private Coupon__c coupon;

    public CouponTestDataBuilder() {
        coupon = new Coupon__c();
        this.coupon.Name = 'Coupon Test Data';        
        this.coupon.Status__c = 'Draft';        
        this.coupon.ExpirationDate__c = System.today() - 10;
        this.coupon.SpendingExpirationDate__c = System.today() + 20;    
        this.coupon.Amount__c  = 10;    
        this.coupon.IsSpendingBonusCoupon__c = false;

    }

    public CouponTestDataBuilder setCampaign(String campId){
        this.coupon.Campaign__c = campId;
        return this;
    }

    public CouponTestDataBuilder setQCAccount(String qcId){
        this.coupon.QC_Account__c = qcId;
        return this;
    }

    public CouponTestDataBuilder setAmount(Decimal amt){
        this.coupon.Amount__c = amt;
        return this;
    }

    public CouponTestDataBuilder setName(String name){
        this.coupon.Name = name;
        return this;
    }

    public CouponTestDataBuilder setCouponId(String couponId){
        this.coupon.CouponId__c = couponId;
        return this;
    }

    public CouponTestDataBuilder setStatus(String status){
        this.coupon.Status__c = status;
        return this;
    }

    public CouponTestDataBuilder setExpiredDate(Date startdate){
        this.coupon.ExpirationDate__c = startdate;
        return this;
    }

    public CouponTestDataBuilder setSpendingExpiredDate(Date endate){
        this.coupon.SpendingExpirationDate__c = endate;
        return this;
    }     

    public CouponTestDataBuilder setSpendingPaymentBonus(Boolean value){
        this.coupon.IsSpendingBonusCoupon__c = value;
        return this;
    }

    public CouponTestDataBuilder setSource(String value){
        this.coupon.Source__c = value;
        return this;
    }

    public CouponTestDataBuilder setStartDate(Date value){
        this.coupon.Start_Date__c = value;
        return this;
    }

    public CouponTestDataBuilder setEndDate(Date value){
        this.coupon.End_Date__c = value;
        return this;
    }

    public CouponTestDataBuilder setIntervalSpendingDays(Integer value){
        this.coupon.Interval_Spending_Days__c = value;
        return this;
    }

    public CouponTestDataBuilder setConditionAmount(Decimal value){
        this.coupon.Condition_Amount__c = value;
        return this;
    }

    public Coupon__c build(){
        return this.coupon;
    }

    public Coupon__c buildAndSave(){             
        if(Schema.SObjectType.Coupon__c.isCreateable()){
            insert this.coupon;
        }   
        
        return this.coupon;
    }
}