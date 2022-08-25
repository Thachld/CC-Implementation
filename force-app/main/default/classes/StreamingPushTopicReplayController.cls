public class StreamingPushTopicReplayController {

    private static String TOPIC_NAME = 'CreateNormalPaymentStr';// 'CreateRf_TfPaymentStr'; //CreateQCAccountStreaming 
   
    public String channel{get; private set;}
    public Integer replayFrom{get;set;}
    public Id topicId{get;set;}
    
    public StreamingPushTopicReplayController() {
        cc_setting__c setting = [select id, name, push_topic__c  from cc_setting__c];
        TOPIC_NAME = setting.push_topic__c; //'quynhnt@coccoc.com';
        this.channel = '/topic/' + TOPIC_NAME;
        this.replayFrom = -1;
    }
    public void commandButtonSpending()
    {
        cc_KPI_Spending_Batchv2 temp = new cc_KPI_Spending_Batchv2('01/01/2020');
        database.executeBatch(temp);
    }
    public void commandButtonPayment(){
        cc_KPI_Payment_Batch temp = new cc_KPI_Payment_Batch('01/01/2020');
        database.executeBatch(temp);
    }
    
    public PageReference getOrCreatePushChannel() {
        List<PushTopic> pushTopics = [SELECT Id,Name FROM PushTopic WHERE Name=:TOPIC_NAME];
        if( Test.isRunningTest())
        {
            TOPIC_NAME = 'CreateNormalPaymentStr1';
        }
        if (null == pushTopics || pushTopics.size() == 0) {
            PushTopic topic = new PushTopic();
            topic.Name = TOPIC_NAME;
            string done = '\'Done\'';
            string  failure = '\'Failure\'';
            
            //topic.Query = 'SELECT Id,Name,QC_Email__c,Payment_method__c,Stage__c,Type__c  FROM Payment__c where Stage__c='  + done+ ' or Stage__c=' + failure;
            //CreateQCPaymentStreaming: SELECT Id,Name, Stage__c, Final_Amount__c, Note__c  FROM Payment__c where Stage__c='Done' or Stage__c='Failure' and recordTypeId = '0120k000000IcAs'
            
            /*CreateRfQCPaymentStr
            string  standardRecordType = '\'0120k000000IcAs\'';
            topic.Query = 'SELECT Id,Name, Stage__c, Final_Amount__c, Note__c  FROM Payment__c where (Stage__c='  + done+ ' or Stage__c=' + failure  + ' ) and  (State_temp__c !='  + done+ ' or State_temp__c !=' + failure  + ' )   and recordTypeId=' + standardRecordType;
            */
            
            //CreateRf_TfPaymentStr
            //Rf: 0120k000000IcOG
            //Tf: 0120k000000IcAn
            string  rfRecordType = '\'0120k000000IcOG\'';
            string  tfRecordType = '\'0120k000000IcAn\'';
            topic.Query = 'SELECT Id,Name,QC_Email__c,QC_Id__c, Final_Amount__c,Payment_method__c,Stage__c,Type__c,Note__c  FROM Payment__c '; 
            topic.Query +=  'where ((Stage__c='  + done+ ' or Stage__c=' + failure  + ' ) and  (State_temp__c !='  + done+ ' or State_temp__c !=' + failure  + ' )   and  recordTypeId=' + rfRecordType  + ') ' ;
            topic.Query += ' or  ((Stage__c='  + done+ ' or Stage__c=' + failure  + ' ) and recordTypeId=' + tfRecordType + ')';
            
            
            topic.NotifyForFields = 'Referenced';
            topic.ApiVersion = 36.0;
            //insert topic;
            //this.topicId = topic.Id;
        } else {
            //this.topicId = pushTopics.get(0).Id;
        }
        return null;
    }
}