public class ClientSharingTriggerHelper {

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Dispatch method to run Asyn or Sync to Sharing client and related data to Sale.
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/
    public static void attemptSharing(Set<String> clIds){

        if(!System.isBatch() && !System.isFuture()){
            asyncSharing(clIds);
        }else{
            syncSharing(clIds);
        }
        
    }



    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 20
    * @description   Dispatch method to run Asyn or Sync to Stop Sharing client and related data to Sale.
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/
    public static void attemptStopSharing(Set<String> clIds){

        if(!System.isBatch() && !System.isFuture()){
            asyncStopSharing(clIds);
        }else{
            syncStopSharing(clIds);
        }
        
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Asynchronous Method to Start sharing client and related data to Sale.
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/
    @future
    public static void asyncSharing(Set<String> clIds){
        List<Client_Sharing__c> listCLs = [SELECT Id, Account__c, Share_To__c 
                                            FROM Client_Sharing__c WHERE Id IN : clIds];

        if(listCLs != null && listCLs.size() > 0){
            addToAccountTeam(listCLs);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Synchronous Method to Start sharing client and related data to Sale.
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/    
    public static void syncSharing(Set<String> clIds){
        List<Client_Sharing__c> listCLs = [SELECT Id, Account__c, Share_To__c
                                            FROM Client_Sharing__c WHERE Id IN : clIds];

        if(listCLs != null && listCLs.size() > 0){
            addToAccountTeam(listCLs);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Asynchronous Method to Stop sharing client to Sale.
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/
    @future
    public static void asyncStopSharing(Set<String> clIds){
        List<Client_Sharing__c> listCLs = [SELECT Id, Account__c, Share_To__c 
                                            FROM Client_Sharing__c WHERE Id IN : clIds];

        if(listCLs != null && listCLs.size() > 0){
            stopSharingClient(listCLs);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 20
    * @description   Synchronous Method to Stop sharing client to Sale.
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/    
    public static void syncStopSharing(Set<String> clIds){
        List<Client_Sharing__c> listCLs = [SELECT Id, Account__c, Share_To__c
                                            FROM Client_Sharing__c WHERE Id IN : clIds];

        if(listCLs != null && listCLs.size() > 0){
            stopSharingClient(listCLs);
        }
    }



    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method to Create Account Team for Shared Sale.
    * @return   void
    *********************************************************************************************************/
    public static void addToAccountTeam(List<Client_Sharing__c> listNewRec){
        List<AccountTeamMember> insertAccountTeam = new List<AccountTeamMember>();        
        List<Account> updateAccounts = new List<Account>();
        Map<String, List<QC_Account__c>> mapCL = new Map<String, List<QC_Account__c>>();
        Set<String> shareToIds = new Set<String>();

        Client_Sharing_Setting__mdt dfSetting = Client_Sharing_Setting__mdt.getInstance('default');

        for(Client_Sharing__c cl : listNewRec){

            shareToIds.add(cl.Share_To__c);
            AccountTeamMember accTeam = new AccountTeamMember();
            accTeam.AccountId = cl.Account__c;
            accTeam.UserId = cl.Share_To__c;
            accTeam.TeamMemberRole = dfSetting.TeamMemberRole__c;
            accTeam.AccountAccessLevel = dfSetting.AccountAccessLevel__c;
            accTeam.ContactAccessLevel = dfSetting.ContactAccessLevel__c;
            accTeam.CaseAccessLevel = dfSetting.CaseAccessLevel__c;
            accTeam.OpportunityAccessLevel = dfSetting.OpportunityAccessLevel__c;
            insertAccountTeam.add(accTeam);     
            
            Account acc = new Account();
            acc.Id = cl.Account__c;
            acc.Available_Client_to_be_shared__c  = false;
            acc.Shared_Client__c  = true;
            updateAccounts.add(acc);

        }        
        
        System.debug('insertAccountTeam=>' + insertAccountTeam.size());
        if(insertAccountTeam.size() > 0){
            insert insertAccountTeam;

            mapCL = shareQCAccounts(listNewRec);
            createClientSharingDetailRec(mapCL);
            updateCrossSellingCategory(shareToIds);
        }

        System.debug('updateAccounts=>' + updateAccounts.size());
        if(updateAccounts.size() > 0){
            update updateAccounts;
        }


    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method to Share all QC Accounts belong to Account to Sale.
    * @return   void
    *********************************************************************************************************/
    public static Map<String, List<QC_Account__c>> shareQCAccounts(List<Client_Sharing__c> listNewRec){
        Map<String, List<QC_Account__c>> mapCL = new Map<String, List<QC_Account__c>>();
        Map<String, List<QC_Account__c>> mapQC = new Map<String, List<QC_Account__c>>();
        List<QC_Account__Share> insertQCAccountShare = new List<QC_Account__Share>();
        Client_Sharing_Setting__mdt dfSetting = Client_Sharing_Setting__mdt.getInstance('default');
        Set<String> accIds = new Set<String>();
        

        for(Client_Sharing__c cl : listNewRec){
            accIds.add(cl.Account__c);
        }
        
        for(QC_Account__c qc: [SELECT Id,AccountOwner__c, Industry__c, 
                                Sales__c,Sales__r.Manager_Level__c, Sales__r.ManagerId, Sales__r.Manager.Manager_Level__c  
                                FROM QC_Account__c WHERE AccountOwner__c IN :accIds]){
            if(mapQC.containsKey(qc.AccountOwner__c)){
                mapQC.get(qc.AccountOwner__c).add(qc);
            }else {
                mapQC.put(qc.AccountOwner__c, new List<QC_Account__c>{qc});
            }
        }

        for(Client_Sharing__c cl : listNewRec){         
            List<QC_Account__c> listQCs = mapQC.get(cl.Account__c);
            if(listQCs != null){
                for(QC_Account__c qc : listQCs){
                    QC_Account__Share addShr = new QC_Account__Share();
                    addShr.AccessLevel = dfSetting.QCAccessLevel__c;
                    addShr.ParentId = qc.Id;
                    addShr.RowCause = Schema.QC_Account__Share.RowCause.Client_Sharing__c ;
                    addShr.UserOrGroupId = cl.Share_To__c;   
                    insertQCAccountShare.add(addShr); 
                }

                mapCL.put(cl.Id, listQCs);
            }
        }        

        if(insertQCAccountShare.size() > 0){
            insert insertQCAccountShare;
        }

        return mapCL;
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method to Create Client Sharing Detail record for each QC Account.
    * @return   void
    *********************************************************************************************************/
    public static void createClientSharingDetailRec(Map<String, List<QC_Account__c>> mapCL){
        List<Client_Sharing_Detail__c> insertCLD = new List<Client_Sharing_Detail__c>();

        if(mapCL.size() > 0){
            for(String liId : mapCL.keySet()){
                List<QC_Account__c> listQCs = mapCL.get(liId);
                if(listQCs != null){
                    for(QC_Account__c qc : listQCs){
                        Client_Sharing_Detail__c cld = new Client_Sharing_Detail__c();
                        cld.QC_Account__c = qc.Id;
                        cld.Client_Sharing__c = liId;
                        insertCLD.add(cld); 
                    }
                }
            }
        }

        if(insertCLD.size() > 0){
            insert insertCLD;
        }
    }   

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 20
    * @description   Method to Create Account Team for Shared Sale.
    * @return   void
    *********************************************************************************************************/
    public static void stopSharingClient(List<Client_Sharing__c> listNewRec){
        List<AccountTeamMember> deleteAccountTeam = new List<AccountTeamMember>();  
        List<QC_Account__Share> deleteQCAccShare = new List<QC_Account__Share>();   
        Map<String, String> mapAccvsSale = new Map<String, String>();
        Map<String, String> mapQCvsSale = new Map<String, String>();
        Map<String, List<QC_Account__c>> mapCL = new Map<String, List<QC_Account__c>>();
        Set<String> clIds = new Set<String>();
        Set<String> shareToIds = new Set<String>();
        Client_Sharing_Setting__mdt dfSetting = Client_Sharing_Setting__mdt.getInstance('default');        

        for(Client_Sharing__c cl : listNewRec){
            mapAccvsSale.put(cl.Account__c, cl.Share_To__c);
            clIds.add(cl.Id);
            shareToIds.add(cl.Share_To__c);
        }

        for(AccountTeamMember del : [SELECT Id, UserId,AccountId FROM AccountTeamMember WHERE AccountId IN :mapAccvsSale.keySet() AND TeamMemberRole = :dfSetting.TeamMemberRole__c]){
            if(mapAccvsSale.get(del.AccountId) != null && mapAccvsSale.get(del.AccountId) == del.UserId){
                deleteAccountTeam.add(del);                
            }
        }

        for(Client_Sharing_Detail__c  cld: [SELECT Id, QC_Account__c, Client_Sharing__r.Share_to__c  FROM Client_Sharing_Detail__c WHERE Client_Sharing__c IN :clIds]){
            mapQCvsSale.put(cld.QC_Account__c, cld.Client_Sharing__r.Share_to__c);
        }

        for(QC_Account__Share del : [SELECT Id, UserOrGroupId, ParentId FROM QC_Account__Share WHERE ParentId IN :mapQCvsSale.keySet() AND RowCause = 'Client_Sharing__c']){
            if(mapQCvsSale.get(del.ParentId) != null && mapQCvsSale.get(del.ParentId) == del.UserOrGroupId){
                deleteQCAccShare.add(del);                
            }
        }
        
        System.debug('deleteAccountTeam=>' + deleteAccountTeam.size());
        if(deleteAccountTeam.size() > 0){
            delete deleteAccountTeam;
        }

        System.debug('deleteQCAccShare=>' + deleteQCAccShare.size());
        if(deleteQCAccShare.size() > 0){
            update deleteQCAccShare;
        }

        System.debug('shareToIds=>' + shareToIds.size());
        if(shareToIds.size() > 0){
            updateCrossSellingCategory(shareToIds);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method to detect KPI Categories and update to User.
    * @return   void
    *********************************************************************************************************/
    public static void updateCrossSellingCategory(Set<String> shareToIds){            
        Map<String,Set<String>> mapCrossSellingKpiCat = new Map<String,Set<String>>();            

        for( Client_Sharing_Detail__c cl: [SELECT Id, QC_Account__r.Industry__c, 
                                            Client_Sharing__r.Share_To__c, Client_Sharing__r.Share_To__r.Manager_Level__c, Client_Sharing__r.Share_To__r.ManagerId,
                                            QC_Account__r.Sales__c, QC_Account__r.Sales__r.Manager_Level__c, 
                                            QC_Account__r.Sales__r.ManagerId, QC_Account__r.Sales__r.Manager.Manager_Level__c
                                            ,Client_Sharing__r.Share_To__r.Sale_Team__c                                       
                                            FROM Client_Sharing_Detail__c 
                                            WHERE Client_Sharing__r.Share_To__c IN :shareToIds                                            
                                            AND Client_Sharing__r.Status__c = :ClientSharingConstant.STATUS_IN_PROGRESS
                                            ]){                                       
            if(!String.isBlank(cl.QC_Account__r.Industry__c)){
                String KPICat;
                if(cl.QC_Account__r.Industry__c == 'Retails' || cl.QC_Account__r.Industry__c == 'FMCG'){
                    KPICat = 'FMCG-Retails';
                }else{
                    KPICat = cl.QC_Account__r.Industry__c.trim();
                }

                //Share client from Sale to other Sale Manager
                if(!String.isBlank(cl.Client_Sharing__r.Share_To__r.Manager_Level__c) && String.isBlank(cl.QC_Account__r.Sales__r.Manager_Level__c)){
                    if(cl.QC_Account__r.Sales__r.ManagerId != cl.Client_Sharing__r.Share_To__c){
                        if(mapCrossSellingKpiCat.containsKey(cl.Client_Sharing__r.Share_To__c)){
                            mapCrossSellingKpiCat.get(cl.Client_Sharing__r.Share_To__c).add(KPICat);
                        }else {
                            mapCrossSellingKpiCat.put(cl.Client_Sharing__r.Share_To__c,new Set<String>{KPICat});
                        }
                    }
                //Share client from Sale Manager to other Sale
                }else if(String.isBlank(cl.Client_Sharing__r.Share_To__r.Manager_Level__c) && !String.isBlank(cl.QC_Account__r.Sales__r.Manager_Level__c)){
                    if(cl.QC_Account__r.Sales__c != cl.Client_Sharing__r.Share_To__r.ManagerId){
                        if(mapCrossSellingKpiCat.containsKey(cl.Client_Sharing__r.Share_To__c)){
                            mapCrossSellingKpiCat.get(cl.Client_Sharing__r.Share_To__c).add(KPICat);
                        }else {
                            mapCrossSellingKpiCat.put(cl.Client_Sharing__r.Share_To__c,new Set<String>{KPICat});
                        }
                    }
                //Share client from Sale Manager to other Sale Manager
                }else if(!String.isBlank(cl.Client_Sharing__r.Share_To__r.Manager_Level__c) && !String.isBlank(cl.QC_Account__r.Sales__r.Manager_Level__c)){
                    if(mapCrossSellingKpiCat.containsKey(cl.Client_Sharing__r.Share_To__c)){
                        mapCrossSellingKpiCat.get(cl.Client_Sharing__r.Share_To__c).add(KPICat);
                    }else {
                        mapCrossSellingKpiCat.put(cl.Client_Sharing__r.Share_To__c,new Set<String>{KPICat});
                    }
                //Share client from Sale to other Sale
                }else {
                    if(cl.QC_Account__r.Sales__r.ManagerId != cl.Client_Sharing__r.Share_To__r.ManagerId){
                        if(mapCrossSellingKpiCat.containsKey(cl.Client_Sharing__r.Share_To__c)){
                            mapCrossSellingKpiCat.get(cl.Client_Sharing__r.Share_To__c).add(KPICat);
                        }else {
                            mapCrossSellingKpiCat.put(cl.Client_Sharing__r.Share_To__c,new Set<String>{KPICat});
                        }
                    }
                }
            }    
        }        

        if(mapCrossSellingKpiCat.size() > 0){
            updateUser(mapCrossSellingKpiCat);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2022 Jan 17
    * @description   Method to Update user's kpi information
    * @return   void
    *********************************************************************************************************/
    public static void updateUser(Map<String,Set<String>> mapCrossSellingKpiCat){
        List<User> userToUpdate = new List<User>();

        for(User us : [SELECT Id, Sale_Team__c, KPI_Category__c,Cross_Selling_KPI_Category__c
                        FROM User 
                        WHERE Id IN :mapCrossSellingKpiCat.keySet()
                        AND Sale_Team__c = :KPIConstant.SALE_TEAM_DIRECT]){

            Set<String> crossSelling_Cat = mapCrossSellingKpiCat.get(us.Id); 
            String crossSellingCat = '';   
            if(crossSelling_Cat != null){
                crossSellingCat = String.join(new List<String>(crossSelling_Cat), ';');
                User upUs = new User();
                upUs.Id = us.Id;
                upUs.Cross_Selling_KPI_Category__c = crossSellingCat;
                userToUpdate.add(upUs);    
            }                        
        }
       
        if(userToUpdate.size() > 0){
            update userToUpdate;
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method to validate Date Period should not be conflict with other Client Sharing request.
    * @return   void
    *********************************************************************************************************/
    public static void checkValidDate(List<Client_Sharing__c> listNewRec,Set<String> accIds){
        Map<String,List<Client_Sharing__c>> mapCl = new Map<String,List<Client_Sharing__c>>();
        Set<String> setStatus = new Set<String>{ClientSharingConstant.STATUS_WAITING_FOR_APPROVAL, ClientSharingConstant.STATUS_IN_PROGRESS, ClientSharingConstant.STATUS_COMPLETED};
        Set<String> newIds = new Set<String>();
        for(Client_Sharing__c newCl : listNewRec){
            newIds.add(newCl.Id);
        }

        for(Client_Sharing__c currCl : [SELECT Id, Account__c,  Share_To__c, Start_date__c, End_date__c, Share_type__c
                                            FROM Client_Sharing__c 
                                            WHERE Account__c IN :accIds
                                            AND Id NOT IN :newIds
                                            AND Status__c IN :setStatus]){

            if(mapCl.containsKey(currCl.Account__c)){
                mapCl.get(currCl.Account__c).add(currCl);
            }else {
                mapCl.put(currCl.Account__c, new List<Client_Sharing__c>{currCl});
            }
        }

        for(Client_Sharing__c cl : (List<Client_Sharing__c>)Trigger.new){
            if(!String.isBlank(cl.Account__c)){                    
                List<Client_Sharing__c> listCl = mapCl.get(cl.Account__c);

                if(listCl != null){
                    for(Client_Sharing__c currCL : listCl){
                        if(currCL.Share_type__c == cl.Share_type__c){
                            if( cl.Start_date__c >= currCL.Start_date__c && cl.Start_date__c <= currCL.End_date__c){
                                cl.addError('Start date must not be in other Sharing request');
                            }else if( cl.End_date__c >= currCL.Start_date__c && cl.End_date__c <= currCL.End_date__c){
                                cl.addError('End date must not be in other Sharing request');
                            }else if( cl.Start_date__c < currCL.Start_date__c && cl.End_date__c > currCL.End_date__c){
                                cl.addError('This Client is sharing for other request. Please re-select you Start date and End Date');
                            }
                        }
                    }
                }
            }
        } 
    }
}