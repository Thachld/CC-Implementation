public with sharing class cc_CampaignHelper { 
    static final String ALGORITHMNAME = 'AES256';

    public static void attemptCreateCampaignToQC(Set<String> campIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncCreateCampaignToQC(campIds);
        }
    }

    public static void attemptUpdateCampaignToQC(Set<String> campIds){
        if(!System.isBatch() && !System.isFuture()){
            asyncUpdateCampaignToQC(campIds);
        }
    }


    @future(callout=true)
    public static void asyncCreateCampaignToQC(Set<String> campIds){        
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        List<Campaign> campaigntoUpdate = new List<Campaign>();
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();
        Map<String,String> headers = new Map<String,String>();        

        CouponIntegration__c campaignapi = CouponIntegration__c.getInstance('createcouponcampaignapi');
        String endpoint = campaignapi.apiuri__c;
        String method = campaignapi.method__c;
        Integer timeout = (Integer)campaignapi.timeout__c;


        //Make request
        for(Campaign camp: [SELECT Id, Name,MultipleUsage__c FROM Campaign WHERE Id IN :campIds]){   
            if(!String.isBlank(camp.Name)){                                

                String jsonbody = intiCreateCampaignJSON(camp);
                // System.debug('jsonbody=>' + jsonbody);  
                if ( String.isNotBlank(jsonbody) ){
                    headers.put('Content-Length',jsonbody.length()+'');                        
                }

                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
                HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
                if(req != null){
                    HttpResponse res = cc_HttpCallout.makeRequest(req);
                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                        mapResponse.put(camp.Id, res);
                    }else {
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Create Campaign Callout', camp.Id, 'cc_CampaignHelper', 'asyncCreateCampaignToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }                   
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Create Campaign Callout', '' ,'cc_CampaignHelper', 'asyncCreateCampaignToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }
            }
        } 
        
        if(mapResponse.size() > 0){
            for(String campId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(campId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CampaignAPIResultWrapper result = (cc_CouponAPIWrapper.CampaignAPIResultWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CampaignAPIResultWrapper.class);

                if(result.success == true){
                    cc_CouponAPIWrapper.SuccessCampaignWraper campinfo = result.data;
                    Campaign camp = new Campaign();

                    camp.Id = campId;
                    camp.QCCampaignId__c = campinfo.id;
                    campaigntoUpdate.add(camp);
                }else {
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error;  
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Create Campaign Callout', campId, 'cc_CampaignHelper', 'asyncUpdateCampaignToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);   
                }                 
            }
        }
        
        // System.debug('campaigntoUpdate=>' + campaigntoUpdate.size());
        if(campaigntoUpdate.size() > 0 && Schema.sObjectType.Campaign.isUpdateable()){
            update campaigntoUpdate;
        }        

        // System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0 && Schema.sObjectType.CalloutLog__c.isCreateable()){
            insert calloutLogs;
        }
    }


    @future(callout=true)
    public static void asyncUpdateCampaignToQC(Set<String> campIds){        
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();
        Map<String,String> headers = new Map<String,String>();
        Map<String,HttpResponse> mapResponse = new Map<String,HttpResponse>();        

        CouponIntegration__c campaignapi = CouponIntegration__c.getInstance('updatecouponcampaignapi');
        String endpoint = campaignapi.apiuri__c;
        String method = campaignapi.method__c;
        Integer timeout = (Integer)campaignapi.timeout__c;        


        //Make request
        for(Campaign camp: [SELECT Id, Name,MultipleUsage__c, QCCampaignId__c FROM Campaign WHERE Id IN :campIds]){   
            if(!String.isBlank(camp.QCCampaignId__c)){
                String jsonbody = intiUpdateCampaignJSON(camp);  
                    
                if ( String.isNotBlank(jsonbody) ){
                        headers.put('Content-Length',jsonbody.length()+'');                        
                }
                    
                endpoint = endpoint + '/' + camp.QCCampaignId__c;
                cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, timeout, null);                  
                HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
                
                if(req != null){
                    HttpResponse res = cc_HttpCallout.makeRequest(req);    
                    if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                        mapResponse.put(camp.Id, res);
                    }else {
                        CalloutLog__c calloutLog = new CalloutLog__c();        
                        calloutLog = cc_Util.parseCallOutLog('Update Campaign Callout', camp.Id,'cc_CampaignHelper', 'asyncUpdateCampaignToQC', method, endpoint, headers, req.getBody(),res.getBody(), String.valueOf(res.getStatusCode()), UserInfo.getUserId());
                        calloutLogs.add(calloutLog);
                    }
                }else {
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Update Campaign Callout', '' ,'cc_CampaignHelper', 'asyncUpdateCampaignToQC', method, endpoint, headers, '', 'Token is null or blank', '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);
                }
    
            }
        }          

        //Reponse processing 
        if(mapResponse.size() > 0){
            for(String campId: mapResponse.keySet()){
                HttpResponse res = mapResponse.get(campId);
                cc_CouponAPIWrapper.Responds log = new cc_CouponAPIWrapper.Responds();

                String reponeJs = res.getBody();
                cc_CouponAPIWrapper.CampaignAPIResultWrapper result = (cc_CouponAPIWrapper.CampaignAPIResultWrapper)JSON.deserialize(reponeJs, cc_CouponAPIWrapper.CampaignAPIResultWrapper.class);

                if(result.success == false){                    
                    cc_CouponAPIWrapper.FalseResultWraper error = result.error;  
                    CalloutLog__c calloutLog = new CalloutLog__c();        
                    calloutLog = cc_Util.parseCallOutLog('Update Campaign Callout', campId, 'cc_CampaignHelper', 'asyncUpdateCampaignToQC', '', '', headers, '', error.message, '', UserInfo.getUserId());
                    calloutLogs.add(calloutLog);    
                }               
                
            }
        }        

        // System.debug('calloutLogs=>' + calloutLogs.size());
        if(calloutLogs.size() > 0 ){
            insert calloutLogs;
        }
    }

    //Generate Create Campaign JS Body
    public static String intiCreateCampaignJSON(Campaign camp){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
            gen.writeStringField('name', camp.Name);
            gen.writeStringField('multiple_usage', camp.MultipleUsage__c == true?'YES': 'NO');
        gen.writeEndObject();

        String jsonbody = gen.getAsString();   
        return jsonbody;  
    }

    //Generate Update Campaign JS Body
    public static String intiUpdateCampaignJSON(Campaign camp){
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();     
            gen.writeStringField('name', camp.Name);
            gen.writeStringField('multiple_usage', camp.MultipleUsage__c == true?'YES': 'NO');
        gen.writeEndObject();

        String jsonbody = gen.getAsString();   
        return jsonbody;  
    }
}