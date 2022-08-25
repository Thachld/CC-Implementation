@RestResource(urlMapping='/qcaccountdataskintooltosf')
global class cc_QCAccountDataSkintooltoSF_API {
    @HttpPost
    global static string doPostAccountFromQCSystem(){
        QCAccountDataWrapper.Responds rp = new QCAccountDataWrapper.Responds();
         cc_setting__c setting = cc_Util.getCustomSetting();
        Map<string,qc_Account__c> qcAccountInvalidMap = new Map<string,qc_Account__c>();
        try{
            List<QCAccountDataWrapper> incomeQCAccountList = QCAccountDataWrapper.parse(RestContext.request.requestBody.tostring());
           //cc_Util.writeLog('debug: skintool:', RestContext.request.requestBody.tostring(), 'null');
            Map<string,QCAccountDataWrapper> incomeQCAccountMap =  initMapQCAccountIncome( incomeQCAccountList);
            Map<string, QC_Account_Data__c> qcAccountInsertTempMap = new Map<string,QC_Account_Data__c>();
            Map<string, QC_Account_Data__c> qcAccountInsertMap = new Map<string,QC_Account_Data__c>();
            if(incomeQCAccountList == null ){
                rp.error = 'input data is null';
                return system.JSON.serialize(rp);
            }
            Set<string> qcAccountIdSet = new Set<string>();
            set<string> qcAccountDataMappingSet = new Set<string>();
            for(integer i = 0; i < incomeQCAccountList.size(); i++){
                qcAccountIdSet.add(incomeQCAccountList.get(i).customer_id);
                qcAccountDataMappingSet.add(incomeQCAccountList.get(i).customer_id +'_' + incomeQCAccountList.get(i).synDateString);
            } 
            List<QC_Account_Data__c> qcAccountDataExistList = [select id,mappingkey__c from QC_Account_Data__c where mappingkey__c in:qcAccountDataMappingSet  ];
            Map<string, QC_Account_Data__c> qcAccountDataExistMap = getQCAccountDataMap(qcAccountDataExistList);
            
            List<QC_Account__c> qcAccountList = [select id,Name,Industry__c,Sales__c,Support__c,Sales__r.IsActive,Support__r.IsActive, QC_Account_Id__c,Balance__c, Agency__c ,OwnerId, Type__c,AccountOwner__c  from QC_Account__c where id in:qcAccountIdSet];
            Map<string, QC_Account__c> qcAccountMap = new Map<string,QC_Account__c>( );
            for( integer i = 0; i< qcAccountList.size(); i++){
                if( !qcAccountMap.containsKey(qcAccountList.get(i).id)){
                    qcAccountMap.put(qcAccountList.get(i).id, qcAccountList.get(i));
                }
            }
            
            
            List<string> customerIdListTemp = new List<string>();
            for(integer i = 0; i < incomeQCAccountList.size(); i++){
                QC_Account_Data__c qcAccData = initQCAccountData(incomeQCAccountList.get(i));
                QC_Account__c qcAccount = qcAccountMap.get(incomeQCAccountList.get(i).customer_id);
                if( qcAccount != null){
                    qcAccData.Name = qcAccount.name;
                    if( qcAccData.syn_date__c != null){
                        qcAccData.Name = qcAccount.Name + ' ' + incomeQCAccountList.get(i).synDateString;
                        qcAccData.mappingkey__c  = incomeQCAccountList.get(i).customer_id +'_' + incomeQCAccountList.get(i).synDateString;
                    }
                    qcAccData.QC_Account__c = qcAccount.id;
                    if( !string.isBlank(qcAccount.AccountOwner__c) && string.isBlank(qcAccData.Accounts__c)){
                        qcAccData.Accounts__c = qcAccount.AccountOwner__c;
                    }
                    if( string.isBlank(qcAccData.Agency__c))
                    	qcAccData.Agency__c = qcAccount.Agency__c;
                    if(string.isBlank(qcAccData.Industry__c))
                    	qcAccData.Industry__c = qcAccount.Industry__c;
                    if(string.isBlank(qcAccData.Support__c))
                    	qcAccData.Support__c = qcAccount.Support__c;
                    qcAccData.Balance__c = qcAccount.Balance__c;
                    if( string.isBlank(qcAccData.Sale__c))
                    	qcAccData.Sale__c = qcAccount.Sales__c;
                    
                    if( qcAccountDataExistMap.containsKey(qcAccData.mappingkey__c) ){
                        qcAccData.id = qcAccountDataExistMap.get(qcAccData.mappingkey__c).id;
                    }else{
                        if( Test.isRunningTest() || (qcAccount.Type__c != 'External' && qcAccount.Type__c != 'Internal' && qcAccData.Total_Spending__c > 0 && setting.Notify_missing_in_QC_Account__c == true)){
                            handleValidQCAccount(qcAccountInvalidMap, qcAccount);
                        }
                    }
                }
                else{
                    QCAccountDataWrapper.QCAccountDataError error = new QCAccountDataWrapper.QCAccountDataError();
                    error.incomeError = incomeQCAccountMap.get(incomeQCAccountList.get(i).customer_id);
                    error.insertError = 'Can not find QC Account';
                    rp.qcAccountError.add(error);
                    continue;
                }
                customerIdListTemp.add(incomeQCAccountList.get(i).customer_id);
                qcAccountInsertTempMap.put(incomeQCAccountList.get(i).customer_id,qcAccData);
            }
            customerIdListTemp.sort();
            for(string item: customerIdListTemp){
                qcAccountInsertMap.put(item, qcAccountInsertTempMap.get(item));
            }
            Database.UpsertResult[] qcAccountInsertListResult = database.upsert(qcAccountInsertMap.values(), false);
            
            
            for(integer i = 0; i < customerIdListTemp.size(); i++){
                Database.UpsertResult sr = qcAccountInsertListResult.get(i);
                if(!sr.isSuccess()){
                    QC_Account_Data__c qcAccountTemp = qcAccountInsertMap.get(customerIdListTemp.get(i));
                    QCAccountDataWrapper.QCAccountDataError error = new QCAccountDataWrapper.QCAccountDataError();
                    error.incomeError = incomeQCAccountMap.get(customerIdListTemp.get(i));
                    if( sr.isCreated())
                        error.insertError = '' + sr.getErrors();
                    else{
                        error.updateError = '' + sr.getErrors();
                    }
                    
                    rp.qcAccountError.add(error);				
                }
            }   
            rp.totalqcAccount =incomeQCAccountList.size();
            rp.totalFail = rp.qcAccountError.size();
            rp.totalSuccess = rp.totalqcAccount - rp.totalFail;  
            if(qcAccountInvalidMap.keyset().size() >0){
                handleSendEmailandChatter( qcAccountInvalidMap);
            }
            if( rp.totalFail != null && rp.totalFail >0){
                cc_Util.writeLog('KPI report data qcaccountdataskintooltosf','kpi report error', system.JSON.serialize(rp));
            }
        }
        catch(Exception ex){
            rp.error = ex.getMessage();
            string strbody = '';
            if(RestContext.request.requestBody == null){
                cc_Util.writeLog('KPI report data qcaccountdataskintooltosf',ex.getMessage(), 'null');
            }
            if( RestContext.request.requestBody.tostring().length() <=100 )
            {
                strbody += RestContext.request.requestBody.tostring();
            }
            else{
                strbody += RestContext.request.requestBody.tostring().substring(0,100);
            }
            if( setting.is_write_api_log__c){
                cc_Util.writeLog('KPI report data qcaccountdataskintooltosf',ex.getMessage(), strbody);
            }
            else{
                cc_Util.writeLog('KPI report data qcaccountdataskintooltosf',ex.getMessage(), strbody);
            }
            return system.JSON.serialize(rp);
        }
        return system.JSON.serialize(rp);
    }
    public static Map<string,QCAccountDataWrapper> initMapQCAccountIncome(List<QCAccountDataWrapper> incomeQCAccountList){
        Map<string,QCAccountDataWrapper> result  = new Map<string,QCAccountDataWrapper>();
        for(QCAccountDataWrapper item: incomeQCAccountList ){
            result.put(item.customer_id, item );
        }
        return result;
    }
    public static QC_Account_Data__c initQCAccountData(QCAccountDataWrapper inComeQCAccountData){
        QC_Account_Data__c qcAccData = new QC_Account_Data__c();
        qcAccData.syn_date__c = inComeQCAccountData.synDate;
        
        if ( inComeQCAccountData.skintool_skin_view != null ) 
            qcAccData.skintool_skin_view__c = inComeQCAccountData.skintool_skin_view;
        if ( inComeQCAccountData.skintool_skin_click != null ) 
            qcAccData.skintool_skin_click__c = inComeQCAccountData.skintool_skin_click;
        if ( inComeQCAccountData.skintool_skin_price != null ) 
            qcAccData.skintool_skin_price__c = inComeQCAccountData.skintool_skin_price;
        if ( inComeQCAccountData.skintool_skin_spending != null ) 
            qcAccData.skintool_skin_spending__c = inComeQCAccountData.skintool_skin_spending;
        
        //system.debug('debug:skintool_video_skin_view:' +inComeQCAccountData.skintool_video_skin_view );
        if ( inComeQCAccountData.skintool_video_skin_view != null ) 
            qcAccData.skintool_video_skin_view__c = inComeQCAccountData.skintool_video_skin_view;
        if ( inComeQCAccountData.skintool_video_skin_click != null ) 
            qcAccData.skintool_video_skin_click__c = inComeQCAccountData.skintool_video_skin_click;
        if ( inComeQCAccountData.skintool_video_skin_price != null ) 
            qcAccData.skintool_video_skin_price__c = inComeQCAccountData.skintool_video_skin_price;
        if ( inComeQCAccountData.skintool_video_skin_spending != null ) 
            qcAccData.skintool_video_skin_spending__c = inComeQCAccountData.skintool_video_skin_spending;
        
        if ( inComeQCAccountData.skintool_masthead_view != null ) 
            qcAccData.skintool_masthead_view__c = inComeQCAccountData.skintool_masthead_view;
        if ( inComeQCAccountData.skintool_masthead_click != null ) 
            qcAccData.skintool_masthead_click__c = inComeQCAccountData.skintool_masthead_click;
        if ( inComeQCAccountData.skintool_masthead_price != null ) 
            qcAccData.skintool_masthead_price__c = inComeQCAccountData.skintool_masthead_price;
        if ( inComeQCAccountData.skintool_masthead_spending != null ) 
            qcAccData.skintool_masthead_spending__c = inComeQCAccountData.skintool_masthead_spending;
        
        if ( inComeQCAccountData.skintool_masthead_video_view != null ) 
            qcAccData.skintool_masthead_video_view__c = inComeQCAccountData.skintool_masthead_video_view;
        if ( inComeQCAccountData.skintool_masthead_video_click != null ) 
            qcAccData.skintool_masthead_video_click__c = inComeQCAccountData.skintool_masthead_video_click;
        if ( inComeQCAccountData.skintool_masthead_video_price != null ) 
            qcAccData.skintool_masthead_video_price__c = inComeQCAccountData.skintool_masthead_video_price;
        if ( inComeQCAccountData.skintool_masthead_video_spending != null ) 
            qcAccData.skintool_masthead_video_spending__c = inComeQCAccountData.skintool_masthead_video_spending;
        
        if ( inComeQCAccountData.skintool_iconsidebar_view != null ) 
            qcAccData.skintool_iconsidebar_view__c = inComeQCAccountData.skintool_iconsidebar_view;
        if ( inComeQCAccountData.skintool_iconsidebar_click != null ) 
            qcAccData.skintool_iconsidebar_click__c = inComeQCAccountData.skintool_iconsidebar_click;
        if ( inComeQCAccountData.skintool_iconsidebar_price != null ) 
            qcAccData.skintool_iconsidebar_price__c = inComeQCAccountData.skintool_iconsidebar_price;
        if ( inComeQCAccountData.skintool_iconsidebar_spending != null ) 
            qcAccData.skintool_iconsidebar_spending__c = inComeQCAccountData.skintool_iconsidebar_spending;
        
        
        if ( inComeQCAccountData.skintool_video_banner_view != null ) 
            qcAccData.skintool_video_banner_view__c = inComeQCAccountData.skintool_video_banner_view;
        if ( inComeQCAccountData.skintool_video_banner_click != null ) 
            qcAccData.skintool_video_banner_click__c = inComeQCAccountData.skintool_video_banner_click;
        if ( inComeQCAccountData.skintool_video_banner_price != null ) 
            qcAccData.skintool_video_banner_price__c = inComeQCAccountData.skintool_video_banner_price;
        if ( inComeQCAccountData.skintool_video_banner_spending != null ) 
            qcAccData.skintool_video_banner_spending__c = inComeQCAccountData.skintool_video_banner_spending;

        if ( inComeQCAccountData.skintool_vast_skin_view != null ){
            qcAccData.skintool_vast_skin_view__c = inComeQCAccountData.skintool_vast_skin_view;
        }
        if ( inComeQCAccountData.skintool_vast_skin_click != null ) {
            qcAccData.skintool_vast_skin_click__c = inComeQCAccountData.skintool_vast_skin_click;
        }

        if ( inComeQCAccountData.skintool_vast_skin_price != null ) {
            qcAccData.skintool_vast_skin_price__c = inComeQCAccountData.skintool_vast_skin_price;
        }
        
        if ( inComeQCAccountData.skintool_vast_skin_spending != null ) {
            qcAccData.skintool_vast_skin_spending__c = inComeQCAccountData.skintool_vast_skin_spending;
        }    



        qcAccData.TotalSkintoolSpending__c = (inComeQCAccountData.skintool_iconsidebar_spending ==null? 0 : inComeQCAccountData.skintool_iconsidebar_spending) 
                                            + (inComeQCAccountData.skintool_masthead_spending ==null? 0 : inComeQCAccountData.skintool_masthead_spending)
                                            + (inComeQCAccountData.skintool_masthead_video_spending ==null? 0 : inComeQCAccountData.skintool_masthead_video_spending)
                                            + (inComeQCAccountData.skintool_skin_spending ==null? 0 : inComeQCAccountData.skintool_skin_spending)
                                            + (inComeQCAccountData.Skintool_Video_Banner_Spending ==null? 0 : inComeQCAccountData.Skintool_Video_Banner_Spending)
                                            + (inComeQCAccountData.skintool_video_skin_spending ==null? 0 : inComeQCAccountData.skintool_video_skin_spending)
                                            + (inComeQCAccountData.skintool_vast_skin_spending ==null? 0 : inComeQCAccountData.skintool_vast_skin_spending);

        qcAccData.TotalSkintoolClick__c = (inComeQCAccountData.skintool_iconsidebar_click ==null? 0 : inComeQCAccountData.skintool_iconsidebar_click) 
                                            + (inComeQCAccountData.skintool_masthead_click ==null? 0 : inComeQCAccountData.skintool_masthead_click)
                                            + (inComeQCAccountData.skintool_masthead_video_click ==null? 0 : inComeQCAccountData.skintool_masthead_video_click)
                                            + (inComeQCAccountData.skintool_skin_click ==null? 0 : inComeQCAccountData.skintool_skin_click)
                                            + (inComeQCAccountData.Skintool_Video_Banner_click ==null? 0 : inComeQCAccountData.Skintool_Video_Banner_click)
                                            + (inComeQCAccountData.skintool_video_skin_click ==null? 0 : inComeQCAccountData.skintool_video_skin_click)
                                            + (inComeQCAccountData.skintool_vast_skin_click ==null? 0 : inComeQCAccountData.skintool_vast_skin_click);

        qcAccData.TotalSkintoolImpression__c = (inComeQCAccountData.skintool_iconsidebar_view ==null? 0 : inComeQCAccountData.skintool_iconsidebar_view) 
                                            + (inComeQCAccountData.skintool_masthead_view ==null? 0 : inComeQCAccountData.skintool_masthead_view)
                                            + (inComeQCAccountData.skintool_masthead_video_view ==null? 0 : inComeQCAccountData.skintool_masthead_video_view)
                                            + (inComeQCAccountData.skintool_skin_view ==null? 0 : inComeQCAccountData.skintool_skin_view)
                                            + (inComeQCAccountData.Skintool_Video_Banner_view ==null? 0 : inComeQCAccountData.Skintool_Video_Banner_view)
                                            + (inComeQCAccountData.skintool_video_skin_view ==null? 0 : inComeQCAccountData.skintool_video_skin_view)
                                            + (inComeQCAccountData.skintool_vast_skin_view ==null? 0 : inComeQCAccountData.skintool_vast_skin_view);
        return qcAccData;
    }
    public static Map<string, QC_Account_Data__c> getQCAccountDataMap(List<QC_Account_Data__c> qcAccountDataExistList){
        Map<string, QC_Account_Data__c> qcAccountDataExistMap = new Map<string, QC_Account_Data__c>();
        for( QC_Account_Data__c item: qcAccountDataExistList){
            if( !qcAccountDataExistMap.containsKey(item.mappingkey__c) ){
                qcAccountDataExistMap.put(item.mappingkey__c, item);
            }
        }
        return qcAccountDataExistMap;
    }
     public static void handleValidQCAccount( Map<string,qc_Account__c> qcAccountInvalidMap, qc_Account__c qc){
        if(string.isBlank(qc.industry__c) || string.isBlank(qc.Agency__c) || string.isBlank(qc.Sales__c)){
            if(!qcAccountInvalidMap.containsKey(qc.id)){
                qcAccountInvalidMap.put(qc.id, qc);
            }
        }
        
    }
    public static void handleSendEmailandChatter(Map<string,qc_Account__c> qcAccountInvalidMap){
         cc_setting__c setting = cc_Util.getCustomSetting();
        List<cc_ChatterBatchWrapper> postList = new List<cc_ChatterBatchWrapper>();
        Set<string> qcIdInvalidList = qcAccountInvalidMap.keySet();
        List<string> generalIdList = setting.Fixing_Payment_and_Spending__c.split(',');
        Set<string> generalIdSet = new Set<string>();
        string generalIdZero = '';
        for(string item: generalIdList){
            generalIdSet.add(item);
            if( generalIdZero == '')
                generalIdZero = item;
        }
        string hotlineTeam = [select id from Group where Type =:'Queue' and name =: 'Hotline'].Id;
        cc_ChatterBatchWrapper hotlinePost = new cc_ChatterBatchWrapper();
        boolean sendEmailToHotline = false;
        for(string item: qcIdInvalidList){
            qc_Account__c qcInvalid = qcAccountInvalidMap.get(item);
            Id notifyToId;
            string error ='QC Account:' + qcInvalid.Name + '\n\t';
            if( string.isBlank(qcInvalid.OwnerId)){
                notifyToId = generalIdZero;
            }
            if( !string.isBlank(qcInvalid.OwnerId) && generalIdSet.contains(qcInvalid.OwnerId)){
                //hotline
                notifyToId = hotlineTeam;
            }
            else{
                //assign for owner
                notifyToId = qcInvalid.OwnerId;
            }
            if(string.isBlank(qcInvalid.sales__c)){
                error += 'Sale can not be null' + '\n\t';
            }
             if(string.isBlank(qcInvalid.Industry__c) && !string.isBlank(qcInvalid.Agency__c) && qcInvalid.Agency__c != 'Global Agency' ){
                    error += 'Industry can not be null' + '\n\t';
             }
             
            if(string.isBlank(qcInvalid.Agency__c) || qcInvalid.Agency__c == 'Other'){
                error += 'Qc Account has not linked to Account Owner';
            }
            cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
            post.idList.add(notifyToId);
            post.recordId = qcInvalid.id;
            post.message =  error;
            if( notifyToId == hotlineTeam ){
                sendEmailToHotline = true;
                hotlinePost.idList.add(notifyToId);
                hotlinePost.isEmail = true;
                hotlinePost.title = 'Fix invalid qc account';
                hotlinePost.body = 'Dear Hotline Team <br/>';
                hotlinePost.toEmail = 'support_qc@coccoc.vn';
                if( !string.isBlank(hotlinePost.body)){
                    hotlinePost.body += '<br/>';
                }
                hotlinePost.body += error.replace('\n\t', '<br/>');
                hotlinePost.key = 'QCAccountQCToDataQCtoSF';
            }
            else{
                postList.add(post);
            }
            
        }
        if(sendEmailToHotline){
            postList.add(hotlinePost);
        }        
        cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(postList);
        database.executeBatch(batch);
    }
}