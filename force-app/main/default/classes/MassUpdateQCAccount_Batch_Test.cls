/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 07-04-2022
 * @last modified by  : @Thach Le
**/
@istest(SeeAllData=false)
public with sharing class MassUpdateQCAccount_Batch_Test {
    @istest
    public static void testMassUpdate(){
        Test.startTest();
        List<QC_Account__c> listInsertQCAcc = new List<QC_Account__c>();
        Account acc = new AccountTestDataBuilder().buildAndSave();
        for(Integer i = 0 ; i < 200; i ++){
            QC_Account__c qcacc = new QCAccountTestDataBuilder()
                            .setAccount(acc.Id)
                            .setApplyTransactionType(false)
                            .setSource(QCAccountConstant.SOURCE_QC)
                            .setName('testclient' + String.valueOf(i) +  '@qc.coccoc.com')
                            .build();
            listInsertQCAcc.add(qcacc);
        }

        insert listInsertQCAcc;
        List<QC_Account__c> testQCAcc1 = [SELECT Id FROM QC_Account__c WHERE IsApplyTransactionType__c = false];
        System.debug('testQCAcc1' + testQCAcc1.size());
        MassUpdateQCAccount_Batch batch = new MassUpdateQCAccount_Batch();
        Database.executeBatch(batch,2000);

        try {
            Test.stopTest();
            
            List<QC_Account__c> testQCAcc = [SELECT Id FROM QC_Account__c WHERE IsApplyTransactionType__c = true];
            System.assertEquals(200, testQCAcc.size(), 'Update Success');

        } catch (Exception ex) {
            
        }
        
    }
}