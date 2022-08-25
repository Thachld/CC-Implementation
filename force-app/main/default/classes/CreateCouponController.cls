/**
 * @description       : Create Coupon Controller
 * @author            : @Thach Le
 * @group             : Create Coupon
 * @last modified on  : 07-28-2022
 * @last modified by  : @Thach Le
**/
public with sharing class CreateCouponController {
    
    @AuraEnabled
    public static Campaign getCampaign(String campId){
        try {
            Campaign campResult = new Campaign();
            campResult = [SELECT Id, Name, Transactions_Type__c, Condition_Type__c ,  Internal_Type__c,Interval_Spending_Days__c,CouponExpired__c, Required_Interval_Spending_Days__c FROM Campaign WHERE Id = :campId];

            return campResult;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static QC_Account__c getQCAccount(String qcAccId){
        try {
            QC_Account__c qcAccResult = new QC_Account__c();
            qcAccResult = [SELECT Id, Name, IsApplyTransactionType__c, QC_Account_Id__c FROM QC_Account__c WHERE Id = :qcAccId];

            return qcAccResult;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}