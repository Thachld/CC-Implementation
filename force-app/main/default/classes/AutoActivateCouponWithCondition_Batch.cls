/**
 * @description       : Auto Activate Promotion With Condition
 * @author            : @Thach Le
 * @group             : Promotion With Condition
 * @last modified on  : 07-29-2022
 * @last modified by  : @Thach Le
**/
public with sharing class AutoActivateCouponWithCondition_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    private Date rundate {get;set;}
    public AutoActivateCouponWithCondition_Batch(Date prundate) {
        this.rundate = prundate==null? Date.today(): prundate;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Campaign__r.QCCampaignId__c, 
                                            Campaign__r.Transactions_Type__r.Internal_Type__c,
                                            Campaign__r.Transactions_Type__r.TransactionTypeId__c,
                                            Condition_Type__c,
                                            CouponId__c,
                                            QC_Account__c, 
                                            QC_Account__r.QC_Account_Id__c,
                                            Start_Date__c,
                                            End_Date__c, 
                                            Condition_Amount__c,
                                            CreatedById,
                                            CreatedBy.QCuserId__c
                                        FROM Coupon__c
                                        WHERE Status__c = :CouponConstant.STATUS_ACTIVE
                                            AND CouponId__c != null
                                            AND Start_Date__c <= :this.rundate
                                            AND Campaign__r.Transactions_Type__r.Internal_Type__c = :TransactionTypeConstant.PROMOTION_WITH_CONDITION ]);
    }

    public void execute(Database.BatchableContext bc, List<Coupon__c> scope){
        Map<String,String> mapDisableCP = new Map<String,String>();
        Map<String,cc_CouponAPIWrapper.ActivateCouponWrapper> mapApplyCP = new Map<String,cc_CouponAPIWrapper.ActivateCouponWrapper>();
        Map<Id, Coupon__c> mapToUpdateCoupon = new Map<Id, Coupon__c>();

        for(Coupon__c cp: scope){
            if(cp.Condition_Type__c == CampaignConstant.CONDITION_TYPE_PAYMENT){               
                List <AggregateResult> aggresults  = [SELECT SUM(Final_Amount__c) Amount FROM Payment__c 
                                                        WHERE QC_Account__c = : cp.QC_Account__c
                                                        AND DAY_ONLY(convertTimezone(Effective_Date__c)) >= :cp.Start_Date__c 
                                                        AND DAY_ONLY(convertTimezone(Effective_Date__c)) <= :cp.End_Date__c
                                                        AND Stage__c = :PaymentConstant.STAGE_DONE
                                                        AND (RecordType.DeveloperName = :PaymentConstant.RECORDTYPE_STANDARD_PAYMENT 
                                                                OR RecordType.DeveloperName = :PaymentConstant.RECORDTYPE_TRANSFER_PAYMENT)
                                                    ];


                Decimal totalAmount = aggresults[0].get('Amount') == null?0: (Decimal)aggresults[0].get('Amount');      
                System.debug('totalAmount=>'+totalAmount);          
                if(totalAmount > 0 && totalAmount >= cp.Condition_Amount__c){
                    cc_CouponAPIWrapper.ActivateCouponWrapper cpwraper = new cc_CouponAPIWrapper.ActivateCouponWrapper();
                    cpwraper.couponid = cp.CouponId__c;
                    cpwraper.userid = cp.QC_Account__r.QC_Account_Id__c;
                    cpwraper.sfrecordId = cp.Id;
                    cpwraper.userRequestId = cp.CreatedBy.QCuserId__c == null? cp.QC_Account__r.QC_Account_Id__c : cp.CreatedBy.QCuserId__c;    

                    mapApplyCP.put(cp.CouponId__c, cpwraper);
                }else if(totalAmount >= 0 && totalAmount < cp.Condition_Amount__c){
                    if(System.today() > cp.End_Date__c){
                        mapDisableCP.put(cp.CouponId__c, cp.Id);
                    }
                }

                Coupon__c udCoupon = new Coupon__c(Id = cp.Id, Achievement_Amount__c = totalAmount);
                mapToUpdateCoupon.put(cp.Id, udCoupon);

            }
            else if(cp.Condition_Type__c == CampaignConstant.CONDITION_TYPE_SPENDING){
                List <AggregateResult> aggresults  = [SELECT SUM(Total_Spending__c) Amount FROM QC_Account_Data__c 
                                                        WHERE QC_Account__c = : cp.QC_Account__c
                                                        AND DAY_ONLY(convertTimezone(syn_date__c)) >= :cp.Start_Date__c 
                                                        AND DAY_ONLY(convertTimezone(syn_date__c)) <= :cp.End_Date__c   
                                                    ];

                Decimal totalAmount = aggresults[0].get('Amount') == null?0: (Decimal)aggresults[0].get('Amount');
                System.debug('totalAmount=>'+totalAmount);      
                if(totalAmount > 0 && totalAmount >= cp.Condition_Amount__c){
                    cc_CouponAPIWrapper.ActivateCouponWrapper cpwraper = new cc_CouponAPIWrapper.ActivateCouponWrapper();
                    cpwraper.couponid = cp.CouponId__c;
                    cpwraper.userid = cp.QC_Account__r.QC_Account_Id__c;
                    cpwraper.sfrecordId = cp.Id;
                    cpwraper.userRequestId = cp.CreatedBy.QCuserId__c == null? cp.QC_Account__r.QC_Account_Id__c : cp.CreatedBy.QCuserId__c;    

                    mapApplyCP.put(cp.CouponId__c, cpwraper);
                }else if(totalAmount >= 0 && totalAmount < cp.Condition_Amount__c){
                    if(System.today() > cp.End_Date__c){
                        mapDisableCP.put(cp.CouponId__c, cp.Id);
                    }
                }
                
                Coupon__c udCoupon = new Coupon__c(Id = cp.Id, Achievement_Amount__c = totalAmount);
                mapToUpdateCoupon.put(cp.Id, udCoupon);
            }
        }

        if(mapApplyCP.size() > 0){
            cc_CouponHelper.syncActivateCouponsToQC(mapApplyCP);
        }


        if(mapDisableCP.size() > 0){
            cc_CouponHelper.syncDisableCouponsToQC(mapDisableCP);
        }

        if(mapToUpdateCoupon.size() > 0){
            update mapToUpdateCoupon.values();
        }
    }

    public void finish(Database.BatchableContext bc){

    }
}