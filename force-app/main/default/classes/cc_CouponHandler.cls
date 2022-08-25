/**
 * @description       : Coupon trigger Handler
 * @author            : @Thach Le
 * @group             : Coupon trigger
 * @last modified on  : 08-10-2022
 * @last modified by  : @Thach Le
**/
public with sharing class cc_CouponHandler implements cc_ITrigger{       
    Set<String> createcouponIds = new Set<String>();     
    Set<String> updatecouponIds = new Set<String>();     
    Set<String> enablecouponIds = new Set<String>();     
    Set<String> disablecouponIds = new Set<String>(); 
    Set<String> activatecouponIds = new Set<String>();     
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        if( cc_static_Message.isDoneCouponViaAPI == null){
            cc_static_Message.isDoneCouponViaAPI = false;
        }
            
        cc_setting__c setting = cc_setting__c.getInstance('cc setting');

        //isInsert
        if(Trigger.isInsert){
            Set<String> qcIds = new Set<String>();
            Map<String, Coupon__c> mapExistsCoupon = new Map<String, Coupon__c>();
            Set<String> campaignIds = new Set<String>();
            Map<String, Campaign> mapCampaign = new Map<String, Campaign>();
            Map<String, Campaign> mapSingleUsageCampaign = new Map<String, Campaign>();

            for(Coupon__c newcp : (List<Coupon__c>)Trigger.new){
                if(!String.isBlank(newcp.QC_Account__c)){
                    qcIds.add(newcp.QC_Account__c);
                }

                if(!String.isBlank(newcp.Campaign__c)){
                    campaignIds.add(newcp.Campaign__c);
                }
            }

            Map<String, QC_Account__c> mapQC = new Map<String, QC_Account__c>([SELECT Id, OwnerId, Sales__c, Support__c, IsApplyTransactionType__c  FROM QC_Account__c WHERE Id IN : qcIds]);
            For(Campaign camp : [SELECT Id, Name, MultipleUsage__c,Transactions_Type__r.Internal_Type__c, Transactions_Type__r.TransactionTypeId__c 
                                                                                FROM Campaign WHERE Id IN : campaignIds]){
                mapCampaign.put(camp.Id, camp);
                if(camp.MultipleUsage__c == false){
                    mapSingleUsageCampaign.put(camp.Id, camp);
                }                                                                    
            }

            for(Coupon__c cp : [SELECT QC_Account__c, QC_Account__r.Name ,Campaign__c, Campaign__r.Name 
                                    FROM Coupon__c WHERE Campaign__c IN :mapSingleUsageCampaign.keySet()]){
                if(!String.isBlank(cp.Campaign__c ) && !String.isBlank(cp.QC_Account__c )){
                    String key = cp.Campaign__c + '##' + cp.QC_Account__c;
                    mapExistsCoupon.put(key, cp);
                }


            }

            for(Coupon__c newcp : (List<Coupon__c>)Trigger.new){
                if(!String.isBlank(newcp.QC_Account__c)){
                    QC_Account__c qc = mapQC.get(newcp.QC_Account__c);
                    Campaign camp = mapCampaign.get(newcp.Campaign__c);

                    //Assign Transaction Type
                    if(qc != null && camp != null){
                        if(qc.IsApplyTransactionType__c){
                            newcp.Internal_Type__c = camp.Transactions_Type__r.Internal_Type__c;
                            newcp.Transaction_Type_Id__c = camp.Transactions_Type__r.TransactionTypeId__c;
                        }
                    }

                    //Assinged Assignee
                    if(setting.CouponDefaultAssignee__c != null && String.isBlank(newcp.Assignee__c)){
                        newcp.Assignee__c = setting.CouponDefaultAssignee__c;
                    }

                    if(newcp.Status__c == CouponConstant.STATUS_ACTIVE ){ 
                        
                        //Update Support
                        if(newcp != null && qc.Support__c != null){                        
                            newcp.Support__c = qc.Support__c;
                        }

                        //Update Sale
                        if(qc != null && qc.Sales__c != null){                        
                            newcp.Sale__c = qc.Sales__c;
                        }

                        //Update Issue time
                        if(newcp.IssueTime__c == null){
                            newcp.IssueTime__c = System.now();
                        }
                    }
                }

                //If status is active
                if(newcp.Status__c == CouponConstant.STATUS_ACTIVE){
                    newcp.IssueTime__c = System.now();
                }


                //Check duplicate coupon with campaign 
                if(!String.isBlank(newcp.Campaign__c ) && !String.isBlank(newcp.QC_Account__c )){
                    String key = newcp.Campaign__c + '##' + newcp.QC_Account__c;                    
                    
                    if(mapExistsCoupon.containsKey(key)){
                        Coupon__c existscp  =  mapExistsCoupon.get(key);
                        String msg = 'QC Account: ' + existscp.QC_Account__r.Name + ' already has coupon record for this Campaign: ' + existscp.Campaign__r.Name;       
                        newcp.addError(msg);
                    }
                }


            }
        }else if(Trigger.isUpdate){
            Map<Id,Coupon__c> oldMap = (Map<Id,Coupon__c>)Trigger.oldMap;
            Set<String> qcIds = new Set<String>();
            Set<String> campaignIds = new Set<String>();
            Map<String, Coupon__c> mapExistsCoupon = new Map<String, Coupon__c>();

            for(Coupon__c newcp : (List<Coupon__c>)Trigger.new){
                Coupon__c oldCp = oldMap.get(newcp.Id);    
                if( !String.isBlank(newcp.QC_Account__c) 
                    && newcp.Status__c == CouponConstant.STATUS_ACTIVE ){
                    qcIds.add(newcp.QC_Account__c);
                }
            }

            Map<String, QC_Account__c> mapQC = new Map<String, QC_Account__c>([SELECT Id, OwnerId, Sales__c, Support__c FROM QC_Account__c WHERE Id IN : qcIds]);
            
            for(Coupon__c newcp : (List<Coupon__c>)Trigger.new){
                Coupon__c oldCp = oldMap.get(newcp.Id);   
                QC_Account__c qc = mapQC.get(newcp.QC_Account__c);                

                //Assinged Assignee
                if(setting.CouponDefaultAssignee__c != null && String.isBlank(newcp.Assignee__c)){
                    newcp.Assignee__c = setting.CouponDefaultAssignee__c;
                }

                if(newcp.Status__c == CouponConstant.STATUS_ACTIVE 
                    && newcp.Status__c != oldCp.Status__c){
                    
                    //Change Support
                    if(qc != null && qc.Support__c != null && newcp.Support__c != qc.Support__c){                        
                        newcp.Support__c = qc.Support__c;
                    }

                    //Change Sale
                    if(qc != null && qc.Sales__c != null && newcp.Sale__c != qc.Sales__c){                        
                        newcp.Sale__c = qc.Sales__c;
                    }

                    //Update Issue time
                    if(newcp.IssueTime__c == null){
                        newcp.IssueTime__c = System.now();
                    }
                }                
            }
        }else if(Trigger.isDelete){
            for(Coupon__c newcp : (List<Coupon__c>)Trigger.old){
                if(!String.isBlank(newcp.CouponId__c)){
                    newcp.addError('You can not delete this coupon because this coupon already created on QC System!');
                }
            }
        }
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {
        if(Trigger.isInsert){
            for(Coupon__c newcp : (List<Coupon__c>)Trigger.new){                
                if(newcp.Status__c == CouponConstant.STATUS_ACTIVE 
                        && String.isBlank(newcp.CouponId__c) 
                        && newcp.Source__c == CouponConstant.SOURCE_SALESFORCE ){
                    createcouponIds.add(newcp.Id);
                }
            }

        }else if (Trigger.isUpdate) { 
            Map<Id, Coupon__c>  oldMap = (Map<Id, Coupon__c>)Trigger.oldMap;
            for(Coupon__c newcp : (List<Coupon__c>)Trigger.new){                
                Coupon__c oldcp = oldMap.get(newcp.Id);
                
                //Create New Coupon
                if( newcp.Status__c == CouponConstant.STATUS_ACTIVE 
                        && oldcp.Status__c != newcp.Status__c 
                        && String.isBlank(newcp.CouponId__c) 
                        && newcp.Source__c == CouponConstant.SOURCE_SALESFORCE ){
                    createcouponIds.add(newcp.Id);

                //Edit Coupon
                }else if(newcp.Status__c == CouponConstant.STATUS_ACTIVE 
                            && oldcp.Status__c == newcp.Status__c 
                            && !String.isBlank(newcp.CouponId__c) 
                            && newcp.Source__c == CouponConstant.SOURCE_SALESFORCE ){
                    if(        oldcp.ExpirationDate__c == newcp.ExpirationDate__c 
                            || oldcp.Amount__c != newcp.Amount__c 
                            || oldcp.Interval_Spending_Days__c != newcp.Interval_Spending_Days__c 
                            || oldcp.Promotion_Condition_Content__c != newcp.Promotion_Condition_Content__c 
                            || oldcp.Condition_Amount__c != newcp.Condition_Amount__c 
                            ){
                        updatecouponIds.add(newcp.Id);   
                    }
                
                //Deactive Coupon
                }else if(newcp.Status__c == CouponConstant.STATUS_DEACTIVATED 
                            && oldcp.Status__c == CouponConstant.STATUS_ACTIVE  
                            && !String.isBlank(newcp.CouponId__c) 
                            && newcp.Source__c == CouponConstant.SOURCE_SALESFORCE ){
                    disablecouponIds.add(newcp.Id);

                //Re Active Coupon
                }else if(newcp.Status__c == CouponConstant.STATUS_ACTIVE   
                            && oldcp.Status__c == CouponConstant.STATUS_DEACTIVATED 
                            && !String.isBlank(newcp.CouponId__c) 
                            && newcp.Source__c == CouponConstant.SOURCE_SALESFORCE ){
                    enablecouponIds.add(newcp.Id);      

                //Manual activate Coupon PROMOTION_WITH_CONDITION
                }else if(newcp.Status__c == CouponConstant.STATUS_USED
                            && oldcp.Status__c == CouponConstant.STATUS_ACTIVE
                            && !String.isBlank(newcp.CouponId__c) 
                            && newcp.Source__c == CouponConstant.SOURCE_SALESFORCE
                            && newcp.Transaction_Type__c == TransactionTypeConstant.PROMOTION_WITH_CONDITION
                            && cc_static_Message.isDoneCouponViaAPI == false
                            ){        
                    activatecouponIds.add(newcp.Id);
                } 
            }
        }		
        
    }
    
    /**
    * beforeInsert
    *
    * This method is called iteratively for each record to be inserted during a BEFORE
    * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    */
    public void beforeInsert(SObject so) {}
    
    /**
    * beforeUpdate
    *
    * This method is called iteratively for each record to be updated during a BEFORE
    * trigger.
    */
    public void beforeUpdate(SObject oldSo, SObject so) {}

    /**
    * beforeDelete
    *
    * This method is called iteratively for each record to be deleted during a BEFORE
    * trigger.
    */
    public void beforeDelete(SObject so) {}
       

    /**
    * afterInsert
    *
    * This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field validation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    */
    public void afterInsert(SObject so) {}

    /**
    * afterUpdate
    *
    * This method is called iteratively for each record updated during an AFTER
    * trigger.
    */
    public void afterUpdate(SObject oldSo, SObject so) {}

    /**
    * afterDelete
    *
    * This method is called iteratively for each record deleted during an AFTER
    * trigger.
    */
    public void afterDelete(SObject so) {}
    
    /**
    * afterUnDelete
    *
    * This method is called iteratively for each record Undeleted during an AFTER
    * trigger.
    */
    public void afterUnDelete(SObject so) {}

    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally() {       
        System.debug('createcouponIds=>' + createcouponIds.size());
        if(createcouponIds.size() > 0){
            cc_CouponHelper.attemptCreateCouponsToQC(createcouponIds);
        }

        System.debug('updatecouponIds=>' + updatecouponIds.size());
        if(updatecouponIds.size() > 0){
            cc_CouponHelper.attemptUpdateCouponsToQC(updatecouponIds);
        }

        System.debug('enablecouponIds=>' + enablecouponIds.size());
        if(enablecouponIds.size() > 0){
            cc_CouponHelper.attemptEnableCouponsToQC(enablecouponIds);
        }

        System.debug('disablecouponIds=>' + disablecouponIds.size());
        if(disablecouponIds.size() > 0){
            cc_CouponHelper.attemptDisableCouponsToQC(disablecouponIds);
        }

        System.debug('activatecouponIds=>' + activatecouponIds.size());
        if(activatecouponIds.size() > 0){
            cc_CouponHelper.attemptActivateCouponsToQC(activatecouponIds);
        }
        
    }   
}