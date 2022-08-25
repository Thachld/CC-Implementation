global class cc_KPITargetDetail_Async {
    
    public class PickListWraper {            
        public string value {get;set;}        
        public string label {get;set;}  
    }

    public static void attemptApplySaleKPITarget(Set<String> kpiIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsyncSaleKPITarget(kpiIds);
        }else {
            attemptSyncSaleKPITarget(kpiIds);
        }
    }

    public static void attemptApplyManagerKPITarget(Set<String> kpiManagerIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsyncMngKPITarget(kpiManagerIds);
        }else {
            attemptSyncMngKPITarget(kpiManagerIds);
        }
    }

    

    @future
    global static void attemptAsyncSaleKPITarget(Set<String> saletargetIds){
        attemptSyncSaleKPITarget(saletargetIds);
    }

    private static void attemptSyncSaleKPITarget(Set<String> saletargetIds){  
        
        List<KPI_Target_Detail__c> updateKPItargetdt = new List<KPI_Target_Detail__c>(); 
        Set<String> saleIds = new Set<String>();  
        Set<String> periods = new Set<String>();   
        List<Sale_Spending_Payment__c> listSPSToUpdate = new List<Sale_Spending_Payment__c>();
        Map<String,KPI_Target_Detail__c> mapTarget = new Map<String,KPI_Target_Detail__c>();

        for (KPI_Target_Detail__c target: [SELECT Id, Sale__c, Sale__r.Manager_level__c, SpendingKPI__c, PaymentKPI__c,  KPI_Category__c, Period__c,
                                                    KPITargetType__c, KPI_Target__r.Include_Manager__c, KPI_Target__r.Sale_Manager__c
                                            FROM KPI_Target_Detail__c 
                                            WHERE Id IN :saletargetIds
                                            AND KPI_Target__r.Status__c ='Approved'
                                            AND KPITargetType__c = 'Sale_KPI']){
            String  targetKey = '##'    + (target.Sale__c ==null?'': target.Sale__c) 
                                        + (target.KPI_Category__c ==null?'':target.KPI_Category__c) 
                                        + (target.Period__c ==null?'': target.Period__c) ;            
            
            mapTarget.put(targetKey, target); 

            saleIds.add(target.Sale__c);    
            periods.add(target.Period__c);                               
        }


        for(Sale_Spending_Payment__c sp: [SELECT Id, KPI__r.Sales__c,  SpendingKPI__c, PaymentKPI__c, KPI_Category__c, KPI__r.Period__c, KPI_Sale_Target__c
                                            FROM Sale_Spending_Payment__c
                                            WHERE KPI__r.Sales__c IN :saleIds
                                                AND KPI__r.RecordType.DeveloperName = 'Sale_KPI'
                                                AND KPI__r.Period__c IN :periods]){
            String  spkey = '##'    + (sp.KPI__r.Sales__c ==null?'': sp.KPI__r.Sales__c) 
                                    + (sp.KPI_Category__c ==null?'':sp.KPI_Category__c) 
                                    + (sp.KPI__r.Period__c ==null?'': sp.KPI__r.Period__c) ;  
            KPI_Target_Detail__c target = mapTarget.get(spkey);
            
            if(target != null){
                sp.KPI_Sale_Target__c = target.Id;
                sp.SpendingKPI__c = target.SpendingKPI__c;
                sp.PaymentKPI__c = target.PaymentKPI__c; 
                
                listSPSToUpdate.add(sp);

                KPI_Target_Detail__c dt = new KPI_Target_Detail__c();
                dt.Id = target.Id;
                dt.LastSyncDateTime__c = System.now();

                updateKPItargetdt.add(dt);    
            }
        }

        if(listSPSToUpdate.size() > 0){
            update listSPSToUpdate;
        }

        if(updateKPItargetdt.size() > 0){
            update updateKPItargetdt;
        }
        
    }

    @future
    global static void attemptASyncMngKPITarget(Set<String> saletargetIds){
        attemptSyncMngKPITarget(saletargetIds);
    }

    private static void attemptSyncMngKPITarget(Set<String> saletargetIds){
        List<KPI_Target_Detail__c> updateKPItargetdt = new List<KPI_Target_Detail__c>(); 
        Set<String> saleIds = new Set<String>();  
        Set<String> periods = new Set<String>();   
        List<Sale_Spending_Payment__c> listSPSToUpdate = new List<Sale_Spending_Payment__c>();
        Map<String,KPI_Target_Detail__c> mapTarget = new Map<String,KPI_Target_Detail__c>();

        for (KPI_Target_Detail__c target: [SELECT Id, Sale__c, Sale__r.Manager_level__c, SpendingKPI__c, PaymentKPI__c,  KPI_Category__c, Period__c,
                                                    KPITargetType__c, KPI_Target__r.Include_Manager__c, KPI_Target__r.Sale_Manager__c
                                            FROM KPI_Target_Detail__c 
                                            WHERE Id IN :saletargetIds
                                            AND IsEdit__c = True
                                            AND KPI_Target__r.Status__c ='Approved'
                                            AND KPITargetType__c = 'Sale_Manager_KPI']){
            String  targetKey = '##'    + (target.Sale__c ==null?'': target.Sale__c) 
                                        + (target.KPI_Category__c ==null?'':target.KPI_Category__c) 
                                        + (target.Period__c ==null?'': target.Period__c) ;            
            
            mapTarget.put(targetKey, target); 

            saleIds.add(target.Sale__c);    
            periods.add(target.Period__c);                               
        }


        for(Sale_Spending_Payment__c sp: [SELECT Id, KPI__r.Sales__c,  SpendingKPI__c, PaymentKPI__c, KPI_Category__c, KPI__r.Period__c, KPI_Sale_Target__c
                                            FROM Sale_Spending_Payment__c
                                            WHERE KPI__r.Sales__c IN :saleIds
                                                AND KPI__r.RecordType.DeveloperName = 'Sale_Manager_KPI'                                                
                                                AND KPI__r.Period__c IN :periods]){
            String  spkey = '##'    + (sp.KPI__r.Sales__c ==null?'': sp.KPI__r.Sales__c) 
                                    + (sp.KPI_Category__c ==null?'':sp.KPI_Category__c) 
                                    + (sp.KPI__r.Period__c ==null?'': sp.KPI__r.Period__c) ;  
            KPI_Target_Detail__c target = mapTarget.get(spkey);
            
            if(target != null){
                sp.KPI_Sale_Target__c = target.Id;
                sp.SpendingKPI__c = target.SpendingKPI__c;
                sp.PaymentKPI__c = target.PaymentKPI__c; 
                
                listSPSToUpdate.add(sp);

                KPI_Target_Detail__c dt = new KPI_Target_Detail__c();
                dt.Id = target.Id;
                dt.LastSyncDateTime__c = System.now();

                updateKPItargetdt.add(dt);    
            }
        }

        if(listSPSToUpdate.size() > 0){
            update listSPSToUpdate;
        }

        if(updateKPItargetdt.size() > 0){
            update updateKPItargetdt;
        }
    }
    
}