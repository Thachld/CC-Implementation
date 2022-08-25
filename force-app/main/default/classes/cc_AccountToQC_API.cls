@RestResource(urlMapping='/qctosf')
global class cc_AccountToQC_API {
    @HttpPost
    global static string doPostAccountFromQCSystem()
    {
        AccountToQCWrapper.Responds rp = new AccountToQCWrapper.Responds();
        cc_setting__c setting = [select id, name, Qc_account_email__c,Hotline__c,is_write_api_log__c from cc_setting__c];
        cc_static_Message.isCreateQCAccountViaAPI = true;
        try
        {
            AccountToQCWrapper incomeAccount = AccountToQCWrapper.parse(RestContext.request.requestBody.tostring());
            if(string.isBlank(incomeAccount.agency_email) || !string.isBlank(incomeAccount.mcc_email))
            {
                incomeAccount.agency_email = incomeAccount.mcc_email;
            }
            Set<string> setEmail = new Set<string>();
            if( !string.isBlank( incomeAccount.Sale_email))
            {
                setEmail.add(incomeAccount.Sale_email);
            }
            if( !string.isBlank( incomeAccount.Support_email))
            {
                setEmail.add(incomeAccount.Support_email);             
            }             
            List<User> userList = [select id, QC_Email__c from User where QC_Email__c in:setEmail];
            List<QC_Account__c> qcAccountList = [select id, name from QC_Account__c where QC_Account_Id__c =:incomeAccount.Customer_id];
            Account agencyAccount;
            QC_Account__c agencyQCAccount;
            if( !string.isBlank(incomeAccount.agency_email) )
            {
                string agencyEmailTemp = incomeAccount.agency_email.trim();
                List<QC_Account__c> accTempList = [select id,Name,AccountOwner__c, ownerId, sales__c, support__c from  QC_Account__c where name =:agencyEmailTemp ]; 
                if(accTempList.size() == 0)
                {
                    rp.status = 'fail';
                    rp.message = 'Can not find agencyEmail/mcc Email';
                    if( setting.is_write_api_log__c)
                    {
                        cc_Util.writeLog('qctosf',rp.message, RestContext.request.requestBody.tostring());
                    }
                    return system.JSON.serialize(rp);
                }
                if(string.isBlank(accTempList.get(0).AccountOwner__c))
                {
                    QC_Account__c qcAccount = new QC_Account__c();
                    qcAccount.Name =  incomeAccount.Customer_email;
                    qcAccount.QC_Account_Id__c = incomeAccount.Customer_id;
                    qcAccount.Sales__c = getUserId(userList,incomeAccount.Sale_email);
                    if(string.isBlank(qcAccount.Sales__c))
                    {
                        qcAccount.Sales__c = accTempList.get(0).ownerId;
                    }
                    qcAccount.Support__c = getUserId(userList,incomeAccount.Support_email);
                    qcAccount.Type__c = incomeAccount.Profile_id;
                    qcAccount.Website__c = incomeAccount.Website;
                    qcAccount.Agency_Email__c =  incomeAccount.agency_email;
                    qcAccount.OwnerId = qcAccount.Sales__c;
                    insert  qcAccount;
                    rp.status = 'success';
                    rp.message = '';
                    string result = system.JSON.serialize(rp);
                    return result;
                }
                agencyAccount = [select id, ownerId, Industry__c, recordType.Name, Company_name__c,Customer_Type__c  from Account where id=:accTempList.get(0).AccountOwner__c limit 1] ;
                agencyQCAccount = accTempList.get(0);
            }
            if(qcAccountList.size() >0)
            {
                QC_Account__c qcAccount = qcAccountList.get(0);
                qcAccount.Name =  incomeAccount.Customer_email;
                qcAccount.QC_Account_Id__c = incomeAccount.Customer_id;
                qcAccount.Sales__c = getUserId(userList,incomeAccount.Sale_email);
                qcAccount.Support__c = getUserId(userList,incomeAccount.Support_email);
                qcAccount.Type__c = incomeAccount.Profile_id;
                qcAccount.Website__c = incomeAccount.Website;
                qcAccount.Agency_Email__c =  incomeAccount.agency_email;
                if( !string.isBlank(incomeAccount.agency_email))
                {
                    qcAccount.Agency_QC_Account__c = agencyQCAccount.id;
                }
                update  qcAccount;
            }
            else
            {
                Group gr = [select Id from Group where Name =:setting.Hotline__c and Type = 'Queue'];
                string email = incomeAccount.Customer_email.trim();
                List<Lead>  leadExistList = [select id, isconverted,ConvertedAccountId,email, MobilePhone, Website, OwnerId from Lead where email =:email];
                if( leadExistList.size() > 0)
                {
                    Lead existLead = leadExistList.get(0);
                    if( existLead.IsConverted == true)
                    {
                        
                        Lead l = initLead(incomeAccount, null);
                        QC_Account__c qcAccount =  initQCAccount(l, userList,incomeAccount.Sale_email, incomeAccount.Support_email,  incomeAccount.Profile_id, incomeAccount.Website);
                        insert qcAccount;
                        
                        if( !string.isBlank(qcAccount.Support__c ))
                        {
                            List<cc_ChatterBatchWrapper> postList = new List<cc_ChatterBatchWrapper>();
                            cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
                            
                            post.idList.add(qcAccount.Support__c);
                            post.message =   ' This account has been assigned to you. Please take care customer';
                            post.recordId = qcAccount.id;
                            postList.add(post);
                            if(!Test.isRunningTest())
                            {
                                cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(postList);
                                database.executeBatch(batch,1);
                            }
                        }
                        string relationShipAccId = existLead.ConvertedAccountId;
                        if( agencyAccount != null)
                        {
                            relationShipAccId = agencyAccount.id;
                        }
                        string combine = relationShipAccId + '' + qcAccount.id;
                        List<string> combineList = new List<string>();
                        combineList.add(combine);
                        Map<string,boolean> relationMap = cc_Util.checkRelationship(combineList);
                        if(relationMap.keySet().size() <=0)
                        {
                            Relationship__c rlationShip = new Relationship__c();
                            rlationShip.Account__c = relationShipAccId;
                            rlationShip.QC_Account__c = qcAccount.id;
                            Database.insert(rlationShip, false);       
                        }
                    }
                    else{
                        Lead l = initLead(incomeAccount, gr);
                        l.id = existLead.id;
                        QC_Account__c qcAccount =  initQCAccount(l,  userList,incomeAccount.Sale_email, incomeAccount.Support_email,  incomeAccount.Profile_id, incomeAccount.Website);
                        if(!string.isBlank(incomeAccount.agency_email))
                        {
                            if( !string.isBlank(qcAccount.Sales__c))
                            {
                                l.OwnerId = qcAccount.Sales__c;
                            }
                            else
                            {
                                l.OwnerId = agencyAccount.ownerId;
                            }
                            qcAccount.OwnerId = l.OwnerId;
                            qcAccount.Agency_QC_Account__c = agencyQCAccount.id;
                            if( string.isBlank(l.Industry_c__c))
                            {
                                l.Industry_c__c = agencyAccount.Industry__c;
                            }
                            if(string.isBlank(qcAccount.Industry__c))
                            {
                                qcAccount.Industry__c = l.Industry_c__c;
                            } 
                            if( agencyAccount.recordType.Name != 'Person Account')
                            {
                                l.Company = string.isBlank(agencyAccount.Company_name__c) == true? 'temp company': agencyAccount.Company_name__c; 
                                l.Customer_Type__c = string.isBlank(agencyAccount.Customer_Type__c) == true? 'Agency' : agencyAccount.Customer_Type__c; 
                            }
                        }

                        //If website field is blank on salesforce
                        if(String.isBlank(existLead.Website)){
                            l.Website = incomeAccount.Website;
                        }
                        
                        if(string.isBlank(l.Website))
                        {
                            l.Website = 'No website';
                            Task t = new Task();
                            if(agencyAccount != null){
                                t.OwnerId = agencyAccount.OwnerId;
                                t.WhatId = agencyAccount.id;
                            }else{
                                t.OwnerId = existLead.OwnerId;
                                t.WhoId = existLead.id;
                            }
                            
                            t.Subject = 'Please input website';
                            
                            t.ActivityDate = date.today();
                            Database.insert(t, false);                            
                        }
                        if(!l.isconverted){
                            update l;
                        }                        	
                        
                        qcAccount.Agency_Email__c =  incomeAccount.agency_email;
                        insert qcAccount;
                        if(!string.isBlank(incomeAccount.agency_email))
                        {
                            Database.LeadConvert lc = new database.LeadConvert();
                            lc.setLeadId(l.id);
                            lc.setDoNotCreateOpportunity(true);
                            lc.setConvertedStatus('Converted');
                            lc.setAccountId(agencyAccount.id);
                            Database.LeadConvertResult lcr = Database.convertLead(lc);
                        }
                    }
                }
                else{
                    List<Contact> ctListExist = [select id, name, accountId, email,MobilePhone from contact where email like: email];
                    Contact existContact;
                    
                    if(ctListExist.size() > 0)
                    {
                        existContact = ctListExist.get(0);
                        Lead l = initLead(incomeAccount, gr);
                        QC_Account__c qcAccount =  initQCAccount(l,  userList,incomeAccount.Sale_email, incomeAccount.Support_email,  incomeAccount.Profile_id, incomeAccount.Website);
                        if(!string.isBlank(incomeAccount.agency_email))
                        {
                            if( !string.isBlank(qcAccount.Sales__c))
                            {
                                l.OwnerId = qcAccount.Sales__c;
                            }
                            else
                            {
                                l.OwnerId = agencyAccount.ownerId;
                            }
                            qcAccount.OwnerId = l.OwnerId;
                            qcAccount.Agency_QC_Account__c = agencyQCAccount.id;
                            qcAccount.Agency_Email__c =  incomeAccount.agency_email;
                        }
                        insert qcAccount;
                        string combine = existContact.accountId + '' + qcAccount.id; 
                        List<string> combineList = new List<string>();
                        combineList.add(combine);
                        Map<string,boolean> relationMap = cc_Util.checkRelationship(combineList);
                        if(relationMap.keySet().size() <=0)
                        {
                            Relationship__c rlationShip = new Relationship__c();
                            rlationShip.Account__c = existContact.accountId;
                            rlationShip.Relationship_Type__c = 'Own';
                            
                            rlationShip.QC_Account__c = qcAccount.id;
                            Database.insert(rlationShip, false);                            
                        }
                    }
                    else
                    {
                        if(!string.isBlank(incomeAccount.agency_email))
                        {
                            Lead l = initLead(incomeAccount, gr);
                            QC_Account__c qcAccount =  initQCAccount(l,  userList,incomeAccount.Sale_email, incomeAccount.Support_email,  incomeAccount.Profile_id, incomeAccount.Website);
                            qcAccount.Agency_QC_Account__c = agencyQCAccount.id;
                            qcAccount.Agency_Email__c =  incomeAccount.agency_email;
                            if( !string.isBlank(qcAccount.Sales__c))
                            {
                                qcAccount.OwnerId = qcAccount.Sales__c;
                            }
                            else
                            {
                                qcAccount.OwnerId = agencyQCAccount.ownerId;
                            }
                            qcAccount.Agency_Email__c =  incomeAccount.agency_email;
                            insert qcAccount;
                            string relationShipAccId = agencyAccount.id;
                            string combine = relationShipAccId + '' + qcAccount.id;
                            List<string> combineList = new List<string>();
                            combineList.add(combine);
                            Map<string,boolean> relationMap = cc_Util.checkRelationship(combineList);
                            if(relationMap.keySet().size() <=0)
                            {
                                Relationship__c rlationShip = new Relationship__c();
                                rlationShip.Account__c = relationShipAccId;
                                rlationShip.QC_Account__c = qcAccount.id;
                                Database.insert(rlationShip, false);       
                            }
                        }
                        else{
                            Lead l = initLead(incomeAccount, gr);
                            QC_Account__c qcAccount =  initQCAccount(l,  userList,incomeAccount.Sale_email, incomeAccount.Support_email,  incomeAccount.Profile_id, incomeAccount.Website);
                            
                            if( !string.isBlank(qcAccount.Sales__c))
                            {
                                l.OwnerId = qcAccount.Sales__c;
                                qcAccount.OwnerId = qcAccount.Sales__c;
                            }
                            l.LeadSource = 'Pull client';
                            insert l;
                            insert qcAccount;
                        }
                    }
                }
            }
            
            rp.status = 'success';
            rp.message = '';
            string result = system.JSON.serialize(rp);
            return result;
        }

        catch(Exception ex)
        {
            rp.status = 'fail';
            rp.message = ex.getMessage();
            
            if( setting.is_write_api_log__c)
            {
                cc_Util.writeLog('qctosf',rp.message, RestContext.request.requestBody.tostring());
            }
            return system.JSON.serialize(rp);
        }
    }
    public static string getUserId(List<User> userList,string email)
    {
        if( string.isBlank(email))
        {
            return null;
        }
        for( User item: userList)
        {
            if( item.QC_Email__c == email)
            {
                return item.id;
            }
        }
        return null;
    }
    public static QC_Account__c initQCAccount(Lead l, List<User> userList, string saleEmail, string supportEmail, string profileid,string Website  )
    {
        QC_Account__c qcAccount = new QC_Account__c();
        qcAccount.name = l.Email;
        qcAccount.Industry__c = l.Industry_c__c;
        qcAccount.QC_Account_Id__c =  l.QC_Account_Id__c;
        qcAccount.Register_time__c = l.Register_time__c;
        qcAccount.Sales__c = getUserId(userList,saleEmail);
        qcAccount.Support__c = getUserId(userList,supportEmail);
        qcAccount.Type__c = profileid;
        qcAccount.Website__c = Website;
        qcAccount.Phone__c = l.MobilePhone;
        return qcAccount;
    }
    public static Lead initLead(AccountToQCWrapper incomeAccount, Group gr)
    {
        Lead l = new Lead();
        l.Email = incomeAccount.Customer_email;
        l.LastName = incomeAccount.name;
        l.MobilePhone = incomeAccount.Phone_Number;
        l.QC_Account_Id__c = incomeAccount.Customer_id;
        l.Website = incomeAccount.Website;
        if( gr != null)
            l.ownerId = gr.id;
        l.Register_time__c = incomeAccount.Register_time == null? null: datetime.newInstance(incomeAccount.Register_time);
        return l;
    }
}