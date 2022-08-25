/**
 * @description       : Coupon trigger helper class
 * @author            : @Thach Le
 * @group             : Coupon trigger
 * @last modified on  : 07-29-2022
 * @last modified by  : @Thach Le
**/
public with sharing class cc_CouponHelper {   
    
    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout to create Coupon on QC 
    * @return   void
    *********************************************************************************************************/
    public static void attemptCreateCouponsToQC(Set<String> couponIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncCreateCouponsToQC(couponIds);
        }else {
            System.enqueueJob(new cc_MassCreateCoupon_Queueable(couponIds));
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout to Update Coupon on QC 
    * @return   void
    *********************************************************************************************************/
    public static void attemptUpdateCouponsToQC(Set<String> couponIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncUpdateCouponsToQC(couponIds);
        }
    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout to Re-active Coupon on QC 
    * @return   void
    *********************************************************************************************************/
    public static void attemptEnableCouponsToQC(Set<String> couponIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncEnableCouponsToQC(couponIds);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout to deactivate Coupon on QC 
    * @return   void
    *********************************************************************************************************/
    public static void attemptDisableCouponsToQC(Set<String> couponIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncDisableCouponsToQC(couponIds);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 DEC 06
    * @description   Callout to Activate Coupon on QC - For PROMOTION_WITH_CONDITION only 
    * @return   void
    *********************************************************************************************************/
    public static void attemptActivateCouponsToQC(Set<String> couponIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncActivateCouponsToQC(couponIds);
        }
    }
    

    @future(callout=true)
    public static void asyncCreateCouponsToQC(Set<String> couponIds){
        List<cc_CouponAPIWrapper.CreateCouponWrapper> coupons = new List<cc_CouponAPIWrapper.CreateCouponWrapper>();          

        for(Coupon__c cp: [SELECT Id, Name, Campaign__c, 
                                    Campaign__r.QCCampaignId__c, 
                                    Campaign__r.Required_Interval_Spending_Days__c,
                                    Transaction_Type__c,
                                    TransactionTypeId__c,                                    
                                    QC_Account__r.Name, 
                                    ExpirationDate__c,
                                    SpendingExpirationDate__c, 
                                    Amount__c, 
                                    Quantity__c,
                                    CouponId__c,
                                    Interval_Spending_Days__c,
                                    Promotion_Condition_Content__c                                    
                                    FROM Coupon__c WHERE Id IN :couponIds]){  
            if(!String.isBlank(cp.Campaign__r.QCCampaignId__c) && String.isBlank(cp.CouponId__c)){     

                Datetime expireddt = Datetime.newInstance(cp.ExpirationDate__c.year(),cp.ExpirationDate__c.month(),cp.ExpirationDate__c.day());  
                String expiredStr = expireddt.format('yyyy-MM-dd');

                String expireSpddStr;
                Datetime expiredSpenndingdt;
                if(String.isBlank(cp.TransactionTypeId__c)){    
                    Date expSpendingDate =  cp.SpendingExpirationDate__c == null? Date.today() : cp.SpendingExpirationDate__c;
                    expiredSpenndingdt = Datetime.newInstance(expSpendingDate.year(),expSpendingDate.month(),expSpendingDate.day()); 
                    expireSpddStr = expiredSpenndingdt.format('yyyy-MM-dd'); 
                }
                
                Set<String> emails = new Set<String>();
                emails.add(cp.QC_Account__r.Name);

                cc_CouponAPIWrapper.CreateCouponWrapper coupon = new  cc_CouponAPIWrapper.CreateCouponWrapper();
                coupon.couponCampaignId = cp.Campaign__r.QCCampaignId__c;   
                coupon.expireDate = expiredStr;
                coupon.spendingExpiredDate = expireSpddStr;
                coupon.quantity = Integer.valueOf(cp.Quantity__c==null?1:cp.Quantity__c);            
                coupon.value = cp.Amount__c;    
                coupon.emails = emails;  
                coupon.Id = cp.Id;
                coupon.qcemail = cp.QC_Account__r.Name;
                coupon.campaign = cp.Campaign__c;
                coupon.transactionType = String.isBlank(cp.Transaction_Type__c)? '' : cp.Transaction_Type__c;
                coupon.transactionTypeMappingId = cp.TransactionTypeId__c;
                coupon.intervalSpendingDays = (Integer)cp.Interval_Spending_Days__c;
                coupon.promotionConditionContent = String.isBlank(cp.Promotion_Condition_Content__c)? '': cp.Promotion_Condition_Content__c;
                coupon.requiredIntervalSpendingDays = cp.Campaign__r.Required_Interval_Spending_Days__c;

                coupons.add(coupon);
            }  
        }

        System.debug('coupons=>' + coupons);
        if(coupons.size() > 0 && coupons.size() < 50){
            syncCreateCouponsToQC(coupons);
        }else {
            System.enqueueJob(new cc_MassCreateCoupon_Queueable(couponIds));
        }        
    }

    public static void syncCreateCouponsToQC(List<cc_CouponAPIWrapper.CreateCouponWrapper> coupons){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();
        List<Coupon__c> coupontoUpdate = new List<Coupon__c>();
        List<Coupon__c> coupontoCreate = new List<Coupon__c>();
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();
        Map<String,String> mapQCEmail = new Map<String,String>();
        Map<String,String> mapCampaign = new Map<String,String>();
        
        CouponIntegration__c createcouponapi = CouponIntegration__c.getInstance('createcouponapi');
        String endpoint = createcouponapi.apiuri__c;
        String method = createcouponapi.method__c;
        Integer timeout = (Integer)createcouponapi.timeout__c;       

        //Make request
        for(cc_CouponAPIWrapper.CreateCouponWrapper cp: coupons){  
            String jsonbody = '';
            
            System.debug('cp.transactionTypeMappingId=>' + cp.transactionTypeMappingId);
            System.debug('cp.transactionType=>' + cp.transactionType);
            if(String.isBlank(cp.transactionTypeMappingId)){
                jsonbody = genCreateCouponWithoutTransactionTypeJSON(cp);
            }else{
                if(cp.transactionType == TransactionTypeConstant.PROMOTION){
                    jsonbody = genCreatePromotionCouponJSON(cp);
                }else if (cp.transactionType == TransactionTypeConstant.PROMOTION_WITH_CONDITION){
                    jsonbody = genCouponWithConditionJSON(cp);
                }else {
                    jsonbody = genCreateCouponJSON(cp);
                }     
            }           

            if ( String.isNotBlank(jsonbody) ){
                headers.put('Content-Length',jsonbody.length()+'');                        
            }
            
            cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
            HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
            if(req != null){
                HttpResponse res = cc_HttpCallout.makeRequest(req);
                System.debug('getStatusCode=>' + res.getStatusCode() + ' getBody=> ' + res.getBody());
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    mapResponse.put(cp.Id, res);
                    mapQCEmail.put(cp.Id, cp.qcemail);
                    mapCampaign.put(cp.Id, cp.campaign);     
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Create Coupon Callout', cp.Id,'cc_CouponHelper', 'syncCreateCouponsToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }
            }else {
                CalloutLog__c calloutLog = new CalloutLog__c();        
                calloutLog = cc_Util.parseCallOutLog('Create Coupon Callout', '' ,'cc_CouponHelper', 'syncCreateCouponsToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                calloutLogs.add(calloutLog);
            }
        }       


        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String couponId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(couponId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CouponDatasWrapper result = (cc_CouponAPIWrapper.CouponDatasWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CouponDatasWrapper.class);

                if(result.success == true){
                    List<cc_CouponAPIWrapper.CouponWrapper> cpinfos = result.data;
                    String qcemail = mapQCEmail.get(couponId);

                    for(cc_CouponAPIWrapper.CouponWrapper cpinfo: cpinfos){
                        if(cpinfo.email == qcemail){
                            Coupon__c upcp = new Coupon__c();
                            upcp.Id = couponId;
                            upcp.Name = cpinfo.code;
                            upcp.CouponId__c = cpinfo.id;
                            upcp.Status__c = CouponConstant.STATUS_ACTIVE;
                            upcp.Quantity__c = 1;

                            coupontoUpdate.add(upcp);
                        }                        
                    }   

                }else {
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error; 
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Create Coupon Callout', couponId , 'cc_CouponHelper', 'syncCreateCouponsToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);    
                }                  
            }
        }
        
        System.debug('coupontoUpdate=>' + coupontoUpdate.size());
        if(coupontoUpdate.size() > 0){
            update coupontoUpdate;
        }

        System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0){
            insert calloutLogs;
        }
    
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Future method to callout generate Coupon on QC 
    * Param Set<String> : set of CouponId
    * @return   void
    *********************************************************************************************************/  
    @future(callout=true)
    public static void asyncUpdateCouponsToQC(Set<String> couponIds){
        syncUpdateCouponsToQC(couponIds);
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   callout generate Coupon on QC 
    * Param Set<String> : set of CouponId
    * @return   void
    *********************************************************************************************************/  

    public static void syncUpdateCouponsToQC(Set<String> couponIds){    
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();      
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();        

        CouponIntegration__c updatecouponapi = CouponIntegration__c.getInstance('updatecouponapi');
        String apiendpoint = updatecouponapi.apiuri__c;
        String method = updatecouponapi.method__c;
        Integer timeout = (Integer)updatecouponapi.timeout__c;


        //Make request
        for(Coupon__c cp: [SELECT Id, Name, Campaign__r.QCCampaignId__c, QC_Account__r.Name, CouponId__c,
                                        ExpirationDate__c,
                                        SpendingExpirationDate__c, 
                                        Amount__c, 
                                        Quantity__c,
                                        Interval_Spending_Days__c,
                                        Promotion_Condition_Content__c,
                                        Transaction_Type__c,
                                        TransactionTypeId__c   
                                        FROM Coupon__c WHERE Id IN :couponIds]){   
            if(!String.isBlank(cp.CouponId__c)){
                Datetime expireddt = Datetime.newInstance(cp.ExpirationDate__c.year(),cp.ExpirationDate__c.month(),cp.ExpirationDate__c.day());                  
                String expiredStr = expireddt.format('yyyy-MM-dd');   

                String expireSpddStr;
                Datetime expiredSpenndingdt;
                if(String.isBlank(cp.TransactionTypeId__c)){     
                    Date expSpendingDate =  cp.SpendingExpirationDate__c == null? Date.today() : cp.SpendingExpirationDate__c;
                    expiredSpenndingdt = Datetime.newInstance(expSpendingDate.year(),expSpendingDate.month(),expSpendingDate.day()); 
                    expireSpddStr = expiredSpenndingdt.format('yyyy-MM-dd'); 
                }

                cc_CouponAPIWrapper.EditCouponWrapper editcoupon = new  cc_CouponAPIWrapper.EditCouponWrapper();                
                editcoupon.expireDate = expiredStr; 
                editcoupon.spendingExpiredDate = expireSpddStr; 
                editcoupon.value = cp.Amount__c;    
                editcoupon.email = cp.QC_Account__r.Name;     
                editcoupon.intervalSpendingDays = (Integer)cp.Interval_Spending_Days__c;
                editcoupon.promotionConditionContent = cp.Promotion_Condition_Content__c;
                editcoupon.transactionTypeMappingId = cp.TransactionTypeId__c;
                editcoupon.couponCampaignId = cp.Campaign__r.QCCampaignId__c;

                String jsonbody;

                if(String.isBlank(cp.TransactionTypeId__c)){
                    jsonbody = genEditCouponWithoutTransactionTypeJSON(editcoupon);
                }else{
                    if (cp.Transaction_Type__c == TransactionTypeConstant.PROMOTION_WITH_CONDITION){
                        jsonbody = genEditCouponWithConditionJSON(editcoupon);
                    }else if(cp.Transaction_Type__c == TransactionTypeConstant.PROMOTION){
                        jsonbody = genEditPromotionCouponsJSON(editcoupon);
                    }else {
                        jsonbody = genEditCouponJSON(editcoupon);
                    }  
                }
                
                if ( String.isNotBlank(jsonbody) ){
                    headers.put('Content-Length',jsonbody.length()+'');                        
                }

                System.debug('Edit coupon jsonbody=>' + jsonbody);
                    
                String endpoint = apiendpoint + '/' + cp.CouponId__c.trim();
                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
                HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
                if(req != null){
                   
                    HttpResponse res = cc_HttpCallout.makeRequest(req);

                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                        mapResponse.put(cp.Id, res);   
                    }else {
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Update Coupon Callout', cp.Id,'cc_CouponHelper', 'asyncUpdateCouponsToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }
                    
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Update Coupon Callout', '' ,'cc_CouponHelper', 'asyncUpdateCouponsToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }

            }
        }  

        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String couponId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(couponId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();
                
                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CouponDataWrapper result = (cc_CouponAPIWrapper.CouponDataWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CouponDataWrapper.class);

                System.debug('Edit success=> ' + result.success);
                if(result.success == false){                        
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error; 
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Create Coupon Callout', couponId ,'cc_CouponHelper', 'syncCreateCouponsToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog); 
                }                 
            }
        }        

        System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0){
            insert calloutLogs;
        }        
        
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Future method to callout Enable Coupon on QC 
    * Param Set<String> : set of CouponId
    * @return   void
    *********************************************************************************************************/    

    @future(callout=true)
    public static void asyncEnableCouponsToQC(Set<String> couponIds){
        Map<String,String> mapCoupon = new Map<String,String>();
        for(Coupon__c cp: [SELECT Id, Name, Status__c, CouponId__c FROM Coupon__c WHERE Id IN :couponIds]){ 
            mapCoupon.put(cp.CouponId__c, cp.Id);
        }

        if(mapCoupon.size() > 0){
            syncEnableCouponsToQC(mapCoupon);
        }   
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout Enable Coupon on QC 
    * Param Map<String,String>: Map of coupon with key =>Coupon Id , value=> SF Coupon Id
    * @return   void
    *********************************************************************************************************/    
    public static void syncEnableCouponsToQC(Map<String,String> mapCoupon){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();        
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();        

        CouponIntegration__c enablecouponapi = CouponIntegration__c.getInstance('enablecouponapi');
        String apiendpoint = enablecouponapi.apiuri__c;
        String method = enablecouponapi.method__c;
        Integer timeout = (Integer)enablecouponapi.timeout__c;

        //Make request
        for(String couponId: mapCoupon.keySet()){   
            if(!String.isBlank(couponId)){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeEndObject();

                String jsonbody = gen.getAsString();
                    
                String endpoint = apiendpoint + '/' + couponId.trim() + '/enable';
                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
                HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
                if(req != null){
                    HttpResponse res = cc_HttpCallout.makeRequest(req);

                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                        mapResponse.put(mapCoupon.get(couponId), res);   
                    }else {
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Enable Coupon Callout', mapCoupon.get(couponId),'cc_CouponHelper', 'asyncEnableCouponsToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }                    
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Enable Coupon Callout', '' ,'cc_CouponHelper', 'asyncEnableCouponsToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }

            }
        }

        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String sfCouponId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(sfCouponId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CouponDataWrapper result = (cc_CouponAPIWrapper.CouponDataWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CouponDataWrapper.class);

                System.debug('Enable success=> ' + result.success);
                if(result.success == false){                        
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error; 
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Enable Coupon Callout', sfCouponId , 'cc_CouponHelper', 'asyncEnableCouponsToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog); 
                }                
            }
        }        

        System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0){
            insert calloutLogs;
        }

    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Future method to callout disable Coupon on QC 
    * Param Set<String> : set of CouponId
    * @return   void
    *********************************************************************************************************/    
    @future(callout=true)
    public static void asyncDisableCouponsToQC(Set<String> couponIds){        

        Map<String,String> mapCoupon = new Map<String,String>();
        for(Coupon__c cp: [SELECT Id, Name, Status__c, CouponId__c FROM Coupon__c WHERE Id IN :couponIds]){ 
            mapCoupon.put(cp.CouponId__c, cp.Id);
        }

        if(mapCoupon.size() > 0){
            syncDisableCouponsToQC(mapCoupon);
        }       
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout disable Coupon on QC 
    * Param Map<String,String>: Map of coupon with key =>Coupon Id , value=> SF Coupon Id
    * @return   void
    *********************************************************************************************************/

    public static void syncDisableCouponsToQC(Map<String,String> mapCoupon){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();  
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();        

        CouponIntegration__c disablecouponapi = CouponIntegration__c.getInstance('disablecouponapi');
        String apiendpoint = disablecouponapi.apiuri__c;
        String method = disablecouponapi.method__c;
        Integer timeout = (Integer)disablecouponapi.timeout__c;

        //Make request
        for(String couponId: mapCoupon.keySet()){   
            if(!String.isBlank(couponId)){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeEndObject();

                String jsonbody = gen.getAsString();
                    
                String endpoint = apiendpoint + '/' + couponId.trim() + '/disable';
                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
                HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
                if(req != null){
                    HttpResponse res = cc_HttpCallout.makeRequest(req);

                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                        mapResponse.put(mapCoupon.get(couponId), res);   
                    }else {
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Disable Coupon Callout', mapCoupon.get(couponId),'cc_CouponHelper', 'syncDisableCouponsToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Disable Coupon Callout', '' ,'cc_CouponHelper', 'syncDisableCouponsToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }
            }
        }

        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String sfCouponId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(sfCouponId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CouponDataWrapper result = (cc_CouponAPIWrapper.CouponDataWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CouponDataWrapper.class);

                if(result.success == false){                    
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error; 
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Disable Coupon Callout', sfCouponId, 'cc_CouponHelper', 'syncDisableCouponsToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }                   
            }
        }        

        System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0){
            insert calloutLogs;
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Future method to callout Apply Coupon on QC - For PROMOTION_WITH_CONDITION only 
    * Param Set<String> : set of CouponId
    * @return   void
    *********************************************************************************************************/

    @future(callout=true)
    public static void asyncActivateCouponsToQC(Set<String> couponIds){

        Id currentUserId = UserInfo.getUserId();
        String qcuserId = [SELECT QCUserId__c FROM User WHERE Id = :currentUserId].QCUserId__c;

        Map<String,cc_CouponAPIWrapper.ActivateCouponWrapper> mapCoupon = new Map<String,cc_CouponAPIWrapper.ActivateCouponWrapper>();
        for(Coupon__c cp: [SELECT Id, Name, Status__c, CouponId__c, QC_Account__r.QC_Account_Id__c FROM Coupon__c WHERE Id IN :couponIds]){ 
            if(!String.isBlank(cp.CouponId__c) && !String.isBlank(cp.QC_Account__r.QC_Account_Id__c)){
                cc_CouponAPIWrapper.ActivateCouponWrapper cpwraper = new cc_CouponAPIWrapper.ActivateCouponWrapper();
                cpwraper.couponid = cp.CouponId__c;
                cpwraper.userid = cp.QC_Account__r.QC_Account_Id__c;
                cpwraper.sfrecordId = cp.Id;
                cpwraper.userRequestId = qcuserId == null?cpwraper.userid : qcuserId;

                mapCoupon.put(cp.CouponId__c, cpwraper);
            }
            
        }

        if(mapCoupon.size() > 0){
            syncActivateCouponsToQC(mapCoupon);
        }        
    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Callout to Apply Coupon on QC - For PROMOTION_WITH_CONDITION only 
    * Param Map<String,String>: Map of coupon with key =>Coupon Id , value=> SF Coupon Id
    * @return   void
    *********************************************************************************************************/
    public static void syncActivateCouponsToQC(Map<String,cc_CouponAPIWrapper.ActivateCouponWrapper> mapCoupon){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();        
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();        

        CouponIntegration__c enablecouponapi = CouponIntegration__c.getInstance('activatecouponapi');
        String apiendpoint = enablecouponapi.apiuri__c;
        String method = enablecouponapi.method__c;
        Integer timeout = (Integer)enablecouponapi.timeout__c;

        //Make request
        for(String couponId: mapCoupon.keySet()){   
            if(!String.isBlank(couponId)){
               
                cc_CouponAPIWrapper.ActivateCouponWrapper activateCoupon = mapCoupon.get(couponId);
                String jsonbody = genActivateCouponsJSON(activateCoupon);
                    
                String endpoint = apiendpoint + '/' + couponId.trim() + '/activate';
                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
                HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
                if(req != null){
                    HttpResponse res = cc_HttpCallout.makeRequest(req);

                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                        mapResponse.put(activateCoupon.sfrecordId, res);   
                    }else {
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Apply Coupon Callout', activateCoupon.sfrecordId,'cc_CouponHelper', 'syncActivateCouponsToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }                    
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Apply Coupon Callout', '' ,'cc_CouponHelper', 'syncActivateCouponsToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }

            }
        }

        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String sfcouponId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(sfcouponId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CouponDataWrapper result = (cc_CouponAPIWrapper.CouponDataWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CouponDataWrapper.class);
                
                if(result.success == false){                        
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error; 
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Apply Coupon Callout', sfcouponId , 'cc_CouponHelper', 'syncActivateCouponsToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog); 
                }                
            }
        }        

        System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0 ){
            insert calloutLogs;
        }
    }


    public static String genCreateCouponWithoutTransactionTypeJSON(cc_CouponAPIWrapper.CreateCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     
        Set<String> qcemailIds = coupon.emails;

        System.debug('coupon=>' + coupon);

        gen.writeStartObject();     
            gen.writeNullField('ownerId'); 
            gen.writeNumberField('couponCampaignId', Integer.valueOf(coupon.couponCampaignId));           
            gen.writeStringField('expireDate', coupon.expireDate);  
            gen.writeStringField('spendingExpiredDate', coupon.spendingExpiredDate);
            gen.writeNumberField('value', coupon.value);
            gen.writeNumberField('quantity', coupon.quantity);   
            gen.writeFieldName('emails');
            gen.writeStartArray();   
                for(String email: qcemailIds){
                    gen.writeString(email);
                }                                
            gen.writeEndArray();

        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genCreateCouponJSON(cc_CouponAPIWrapper.CreateCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     
        Set<String> qcemailIds = coupon.emails;
        System.debug('coupon=>' + coupon);

        gen.writeStartObject();     
            gen.writeNullField('ownerId');         
            gen.writeNumberField('transactionTypeMappingId', Integer.valueOf(coupon.transactionTypeMappingId));
            gen.writeStringField('expireDate', coupon.expireDate);  
            gen.writeNumberField('value', coupon.value);
            gen.writeNumberField('quantity', coupon.quantity);   
            gen.writeFieldName('emails');
            gen.writeStartArray();   
                for(String email: qcemailIds){
                    gen.writeString(email);
                }                                
            gen.writeEndArray();

        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genCreatePromotionCouponJSON(cc_CouponAPIWrapper.CreateCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     
        Set<String> qcemailIds = coupon.emails;
        System.debug('coupon=>' + coupon);

        gen.writeStartObject();     
            gen.writeNullField('ownerId');              
            gen.writeNumberField('couponCampaignId', Integer.valueOf(coupon.couponCampaignId));
            gen.writeNumberField('transactionTypeMappingId', Integer.valueOf(coupon.transactionTypeMappingId));
            gen.writeNumberField('intervalSpendingDays', coupon.intervalSpendingDays);            
            gen.writeStringField('expireDate', coupon.expireDate);            
            gen.writeNumberField('value', coupon.value);
            gen.writeNumberField('quantity', coupon.quantity);   
            gen.writeFieldName('emails');
            gen.writeStartArray();   
                for(String email: qcemailIds){
                    gen.writeString(email);
                }                                
            gen.writeEndArray();
        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genCouponWithConditionJSON(cc_CouponAPIWrapper.CreateCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     
        Set<String> qcemailIds = coupon.emails;

        System.debug('coupon=>' + coupon);

        gen.writeStartObject();     
            gen.writeNullField('ownerId');           
            gen.writeNumberField('couponCampaignId', Integer.valueOf(coupon.couponCampaignId));                        
            gen.writeNumberField('transactionTypeMappingId', Integer.valueOf(coupon.transactionTypeMappingId));
            gen.writeNumberField('intervalSpendingDays', coupon.intervalSpendingDays);            
            gen.writeStringField('expireDate', coupon.expireDate);           
            gen.writeNumberField('value', coupon.value);
            gen.writeNumberField('quantity', coupon.quantity);            
            gen.writeStringField('conditionContent', coupon.promotionConditionContent);   
            gen.writeFieldName('emails');
            gen.writeStartArray();   
                for(String email: qcemailIds){
                    gen.writeString(email);
                }                                
            gen.writeEndArray();

        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genEditCouponWithoutTransactionTypeJSON(cc_CouponAPIWrapper.EditCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     

        gen.writeStartObject();     
            gen.writeNullField('ownerId');    
            gen.writeStringField('email', coupon.email);       
            gen.writeStringField('expireDate', coupon.expireDate);
            gen.writeStringField('spendingExpiredDate', coupon.spendingExpiredDate);
            gen.writeNumberField('value', coupon.value); 
        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genEditCouponJSON(cc_CouponAPIWrapper.EditCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     

        gen.writeStartObject();     
            gen.writeNullField('ownerId');    
            gen.writeStringField('email', coupon.email);       
            gen.writeStringField('expireDate', coupon.expireDate);            
            gen.writeNumberField('value', coupon.value); 
        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genEditPromotionCouponsJSON(cc_CouponAPIWrapper.EditCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     

        gen.writeStartObject();     
            gen.writeNullField('ownerId');            
            gen.writeStringField('expireDate', coupon.expireDate);
            gen.writeStringField('email', coupon.email);
            gen.writeNumberField('intervalSpendingDays', coupon.intervalSpendingDays);  
            gen.writeNumberField('couponCampaignId', Integer.valueOf(coupon.couponCampaignId)); 
            gen.writeNumberField('value', coupon.value); 
        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }

    public static String genEditCouponWithConditionJSON(cc_CouponAPIWrapper.EditCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);     

        gen.writeStartObject();     
            gen.writeNullField('ownerId');            
            gen.writeStringField('expireDate', coupon.expireDate);            
            gen.writeNumberField('value', coupon.value);     
            gen.writeStringField('email', coupon.email);
            gen.writeNumberField('intervalSpendingDays', coupon.intervalSpendingDays);            
            gen.writeStringField('conditionContent', coupon.promotionConditionContent);   
            gen.writeNumberField('couponCampaignId', Integer.valueOf(coupon.couponCampaignId));
        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }


    public static String genActivateCouponsJSON(cc_CouponAPIWrapper.ActivateCouponWrapper coupon){
        JSONGenerator gen = JSON.createGenerator(true);  

        gen.writeStartObject();     
           gen.writeStringField('userId', coupon.userid);
           gen.writeStringField('userRequestId', coupon.userRequestId);
        gen.writeEndObject();

        String jsonbody = gen.getAsString();

        return jsonbody;
    }
    
    
}