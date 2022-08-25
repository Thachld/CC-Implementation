public with sharing class MassGenerateSendingBonus_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    private String campId {get;set;}
    
    public MassGenerateSendingBonus_Batch(String pCampId) {
        this.campId = pCampId;
    }


    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Name, Campaign__c, Campaign__r.QCCampaignId__c, 
                                                QC_Account__r.Name, QC_Account__r.QC_Account_Id__c, 
                                                ExpirationDate__c,SpendingExpirationDate__c, Amount__c, Quantity__c
                                        FROM Coupon__c 
                                        WHERE Campaign__c = :this.campId
                                            AND Status__c = 'Draft'
                                        ]);
    }

    public void execute(Database.BatchableContext bc, List<Coupon__c> scope){
        List<Coupon__c> couponToUpdate = new List<Coupon__c>();        
        String rqBody;

        if(scope.size() > 0){
            rqBody = genCreateCouponsJson(scope);
        }

        System.debug('rqBody=>' + rqBody);
        if(!String.isBlank(rqBody)){
            Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();
            Map<String,String> headers = new Map<String,String>();
            List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
            SpendingBonusWrapper result = new SpendingBonusWrapper();

            CouponIntegration__c createcouponapi = CouponIntegration__c.getInstance('generatespendingbonus');
            String endpoint = createcouponapi.apiuri__c;
            String method = createcouponapi.method__c;
            Integer timeout = (Integer)createcouponapi.timeout__c;

            cc_Callout callout = new cc_Callout(rqBody, endpoint, method, timeout, null);                  
            HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);

            if(req != null){
                HttpResponse res = cc_HttpCallout.makeRequest(req);
                System.debug('getStatusCode=>' + res.getStatusCode() + ' getBody=> ' + res.getBody());
                String response = res.getBody();
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){                    
                    result = SpendingBonusWrapper.parse(response);
                    couponToUpdate = processResult(result, scope);

                    if(couponToUpdate != null){
                        update couponToUpdate;
                    }
                }else if(res.getStatusCode() == 403) {
                    cc_CouponAPIWrapper.CouponDataWrapper errResult = (cc_CouponAPIWrapper.CouponDataWrapper)System.JSON.deserialize(response,cc_CouponAPIWrapper.CouponDataWrapper.class);
                    if(errResult.success == false ){
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Generate Spending Bonus Callout', this.campId,'MassGenerateSendingBonus_Batch', 'execute', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }
                    
                }
            }else {
                CalloutLog__c calloutLog = new CalloutLog__c();        
                calloutLog = cc_Util.parseCallOutLog('Generate Spending Bonus Callout', '' ,'MassGenerateSendingBonus_Batch', 'execute', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                calloutLogs.add(calloutLog);
            }

            if(calloutLogs.size() > 0){
                insert calloutLogs;
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        
    }


    public static String genCreateCouponsJson(List<Coupon__c> coupons){
        JSONGenerator gen = JSON.createGenerator(true);  
        gen.writeStartObject();     
        gen.writeFieldName('coupons');

        gen.writeStartArray();   
            for(Coupon__c cp : coupons){
                if(!String.isBlank(cp.QC_Account__r.Name) && cp.Amount__c > 0 && cp.Amount__c != null){
                    gen.writeStartObject(); 
                        gen.writeStringField('email', cp.QC_Account__r.Name);   
                        gen.writeNumberField('amount', Integer.valueOf(cp.Amount__c) );               
                    gen.writeEndObject();
                }                
            }                            
            gen.writeEndArray();  

        gen.writeEndObject();

        String jsonresponse = gen.getAsString();
        return jsonresponse;
    }


    public static List<Coupon__c> processResult(SpendingBonusWrapper result, List<Coupon__c> scope){
        List<Coupon__c> couponToUpdate = new List<Coupon__c>();

        Map<String, SpendingBonusWrapper.CouponWrapper> mapSuccess = new Map<String, SpendingBonusWrapper.CouponWrapper>();
        Map<String, SpendingBonusWrapper.ErrorWrapper> mapFailed = new Map<String, SpendingBonusWrapper.ErrorWrapper>();

        SpendingBonusWrapper.SuccessWrapper success = result.success;
        SpendingBonusWrapper.FailedWrapper failed = result.failed;

        if(success.total > 0 && success.items != null && success.items.size() > 0){
            for(SpendingBonusWrapper.CouponWrapper cp : success.items){
                mapSuccess.put(cp.email, cp);
            }
        }

        if(failed.total > 0 && failed.items != null && failed.items.size() > 0){
            for(SpendingBonusWrapper.ErrorWrapper err : failed.items){
                mapFailed.put(err.email, err);
            }
        }


        for(Coupon__c cp : scope){
            if(mapSuccess.containsKey(cp.QC_Account__r.Name)){
                SpendingBonusWrapper.CouponWrapper cpinfo = mapSuccess.get(cp.QC_Account__r.Name);
                Coupon__c upcp = new Coupon__c();
                upcp.Id = cp.Id;
                upcp.Name = cpinfo.code;
                upcp.CouponId__c = cpinfo.id;
                upcp.Status__c = CouponConstant.STATUS_ACTIVE;
                upcp.Quantity__c = 1;  
                
                couponToUpdate.add(upcp);
            }else if(mapFailed.containsKey(cp.QC_Account__r.Name)){
                SpendingBonusWrapper.ErrorWrapper erinfo = mapFailed.get(cp.QC_Account__r.Name);

                Coupon__c ercp = new Coupon__c();
                ercp.Id = cp.Id;
                ercp.Error_Log__c = erinfo.errorMessage;
                
                couponToUpdate.add(ercp);
            }
        }

        return couponToUpdate;

    }

}