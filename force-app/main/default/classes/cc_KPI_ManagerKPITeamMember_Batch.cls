global class cc_KPI_ManagerKPITeamMember_Batch implements Database.Batchable<SObject>, Database.Stateful{
    public String kpiperiod {get;set;}

    public cc_KPI_ManagerKPITeamMember_Batch(String period) {
        this.kpiperiod = period;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Sales__c, 
                                                Sale_Manager_KPI__c,
                                                Sale_Manager_KPI__r.Sales__c,
                                                RecordType.DeveloperName,
                                                SalesManager__c, 
                                                KPI_Category__c    
                                        FROM KPI__c 
                                        WHERE Period__c = : this.kpiperiod
                                            AND Status__c != 'Confirmed']);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        List<KPI__c> listKPIsToUpdate = new List<KPI__c>();
        Map<String, KPI__c> mapKPIManager = new Map<String, KPI__c>();
        List<KPI__c> listKPIsToprocess = new List<KPI__c>();
        System.debug('scope = >' + scope.size() );

        for(KPI__c kpi: scope){
            if(kpi.RecordType.DeveloperName == 'Sale_Manager_KPI' || kpi.RecordType.DeveloperName == 'Support_Manager_KPI'){
                mapKPIManager.put(kpi.Sales__c, kpi);
            }

            if(String.isBlank(kpi.Sale_Manager_KPI__c)){
                listKPIsToprocess.add(kpi);
            }else if( !String.isBlank(kpi.Sale_Manager_KPI__r.Sales__c)                         
                        && kpi.Sale_Manager_KPI__r.Sales__c <> kpi.SalesManager__c){
                listKPIsToprocess.add(kpi);
            }
        }

        System.debug('listKPIsToprocess = >' + listKPIsToprocess.size() );
        System.debug('mapKPIManager = >' + mapKPIManager.size() );

        for(KPI__c kpi : listKPIsToprocess){
            if(mapKPIManager.containsKey(kpi.SalesManager__c)){
                System.debug('kpi.Id = >' + kpi.Id );
                System.debug('mapKPIManager.get(kpi.SalesManager__c).Id = >' + mapKPIManager.get(kpi.SalesManager__c).Id );

                if(kpi.Id != mapKPIManager.get(kpi.SalesManager__c).Id){
                    kpi.Sale_Manager_KPI__c = mapKPIManager.get(kpi.SalesManager__c).Id;

                    listKPIsToUpdate.add(kpi);
                }                
            }
        }

        if(listKPIsToUpdate.size() > 0 ){
            update listKPIsToUpdate;
        }

    }

    global void finish(Database.BatchableContext bc){
        cc_KPI_Calculation_MngKPI_Batch batch = new cc_KPI_Calculation_MngKPI_Batch(this.kpiperiod);
        Database.executeBatch(batch, 100);
    }
}