public with sharing class cc_LeadTriggerHandler implements cc_ITrigger{
    
    List<QC_Account__c> qcAccountUpdateList = new List<QC_Account__c>();    
    List<cc_LeadTriggerHelper.CombineWrapper> combineList = new List<cc_LeadTriggerHelper.CombineWrapper>();
    List<cc_ChatterBatchWrapper> chatterPosts = new List<cc_ChatterBatchWrapper>();

    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isUpdate

        if(Trigger.isUpdate){            
            Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.oldMap;
            Map<String,Id> mapowners = new Map<String,Id>();
            List<Owner__mdt> listowners = [SELECT Id, Label, ID__c, DeveloperName FROM Owner__mdt];
            for (Owner__mdt owner:listowners){
                mapowners.put (owner.Label,owner.ID__c);
            }

            Id hotlineid = mapowners.get('Hotline');

            for(Lead newLead : (List<Lead>)Trigger.new){                
                Lead oldLead = oldMap.get(newLead.Id);

                if (oldLead.Industry_c__c != newlead.Industry_c__c 
                    && !String.isBlank(newLead.Industry_c__c) 
                    && newlead.OwnerId == hotlineid 
                    && newlead.LeadSource == 'DMP'
                    && !String.isBlank(mapowners.get(newlead.Industry_c__c)) ){
                        newlead.ownerid = mapowners.get(newlead.Industry_c__c);
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

        if(Trigger.isUpdate){

            Set<String> qcIds = new Set<String>();
            Map<String,qc_Account__c> mapQCAcc = new Map<String,qc_Account__c>();

            Map<Id,Lead> newMap = (Map<Id,Lead>)Trigger.newMap;
            Map<Id,Lead> oldMap = (Map<Id,Lead>)Trigger.oldMap;

            for(Lead newLead : newMap.values()){
                if(!String.isBlank(newLead.QC_Account_Id__c)){
                    qcIds.add((newLead.QC_Account_Id__c));
                }
            }

            //Get Map existing QC Account
            for(QC_Account__c qc: [SELECT Id,name, QC_Account_Id__c,Industry__c, Support__c, OwnerId
                                        FROM QC_Account__c 
                                        WHERE QC_Account_Id__c IN : qcIds]){
                if(!String.isBlank(qc.QC_Account_Id__c)){
                    mapQCAcc.put(qc.QC_Account_Id__c,qc);
                }                            
            }


            for(Lead newLead : newMap.values()){
                Lead oldLead = oldMap.get(newlead.Id);
                QC_Account__c qcAccExist = mapQCAcc.get(newLead.QC_Account_Id__c);                
                Boolean isUpdateQcAccount = false;

                if(qcAccExist != null){

                    //Converted Lead
                    //System.debug('newLead.IsConverted=>' + newLead.IsConverted + ' oldLead.IsConverted=>' + oldLead.IsConverted);
                    
                    if( oldLead.IsConverted == false && newLead.IsConverted == true && !String.isBlank( newLead.QC_Account_Id__c)){     
                        
                        //Get combine for creating Relationship
                        cc_LeadTriggerHelper.CombineWrapper combine = new cc_LeadTriggerHelper.CombineWrapper();
                        combine.accountId = newLead.ConvertedAccountId;
                        combine.qc_account_Id = qcAccExist.Id;
                        combineList.add(combine);

                        //Update value for existing QC Account
                        isUpdateQcAccount = false;
                        qcAccExist.OwnerId = newLead.ownerId;
                        qcAccExist.Industry__c = newLead.Industry_c__c;  

                        //Initiate chatter post to Support User
                        if( !String.isBlank(qcAccExist.Support__c )){
                            cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
                            post.idList.add(qcAccExist.Support__c);
                            post.message = ' This account has been assigned to you. Please take care customer';
                            post.recordid = qcAccExist.id;
                            chatterPosts.add(post);
                        }
                    }   
                
                    //Changed Lead Owner
                    if(newLead.OwnerId != oldLead.OwnerId && newLead.OwnerId != qcAccExist.OwnerId){
                        qcAccExist.OwnerId = newLead.ownerId;  
                        isUpdateQcAccount = true;
                    }
                }
                
                if(isUpdateQcAccount){
                    qcAccountUpdateList.add(qcAccExist);
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

        //update existing QC Account
        if(qcAccountUpdateList.size() >0){
            Database.update(qcAccountUpdateList, false);
        }
        
        //attemp create relationship
        if(combineList.size() > 0){
            String params = JSON.serialize(combineList);
            cc_LeadTriggerHelper.attemptCreateRelationShip(params);
        }


        //Post chatter to notify Support about new QC account assignment
        //System.debug('chatterPosts=>' + chatterPosts.size());
        if( chatterPosts.size() > 0 ){
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();            
            for(cc_ChatterBatchWrapper item: chatterPosts){                            
                ConnectApi.FeedItemInput feedItemInput = cc_Util.genChatterwithMetion(item.idList[0], item.recordId, item.message);
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);   
                batchInputs.add(batchInput);
            }
            if(batchInputs.size() > 0)
            {
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
            }
        }
    }     
}