@isTest
public class StreamingPushCtrl_Test {
	@isTest
     public static void test1(){
         cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         StreamingPushTopicReplayController temp = new StreamingPushTopicReplayController();
         temp.getOrCreatePushChannel();
     }
}