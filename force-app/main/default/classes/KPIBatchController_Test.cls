@istest
public with sharing class KPIBatchController_Test {    

    @istest
    public static void testRuncalculationSaleKPI(){
        Test.startTest();
        String period = '10-2021';
        String quater = '4-2021';
        KPIBatchController.runBatchJob('runKPICalculation', period);
        KPIBatchController.runBatchJob('runKPIMngCalculation', period);
        KPIBatchController.runBatchJob('runApplySaleTarget', period);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    @istest
    public static void testRunrunRollOverSaleTarget(){
        Test.startTest();        
        String quater = '4-2021';       
        KPIBatchController.runBatchJob('runRollOverSaleTarget', quater);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    @istest
    public static void testGetJobs(){
        Test.startTest();
        List<String> jobIds = new List<String>();
        String period = '10-2021';
        cc_KPI_Calculation_batch saletBatch = new cc_KPI_Calculation_batch(period);
        Id saleJobId =database.executeBatch(saletBatch,40);
        jobIds.add(saleJobId);
        KPIBatchController.getJobs(jobIds);

        try {
            Test.stopTest();
        } catch (Exception ex) {
            
        }
    }

    @istest 
    public static void testCustomSetting(){
        // Test.startTest();
            cc_KPI_Setting__c kpisetting = cc_initData.initKPISetting('ccKPISetting');
            insert kpisetting;

            cc_KPI_Setting__c test = KPIBatchController.getKPISetting('ccKPISetting');
            cc_KPI_Setting__c test2 = KPIBatchController.updateKPISetting('ccKPISetting',false, false);

        // Test.stopTest();
    }
}