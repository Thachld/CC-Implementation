@istest
public class KPIConstant_Test {
	
    @istest
    public static void testConstant(){
        
        System.assertEquals(KPIConstant.MANAGER_LEVEL_1,'Level 1');
        System.assertEquals(KPIConstant.MANAGER_LEVEL_2,'Level 2');
        System.assertEquals(KPIConstant.MANAGER_LEVEL_3,'Level 3');
        
        System.assertEquals(KPIConstant.SALE_TEAM_GLOBAL_AGENCY,'Global Agency');
        System.assertEquals(KPIConstant.SALE_TEAM_LOCAL_AGENCY,'Local Agency');
        System.assertEquals(KPIConstant.SALE_TEAM_DIRECT,'Direct');
        
        System.assertEquals(KPIConstant.TEAM_TARGET_RECORDTYPE,'Sale_KPI');
        System.assertEquals(KPIConstant.MANAGER_TARGET_RECORDTYPE,'Sale_Manager_KPI');
        
        System.assertEquals(KPIConstant.STATUS_APPROVED,'Approved');
        System.assertEquals(KPIConstant.STATUS_NEW,'New');
        System.assertEquals(KPIConstant.STATUS_PLANNING,'Planning');
        System.assertEquals(KPIConstant.STATUS_PENDING_APPROVAL,'Pending Approval');
        System.assertEquals(KPIConstant.STATUS_CLOSED,'Closed');
    }
}