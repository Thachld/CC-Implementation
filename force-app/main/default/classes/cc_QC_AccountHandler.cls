public Without Sharing class cc_QC_AccountHandler implements cc_ITrigger{    
    cc_setting__c setting = new cc_setting__c();
    cc_Profile__c profle = cc_Util.getProfile('Sales Profile');
    Set<String> updateAccIds = new Set<String>();
    Set<String> accIds = new Set<String>();  
    Map<String,cc_QC_AccountHelper.cc_QCAccountOwner_Wrapper> mapUDOwner = new Map<String,cc_QC_AccountHelper.cc_QCAccountOwner_Wrapper>();    
    List<cc_QC_AccountHelper.cc_QCAccount_Share_Wraper> shareQCs = new List<cc_QC_AccountHelper.cc_QCAccount_Share_Wraper>();
    List<cc_QC_AccountHelper.cc_QCAccountStreaming_Wrapper> streamingMSgs = new List<cc_QC_AccountHelper.cc_QCAccountStreaming_Wrapper>();    
    Map<String, cc_QC_AccountHelper.cc_AccountTeam_Wraper> mapAccteams = new Map<String, cc_QC_AccountHelper.cc_AccountTeam_Wraper>();
    

    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
        if( cc_static_Message.isUpdateBalance == null)
            cc_static_Message.isUpdateBalance = false;
        if( cc_static_Message.isCreateQCAccountViaAPI == null)
            cc_static_Message.isCreateQCAccountViaAPI = false;   
        Set<Id> userIdSet = new Set<Id>();  
        Map<Id,user> userMap = new Map<ID, User>();
        userMap = new Map<ID, User>([SELECT Id,QC_Email__c,ProfileId, Profile.Name, isActive  FROM User WHERE isActive = true]);        
        
        if(Trigger.isInsert){
            Set<Id> accountOwnerChangeSet = new Set<Id>();
            Map<Id, Account> accountOwnerChangeMap;

            for(QC_Account__c qc: (List<QC_Account__c>)Trigger.new){
                if(!String.isBlank(qc.AccountOwner__c)){
                    accountOwnerChangeSet.add(qc.AccountOwner__c);
                }
            }

            //Get Account information
            if(accountOwnerChangeSet.size() > 0){
                accountOwnerChangeMap = new Map<Id,Account>([SELECT Id,RecordType.DeveloperName, Area__c FROM account WHERE Id IN:accountOwnerChangeSet]);
            }  


            for(QC_Account__c qc: (List<QC_Account__c>)Trigger.new){
                qc.Syn_via_Stream__c = !cc_static_Message.isCreateQCAccountViaAPI;

                //OwnerId
                if(string.valueOf(qc.OwnerId).startsWith('005')){
                     
                    String ownerProfleName = userMap.get(qc.OwnerId).Profile.Name;
                    System.debug('ownerProfleName =>' + ownerProfleName);
                    String salesprofile = profle == null? 'Sales Profile': profle.Name;
                    //Owner has profile Is Sale  
                    if(ownerProfleName == salesprofile){
                        qc.Sales__c = qc.ownerId; 
                        User us = userMap.get(qc.Sales__c);
                        if( us != null){
                            qc.Sale_Email__c = us.QC_Email__c;        
                        }                                       
                    }                
                }else {
                    qc.Sales__c = null;
                    qc.Sale_Email__c = null;
                }
                

                //Support user is not blank
                if(!String.isBlank(qc.Support__c)){
                    User us = userMap.get(qc.Support__c);
                    if( us != null)
                        qc.Support_Email__c = us.QC_Email__c;
                }else{
                    qc.Support_Email__c = null;
                }

                //Account Owner is Not Blank
                if(!String.isBlank(qc.AccountOwner__c)){
                    //Update Agency Text for Sharing rule
                    if(String.isBlank(qc.AccountOwner__c)){
                        qc.Agency_Text__c = 'Other';
                    }
                    else{

                        Account acc = accountOwnerChangeMap.get(qc.AccountOwner__c);
                        if(acc.RecordType.DeveloperName == 'Other'){
                            qc.Agency_Text__c = 'Other';
                        }
                        if(acc.RecordType.DeveloperName == 'Client'){
                            qc.Agency_Text__c = 'Client';
                        }
                        if(acc.RecordType.DeveloperName == 'Person Account'){
                            qc.Agency_Text__c = 'PersonAccount';
                        }
                        if(acc.RecordType.DeveloperName == 'Agency'){
                            if(acc.Area__c == 'Local'){
                                qc.Agency_Text__c = 'Local Agency';
                            }else{
                                qc.Agency_Text__c = 'Global Agency';
                            }
                        }
                    }
                }
            }

        }else if (Trigger.isUpdate) {     
            Map<Id,qc_Account__c> newMap = (Map<Id,qc_Account__c>)Trigger.newMap; 
            Map<Id,qc_Account__c> oldMap = (Map<Id,qc_Account__c>)Trigger.oldMap;    
            Map<Id, Account> accountOwnerChangeMap;
            Set<Id> accountOwnerChangeSet = new Set<Id>();

            for(String qcId : newMap.keySet()){
                QC_Account__c newQC = newMap.get(qcId);
                QC_Account__c oldQC = oldMap.get(qcId);

                if(!String.isBlank(newQC.AccountOwner__c)  && (newQC.AccountOwner__c != oldQC.AccountOwner__c  || newQC.Support__c != oldQC.Support__c)){
                    accIds.add(newQC.AccountOwner__c);                    
                }

                if(!String.isBlank(newQC.AccountOwner__c) && newQC.AccountOwner__c != oldQC.AccountOwner__c ){
                    accountOwnerChangeSet.add(newQC.AccountOwner__c);
                }   

            }

            //Get Account Owners Infomation
            if(accountOwnerChangeSet.size() > 0){
                accountOwnerChangeMap = new Map<Id,Account>([SELECT Id,RecordType.DeveloperName, Area__c FROM account WHERE Id IN:accountOwnerChangeSet]);
            }              

            for(QC_Account__c newQC : (List<QC_Account__c>)Trigger.new){                
                QC_Account__c oldQC = oldMap.get(newQC.Id);

                newQC.Syn_via_Stream__c = !cc_static_Message.isCreateQCAccountViaAPI;

                //Change Account Owner 
                if(newQC.AccountOwner__c != oldQC.AccountOwner__c){
                    //Update Agency Text for Sharing rule
                    if(String.isBlank(newQC.AccountOwner__c)){
                        newQC.Agency_Text__c = 'Other';
                    }
                    else{

                        Account acc = accountOwnerChangeMap.get(newQC.AccountOwner__c);
                        if(acc.RecordType.DeveloperName == 'Other'){
                            newQC.Agency_Text__c = 'Other';
                        }
                        if(acc.RecordType.DeveloperName == 'Client'){
                            newQC.Agency_Text__c = 'Client';
                        }
                        if(acc.RecordType.DeveloperName == 'Person Account'){
                            newQC.Agency_Text__c = 'PersonAccount';
                        }
                        if(acc.RecordType.DeveloperName == 'Agency'){
                            if(acc.Area__c == 'Local'){
                                newQC.Agency_Text__c = 'Local Agency';
                            }else{
                                newQC.Agency_Text__c = 'Global Agency';
                            }
                        }
                    }
                }


                //Changed Owner
                if(!String.isBlank(newQC.OwnerId) && newQC.OwnerId != oldQC.OwnerId){   
                    if(string.valueOf(newQC.OwnerId).startsWith('005')){

                        

                        //Owner has profile Is Sale   
                        String ownerProfleName = userMap.get(newQC.OwnerId).Profile.Name;
                        System.debug('ownerProfleName =>' + ownerProfleName);
                        String salesprofile = profle == null? 'Sales Profile': profle.Name;    
                        if(ownerProfleName == salesprofile){
                            // cc_QC_AccountHelper.cc_QCAccountOwner_Wrapper ownerwrap = new cc_QC_AccountHelper.cc_QCAccountOwner_Wrapper();
                            // ownerwrap.QCAccount = newQC.Id;
                            // ownerwrap.newOwner = newQC.OwnerId;
                            // ownerwrap.oldOwner = oldQC.OwnerId;

                            // mapUDOwner.put(newQC.Id, ownerwrap);

                            newQC.Sales__c = newQC.ownerId; 
                            User us = userMap.get(newQC.Sales__c);
                            if( us != null){
                                newQC.Sale_Email__c = us.QC_Email__c;        
                            }                                       
                        }
                    }else {
                        newQC.Sales__c = null;
                        newQC.Sale_Email__c = null;
                    }     
                }
                
                //Changed Support
                if(newQC.Support__c != oldQC.Support__c){
                    if(!string.isBlank(newQC.Support__c)){                        
                        User us = userMap.get(newQC.Support__c);
                        newQC.Support_Email__c = us.QC_Email__c;
                        
                    }else{
                        newQC.Support_Email__c = null;
                    }
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
        if( cc_static_Message.isUpdateBalance == null)
            cc_static_Message.isUpdateBalance = false;
        if( cc_static_Message.isCreateQCAccountViaAPI == null)
            cc_static_Message.isCreateQCAccountViaAPI = false;   

        if(Trigger.isInsert){
            for(QC_Account__c qc: (List<QC_Account__c>)Trigger.new){
                if(!String.isBlank(qc.AccountOwner__c) && !String.isBlank(qc.Support__c)){
                    
                    //Update Start Date of Account                    
                    updateAccIds.add(qc.AccountOwner__c);

                    //Add Account team             
                    accIds.add(qc.AccountOwner__c);
                    String key = qc.AccountOwner__c + '###' + qc.Support__c;
                    if(!mapAccteams.containsKey(key)){
                        cc_QC_AccountHelper.cc_AccountTeam_Wraper team = new cc_QC_AccountHelper.cc_AccountTeam_Wraper();
                        team.Support = qc.Support__c;
                        team.AccountOwner = qc.AccountOwner__c;

                        mapAccteams.put(key, team);
                    } 
                }

                if(!String.isBlank(qc.Support__c)){
                    //Share support      
                    cc_QC_AccountHelper.cc_QCAccount_Share_Wraper curshr = new cc_QC_AccountHelper.cc_QCAccount_Share_Wraper();
                    curshr.QCAccount = qc.Id;
                    curshr.NewSupport = qc.Support__c;
                    curshr.OldSupport = '';

                    shareQCs.add(curshr);
                }

                //add Platform Event
                if(!cc_static_Message.isCreateQCAccountViaAPI){

                    cc_QC_AccountHelper.cc_QCAccountStreaming_Wrapper msg = new cc_QC_AccountHelper.cc_QCAccountStreaming_Wrapper();
                    msg.Id = qc.Id;
                    msg.Name = qc.Name;
                    msg.QC_Account_Id = qc.QC_Account_Id__c;
                    msg.Sales = qc.Sales__c;
                    msg.Sale_Email = qc.Sale_Email__c;
                    msg.Support = qc.Support__c;
                    msg.Support_Email = qc.Support_Email__c;
                    msg.Industry = qc.Industry__c;

                    streamingMSgs.add(msg);
                }
            }
        }else if (Trigger.isUpdate){
            Map<Id,qc_Account__c> newMap = (Map<Id,qc_Account__c>)Trigger.newMap; 
            Map<Id,qc_Account__c> oldMap = (Map<Id,qc_Account__c>)Trigger.oldMap;    

            for(String qcId : newMap.keySet()){
                QC_Account__c newQC = newMap.get(qcId);
                QC_Account__c oldQC = oldMap.get(qcId);

                if(!String.isBlank(newQC.AccountOwner__c) && !String.isBlank(newQC.Support__c) && (newQC.AccountOwner__c != oldQC.AccountOwner__c  || newQC.Support__c != oldQC.Support__c)){
                    
                    //Add Account team
                    String key = newQC.AccountOwner__c + '###' + newQC.Support__c;

                    if(!mapAccteams.containsKey(key)){
                        cc_QC_AccountHelper.cc_AccountTeam_Wraper team = new cc_QC_AccountHelper.cc_AccountTeam_Wraper();
                        team.Support = newQC.Support__c;
                        team.AccountOwner = newQC.AccountOwner__c;

                        mapAccteams.put(key, team);
                    }    
                    
                    accIds.add(newQC.AccountOwner__c);
                }

                //Update Start Date of Account
                if(newQC.AccountOwner__c != oldQC.AccountOwner__c){
                    
                    if(!String.isBlank(newQC.AccountOwner__c)){
                        updateAccIds.add(newQC.AccountOwner__c);
                    }

                    if(!String.isBlank(oldQC.AccountOwner__c)){
                        updateAccIds.add(oldQC.AccountOwner__c);
                    }                    
                }

                //Change Support
                if( newQC.Support__c != oldQC.Support__c ){
                    
                    //Share support  
                    if( !String.isBlank(newQC.Support__c) || !String.isBlank(oldQC.Support__c) ){
                        cc_QC_AccountHelper.cc_QCAccount_Share_Wraper curshr = new cc_QC_AccountHelper.cc_QCAccount_Share_Wraper();
                        curshr.QCAccount = newQC.Id;
                        curshr.NewSupport = newQC.Support__c;
                        curshr.OldSupport = oldQC.Support__c;
                        shareQCs.add(curshr);
                    }              
                    
                }

                //Change owner
                if( newQC.OwnerId != oldQC.OwnerId ){
                    
                    //Need to re-Sharing record to support because when owner is changed sharing record is reset
                    // if( !String.isBlank(newQC.Support__c) ){
                    //     cc_QC_AccountHelper.cc_QCAccount_Share_Wraper curshr = new cc_QC_AccountHelper.cc_QCAccount_Share_Wraper();
                    //     curshr.QCAccount = newQC.Id;
                    //     curshr.NewSupport = newQC.Support__c;
                    //     curshr.OldSupport = '';
                    //     //shareQCs.add(curshr);
                    // }              
                    
                }

                //Changed Sale or Support or Industry
                if( (newQC.Sales__c != oldQC.Sales__c ) || (newQC.Support__c != oldQC.Support__c) || newQC.Industry__c != oldQC.Industry__c){

                    //Platform event MSg
                    if(!cc_static_Message.isCreateQCAccountViaAPI ){
                        cc_QC_AccountHelper.cc_QCAccountStreaming_Wrapper msg = new cc_QC_AccountHelper.cc_QCAccountStreaming_Wrapper();
                        msg.Id = newQC.Id;
                        msg.Name = newQC.Name;
                        msg.QC_Account_Id = newQC.QC_Account_Id__c;
                        msg.Sales = newQC.Sales__c;
                        msg.Sale_Email = newQC.Sale_Email__c;
                        msg.Support = newQC.Support__c;
                        msg.Support_Email = newQC.Support_Email__c;
                        msg.Industry = newQC.Industry__c;

                        streamingMSgs.add(msg);
                    }
                    
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
        
        //Update Account Owner Start Date
        if(updateAccIds.size() > 0){
            cc_QC_AccountHelper.attemptUpdateAccountStartDate(updateAccIds);
        }

        //Push Platform event
        if(streamingMSgs.size() > 0){
            cc_QC_AccountHelper.publishQCAccount(streamingMSgs);
        }



        //Share QC Account
        System.debug('shareQCs =>' + shareQCs);
        if(shareQCs.size() > 0){
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            String params = JSON.serialize(shareQCs);
            cc_QC_AccountHelper.attemptUpdateQCAccountShare(params);

            for(cc_QC_AccountHelper.cc_QCAccount_Share_Wraper qc: shareQCs){
                if(!String.isBlank(qc.NewSupport)){
                    ConnectApi.FeedItemInput feedItemInput = cc_Util.genChatterwithMetion(qc.NewSupport, qc.QCAccount, ' This account has been assigned to you. Please take care customer');
                    ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                    batchInputs.add(batchInput);
                }                
            }

            if( batchInputs.size() > 0){
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
            }
        }

        //Insert Account teams
        System.debug('accIds =>' + accIds);
        if(accIds.size() > 0){
            List<cc_QC_AccountHelper.cc_AccountTeam_Wraper> listAccTeamToInsert = new List<cc_QC_AccountHelper.cc_AccountTeam_Wraper>();
            List<AccountTeamMember> accountTeamList = new List<AccountTeamMember>();
            accountTeamList = [SELECT Id, AccountId,UserId FROM AccountTeamMember WHERE AccountId IN:accIds];                        
            
            Map<String,AccountTeamMember> accountShareMap = new Map<String,AccountTeamMember>();
            for(AccountTeamMember member: accountTeamList){
                accountShareMap.put(member.AccountId + '###' + member.UserId, member);
            }  

            if(accountShareMap != null){
                for(String key : mapAccteams.keySet()){
                    if(!accountShareMap.containsKey(key)){
                        cc_QC_AccountHelper.cc_AccountTeam_Wraper team = mapAccteams.get(key);                        
                        listAccTeamToInsert.add(team);
                    }
                }                
            }
            
            System.debug('listAccTeamToInsert = >' + listAccTeamToInsert);
            if(listAccTeamToInsert.size() > 0){
                String params = JSON.serialize(listAccTeamToInsert);
                cc_QC_AccountHelper.attemptAddAccountTeam(params);
            }

        }

        // System.debug('mapUDOwner =>' + mapUDOwner.size() + 'value=>' + mapUDOwner.values());
        // if(mapUDOwner.size() > 0){
        //     String params = JSON.serialize(mapUDOwner.values());
        //     System.debug('params1 = >' + params);
        //     cc_QC_AccountHelper.attemptAsycnUpdateQCOwner(params);
        // }
        
    }        
}