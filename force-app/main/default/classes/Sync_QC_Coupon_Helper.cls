public with sharing class Sync_QC_Coupon_Helper {
    static final String ALGORITHMNAME = 'AES256';    
    static final String STATUS_USED = 'Used';
    static final String SOURCE_QC = 'QC';    

    //Sync Coupons Created from QC
    public static void attemptSyncCouponsFromQC(String params){
        if(!System.isBatch() && !System.isFuture()){
            asyncSyncCouponsFromQC(params);
        }
    }


    @future(callout=true)
    public static void asyncSyncCouponsFromQC(String params){
        List<cc_CouponAPIWrapper.ParamWrapper> listParams = (List<cc_CouponAPIWrapper.ParamWrapper>)JSON.deserialize(params, List<cc_CouponAPIWrapper.ParamWrapper>.class);

        if(listParams != null){
            syncSyncCouponsFromQC(listParams);
        }
    }

    public static void syncSyncCouponsFromQC(List<cc_CouponAPIWrapper.ParamWrapper> coupons){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();
        List<Coupon__c> coupontoUpdate = new List<Coupon__c>();
        List<Coupon__c> coupontoCreate = new List<Coupon__c>();
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();
        Map<String,cc_CouponAPIWrapper.ParamWrapper> mapParams = new Map<String,cc_CouponAPIWrapper.ParamWrapper>();
        Map<String,String> mapCampaign = new Map<String,String>();

        QC_Integration__c integratinInfo = cc_Util.getQCIntergrationInfo('qccampaignInternal');        
        String encryptedtoken = integratinInfo.EncryptToken__c;
        String key = integratinInfo.Key__c;
        String token;
        
        if(!String.isBlank(encryptedtoken) && !String.isBlank(key)){
            token = cc_Util.decrypted(key, encryptedtoken, ALGORITHMNAME);
        }

        CouponIntegration__c createcouponapi = CouponIntegration__c.getInstance('getcoupon');
        String apiendpoint = createcouponapi.apiuri__c;
        String method = createcouponapi.method__c;
        Integer timeout = (Integer)createcouponapi.timeout__c;       


        //get exists Campaign
        for(Campaign camp: [SELECT Id, QCCampaignId__c FROM Campaign WHERE QCCampaignId__c !=null AND QCCampaignId__c != '']){
            mapCampaign.put(camp.QCCampaignId__c, camp.Id);
        }

        //Make request
        if(!String.isBlank(token)){
            for(cc_CouponAPIWrapper.ParamWrapper cp: coupons){  
                
                String jsonbody = '{}';
                String endpoint = apiendpoint + '/' + cp.coupon_id.trim();
                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, null);
                callout.Token = token;
                HttpRequest req = cc_HttpCallout.setupHttpRequest(callout);
                HttpResponse res = cc_HttpCallout.makeRequest(req);

                System.debug('getStatusCode=>' + res.getStatusCode() + ' getBody=> ' + req.getBody());
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    mapResponse.put(cp.coupon_id, res);     
                    mapParams.put(cp.coupon_id, cp);               
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Sync Coupon Callout', '','cc_CouponHelper', 'syncSyncCouponsFromQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }

                       
            }
        }else {
            CalloutLog__c calloutLog = new CalloutLog__c();        
            calloutLog = cc_Util.parseCallOutLog('Sync Coupon Callout', '' ,'cc_CouponHelper', 'syncSyncCouponsFromQC', method, apiendpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
            calloutLogs.add(calloutLog);
        }        


        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String couponId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(couponId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CouponDataWrapper result = (cc_CouponAPIWrapper.CouponDataWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CouponDataWrapper.class);

                if(result.success == true){
                    cc_CouponAPIWrapper.CouponWrapper cpinfo = result.data;

                    if(cpinfo != null){
                        cc_CouponAPIWrapper.ParamWrapper param = mapParams.get(couponId);

                        if(mapCampaign.get(cpinfo.couponCampaignId) != null){                            
                            Coupon__c crcp = new Coupon__c();                                
                            crcp.Name = cpinfo.code;
                            crcp.CouponId__c = cpinfo.id;
                            crcp.Status__c = STATUS_USED;
                            crcp.Source__c = SOURCE_QC;
                            crcp.QC_Account__c = param.qc_account;
                            crcp.Payment__c = param.payment;
                            crcp.Campaign__c = (mapCampaign.get(cpinfo.couponCampaignId) == null ?'' : mapCampaign.get(cpinfo.couponCampaignId));
                            crcp.ExpirationDate__c = Date.valueOf(cpinfo.expireDate);
                            crcp.TimeUsed__c = cpinfo.timeUsed !=null? Datetime.valueOf(cpinfo.timeUsed) : null;
                            crcp.IssueTime__c = cpinfo.timeIssued !=null? Datetime.valueOf(cpinfo.timeIssued) : null;
                            crcp.SpendingExpirationDate__c = Date.valueOf(cpinfo.spendingExpireDate);
                            crcp.Quantity__c = 1;
                            crcp.Amount__c = cpinfo.amount;

                            coupontoCreate.add(crcp);
                        }        
                    } 

                }else {
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error; 
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Sync Coupon Callout', '' , 'cc_CouponHelper', 'syncCreateCouponsToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);    
                }                  
            }
        }

        System.debug('coupontoCreate=>' + coupontoCreate.size());
        if(coupontoCreate.size() > 0  && Schema.sObjectType.Coupon__c.isCreateable()){
            Database.insert(coupontoCreate, false) ;
        }

        System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0 && Schema.sObjectType.CalloutLog__c.isCreateable()){            
            Database.insert(calloutLogs, false) ;
        }
    
    }
}