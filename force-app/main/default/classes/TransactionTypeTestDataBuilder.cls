@istest
public class TransactionTypeTestDataBuilder {
    private Transactions_Type__c transtype;
    public TransactionTypeTestDataBuilder() {
        transtype = new Transactions_Type__c();    
        transtype.Is_Enable__c = true;    
    }

    public TransactionTypeTestDataBuilder setName(String name){
        transtype.Name = name;
        return this;
    }

    public TransactionTypeTestDataBuilder setTransactionTypeId(String transId){
        transtype.TransactionTypeId__c = transId;
        return this;
    }

    public TransactionTypeTestDataBuilder setInternalType(String internaltype){
        transtype.Internal_Type__c = internaltype;
        return this;
    }

    public TransactionTypeTestDataBuilder setPriority(Integer priority){
        transtype.Priority__c = priority;
        return this;
    }

    public TransactionTypeTestDataBuilder setAllowCoupon(Boolean isAllow){
        transtype.Allow_Coupon__c = isAllow;
        return this;
    }

    public Transactions_Type__c build(){
        return this.transtype;
    }

    public Transactions_Type__c buildAndSave(){
        if(Schema.SObjectType.Transactions_Type__c.isCreateable()){
            insert this.transtype;
        }        
        return this.transtype;
    }
}