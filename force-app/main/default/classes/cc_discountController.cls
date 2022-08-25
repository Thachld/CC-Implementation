public with sharing class cc_discountController {
    public class PicklistWraper{
        @AuraEnabled
        public string value {get;set;}

        @AuraEnabled
        public string label {get;set;}
    }


    @AuraEnabled
	public static List<PicklistWraper> getDiscountByDB(){
		List<PicklistWraper> options = new List<PicklistWraper>();

		Schema.DescribeFieldResult result = Discount__c.Discout_Bonus_By__c.getDescribe();

		List<Schema.PicklistEntry> pList = result.getPickListValues();

		for (Schema.PicklistEntry sp: pList){
            PicklistWraper pick = new PicklistWraper();           
            pick.value = sp.getValue();
            pick.label = sp.getlabel();
           
            options.add(pick);
		}		
		
		return options;
    }


    @AuraEnabled
	public static List<PicklistWraper> getDiscountTypeDB(){
		List<PicklistWraper> options = new List<PicklistWraper>();

		Schema.DescribeFieldResult result = Discount__c.Type__c.getDescribe();

		List<Schema.PicklistEntry> pList = result.getPickListValues();

		for (Schema.PicklistEntry sp: pList){
            PicklistWraper pick = new PicklistWraper();           
            pick.value = sp.getValue();
            pick.label = sp.getlabel();
           
            options.add(pick);
		}		
		
		return options;
    }


    @AuraEnabled
    public static List<Discount__c> getDiscountByContractDB(String conId){
        try {
            List<Discount__c> discounts = new List<Discount__C>();

            discounts = [SELECT Id, Discout_Bonus_By__c, Type__c,
                                Min_payment__c, Max_payment__c, Min_spending__c,Max_spending__c,
                                Discount_rate__c, Amount__c, Custom_Contract__c, CurrencyIsoCode
                        FROM Discount__c WHERE Custom_Contract__c =: conId];
            
            return discounts;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Discount__c saveDiscountDB(Discount__c dis){
        try {
            Discount__c newdis = new Discount__c();
            newdis = dis;

            upsert newdis;
            return newdis;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteDiscountDB(String recId){
        try {
           Delete [SELECT Id FROM Discount__c WHERE Id = :recId];

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}