global class cc_QcAccountChatterBatch implements Database.AllowsCallouts,Database.Batchable<sObject>,Database.Stateful{
    List<cc_ChatterBatchWrapper> feedItemInsertList {get;set;}
    public cc_QcAccountChatterBatch(List<cc_ChatterBatchWrapper> feedItemInsertTempList  ) {
        feedItemInsertList = feedItemInsertTempList;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){        
        return database.getqueryLocator([select id from account limit 1]);
    } 
    global  void execute(Database.BatchableContext BC, List<Account> acc){
        set<id> userIdSet = new Set<id>();
        for(cc_ChatterBatchWrapper item: feedItemInsertList){
            if(item.idList != null && item.idList.size() > 0 )
            	userIdSet.add(item.idList.get(0));
        }
        Map<id, user> userMap= new map<id,user>([select id, name,IsActive from user where id in: userIdSet]);
        for(cc_ChatterBatchWrapper item: feedItemInsertList){
            if( item.isEmail != true){
                if( userMap.containskey(item.idList.get(0)) ){
                    User us = userMap.get(item.idList.get(0));
                    if( us != null && us.IsActive == false)
                        continue;
                }
                cc_Util.initChatter(item.idList[0], item.recordId, item.message);
            }
            else{
                cc_SendEmail.sendEmail(item.toEmail,item.title, item.body, item.key);
            }
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}