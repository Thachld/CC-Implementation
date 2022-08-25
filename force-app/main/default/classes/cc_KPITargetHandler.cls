public with sharing class cc_KPITargetHandler implements  cc_ITrigger{
    Set<String> kpiTeamIds = new Set<String>();
    Set<String> kpiManagerIds = new Set<String>();
    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        //isInsert
        
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkAfter() {
        if (Trigger.isUpdate) {     
            Set<String> targetIds = new Set<String>();
            Id saleRecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get(KPIConstant.TEAM_TARGET_RECORDTYPE).getRecordTypeId();    
            Id mngRecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get(KPIConstant.MANAGER_TARGET_RECORDTYPE).getRecordTypeId();
            
            Map<Id,KPI_Target__c> newMap = (Map<Id,KPI_Target__c>)Trigger.newMap; 
            Map<Id,KPI_Target__c> oldMap = (Map<Id,KPI_Target__c>)Trigger.oldMap;     

            for(String tgId: newMap.keyset()){
                KPI_Target__c newtg = newMap.get(tgId);
                KPI_Target__c oldtg = oldMap.get(tgId);
                
                if(newtg.Status__c != oldtg.Status__c && newtg.Status__c == KPIConstant.STATUS_APPROVED){
                    targetIds.add(newtg.Id);
                }                
            }

            for(KPI_Target_Detail__c tgdl : [SELECT Id, KPITargetType__c FROM KPI_Target_Detail__c WHERE KPI_Target__c IN :targetIds]){
                if(tgdl.KPITargetType__c == KPIConstant.TEAM_TARGET_RECORDTYPE){
                    kpiTeamIds.add(tgdl.Id);
                }else if(tgdl.KPITargetType__c == KPIConstant.MANAGER_TARGET_RECORDTYPE){
                    kpiManagerIds.add(tgdl.Id);
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
        System.debug('kpiTeamIds =>' + kpiTeamIds.size());
        if(kpiTeamIds.size() > 0){            
            cc_KPITargetDetail_Async.attemptApplySaleKPITarget(kpiTeamIds);
        }
        System.debug('kpiManagerIds =>' + kpiManagerIds.size());
        if(kpiManagerIds.size() >0){
            cc_KPITargetDetail_Async.attemptApplyManagerKPITarget(kpiManagerIds);
        }
    }       
}