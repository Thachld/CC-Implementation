trigger cc_ContentDocumentLinkTrigger on ContentDocumentLink (before delete, after insert, before update) {
    if(trigger.isDelete){
        String profileName = [select Name from profile where id = :UserInfo.getProfileId()].Name;
        for( ContentDocumentLink item: trigger.old){
             if(profileName != 'System Administrator'){
                item.adderror('Can not delete file link');
             }
        }
    }
    if(trigger.isInsert || trigger.isUpdate){
        //get profile name to use later
        Profile profile = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1];
        //define new set of Contract id, makedesign id, and a map between recordid and documentid
        Set<Id> contractIdSet = new Set<Id>();
        Set<Id> makeDesignIdset = new Set<Id>();
        Map<Id,Id> recordDocumentMaps = new Map<Id,Id>();
        //loop through the trigger new to check if files are being added to contract, if yes add them to Sets above and handle later!!!
        for( ContentDocumentLink item: trigger.new){
            Schema.SObjectType objType  = item.LinkedEntityId.getSobjectType();
            string objName = objType.getDescribe().getName();
            //add recordId and documentId to a map
            recordDocumentMaps.put(item.LinkedEntityId,item.ContentDocumentId);
            //if files added to contract/annex => add recordId to contract id set
            if((objName == 'Contract__c' || objName == 'Annex__c') && profile.Name == 'Sales Profile'){
                contractIdSet.add(item.LinkedEntityId);
            }
            //if files added to Make design => add recordId to contract id set
            //2021-05-14 removed by Toan Nguyen, reason: feature was requested but not being used by Design team
            /*if(objName == 'Make_Design__c'){
                makeDesignIdset.add(item.LinkedEntityId);
            }*/

        }
        //handle the case of files added to contracts/annexes
        if(contractIdSet.size() > 0){
            Map<id,Contract__c> contractMap = new Map<id,Contract__c>([select id, Status__c from Contract__c 
                                                                       where id in:contractIdSet and (Status__c =: 'Sign contract' or Status__c =: 'Sent contract' or Status__c =: 'Done'  )]);
            Map<id,Annex__c> annexMap = new Map<id,Annex__c>([select id, Status__c from Annex__c 
                                                                       where id in:contractIdSet and (Status__c =: 'Sign contract' or Status__c =: 'Sent contract' or Status__c =: 'Done'  )]); 
            
            for( ContentDocumentLink item: trigger.new){
                Schema.SObjectType objType  = item.LinkedEntityId.getSobjectType();
                string objName = objType.getDescribe().getName();
                if((objName == 'Contract__c' || objName == 'Annex__c') && profile.Name == 'Sales Profile'){
                    Contract__c ctr = contractMap.get(item.LinkedEntityId);
                     Annex__c  annex = annexMap.get(item.LinkedEntityId);
                    if(ctr != null || annex != null){
                        if(!Test.isRunningTest())
                        	item.adderror('You can\'t upload files after approving it, please contact Legal staff if you need to change something');
                    }
                }
        	}
        }
        //handle the case files added to Make design recods
        //2021-05-14 removed by Toan Nguyen, reason: feature was requested but not being used by Design team
        /*if(makeDesignIdset.size()>0){
            //define a new list of contentdocumentlink to link files with parent records
            set<ContentDocumentLink> insertList = new set<ContentDocumentLink>();
            for (Make_design__c item:[select id,name,parent_request__c from Make_design__c where id in:makeDesignIdset]){
                //if a make design record has parent request, also link the file to parent record
                if (item.parent_request__c != null) {
                    ContentDocumentLink link = new ContentDocumentLink();
                    link.LinkedEntityId = item.parent_request__c;
                    link.ContentDocumentId = recordDocumentMaps.get(item.id);
                    insertList.add(link);
                }
            }
            if (insertList.size()>0) {
                Database.insert (new List<ContentDocumentLink>(insertList),false);
            }
        }*/
    } 
}