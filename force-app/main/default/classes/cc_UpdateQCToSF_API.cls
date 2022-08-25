@RestResource(urlMapping='/updateqctosf')
global class cc_UpdateQCToSF_API {
    @HttpPost
    global static string doPostAccountFromQCSystem(){
        UDAccountToQCWrapper.Responds rp = new UDAccountToQCWrapper.Responds();
        cc_setting__c setting = [select id, name, Qc_account_email__c,Hotline__c,is_write_api_log__c   from cc_setting__c];
        API_Inbound_Message_Setting__c apisetting = API_Inbound_Message_Setting__c.getInstance('cc_UpdateQCToSF_API');
        cc_static_Message.isCreateQCAccountViaAPI = true;
        Account mccAccount;
        try{
            UDAccountToQCWrapper incomeAccount = UDAccountToQCWrapper.parse(RestContext.request.requestBody.tostring());

            if(apisetting != null){
               	if(apisetting.On_Off__c == true){
                	cc_Util.doPublishAPIInboundMsg('cc_UpdateQCToSF_API','updateqctosf',RestContext.request.requestBody.tostring());
            	}
            }
            
            List<QC_Account__c> qcAccountList = [select id,Industry__c,sales__c, support__c,ownerId, name,Agency_Email__c,AccountOwner__c,is_mcc__c from QC_Account__c where QC_Account_Id__c =:incomeAccount.Customer_id];
            if(qcAccountList.size() == 0){
                rp.status = 'fail';
                rp.message = 'Can not find QC Account';
                if( setting.is_write_api_log__c){
                    cc_Util.writeLog('updateqctosf',rp.message, RestContext.request.requestBody.tostring());
                }
                return system.JSON.serialize(rp);
            }
            
            Set<string> setEmail = new Set<string>();
            if( !string.isBlank( incomeAccount.Customer_sale_email))
            {
                setEmail.add(incomeAccount.Customer_sale_email.toLowerCase());
            }
            if( !string.isBlank( incomeAccount.Customer_support_email))
            {
                setEmail.add(incomeAccount.Customer_support_email.toLowerCase());             
            }             
            List<User> userList = [select id, QC_Email__c, IsActive from User where QC_Email__c IN :setEmail];
            for(User item: userList){
                if( !item.IsActive){
                    rp.status = 'fail';
                    rp.message = 'Can not update for deactive user';
                    if( setting.is_write_api_log__c){
                        cc_Util.writeLog('updateqctosf',rp.message, RestContext.request.requestBody.tostring());
                    }
                    return system.JSON.serialize(rp);
                }
            }
            QC_Account__c qcAccountExist = qcAccountList.get(0);
            boolean isUpdateCustomerMCC = false;
            
            //Relationship__c relationship = null;
            List<QC_Account__c> mccQCAccTempList = new List<QC_Account__c>();
            if(!string.isBlank(incomeAccount.Customer_mcc_email ) || !string.isBlank(incomeAccount.Customer_agency_email )){
                string mccEmailTemp = '';
                if(!string.isBlank(incomeAccount.Customer_mcc_email )){
                    mccEmailTemp = incomeAccount.Customer_mcc_email.trim();
                }
                else{
                    mccEmailTemp  = incomeAccount.Customer_agency_email.trim();
                }
                
                mccQCAccTempList = [select id,Name,ownerId, AccountOwner__c, industry__c from  QC_Account__c where name =:mccEmailTemp ];
                if( mccQCAccTempList.size() == 0){
                    rp.status = 'fail';
                    rp.message = 'Can not find agencyEmail/mcc Email';
                    if( setting.is_write_api_log__c){
                        cc_Util.writeLog('updateqctosf',rp.message, RestContext.request.requestBody.tostring());
                    }
                    return system.JSON.serialize(rp);
                }
                if(string.isblank(mccQCAccTempList.get(0).AccountOwner__c)){
                    qcAccountExist.Agency_Email__c = mccEmailTemp;
                	qcAccountExist.Agency_QC_Account__c = mccQCAccTempList.get(0).id;
                    if( !string.isBlank(incomeAccount.Customer_industry) )
                        qcAccountExist.Industry__c = incomeAccount.Customer_industry;
                    if(string.isBlank(qcAccountExist.Industry__c) && mccQCAccTempList.size() >0){
                        qcAccountExist.Industry__c = mccQCAccTempList.get(0).industry__c;
                    }
                    string str = getUserId(userList,incomeAccount.Customer_sale_email);
                    
                    qcAccountExist.Sales__c =  getUserId(userList,incomeAccount.Customer_sale_email);
                    if(string.isBlank(qcAccountExist.Sales__c) &&  mccQCAccTempList.size() > 0){
                        qcAccountExist.Sales__c = mccQCAccTempList.get(0).ownerId;
                    }
                    if( !string.isBlank( qcAccountExist.Sales__c)){
                        qcAccountExist.OwnerId = qcAccountExist.Sales__c;
                    }
                    qcAccountExist.Support__c = getUserId(userList,incomeAccount.Customer_support_email);
                    update qcAccountExist;
                     rp.status = 'success';
                    rp.message = '';
                    return system.JSON.serialize(rp);
                }
                
                qcAccountExist.Agency_Email__c = mccEmailTemp;
                qcAccountExist.Agency_QC_Account__c = mccQCAccTempList.get(0).id;
                qcAccountExist.is_mcc__c = true;
                mccAccount = [select id, ownerId, Industry__c, recordType.Name from Account where id=:mccQCAccTempList.get(0).AccountOwner__c limit 1] ;
                system.debug('debug:' + qcAccountExist.AccountOwner__c +  '     ' +  mccAccount.id);
                if( !string.isBlank(qcAccountExist.AccountOwner__c)  && qcAccountExist.AccountOwner__c != mccAccount.id)
                {
                    String combineId = (String)mccAccount.id + (String)qcAccountExist.id;                    

                    Relationship__c rlationShip = new Relationship__c();
                    rlationShip.Account__c = mccAccount.id;
                    rlationShip.Relationship_Type__c = 'Own';
                    rlationShip.QC_Account__c = qcAccountExist.id;
                    rlationShip.ID_combination__c = combineId;
                    system.debug('debug:' + mccAccount.id);
                    qcAccountExist.AccountOwner__c = mccAccount.id;

                    Schema.SObjectField usfield = Relationship__c.Fields.ID_combination__c;
                    Database.upsert(rlationShip, usfield, false) ;
                    isUpdateCustomerMCC = true;
                }
                if(string.isBlank(qcAccountExist.AccountOwner__c) ){
                    String combineId = (String)mccAccount.id + (String)qcAccountExist.id;      

                    Relationship__c rlationShip = new Relationship__c();
                    rlationShip.Account__c = mccAccount.id;
                    rlationShip.Relationship_Type__c = 'Own';
                    rlationShip.QC_Account__c = qcAccountExist.id;
                    qcAccountExist.AccountOwner__c = mccAccount.id;
                    rlationShip.ID_combination__c = combineId;

                    Schema.SObjectField usfield = Relationship__c.Fields.ID_combination__c;
                    Database.upsert(rlationShip, usfield, false) ;                   
                    isUpdateCustomerMCC = true;
                }
            }
            
            if( !string.isBlank(incomeAccount.Customer_industry) )
                qcAccountExist.Industry__c = incomeAccount.Customer_industry;
            if(string.isBlank(qcAccountExist.Industry__c) && mccQCAccTempList.size() >0){
                qcAccountExist.Industry__c = mccQCAccTempList.get(0).industry__c;
            }
            string str = getUserId(userList,incomeAccount.Customer_sale_email);
            system.debug('debug#user:' + str + '   ' + incomeAccount.Customer_sale_email);
            qcAccountExist.Sales__c =  getUserId(userList,incomeAccount.Customer_sale_email);
            if(string.isBlank(qcAccountExist.Sales__c) &&  mccQCAccTempList.size() > 0){
                qcAccountExist.Sales__c = mccQCAccTempList.get(0).ownerId;
            }
            if( !string.isBlank( qcAccountExist.Sales__c)){
                qcAccountExist.OwnerId = qcAccountExist.Sales__c;
            }
            qcAccountExist.Support__c = getUserId(userList,incomeAccount.Customer_support_email);
            update qcAccountExist;
            
            List<Lead>  lList = [select id,Industry_c__c,ownerId,owner.Type, IsConverted , Company, Customer_Type__c
                                 from Lead where QC_Account_Id__c =: incomeAccount.Customer_id ];
            if( lList.size() > 0){
                Lead l = lList.get(0);
                if( isUpdateCustomerMCC && !l.IsConverted){
                    if( mccAccount.recordType.Name == 'Person Account'){
                        l.Company = null;
                        l.Customer_Type__c = null;
                    }
                    else{
                        l.Company = string.isBlank(l.Company) == true? 'test company': l.Company;
                        l.Customer_Type__c = string.isBlank(l.Customer_Type__c) == true? 'Agency': l.Customer_Type__c;
                    }
                    delete l;
                }
                else{
                    if(!l.IsConverted){
                        if( l.owner.Type != 'User')
                        {
                            l.ownerId = qcAccountExist.OwnerId;
                        }
                        
                        l.Industry_c__c = qcAccountExist.Industry__c;
                        update l;
                    }
                }
            }
        }Catch(Exception ex){
            rp.status = 'fail';
            rp.message = ex.getMessage();
            if( setting.is_write_api_log__c){
                cc_Util.writeLog('updateqctosf',rp.message, RestContext.request.requestBody.tostring());
            }
            return system.JSON.serialize(rp);
        }
        
        rp.status = 'success';
        rp.message = '';
        
        return system.JSON.serialize(rp);
        
    }
    public static string getUserId(List<User> userList,string email)
    {
        if( string.isBlank(email)){
            return null;
        }
        for( User item: userList)
        {
            if( item.QC_Email__c == email){
                return item.id;
            }
        }
        return null;
    }
}