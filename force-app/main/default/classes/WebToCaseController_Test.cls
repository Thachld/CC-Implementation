@istest
public with sharing class WebToCaseController_Test {
    
    @istest
    public static void testPositiveInsertCase(){
        Test.startTest();
            Case newcs = new Case();
            newcs.Subject = 'TEST SUBJECT';
            newcs.SuppliedName = 'TEST NAME';
            newcs.SuppliedEmail = 'TESTEMAIL@gmail.com';
            newcs.SuppliedPhone = '0977849448';
            newcs.Origin = 'Web';
            newcs.Status = 'New';
            newcs.Description = 'TEST DESCRIPTION';

            WebToCaseController.saveCase(newcs, '', '');

            Case testcs = [SELECT Id,SuppliedPhone  FROM Case WHERE SuppliedPhone = :newcs.SuppliedPhone];
            System.assertEquals(testcs.SuppliedPhone, newcs.SuppliedPhone);
        Test.stopTest();
    }

    @istest
    public static void testNegativeInsertCase(){       
        Exception capturedException; 
        Test.startTest();
        try {
            Case newcs = new Case();
          
            WebToCaseController.saveCase(newcs, '', '');
        } catch (AuraHandledException  ex) {
            capturedException = ex;       
            
            // System.assertNotEquals(null, capturedException, 'Exception should be thrown');     
        }       
        
        Test.stopTest();
        
    }

}