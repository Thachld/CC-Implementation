@istest
public class cc_discountController_Test {
    @TestSetup
    static void testSetup(){
        cc_setting__c ccSetting = cc_initData.initCustomeSetting();
        insert ccSetting;
        Date today = System.today();

        String accname = 'Batch Account test 1';
        Account acc = cc_initData.initAccount(accname);   
        insert acc;
        
        Date constartDate = today.toStartOfMonth();
        Date conendDate = constartDate.addMonths(5);
        String type = 'Master - Commitment';
        Contract__c con = cc_initData.initContract(acc.Id, constartDate, conendDate, type);        
        insert con;
    }

 
    public testMethod static void testgetDiscountByContractDB(){
        Contract__c con = [SELECT ID FROM Contract__c LIMIT 1];

        Discount__c newdiscount = new Discount__c();

        newdiscount.Discout_Bonus_By__c = 'Spending';
        newdiscount.Type__c = 'Discount';
        newdiscount.Min_spending__c = 0;
        newdiscount.Max_spending__c = 10000000;
        newdiscount.Discount_rate__c = 10;
        newdiscount.Custom_Contract__c = con.Id;
        
        Discount__c insDiscount = cc_discountController.saveDiscountDB(newdiscount);

        System.assert(insDiscount.Id != null);

        List<Discount__c> discounts =  cc_discountController.getDiscountByContractDB(con.Id);

        System.assertEquals(1, discounts.size());

        cc_discountController.deleteDiscountDB(insDiscount.Id);

    }

    public testMethod static void testGetPicklist(){
        List<cc_discountController.PicklistWraper> bys  = cc_discountController.getDiscountByDB();
        List<cc_discountController.PicklistWraper> types  = cc_discountController.getDiscountTypeDB();

        System.assert(bys.size() > 0);
        System.assert(types.size() > 0);
    }
}