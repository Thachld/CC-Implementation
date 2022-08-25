@isTest
public class cc_QcAccountChatterBatch_Test {
	@isTest
    public static void testBatch(){
        
        Account acc = cc_initData.initAccount();
        insert acc;
        User us = [select id from user where profile.Name = 'System Administrator' and isactive = true limit 1];
        cc_ChatterBatchWrapper fItem = new cc_ChatterBatchWrapper();
        List<cc_ChatterBatchWrapper> fItemList = new List<cc_ChatterBatchWrapper>();
        fItemList.add(fItem);
            
        fItem.idList.add(us.id);
        fItem.recordId = acc.id;
        fItem.message = 'test';
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
       cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(fItemList);
       database.executeBatch(batch,1);
        Test.stopTest();
    }
}