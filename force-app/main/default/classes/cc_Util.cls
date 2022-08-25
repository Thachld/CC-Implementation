public class cc_Util {
    public static cc_setting__c getCustomSetting(){
        cc_setting__c setting = [select id, Feedback_default_assignee__c, Hotline__c,is_write_api_log__c, payment_assignee__c,
                                push_topic__c,Qc_account_email__c,run_bachth__c,Ads_Local__c,Consultant_to_Agency_Business__c,Deputy_Head_of_Agency__c,
                                 Global_Ads_Leader__c, Xaxis_Name__c, Fixing_Payment_and_Spending__c, Notify_missing_in_QC_Account__c,
                                 Hom_assign__c, Weekend__c
                                from cc_setting__c limit 1];
        return setting;
    }

    public static cc_Profile__c getProfile(String customSetting) {        
        try {
            cc_Profile__c profile = new cc_Profile__c();
            profile = cc_Profile__c.getInstance(customSetting);
            return profile;
        }
        catch (Exception e) {            
            return null;
        }
    }

    public static cc_Batch_Parameter__c getBatchParameter(String customSetting) {        
        try {
            cc_Batch_Parameter__c params = new cc_Batch_Parameter__c();
            params = cc_Batch_Parameter__c.getInstance(customSetting);
            return params;
        }
        catch (Exception e) {            
            return null;
        }
    }

    public static QC_Integration__c getQCIntergrationInfo(String customSetting) {        
        try {
            QC_Integration__c params = new QC_Integration__c();
            params = QC_Integration__c.getInstance(customSetting);
            return params;
        }
        catch (Exception e) {            
            return null;
        }
    }

    public static cc_Payment_Setting__c getPaymentSetting(String customSetting) {        
        try {
            cc_Payment_Setting__c params = new cc_Payment_Setting__c();
            params = cc_Payment_Setting__c.getInstance(customSetting);
            return params;
        }
        catch (Exception e) {            
            return null;
        }
    }

    public static cc_KPI_Setting__c getKPISetting(String customSetting) {        
        try {
            cc_KPI_Setting__c params = new cc_KPI_Setting__c();
            params = cc_KPI_Setting__c.getInstance(customSetting);
            return params;
        }
        catch (Exception e) {            
            return null;
        }
    }


    public static void writeLog(string name, string description, string inputData){
        Error_log__c error = new Error_log__c();
        error.name = name;
        error.error_description__c = description + '  /r/n' + inputData;
        insert error;        
    }

    public static CalloutLog__c parseCallOutLog(
        String name,
        String recordId,
        String className,
        String classMethod,
		String method,
		String endpoint,
		Map<String,String> headers,
		String requestBody,
		String responseBody,
        String statuscode,
        String notifyId        
	){
		CalloutLog__c log = new CalloutLog__c();
		log.Headers__c = JSON.serializePretty(headers);
		log.Request_Body__c = requestBody;
		log.Response_Body__c = responseBody;
		log.Method__c = method;
		log.Endpoint__c = endpoint;
		log.classname__c = className;
        log.classMethod__c = classMethod;
        log.Statuscode__c = statuscode;
        log.Name = name;
        log.RecordId__c = recordId;
        log.UserNotify__c = notifyId;
        return log;
	}

    public static Error_log__c parseLog(string name, string description, string inputData){
        Error_log__c error = new Error_log__c();
        error.name = name;
        error.error_description__c = description + '  /r/n' + inputData;        

        return error;        
    }
    
    public static AccountShare initSharing(string accountId, string userId){
        AccountShare sharing = new AccountShare();
        sharing.AccountAccessLevel = 'Read';
        sharing.AccountId = accountId;
        //sharing.ContactAccessLevel = 'Read';
        sharing.OpportunityAccessLevel = 'Read';
        sharing.UserOrGroupId = userId;
        return sharing;
    }
    public static AccountTeamMember initTeamAccount(string accountId, string userId, string role){
        AccountTeamMember team = new AccountTeamMember();
        team.AccountAccessLevel = 'Read';
        team.ContactAccessLevel = 'None';
        team.OpportunityAccessLevel = 'None';
        team.CaseAccessLevel = 'None';
        team.TeamMemberRole = 'Ad Op Manager';
        team.AccountId = accountId;
        //sharing.ContactAccessLevel = 'Read';
        team.UserId = userId;
        return team;
    }
    public static void initChatter(string userId, string recordId, string chatterAlert){        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
		ConnectApi.MarkupEndSegmentInput markupEndSegment;
        
        mentionSegmentInput.id = userId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
		markupBeginSegment.markupType = ConnectApi.MarkupType.Code;
		//messageBodyInput.messageSegments.add(markupBeginSegment);
        
        //textSegmentInput.text = '<html>\n\t<body>\n\t\tHello, world!\n\t</body>\n</html>'; //' ' + chatterAlert  + ;
        textSegmentInput.text =  ' ' + chatterAlert;
        messageBodyInput.messageSegments.add(textSegmentInput); 
        
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupEndSegment.markupType = ConnectApi.MarkupType.Code;
		//messageBodyInput.messageSegments.add(markupEndSegment);
        
        feedItemInput.body = messageBodyInput;
        
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        if( !test.isRunningTest()){
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
        } 
    }

    public static ConnectApi.FeedItemInput genChatterwithMetion(String userId, String recordId, String chatterAlert){        
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.MarkupBeginSegmentInput markupBeginSegment;
		ConnectApi.MarkupEndSegmentInput markupEndSegment;
        
        mentionSegmentInput.Id = userId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        markupBeginSegment = new ConnectApi.MarkupBeginSegmentInput();
		markupBeginSegment.markupType = ConnectApi.MarkupType.Code;
	    textSegmentInput.text =  ' ' + chatterAlert;
        messageBodyInput.messageSegments.add(textSegmentInput);         
        
        markupEndSegment = new ConnectApi.MarkupEndSegmentInput();
		markupEndSegment.markupType = ConnectApi.MarkupType.Code;
		 
        feedItemInput.body = messageBodyInput;        
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = recordId;
        
        return feedItemInput;
    }

    public static void initChatter(List<id> userIdList, string recordId, string chatterAlert){
        String salesforceHost = System.Url.getSalesforceBaseURL().toExternalForm();
        String url =  salesforceHost + '/services/data/v26.0/chatter/feeds/record/' + RecordId + '/feed-items';
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setHeader('Content-type', 'application/json');
        req.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());
        string mentionTemplate = '{ "type": "mention", "id" : "@userId" }';
        string memtion = '';
        for(string item: userIdList){
            if(!string.isBlank(memtion)){
                memtion += ',';
            }
            memtion += mentionTemplate.replace('@userId', item);
        }
        req.setBody('{ "body" : { "messageSegments" : [ ' +memtion+ ', { "type": "text",  "text" : "' + ' ' + chatterAlert +  '" } ] } }');
        system.debug('tndebug:' + req.getBody());
        Http http = new Http();
        if( !test.isRunningTest()){
        	HTTPResponse res = http.send(req);
        }
    } 
     public static set<string> getSetDate(integer startdate, integer enddate, integer month, integer year){
        set<string> strDateSet = new set<string>();
        for(integer i = startdate; i<= enddate; i++){
            string strTemp = '';
            if( i < 10)
            {
                strTemp = '0' + string.valueOf(i);
            }
            else{
                strTemp =  string.valueOf(i);
            }
            if(month <10){
                strTemp += '/0' + string.valueOf(month);
            }else{
                 strTemp += '/' + string.valueOf(month);
            }
            strTemp += '/' + string.valueOf(year);
            strDateSet.add(strTemp);
        }
        return strDateSet;
    }
    public static void insertQcAccountSpendingReport(set<string> setDatestr ){
        string soql = 'SELECT QC_Account__c FROM QC_Account_Data__c where ';// group by  QC_Account__c';
        string condition = '';
        string monthYear = '';
        for(string item: setDatestr){
            if( !string.isBlank(condition)){
                condition += ' or ';
                monthYear = item.split('/')[1] + '/' + item.split('/')[2];
            }
            	
            condition += ' Name LIKE \'%'+ item +'\'';
        }
        soql+= condition + ' group by  QC_Account__c ';
        List<AggregateResult> qcAccountDateList = database.query(soql);
        List<Spending_Report__c> resultList = new List<Spending_Report__c>();
        integer i = 0;
        for(AggregateResult item:  qcAccountDateList){
            
            Spending_Report__c temp = new Spending_Report__c();
            temp.QC_Account_Name_Month__c = string.valueof(item.get('QC_Account__c')) + '_' + monthYear; 
            temp.QC_Accounts__c = string.valueOf(item.get('QC_Account__c'));
            resultList.add(temp); 
            i++;
            if( i >=5000){
                i= 0;
                //cc_SpendingReport_ISQcAccount tempBatch = new cc_SpendingReport_ISQcAccount(resultList);
                //List<AsyncApexJob> asyncJobList = [Select Id From AsyncApexJob where ApexClassId=:'cc_SpendingReport_getQCAccountv1' AND JobType='BatchApex' and Status In ('Processing','Preparing','Holding','Queued')];

            	//ID batchprocessid = database.executeBatch(tempBatch,1);
                //if(asyncJobList.size() >0)
                	//System.FlexQueue.moveJobToEnd(batchprocessid);
                database.insert(resultList, false);
                resultList = new List<Spending_Report__c>();
            }
        }
        if( resultList.size() >0){
            /* cc_SpendingReport_ISQcAccount tempBatch = new cc_SpendingReport_ISQcAccount(resultList);
             ID batchprocessid1 =  database.executeBatch(tempBatch,1); 
             List<AsyncApexJob> asyncJobList = [Select Id From AsyncApexJob where ApexClassId=:'cc_SpendingReport_getQCAccountv1' AND JobType='BatchApex' and Status In ('Processing','Preparing','Holding','Queued')];
			if(asyncJobList.size() >0)
                	System.FlexQueue.moveJobToEnd(batchprocessid1);
			*/
            
        }
        
        
       
    }
    
    public static Map<string,boolean> checkRelationship(List<string> compileList){
        List<Relationship__c> relationshipList = [select id, name, ID_combination__c from Relationship__c where 
                                                 ID_combination__c in:compileList ];
        Map<string,boolean> result = new Map<string,boolean>();
        for(Relationship__c item: relationshipList){
            if( !result.containsKey( item.ID_combination__c)  ){
                result.put(item.ID_combination__c, true);
            }
        }
        return result;
    }


    public static boolean checkTriggerAllowRun(String pName) {      
        try {            
            cc_Trigger_Control__c item = cc_Trigger_Control__c.getInstance(pName);
            return item.allow_run__c;
        } catch (Exception e) {
            System.debug('checkTriggerAllowRun() --> EXCEPTION: ' + e.getMessage());
            return false;
        }  
    }


    public static List<String> getPeriodbyQuarter(String quater){
        List<String> periods = new List<String>();
        String trimQuater = quater.trim();
        String year = quater.right(4);
        String quaternum = quater.left(1);
        if(quaternum == '1'){
            periods.add('01-' + year);
            periods.add('02-' + year);
            periods.add('03-' + year);
        }else if(quaternum == '2'){
            periods.add('04-' + year);
            periods.add('05-' + year);
            periods.add('06-' + year);
        }else if(quaternum == '3'){
            periods.add('07-' + year);
            periods.add('08-' + year);
            periods.add('09-' + year);
        }else if(quaternum == '4'){
            periods.add('10-' + year);
            periods.add('11-' + year);
            periods.add('12-' + year);
        }

        return periods;
    }

    public static String decrypted(String key, String cipherText, String algorithmName){
        
        Blob encryptKey = EncodingUtil.base64Decode(key);
        Blob decryptdata = EncodingUtil.base64Decode(cipherText);
        Blob decrypted = Crypto.decryptWithManagedIV(algorithmName, encryptKey, decryptdata);
        String decryptedString = decrypted.toString();        

        return decryptedString;
    }

    public static void doPublishAPIInboundMsg(String clsName, String urlMaping, String jsBody){
        
        API_Inbound_Message__e eventMsg = new API_Inbound_Message__e();
        eventMsg.ClassName__c = clsName;
        eventMsg.Message__c = jsBody;
        eventMsg.urlMapping__c = urlMaping;

        Eventbus.publish(eventMsg);
    }
}