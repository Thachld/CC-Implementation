public with sharing class cc_HandOverMinute_Handler implements  cc_ITrigger{     
    //Set<String> contractIdSet = new Set<String>();
    //cc_setting__c setting = cc_Util.getCustomSetting();
    //Id currentUserId = UserInfo.getUserId();
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
        if(Trigger.isInsert){
            Map<Id,Set<String>> mapCons = new Map<Id,Set<String>>();
            set<id> accountIdSet = new Set<Id>();
            for(HandOver_Minute__c hom : (List<HandOver_Minute__c>)Trigger.new){
                accountIdSet.add(hom.Account__c);
            }
            
            //Map<ID, Account> accMap  = new Map<ID, Account>([SELECT Id, ownerId FROM Account WHERE Id IN: accountIdSet]);

            for(Contract__c con : [SELECT Id, Account__c FROM Contract__c WHERE Account__c IN :accountIdSet]){
                if(mapCons.containsKey(con.Account__c)){
                    mapCons.get(con.Account__c).Add(con.Id);
                }else{
                    mapCons.put(con.Account__c, new Set<String>{con.Id});
                }
            }

            for(HandOver_Minute__c hom : (List<HandOver_Minute__c>)Trigger.new){               

                //2021.06.22 removed by Toan Nguyen
                //Reason: move logic to Flows. 
                //Document: https://coccoc.atlassian.net/wiki/spaces/BI/pages/1827078455/Handover+Minute+Flow
                /*Account acc = accMap.get(hom.Account__c);
                if(acc != null && acc.OwnerId != hom.OwnerId && !Test.isRunningTest()){
                    hom.OwnerId = acc.OwnerId;
                }

                if(String.isBlank(hom.Assign_to__c)){
                    hom.Assign_to__c = setting.Hom_assign__c;
                }*/
                    
                if(String.isBlank(hom.Custom_Contract__c)){
                    if(!String.isBlank(hom.Account__c)){
                        Set<String> conIds = mapCons.get(hom.Account__c) == null? New Set<String>(): mapCons.get(hom.Account__c);
                        if(conIds.size() > 0){
                            hom.addError('Please Select Contract beforce Create HOM');
                            continue;
                        }
                    }                    
                }
            }
        //isUpdate
        }else if(Trigger.isUpdate){
            Map<Id,Set<String>> mapCons = new Map<Id,Set<String>>();
            set<id> accountIdSet = new Set<Id>();           

            for(HandOver_Minute__c hom : (List<HandOver_Minute__c>)Trigger.new){
                accountIdSet.add(hom.Account__c);
            }

            //Map<ID, Account> accMap  = new Map<ID, Account>([SELECT Id, ownerId FROM Account WHERE Id IN: accountIdSet]);

            for(Contract__c con : [SELECT Id, Account__c FROM Contract__c WHERE Account__c IN :accountIdSet]){
                if(mapCons.containsKey(con.Account__c)){
                    mapCons.get(con.Account__c).Add(con.Id);
                }else{
                    mapCons.put(con.Account__c, new Set<String>{con.Id});
                }
            }


            Map<Id,HandOver_Minute__c> newMap = (Map<Id,HandOver_Minute__c>)Trigger.newMap; 
            Map<Id,HandOver_Minute__c> oldMap = (Map<Id,HandOver_Minute__c>)Trigger.oldMap;     

            for(String  homId : newMap.keySet()){
                HandOver_Minute__c hom = newMap.get(homId);
                HandOver_Minute__c oldHOM = oldMap.get(homId);

                
                //2021.06.22 removed by Toan Nguyen
                //Reason: move logic to Flows. 
                //Document: https://coccoc.atlassian.net/wiki/spaces/BI/pages/1827078455/Handover+Minute+Flow
                /*Account acc = accMap.get(hom.Account__c);
                if(acc != null && acc.OwnerId != hom.OwnerId && !Test.isRunningTest()){
                    hom.OwnerId = acc.OwnerId;
                }*/

                if(String.isBlank(hom.Custom_Contract__c) && hom.Custom_Contract__c != oldHOM.Custom_Contract__c){
                    if(!String.isBlank(hom.Account__c)){
                        Set<String> conIds = mapCons.get(hom.Account__c) == null? New Set<String>(): mapCons.get(hom.Account__c);
                        if(conIds.size() > 0){
                            hom.addError('Please Select Contract beforce Create HOM');
                            continue;
                        }
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
        //2021.06.22 removed by Toan Nguyen
        //Reason: unnecessary logic due to the implement of new transaction priority (QC) and spending service (BI-DE)
        /*
        if (Trigger.isUpdate) {     
            Map<Id,HandOver_Minute__c> newMap = (Map<Id,HandOver_Minute__c>)Trigger.newMap; 
            Map<Id,HandOver_Minute__c> oldMap = (Map<Id,HandOver_Minute__c>)Trigger.oldMap;     

            for(String  homId : newMap.keySet()){
                HandOver_Minute__c newHOM = newMap.get(homId);
                HandOver_Minute__c oldHOM = oldMap.get(homId);

                if(newHOM.status__c == 'Received' && !string.isBlank(newHOM.Custom_Contract__c) && newHOM.status__c != oldHOM.status__c){
                    contractIdSet.add(newHOM.Custom_Contract__c);
                }
            }
        }
		*/
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
        //2021.06.22 removed by Toan Nguyen
        //Reason: unnecessary logic due to the implement of new transaction priority (QC) and spending service (BI-DE)
        /*
        if(contractIdSet.size() > 0 || Test.isRunningTest()){
            List<Contract__c> contractList = [SELECT id, Previous_Coupon__c, Current_Coupon__c  FROM Contract__c WHERE id IN:contractIdSet];
            for(Contract__c con: contractList){
                System.debug('con.Previous_Coupon__c => ' + con.Previous_Coupon__c);
                System.debug('con.Current_Coupon__c => ' + con.Current_Coupon__c);
                con.Previous_Coupon__c = con.Current_Coupon__c;     
            }
            update contractList;
        }	*/
    }

}