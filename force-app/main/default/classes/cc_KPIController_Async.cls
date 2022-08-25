global class cc_KPIController_Async {

    public static void attempgenerateSaleKPI(Set<String> kpis){
        if(!System.isFuture() && !System.isBatch()){
            attemptAsyncGenSaleKPICategory(kpis);
        }else {
            attemptSyncGenSaleKPICategory(kpis);
        }
    }

    @future    
    public static void attemptAsyncGenSaleKPICategory(Set<String> kpiIds){
        attemptSyncGenSaleKPICategory(kpiIds);     
    }
    
    public static void attemptSyncGenSaleKPICategory(Set<String> kpiIds){
        List<KPI__c> kpis = [SELECT ID,KPI_Category__c, Cross_Selling_KPI_Category__c , KPIAutoNumber__c, Period__c, Sales__r.Trac_Name__c, Sales__c FROM KPI__c WHERE Id IN :kpiIds];
        if(kpis.size() > 0){
            genSaleKPICategory(kpis);
        }
    }

    public static void genSaleKPICategory(List<KPI__c> kpis){       
        Map<String,KPI__c> mapkpi = new Map<String,KPI__c>();
        Map<String,List<Sale_Spending_Payment__c>> mapSSP = new Map<String,List<Sale_Spending_Payment__c>>();
        List<Sale_Spending_Payment__c> listtoInsert = new List<Sale_Spending_Payment__c>();

        for (KPI__c kpi: kpis){
            if(!mapkpi.containsKey(kpi.Id)){
                mapkpi.put(kpi.Id,kpi);
            }
        }   

        for(Sale_Spending_Payment__c sp: [SELECT Id, KPI_Category__c, KPI__r.KPI_Category__c, KPI__r.KPIAutoNumber__c,KPI__c 
                                            FROM Sale_Spending_Payment__c WHERE KPI__c IN :mapkpi.keySet()]){
            
            if(mapSSP.containsKey(sp.KPI__c)){
                mapSSP.get(sp.KPI__c).add(sp);
            }else{
                mapSSP.put(sp.KPI__c, new List<Sale_Spending_Payment__c>{sp});
            }
        }

        System.debug('mapkpi=>' + mapkpi.size());
        System.debug('mapSSP=>' + mapSSP.size());

        for(String kpiId: mapkpi.keySet()){  
            List<Sale_Spending_Payment__c> sps = new List<Sale_Spending_Payment__c>();
            Set<String> setCrossCat = new Set<String>();          
            String[] kpicat;
            if(!String.isBlank(mapkpi.get(kpiId).KPI_Category__c )){
                kpicat = mapkpi.get(kpiId).KPI_Category__c.split(';');
            }

            String[] cross_selling_kpicat;
            if(!String.isBlank(mapkpi.get(kpiId).Cross_Selling_KPI_Category__c )){
                cross_selling_kpicat = mapkpi.get(kpiId).Cross_Selling_KPI_Category__c.split(';');
                setCrossCat.addAll(cross_selling_kpicat);
            }

            if(kpicat != null ){
                sps = mapSSP.get(kpiId);
                for(String cat: kpicat){
                    Boolean exists = false;
                    if(sps != null){
                        for(Sale_Spending_Payment__c sp: sps ){
                            if(cat == sp.KPI_Category__c){
                                exists = true;
                            }
                        }
                    }

                    System.debug('sps=>' + sps);
                    System.debug('exists=>' + exists);
                    if(!exists){
                        Sale_Spending_Payment__c saleKPI = new Sale_Spending_Payment__c();
                        String externalNumber = (String)mapkpi.get(kpiId).KPIAutoNumber__c + '_' + (String)cat + '_' + (String)mapkpi.get(kpiId).Period__c;   
                        System.debug('externalNumber=>' + externalNumber);                 
                        saleKPI.KPI__c = kpiId;
                        saleKPI.KPI_Category__c = cat;
                        saleKPI.Name = (String)mapkpi.get(kpiId).Sales__r.Trac_Name__c + ' - ' + (String)cat;                       
                        saleKPI.PaymentKPI__c = 0;
                        saleKPI.SpendingKPI__c = 0;
                        saleKPI.KPI_Number__c = externalNumber;

                        listtoInsert.add(saleKPI);
                    }

                    if(setCrossCat.contains(cat)){
                        setCrossCat.remove(cat);
                    }
                }

                for(String crossCat : setCrossCat){
                    Boolean exists = false;
                    if(sps != null){
                        for(Sale_Spending_Payment__c sp: sps ){
                            if(crossCat == sp.KPI_Category__c){
                                exists = true;
                            }
                        }
                    }

                    System.debug('sps=>' + sps);
                    System.debug('exists=>' + exists);
                    if(!exists){
                        Sale_Spending_Payment__c saleKPI = new Sale_Spending_Payment__c();
                        String externalNumber = (String)mapkpi.get(kpiId).KPIAutoNumber__c + '_' + (String)crossCat + '_' + (String)mapkpi.get(kpiId).Period__c;   
                        System.debug('externalNumber=>' + externalNumber);                 
                        saleKPI.KPI__c = kpiId;
                        saleKPI.KPI_Category__c = crossCat;
                        saleKPI.Name = (String)mapkpi.get(kpiId).Sales__r.Trac_Name__c + ' - ' + (String)crossCat;                       
                        saleKPI.PaymentKPI__c = 0;
                        saleKPI.SpendingKPI__c = 0;
                        saleKPI.KPI_Number__c = externalNumber;
                        saleKPI.Cross_Selling_KPI_Category__c =  true;

                        listtoInsert.add(saleKPI);
                    }
                }
            }

            
        }


        if(listtoInsert.size() > 0 ){
            insert listtoInsert;
        }
    }
}