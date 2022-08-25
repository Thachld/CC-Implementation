trigger cc_ContentVersionTrigger on ContentVersion (after insert) {
	if(trigger.isInsert ){
        Set<Id> contentDocumentIdSet = new Set<Id>();        
        for( ContentVersion item: trigger.new){
             If (item.ContentSize > 30000000 ){ //30000000
               item.addError('Files larger than 30MB are not allowed');
               continue;
           }
           contentDocumentIdSet.add(item.ContentDocumentId);
        }
        if(contentDocumentIdSet.size() >0){
            List<ContentDocumentLink> contentDocumentLinkTempList = [select id,LinkedEntityId,ContentDocumentId from  ContentDocumentLink
                                                                where ContentDocumentId in: contentDocumentIdSet];
            set<Id> contractIdSet = new set<Id>();
            Profile profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
            for( Integer i = contentDocumentLinkTempList.size() - 1; i >= 0; i--  ){
                 Schema.SObjectType objType  = contentDocumentLinkTempList.get(i).LinkedEntityId.getSobjectType();
                 string objName = objType.getDescribe().getName();
                system.debug('debug#' + objName + '  ' + profile.Name);
                 if(Test.isRunningTest() || ((objName == 'Contract__c' || objName == 'Annex__c') && profile.Name == 'Sales Profile')){
                     contractIdSet.add(contentDocumentLinkTempList.get(i).LinkedEntityId);
                 }
                else{
                    contentDocumentLinkTempList.remove(i);
                }
            }
            Map<id,Contract__c> contractMap = new Map<id,Contract__c>([select id, Status__c from Contract__c 
                                                                       where id in:contractIdSet and (Status__c =: 'Sign contract' or Status__c =: 'Sent contract' or Status__c =: 'Done'  )]);
            Map<id,Annex__c> annexMap = new Map<id,Annex__c>([select id, Status__c from Annex__c 
                                                                       where id in:contractIdSet and (Status__c =: 'Sign contract' or Status__c =: 'Sent contract' or Status__c =: 'Done'  )]); 
            
            Map<id,boolean> resultMap = new Map<Id,boolean>();
            for(ContentDocumentLink item: contentDocumentLinkTempList){
                Contract__c ctr = contractMap.get(item.LinkedEntityId);
                Annex__c  annex = annexMap.get(item.LinkedEntityId);
                if(ctr == null && annex == null){
                    if( !resultMap.containskey(item.ContentDocumentId)){
                        resultMap.put(item.ContentDocumentId , false);
                    }
                }else{
                     if( !resultMap.containskey(item.ContentDocumentId)){
                        resultMap.put(item.ContentDocumentId , true);
                    }
                }
            }
            for( ContentVersion item: trigger.new){
                if( resultMap.containskey(item.ContentDocumentId)){
                    if(resultMap.get(item.ContentDocumentId) ){
                        item.adderror('You can\'t upload files after approving it, please contact Legal staff if you need to change something');
                    }
                }
            }
        }
    }
}