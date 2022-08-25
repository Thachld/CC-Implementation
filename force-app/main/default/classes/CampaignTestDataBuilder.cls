@istest
public with sharing class CampaignTestDataBuilder {

    private Campaign camp;

    public CampaignTestDataBuilder() {
        camp = new Campaign();
        this.camp.Name = 'Campaign Test Data';
        this.camp.CurrencyIsoCode = 'VND';
        this.camp.Status = 'Planned';
        this.camp.IsActive = true;
        this.camp.StartDate = System.today() - 10;
        this.camp.EndDate = System.today() + 20;  
        this.camp.IsSpendingBonusCampaign__c = false;      
    }

    public CampaignTestDataBuilder setRecordType(String recID){
        this.camp.RecordtypeId = recID;
        return this;
    }

    public CampaignTestDataBuilder setName(String name){
        this.camp.Name = name;
        return this;
    }

    public CampaignTestDataBuilder setStatus(String status){
        this.camp.Status = status;
        return this;
    }
    public CampaignTestDataBuilder setStartDate(Date startdate){
        this.camp.StartDate = startdate;
        return this;
    }

    public CampaignTestDataBuilder setEnddate(Date endate){
        this.camp.EndDate = endate;
        return this;
    }    

    public CampaignTestDataBuilder setDescription(String descr){
        this.camp.Description = descr;
        return this;
    }

    public CampaignTestDataBuilder setSpendingPaymentBonus(Boolean value){
        this.camp.IsSpendingBonusCampaign__c = value;
        return this;
    }

    public CampaignTestDataBuilder setQCCampaignId(String campId){
        this.camp.QCCampaignId__c = campId;

        return this;
    }

    public CampaignTestDataBuilder setTransactionType(String transId){
        this.camp.Transactions_Type__c = transId;

        return this;
    }

    public CampaignTestDataBuilder setMultipleUsage(Boolean isMultipleUsage){
        this.camp.MultipleUsage__c = isMultipleUsage;

        return this;
    }

    public CampaignTestDataBuilder setConditionType(String onditionType){
        this.camp.Condition_Type__c = onditionType;

        return this;
    }

    public CampaignTestDataBuilder setCampaignContent(String content){
        this.camp.Campaign_Content__c = content;

        return this;
    }

    public Campaign build(){
        return this.camp;
    }

    public Campaign buildAndSave(){             
        if(Schema.SObjectType.Campaign.isCreateable()){
            insert this.camp;
        }   
        
        return this.camp;
    }
}