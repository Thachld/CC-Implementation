public without Sharing class cc_QC_AccountHelper {
    public class cc_QCAccountStreaming_Wrapper{
        public String Id {get;set;}
        public String Name {get;set;}
        public String QC_Account_Id {get;set;}
        public String Sales {get;set;}
        public String Sale_Email {get;set;}
        public String Support {get;set;}
        public String Support_Email {get;set;}
        public String Industry {get;set;}
    }

    public class cc_QCAccount_Share_Wraper{
        public String QCAccount {get;set;}
        public String NewSupport {get;set;}
        public String OldSupport {get;set;}
    }

    public class cc_QCAccountOwner_Wrapper{
        public String QCAccount {get;set;}
        public String newOwner {get;set;}
        public String oldOwner {get;set;}
    }

    public class cc_AccountTeam_Wraper {
        public String Support {get;set;}
        public String AccountOwner {get;set;}
    }

    //Update QC Account Team
    public static void attemptAddAccountTeam(String params){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnAddAccountTeam(params);
        }else {
            attemptSycnAddAccountTeam(params);
        }
    }

    //Update QC Account manual Sharing
    public static void attemptUpdateQCAccountShare(String params){
        // if(!System.isBatch() && !System.isFuture()){
        //     attemptAsycnUpdateQCAccountShare(params);
        // }else {
        //     attemptSycnUpdateQCAccountShare(params);
        // }

        attemptSycnUpdateQCAccountShare(params);
    }

    //Update QC Account manual Sharing
    public static void attemptDeleteQCAccountShare(Set<String> shareIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnDeleteQCAccountShare(shareIds);
        }else {
            attemptSycnDeleteQCAccountShare(shareIds);
        }       
    }


    //Update Account Owner Start Date
    public static void attemptUpdateAccountStartDate(Set<String> accIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnUpdateAccount(accIds);
        }else {
            attemptSycnUpdateAccount(accIds);
        }
    }

    //Update QC Owner
    // public static void attemptUpdateQCOwner(String params){
    //     if(!System.isBatch() && !System.isFuture()){
    //         attemptAsycnUpdateQCOwner(params);
    //     }else {
    //         attemptSycnUpdateQCOwner(params);
    //     }
    // }

    // @future
    // public static void attemptAsycnUpdateQCOwner(String params){
    //     attemptSycnUpdateQCOwner(params);
    // }

    // public static void  attemptSycnUpdateQCOwner(String params){
    //     Map<Id,user> userMap;        

    //     Set<String> usIds = new Set<String>();
    //     List<QC_Account__c> updateQC = new List<QC_Account__c>();
    //     List<cc_QCAccountOwner_Wrapper> owners = (List<cc_QCAccountOwner_Wrapper>)JSON.deserialize(params, List<cc_QCAccountOwner_Wrapper>.class);
    //     System.debug('params = >' + owners);

    //     for(cc_QCAccountOwner_Wrapper owner: owners){
    //         if(!String.isBlank(owner.newOwner)){
    //             usIds.add(owner.newOwner);
    //         }

    //         if(!String.isBlank(owner.oldOwner)){
    //             usIds.add(owner.oldOwner);
    //         }
    //     }
        
    //     userMap = new Map<ID, User>([SELECT Id,QC_Email__c,ProfileId, Profile.Name, isActive  FROM User WHERE Id IN :usIds AND isActive = true]);   
    //     for(cc_QCAccountOwner_Wrapper owner: owners){
    //         QC_Account__c qcAcc = new QC_Account__c();
    //         qcAcc.Id = owner.QCAccount;
    //         qcAcc.Sales__c = owner.newOwner; 
    //         qcAcc.OwnerId = owner.newOwner; 
            
    //         User us = userMap.get(owner.newOwner);
    //         if( us != null){
    //             qcAcc.Sale_Email__c = us.QC_Email__c;        
    //         }              
            
    //         updateQC.add(qcAcc);
    //     }

    //     System.debug('updateQC = >' + updateQC);
    //     if(updateQC.size() > 0){            
    //         database.update(updateQC, false);        

    //     }
    // }


    @future
    public static void attemptAsycnAddAccountTeam(String params){
        attemptSycnAddAccountTeam(params);
    }


    public static void  attemptSycnAddAccountTeam(String params){
        
        List<AccountTeamMember> listAccTeamToInsert = new List<AccountTeamMember>();
        List<cc_AccountTeam_Wraper> teams = (List<cc_AccountTeam_Wraper>)JSON.deserialize(params, List<cc_AccountTeam_Wraper>.class);
        System.debug('params = >' + params);
        
        for(cc_AccountTeam_Wraper team: teams){
            AccountTeamMember teamAccountTemp = cc_Util.initTeamAccount(team.AccountOwner, team.Support, 'Ad Op Manager');
            listAccTeamToInsert.add(teamAccountTemp);
        }
        System.debug('listAccTeamToInsert = >' + listAccTeamToInsert);
        if(listAccTeamToInsert.size() > 0){            
            database.insert(listAccTeamToInsert, false);
            // insert listAccTeamToInsert;
        }
    }

    @future
    public static void attemptAsycnUpdateQCAccountShare(String params){
        attemptSycnUpdateQCAccountShare(params);
    }

    public static void attemptSycnUpdateQCAccountShare(String params){
        List<QC_Account__Share> insertList = new List<QC_Account__Share>();
        Set<String> deleteIds = new Set<String>();
        List<FeedItem> feedItemList = New List<FeedItem>();
        Set<String> qcIds = new Set<String>();
        Map<String,QC_Account__Share> mapShare = new Map<String,QC_Account__Share>();

        List<cc_QCAccount_Share_Wraper> shares = (List<cc_QCAccount_Share_Wraper>)JSON.deserialize(params, List<cc_QCAccount_Share_Wraper>.class);        
        
        for(cc_QCAccount_Share_Wraper shr : shares){
            qcIds.add(shr.QCAccount);
        }

        for(QC_Account__Share qcshare : [SELECT Id, AccessLevel, RowCause, parentId, Parent.name, UserOrGroupId  FROM QC_Account__Share WHERE parentId IN :qcIds ]){
            String key = qcshare.parentId + '###' + qcshare.UserOrGroupId;
            if (!mapShare.containsKey(key)){
                mapShare.put(key, qcshare);
            }
        }

        for(cc_QCAccount_Share_Wraper shr : shares){
            if(!String.isBlank(shr.NewSupport)){
                String addkey = shr.QCAccount + '###' + shr.NewSupport;
                if(!mapShare.containsKey(addkey)){
                    QC_Account__Share addShr = new QC_Account__Share();
                    addShr.AccessLevel = 'Edit';
                    addShr.ParentId = shr.QCAccount;
                    addShr.RowCause = Schema.QC_Account__Share.RowCause.Support__c ;//'Support';
                    addShr.UserOrGroupId = shr.NewSupport;               

                    insertList.add(addShr);
                }
            }
            

            if(!String.isBlank(shr.OldSupport)){
                String delkey = shr.QCAccount + '###' + shr.OldSupport;
                if(mapShare.containsKey(delkey)){
                    QC_Account__Share delShr = mapShare.get(delkey);
                    if(delShr != null){
                        if(mapShare.get(delkey).RowCause == 'Support__c' || mapShare.get(delkey).RowCause == 'Manual'){                       
                            deleteIds.add(delShr.Id);

                            FeedItem post = new FeedItem();
                            post.ParentId = delShr.UserOrGroupId;
                            post.Body = 'Your permission in ' + delShr.Parent.name + ' have just removed by ' + UserInfo.getName();
                            post.Title = 'QC Account Permission';
                            feedItemList.add(post);      
                        }
                    }     
                }
            }
            
            
        }

        System.debug('insertList =>' + insertList);
        if(insertList.size() > 0){
            Database.insert(insertList, false) ;
        }

        System.debug('deleteIds =>' + deleteIds);
        if(deleteIds.size() > 0){
            attemptDeleteQCAccountShare(deleteIds);
        }

        System.debug('feedItemList =>' + feedItemList);
        if(feedItemList.size() > 0){            
            Database.insert(feedItemList, false) ;
        }

    } 


    @future
    public static void attemptAsycnDeleteQCAccountShare(Set<String> shareIds){
        attemptSycnDeleteQCAccountShare(shareIds);
    }


    public static void attemptSycnDeleteQCAccountShare(Set<String> shareIds){
        List<QC_Account__Share> deletelist = new List<QC_Account__Share>();
        try{

        
            for(String delId: shareIds){
                QC_Account__Share share = new QC_Account__Share();
                share.Id = delId;

                deletelist.add(share);
            }

            if(deletelist.size() > 0){
                Database.delete(deletelist, false);
            }
        }catch (Exception ex){

        }

    }


    @future
    public static void attemptAsycnUpdateAccount(Set<String> accIds){
        attemptSycnUpdateAccount(accIds);
    }


    public static void attemptSycnUpdateAccount(Set<String> accIds){
        List<Account> accList = [SELECT Id, (SELECT Id,Register_time__c 
                                    FROM QC_Accounts__r ORDER BY Register_time__c  ASC limit 1) 
                                    FROM Account
                                    WHERE Id IN :accIds];

        for(Account acc: accList){

            if(acc.QC_Accounts__r != null){

                if(acc.QC_Accounts__r.size() >0){
                    acc.Start_date__c = acc.QC_Accounts__r.get(0).Register_time__c;
                }

                if(acc.QC_Accounts__r.size() == 0){
                    acc.Start_date__c = null;
                }
            }
        }   
            
        update accList;      
        
    }

    //publist QCAccountStreaming__e Platform Event
    public static void publishQCAccount(List<cc_QCAccountStreaming_Wrapper> evntMsg){        
        List<QCAccountStreaming__e> evts = new List<QCAccountStreaming__e>();
        for(cc_QCAccountStreaming_Wrapper msg:  evntMsg){
            QCAccountStreaming__e evt = new QCAccountStreaming__e();
            evt.Id__c = msg.Id;
            evt.Name__c = msg.Name;
            evt.QC_Account_Id__c = msg.QC_Account_Id;
            evt.Sales__c = msg.Sales;
            evt.Sale_Email__c = msg.Sale_Email;
            evt.Support__c = msg.Support;
            evt.Support_Email__c = msg.Support_Email;
            evt.Industry__c = msg.Industry;
            evts.add(evt);
        }        

        if(evts.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(evts);
            List<Error_log__c> logs = new List<Error_log__c>();

            for (Database.SaveResult sr : results) {
                if (!sr.isSuccess()) {      
                    Error_log__c error = new Error_log__c();
                    error.name = 'Publish QCAccountStreaming'; 

                    String description = 'Error returned: ';
                    for(Database.Error err : sr.getErrors()) { 
                        description = description  + '  /r/n' + err.getStatusCode() +' - ' + err.getMessage();                        
                    }

                    error.error_description__c = description;
                    logs.add(error);
                }
            }


            if(logs.size() > 0){
                insert logs;
            }
        }
    }
}