public with sharing class cc_KPIHandler implements  cc_ITrigger{
    Set<String> kpis = new Set<String>();    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {  
        if(Trigger.isInsert){            
            for(KPI__c kpi : (List<KPI__c>)Trigger.new){
                if(!String.isBlank(kpi.Cross_Selling_KPI_Category__c) && !String.isBlank(kpi.KPI_Category__c)){
                    Set<String> kpicatset= new Set<String>();
                    String[] kpicat;
                    kpicat = kpi.KPI_Category__c.split(';');                
                    kpicatset.addAll(kpicat);

                    String[] cross_selling_kpicat;
                    cross_selling_kpicat = kpi.Cross_Selling_KPI_Category__c.split(';');          
                    
                    for(String crossCat : cross_selling_kpicat){
                        if(kpicatset.contains(crossCat)){
                            String msg = 'KPI Category {0} already exists in standard kpi categories of Sale';
                            List<String> params = new List<String>{crossCat};
                            String errmsg = String.format(msg, params);
                            kpi.addError(errmsg);
                        }
                    }
                    
                }
            }        
        }else if(Trigger.isUpdate){
            Map<Id,KPI__c> oldMap = (Map<Id,KPI__c>)Trigger.oldMap;
            for(KPI__c kpi : (List<KPI__c>)Trigger.new){
                KPI__c oldKPI = oldMap.get(kpi.Id);
                if(kpi.Cross_Selling_KPI_Category__c != oldKPI.Cross_Selling_KPI_Category__c 
                    || kpi.KPI_Category__c != oldKPI.KPI_Category__c ){
                    if(!String.isBlank(kpi.Cross_Selling_KPI_Category__c) && !String.isBlank(kpi.KPI_Category__c)){
                        Set<String> kpicatset= new Set<String>();
                        String[] kpicat;
                        kpicat = kpi.KPI_Category__c.split(';');                
                        kpicatset.addAll(kpicat);

                        String[] cross_selling_kpicat;
                        cross_selling_kpicat = kpi.Cross_Selling_KPI_Category__c.split(';');          
                        
                        for(String crossCat : cross_selling_kpicat){
                            if(kpicatset.contains(crossCat)){
                                String msg = 'KPI Category {0} already exists in standard kpi categories of Sale';
                                List<String> params = new List<String>{crossCat};
                                String errmsg = String.format(msg, params);
                                kpi.addError(errmsg);
                            }
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
        if(Trigger.isInsert){           
            for(KPI__c kpi :(List<KPI__c>)Trigger.new){
                if( !String.isBlank(kpi.Sales__c) && (!String.isBlank(kpi.KPI_Category__c) || !String.isBlank(kpi.Cross_Selling_KPI_Category__c) ) && kpi.Status__c != 'Confirmed'){
                    kpis.add(kpi.Id);
                }
            }
        }else if (Trigger.isUpdate) {     
            Map<Id,KPI__c> newMap = (Map<Id,KPI__c>)Trigger.newMap; 
            Map<Id,KPI__c> oldMap = (Map<Id,KPI__c>)Trigger.oldMap;     

            for(KPI__c newkpi: newMap.values()){
                KPI__c oldkpi = oldMap.get(newkpi.Id);

                if(( newkpi.KPI_Category__c != oldkpi.KPI_Category__c 
                    || newkpi.Cross_Selling_KPI_Category__c != oldkpi.Cross_Selling_KPI_Category__c )
                    && newkpi.Status__c != 'Confirmed'){
                    kpis.add(newkpi.Id);
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
        System.debug('kpis =>' + kpis.size());
        if(kpis.size() > 0){            
            cc_KPIController_Async.attempgenerateSaleKPI(kpis);
        }        
    }   
}