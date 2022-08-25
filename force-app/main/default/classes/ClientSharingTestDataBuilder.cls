public with sharing class ClientSharingTestDataBuilder {
    private Client_Sharing__c clSharing;
    public ClientSharingTestDataBuilder() {
        this.clSharing = new Client_Sharing__c();       
    }

    public ClientSharingTestDataBuilder setName(String value){
        this.clSharing.Name = value;
        return this;
    }

    public ClientSharingTestDataBuilder setAccount(String value){
        this.clSharing.Account__c = value;
        return this;
    }

    public ClientSharingTestDataBuilder setShareType(String value){
        this.clSharing.Share_Type__c = value;
        return this;
    }

    public ClientSharingTestDataBuilder setShareFrom(String value){
        this.clSharing.Share_To__c = value;
        return this;
    }

    public ClientSharingTestDataBuilder setShareTo(String value){
        this.clSharing.Share_To__c = value;
        return this;
    }

    public ClientSharingTestDataBuilder setStatus(String value){
        this.clSharing.Status__c = value;
        return this;
    }

    public ClientSharingTestDataBuilder setStartDate(Date value){
        this.clSharing.Start_Date__c = value;
        return this;
    }

    public ClientSharingTestDataBuilder setEndDate(Date value){
        this.clSharing.End_Date__c = value;
        return this;
    }


    public Client_Sharing__c build(){
        return this.clSharing;
    }

    public Client_Sharing__c buildAndSave(){
        if(Schema.SObjectType.Client_Sharing__c.isCreateable()){
            insert this.clSharing;
        }   
        return this.clSharing;
    }

}