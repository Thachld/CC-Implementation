@istest
public with sharing class QCAccountTestDataBuilder {
    private QC_Account__c qcAcc;

    public QCAccountTestDataBuilder() {
        this.qcAcc = new QC_Account__c();
        this.qcAcc.Name = 'cococTestdata@coccoc.com';
        this.qcAcc.Industry__c = 'Retails';
        this.qcAcc.Status__c = 'New Account';
    }

    public QCAccountTestDataBuilder setName(String name) {
        this.qcAcc.Name = name;
        return this;
    }

    public QCAccountTestDataBuilder setAccount(String accId) {
        this.qcAcc.AccountOwner__c =  accId;

        return this;
    }

    public QCAccountTestDataBuilder setIndustry(String industry) {
        this.qcAcc.Industry__c =  industry;

        return this;
    }

    public QCAccountTestDataBuilder setStatus(String status) {
        this.qcAcc.Status__c = status;
        return this;
    }

    public QCAccountTestDataBuilder setOwner(String userId) {
        this.qcAcc.OwnerId = userId;        
        return this;
    }

    public QCAccountTestDataBuilder setSale(String saleId) {
        this.qcAcc.Sales__c = saleId;        
        return this;
    }

    public QCAccountTestDataBuilder setSupport(String suportId) {
        this.qcAcc.Support__c = suportId;
        return this;
    }

    public QCAccountTestDataBuilder setQcId(String value) {
        this.qcAcc.QC_Account_Id__c = value;
        return this;
    }

    public QCAccountTestDataBuilder setSource(String value) {
        this.qcAcc.Source__c = value;
        return this;
    }

    public QCAccountTestDataBuilder setApplyTransactionType(Boolean value) {
        this.qcAcc.IsApplyTransactionType__c = value;
        return this;
    }
  
    public QC_Account__c build(){
        return this.qcAcc;
    }

    public QC_Account__c buildAndSave(){
        if(Schema.SObjectType.QC_Account__c.iscreateable()){
            insert this.qcAcc;
        }

        return this.qcAcc;
    }
}