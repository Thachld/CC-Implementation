@istest
public with sharing class AccountTestDataBuilder {
    private Account acc;

    public AccountTestDataBuilder() {
        this.Acc = new Account();
        this.Acc.name = 'Account Test Data';       
    }

    public AccountTestDataBuilder setIndustry(String industry){
        this.acc.Industry__c = industry;
        return this;
    }

    public AccountTestDataBuilder setRecordType(String rectypeId){
        this.acc.RecordtypeId = rectypeId;
        return this;
    }


    public AccountTestDataBuilder setArea(String area){
        this.acc.Area__c = area;
        return this;
    }


    public AccountTestDataBuilder setName(String name){
        this.acc.Name = name;
        return this;
    }

    public Account build(){
        return this.acc;
    }

    public Account buildAndSave(){
        if(Schema.SObjectType.Account.iscreateable()){
            insert this.acc;
        }

        return this.acc;
    }

}