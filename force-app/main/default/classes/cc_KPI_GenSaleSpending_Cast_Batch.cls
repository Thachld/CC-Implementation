global class cc_KPI_GenSaleSpending_Cast_Batch implements Database.Batchable<SObject>{
    public String period {get;set;}
    public cc_KPI_GenSaleSpending_Cast_Batch(String pperiod) {
        this.period = pperiod;
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT ID,KPI_Category__c ,Cross_Selling_KPI_Category__c , KPIAutoNumber__c, Period__c, Sales__r.Trac_Name__c, Sales__c 
                                            FROM KPI__c 
                                            WHERE Period__c = :this.period
                                                AND Status__c != 'Confirmed']);    
    }


    global void execute(Database.BatchableContext bc, List<KPI__c> scope){        
        List<KPI__c> mapkpi = new List<KPI__c>();
        if(scope.size() > 0){
            cc_KPIController_Async.genSaleKPICategory(scope);
        }        
    }

    global void finish(Database.BatchableContext bc){

    }


}