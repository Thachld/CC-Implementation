@isTest
public class cc_SendEmail_Test {
	 @isTest
    public static void testSendEmail(){
        Test.startTest();
        
        User us = [select id, email,QC_Email__c from user where IsActive = true and QC_Email__c != null limit 1];
        List<cc_ChatterBatchWrapper> postList = new List<cc_ChatterBatchWrapper>();
        cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
        //post.idList.add(');
            //post.recordId = qcInvalid.id;
          
        post.isEmail = true;
        post.title = 'Fix invalid qc account';
        post.body = 'Dear Hotline Team <br/>';
        post.toEmail = 'toannc1@coccoc.com';
        post.body += 'test';
           
        postList.add(post);
        cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(postList);
        database.executeBatch(batch);
        batch.execute(null, null);
        Test.stopTest();
    }
}