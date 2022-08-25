public with sharing class CouponIntegrationTestDataBuilder {
    private CouponIntegration__c cpinte;
    public CouponIntegrationTestDataBuilder() {
        this.cpinte = new CouponIntegration__c();        
    }

    public CouponIntegrationTestDataBuilder setName(String name){
        this.cpinte.Name = name;
        return this;
    }

    public CouponIntegrationTestDataBuilder setURI(String uri){
        this.cpinte.apiuri__c = uri;
        return this;
    }

    public CouponIntegrationTestDataBuilder setMethod(String method){
        this.cpinte.method__c = method;
        return this;
    }

    public CouponIntegrationTestDataBuilder setTimeout(Integer timeout){
        this.cpinte.TIMEOUT__c = timeout;
        return this;
    }

    public CouponIntegration__c build(){
        return this.cpinte;
    }

    public CouponIntegration__c buildAndSave(){
        insert this.cpinte;
        return this.cpinte;
    }
}