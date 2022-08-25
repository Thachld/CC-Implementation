@RestResource(urlMapping='/updateaddressqctosf')
global class cc_UpdateAddressQCToSF_API {
    @HttpPost
    global static string doPostAddressFromQCSystem(){
        AddressQCToSF.Responds rp = new AddressQCToSF.Responds();
        cc_setting__c setting = [select id, name, Qc_account_email__c,Hotline__c,is_write_api_log__c   from cc_setting__c];
        cc_static_Message.isCreateQCAccountViaAPI = true;
        try{
            AddressQCToSF incomeAccount = AddressQCToSF.parse(RestContext.request.requestBody.tostring());
            List<QC_Account__c> qcAccountList = [select id, name from QC_Account__c where QC_Account_Id__c =:incomeAccount.customer_id];
            if(qcAccountList.size() == 0){
                rp.status = 'fail';
                rp.message = 'Can not find QC Account';
                if( setting.is_write_api_log__c){
                    cc_Util.writeLog('updateaddressqctosf',rp.message, RestContext.request.requestBody.tostring());
                }
                return system.JSON.serialize(rp);
            }
            QC_Account__c qcAccountExist = qcAccountList.get(0);
            
            qcAccountExist.Customer_Type__c =  incomeAccount.customer_type;
            qcAccountExist.Individual_Name__c =  incomeAccount.name;
            qcAccountExist.Individual_Phone__c =  incomeAccount.phone;
            
            qcAccountExist.Position__c =  incomeAccount.position;
            qcAccountExist.Representative__c =  incomeAccount.representative;
            qcAccountExist.Company_type__c =  incomeAccount.company_type;
            qcAccountExist.Company_name__c =  incomeAccount.company_name;
            qcAccountExist.Official_address__c =  incomeAccount.official_address;
            qcAccountExist.Shipping_address__c =  incomeAccount.shipping_address;
            
            update qcAccountExist;
            
            
        }Catch(Exception ex){
            rp.status = 'fail';
            rp.message = ex.getMessage();
            if( setting.is_write_api_log__c){
                cc_Util.writeLog('updateaddressqctosf',rp.message, RestContext.request.requestBody.tostring());
            }
            return system.JSON.serialize(rp);
        }
        
        rp.status = 'success';
        rp.message = '';
        /*if( setting.is_write_api_log__c){
            cc_Util.writeLog('updateaddressqctosf',rp.message, RestContext.request.requestBody.tostring());
        }*/
        return system.JSON.serialize(rp);
    }
}