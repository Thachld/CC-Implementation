@isTest
public class cc_ChatterQueueable_Test {
	@isTest
     public static void testChatterQueueable(){
         User us = [select id from user where profile.Name = 'System Administrator' and isactive = true limit 1];
         cc_setting__c settting = cc_initData.initCustomeSetting();
         insert settting;
         QC_Account__c qcAccount = cc_initData.initQCAccount();
         qcAccount.Support__c = us.id;
         insert qcAccount;
         
         cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
         List<cc_ChatterBatchWrapper> chatterList = new List<cc_ChatterBatchWrapper>();
         chatterList.add(post);
         post.idList.add(qcAccount.Support__c);
         post.message =   ' This account has been assigned to you. Please take care customer';
         post.recordid = qcAccount.id;
         //post.Title = 'Support assign';
         cc_ChatterQueueable chatterQueue = new cc_ChatterQueueable(chatterList);
         System.enqueueJob(chatterQueue);
     }
}