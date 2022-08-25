public with sharing class cc_ManualSyncKPITargetController {  
    
    @AuraEnabled(cacheable=true)
    public static List<KPI_Target_Detail__c> getKPItargetDetails(String kpitargetId){
        try {
            
            List<KPI_Target_Detail__c> kpitargetdetails = new List<KPI_Target_Detail__c>();
            kpitargetdetails = [SELECT Id, Name, Sale__c, SpendingKPI__c, PaymentKPI__c,  KPI_Category__c, Period__c, Month__c,
                                        KPITargetType__c, SaleName__c, LastSyncDateTime__c
                                FROM KPI_Target_Detail__c 
                                WHERE KPI_Target__c = :kpitargetId
                                    AND IsEdit__c = True
                                ];

            return kpitargetdetails;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean syncKpiTarget(List<KPI_Target_Detail__c> syncRecords, String recordId){
        try {   

            Boolean result = false;            
            Set<String> selectedIds = new Set<String>();

            System.debug('syncRecords=>' + syncRecords);
            System.debug('recordId=>' + recordId);
            for(KPI_Target_Detail__c  target:syncRecords){
                selectedIds.add(target.Id);
            }

            KPI_Target__c target = [SELECT Id, RecordType.DeveloperName FROM KPI_Target__c WHERE Id = :recordId LIMIT 1];

            System.debug('target.RecordType.DeveloperName=>' + target.RecordType.DeveloperName);
            if(target != null){   

                if(target.RecordType.DeveloperName == 'Sale_Manager_KPI'){
                    result = attemptSyncMngKPITarget(selectedIds);
                }else if(target.RecordType.DeveloperName == 'Sale_KPI'){
                    result = attemptSyncSaleKPITarget(selectedIds);
                }
            }

            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());         
        }
    }

    private static Boolean attemptSyncMngKPITarget(Set<String> selectedIds){
        try {
            List<KPI_Target_Detail__c> updateKPItargetdt = new List<KPI_Target_Detail__c>();
            Set<String> saleIds = new Set<String>();  
            Set<String> periods = new Set<String>();   
            List<Sale_Spending_Payment__c> listSPSToUpdate = new List<Sale_Spending_Payment__c>();
            Map<String,KPI_Target_Detail__c> mapTarget = new Map<String,KPI_Target_Detail__c>();

            for (KPI_Target_Detail__c target: [SELECT Id, Sale__c, Sale__r.Manager_level__c, SpendingKPI__c, PaymentKPI__c,  KPI_Category__c, Period__c,
                                                        KPITargetType__c, KPI_Target__r.Include_Manager__c, KPI_Target__r.Sale_Manager__c
                                                FROM KPI_Target_Detail__c 
                                                WHERE Id IN :selectedIds
                                                AND IsEdit__c = True
                                                AND KPITargetType__c = 'Sale_Manager_KPI']){
                String  targetKey = '##'    + (target.Sale__c == null?'': target.Sale__c) 
                                            + (target.KPI_Category__c == null?'':target.KPI_Category__c) 
                                            + (target.Period__c == null?'': target.Period__c) ;            
                
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

            return true;
        } catch (Exception ex) {
            System.debug('ManualSyncKPITarget->attemptSyncMngKPITarget=>' + ex.getMessage());
            return false;
        }
    }

    private static Boolean attemptSyncSaleKPITarget(Set<String> selectedIds){   
        try {
            List<KPI_Target_Detail__c> updateKPItargetdt = new List<KPI_Target_Detail__c>();
            Set<String> saleIds = new Set<String>();  
            Set<String> periods = new Set<String>();   
            List<Sale_Spending_Payment__c> listSPSToUpdate = new List<Sale_Spending_Payment__c>();
            Map<String,KPI_Target_Detail__c> mapTarget = new Map<String,KPI_Target_Detail__c>();

            for (KPI_Target_Detail__c target: [SELECT Id, Sale__c, Sale__r.Manager_level__c, SpendingKPI__c, PaymentKPI__c,  KPI_Category__c, Period__c,
                                                        KPITargetType__c, KPI_Target__r.Include_Manager__c, KPI_Target__r.Sale_Manager__c
                                                FROM KPI_Target_Detail__c 
                                                WHERE Id IN :selectedIds
                                                AND KPITargetType__c = 'Sale_KPI']){
                String  targetKey = '##'    + (target.Sale__c ==null?'': target.Sale__c) 
                                            + (target.KPI_Category__c ==null?'':target.KPI_Category__c) 
                                            + (target.Period__c ==null?'': target.Period__c) ;            
                
                mapTarget.put(targetKey, target); 

                saleIds.add(target.Sale__c);    
                periods.add(target.Period__c);                               
            }

            System.debug('mapTarget=>' + mapTarget.size());
            
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

            
            System.debug('listSPSToUpdate=>' + listSPSToUpdate);
            if(listSPSToUpdate.size() > 0){
                update listSPSToUpdate;                
            }

            if(updateKPItargetdt.size() > 0){
                update updateKPItargetdt;
            }

            return true;
        } catch (Exception ex) {
            System.debug('ManualSyncKPITarget->attemptSyncSaleKPITarget=>' + ex.getMessage());
            return false;
        }
    }
}