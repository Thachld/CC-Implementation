@RestResource(urlMapping= '/qcrefeshtoken')
global class cc_QCRefreshToken_API {

    @HttpPost
    global static String postToken() {
        AccountToQCWrapper.Responds rp = new AccountToQCWrapper.Responds();           

        try {
            
            cc_TokenWrapper wrap = cc_TokenWrapper.parse(RestContext.request.requestBody.tostring());            
            QC_Integration__c setting = cc_Util.getQCIntergrationInfo('qccampaignInternal');            
            if(setting != null){            
                if(wrap != null){                   
                    
                    // setting.Token__c = wrap.token;
                    setting.Time_expire__c = DateTime.valueOf(wrap.time_expire);    
                    setting.LastUpdatedDateTime__c = System.now();  
                    
                    Blob encryptKey = Crypto.generateAesKey(256);                             
                    Blob tokenData = Blob.valueOf(wrap.token);
                    Blob encryptData = Crypto.encryptWithManagedIV('AES256', encryptKey, tokenData);
                    String encryptStr = EncodingUtil.base64Encode(encryptData);                    
                    setting.EncryptToken__c = encryptStr;   
                    setting.Key__c = EncodingUtil.base64Encode(encryptKey);   

                    update setting;
                    coccoc.ManageQCCredential.updateOrgDefaultQCCredential(wrap.token, DateTime.valueOf(wrap.time_expire));         

                    rp.status = 'success';
                    rp.message = '';
                      
                }else {
                    rp.status = 'fail';
                    rp.message = 'Request body is null';

                    cc_Util.writeLog('qcrefeshtoken',rp.message, RestContext.request.requestBody.tostring());
                }
            }else {
                rp.status = 'fail';
                rp.message = 'Can not find custom setting for store token';

                cc_Util.writeLog('qcrefeshtoken',rp.message, RestContext.request.requestBody.tostring());
            }    

        } catch (Exception ex) {
            rp.status = 'fail';
            rp.message = ex.getMessage();

            cc_Util.writeLog('qcrefeshtoken',rp.message, RestContext.request.requestBody.tostring());
        }

        System.debug('rp=>' + rp);
        return JSON.serialize(rp);
    }
}