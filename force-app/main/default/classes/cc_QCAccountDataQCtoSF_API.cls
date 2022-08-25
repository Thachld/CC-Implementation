@RestResource(urlMapping='/qcaccountdataqctosf')
global class cc_QCAccountDataQCtoSF_API {
    @HttpPost
    global static string doPostAccountFromQCSystem(){
        QCAccountDataWrapper.Responds rp = new QCAccountDataWrapper.Responds();
        
        cc_setting__c setting = cc_Util.getCustomSetting();
        Map<string,qc_Account__c> qcAccountInvalidMap = new Map<string,qc_Account__c>();
        try{
            List<QCAccountDataWrapper> incomeQCAccountList = QCAccountDataWrapper.parse(RestContext.request.requestBody.tostring());

            
            Map<integer,QCAccountDataWrapper> incomeQCAccountMap =  initMapQCAccountIncome( incomeQCAccountList);
            Map<integer, QC_Account_Data__c> qcAccountInsertTempMap = new Map<integer,QC_Account_Data__c>();
            Map<integer, QC_Account_Data__c> qcAccountInsertMap = new Map<integer,QC_Account_Data__c>();
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
            
            List<QC_Account__c> qcAccountList = [select id,Name,AccountOwner__c, Industry__c,Sales__c,Support__c,Sales__r.IsActive,Support__r.IsActive, QC_Account_Id__c,Balance__c, Agency__c, OwnerId, Type__c  from QC_Account__c where QC_Account_Id__c in:qcAccountIdSet];
            Map<string, QC_Account__c> qcAccountMap = new Map<string,QC_Account__c>( );
            for( integer i = 0; i< qcAccountList.size(); i++){
                if( !qcAccountMap.containsKey(qcAccountList.get(i).QC_Account_Id__c)){
                    qcAccountMap.put(qcAccountList.get(i).QC_Account_Id__c, qcAccountList.get(i));
                }
            }            
            
            List<integer> customerIdListTemp = new List<integer>();
            for(integer i = 0; i < incomeQCAccountList.size(); i++){
                QC_Account_Data__c qcAccData = initQCAccountData(incomeQCAccountList.get(i));
                QC_Account__c qcAccount = qcAccountMap.get(incomeQCAccountList.get(i).customer_id);
                if( qcAccount != null){
                    qcAccData.Name = qcAccount.name;
                    if( qcAccData.syn_date__c != null){
                        qcAccData.Name = qcAccount.name + ' ' + incomeQCAccountList.get(i).synDateString;
                        qcAccData.mappingkey__c  = incomeQCAccountList.get(i).customer_id +'_' + incomeQCAccountList.get(i).synDateString;
                    }

                    if( qcAccountDataExistMap.containsKey(qcAccData.mappingkey__c) ){
                        qcAccData.Id = qcAccountDataExistMap.get(qcAccData.mappingkey__c).id;
                    }
                    else{
                        
                        qcAccData.QC_Account__c = qcAccount.id;
                        if( !String.isBlank(qcAccount.AccountOwner__c) && String.isBlank(qcAccData.Accounts__c)){
                            qcAccData.Accounts__c = qcAccount.AccountOwner__c;
                        }
                        if(string.isBlank(qcAccData.Support__c)){
                            qcAccData.Support__c = qcAccount.Support__c;
                        }  
                            
                        if( string.isBlank(qcAccData.Sale__c)){
                            qcAccData.Sale__c = qcAccount.Sales__c;
                        }  
                        
                        if( string.isBlank(qcAccData.Agency__c)){
                            qcAccData.Agency__c = qcAccount.Agency__c;
                        }
                        if(string.isBlank(qcAccData.Industry__c)){
                            qcAccData.Industry__c = qcAccount.Industry__c;    
                        }   

                        qcAccData.Balance__c = qcAccount.Balance__c; 
                    }

                    if(Test.isRunningTest() || 
                        (   qcAccount.Type__c != 'External' 
                            && qcAccount.Type__c != 'Internal' 
                            &&  qcAccData.Total_Spending__c > 0 
                            && setting.Notify_missing_in_QC_Account__c == true)
                            ){
                        handleValidQCAccount(qcAccountInvalidMap, qcAccount);                        
                    }
                }
                else{
                    QCAccountDataWrapper.QCAccountDataError error = new QCAccountDataWrapper.QCAccountDataError();
                    error.incomeError = incomeQCAccountMap.get(integer.valueOf(incomeQCAccountList.get(i).customer_id));
                    error.insertError = 'Can not find QC Account qcaccountdataskintooltosf';
                    rp.qcAccountError.add(error);
                    continue;
                }
                customerIdListTemp.add(integer.valueOf(incomeQCAccountList.get(i).customer_id));
                qcAccountInsertTempMap.put(integer.valueOf(incomeQCAccountList.get(i).customer_id),qcAccData);
            }
            customerIdListTemp.sort();
            for(integer item: customerIdListTemp){
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
                cc_Util.writeLog('KPI report data qcaccountdataqctosf','kpi report error', system.JSON.serialize(rp));
            }
        }
        catch(Exception ex){
            rp.error = ex.getMessage();
            string strbody = '';
            if(RestContext.request.requestBody == null){
                cc_Util.writeLog('KPI report data qcaccountdataqctosf',ex.getMessage(), 'null');
            }
            if( RestContext.request.requestBody.tostring().length() <=100 )
            {
                strbody += RestContext.request.requestBody.tostring();
            }
            else{
                strbody += RestContext.request.requestBody.tostring().substring(0,100);
            }
            if( setting.is_write_api_log__c){
                cc_Util.writeLog('KPI report data qcaccountdatasqctosf',ex.getMessage(), strbody);
            }
            else{
                cc_Util.writeLog('KPI report data qcaccountdataqctosf',ex.getMessage(), strbody);
            }
            return system.JSON.serialize(rp);
        }
        return system.JSON.serialize(rp);
    }
    public static Map<integer,QCAccountDataWrapper> initMapQCAccountIncome(List<QCAccountDataWrapper> incomeQCAccountList){
        Map<integer,QCAccountDataWrapper> result  = new Map<integer,QCAccountDataWrapper>();
        for(QCAccountDataWrapper item: incomeQCAccountList ){
            result.put(integer.valueOf(item.customer_id), item );
        }
        return result;
    }
    public static QC_Account_Data__c initQCAccountData(QCAccountDataWrapper inComeQCAccountData){
        QC_Account_Data__c qcAccData = new QC_Account_Data__c();
        qcAccData.syn_date__c = inComeQCAccountData.synDate;
        if(inComeQCAccountData.serp_desktop_click != null )
            qcAccData.serp_desktop_click__c = inComeQCAccountData.serp_desktop_click;
        if(inComeQCAccountData.serp_desktop_show != null )
            qcAccData.serp_desktop_show__c = inComeQCAccountData.serp_desktop_show;
        if(inComeQCAccountData.serp_desktop_spending != null )
            qcAccData.serp_desktop_spending__c = inComeQCAccountData.serp_desktop_spending;
        
        if(inComeQCAccountData.serp_banners_click != null )
            qcAccData.serp_banners_click__c = inComeQCAccountData.serp_banners_click;
        if(inComeQCAccountData.serp_banners_show != null )
            qcAccData.serp_banners_show__c = inComeQCAccountData.serp_banners_show;
        if(inComeQCAccountData.serp_banners_spending != null )
            qcAccData.serp_banners_spending__c = inComeQCAccountData.serp_banners_spending;
        
        if(inComeQCAccountData.serp_market_click != null )
            qcAccData.serp_market_click__c = inComeQCAccountData.serp_market_click;
        if(inComeQCAccountData.serp_market_show != null )
            qcAccData.serp_market_show__c = inComeQCAccountData.serp_market_show;
        if(inComeQCAccountData.serp_market_spending != null )
            qcAccData.serp_market_spending__c = inComeQCAccountData.serp_market_spending;
        
        if(inComeQCAccountData.serp_mobile_click != null )
            qcAccData.serp_mobile_click__c = inComeQCAccountData.serp_mobile_click;
        if(inComeQCAccountData.serp_mobile_show != null )
            qcAccData.serp_mobile_show__c = inComeQCAccountData.serp_mobile_show;
        if(inComeQCAccountData.serp_mobile_spending != null )
            qcAccData.serp_mobile_spending__c = inComeQCAccountData.serp_mobile_spending;
        
        if(inComeQCAccountData.maps_click != null )
            qcAccData.maps_click__c = inComeQCAccountData.maps_click;
        if(inComeQCAccountData.maps_show != null )
            qcAccData.maps_show__c = inComeQCAccountData.maps_show;
        if(inComeQCAccountData.maps_spending != null )
            qcAccData.maps_spending__c = inComeQCAccountData.maps_spending;
        
        if(inComeQCAccountData.icons_newtab_click != null )
            qcAccData.icons_newtab_click__c = inComeQCAccountData.icons_newtab_click;
        if(inComeQCAccountData.icons_newtab_show != null )
            qcAccData.icons_newtab_show__c = inComeQCAccountData.icons_newtab_show;
        if(inComeQCAccountData.icons_newtab_spending != null )
            qcAccData.icons_newtab_spending__c = inComeQCAccountData.icons_newtab_spending;
        
        if(inComeQCAccountData.new_tab_click != null )
            qcAccData.new_tab_click__c = inComeQCAccountData.new_tab_click;
        if(inComeQCAccountData.new_tab_show != null )
            qcAccData.new_tab_show__c = inComeQCAccountData.new_tab_show;
        if(inComeQCAccountData.new_tab_spending != null )
            qcAccData.new_tab_spending__c = inComeQCAccountData.new_tab_spending;
        
        if(inComeQCAccountData.new_tab_js_code_click != null )
            qcAccData.new_tab_js_code_click__c = inComeQCAccountData.new_tab_js_code_click;
        if(inComeQCAccountData.new_tab_js_code_show != null )
            qcAccData.new_tab_js_code_show__c = inComeQCAccountData.new_tab_js_code_show;
        if(inComeQCAccountData.new_tab_js_code_spending != null )
            qcAccData.new_tab_js_code_spending__c = inComeQCAccountData.new_tab_js_code_spending;
        
        if(inComeQCAccountData.skins_click != null )
            qcAccData.skins_click__c = inComeQCAccountData.skins_click;
        if(inComeQCAccountData.skins_show != null )
            qcAccData.skins_show__c = inComeQCAccountData.skins_show;
        if(inComeQCAccountData.skins_spending != null )
            qcAccData.skins_spending__c = inComeQCAccountData.skins_spending;
        
        if(inComeQCAccountData.masthead_click != null )
            qcAccData.masthead_click__c = inComeQCAccountData.masthead_click;
        if(inComeQCAccountData.masthead_show != null )
            qcAccData.masthead_show__c = inComeQCAccountData.masthead_show;
        if(inComeQCAccountData.masthead_spending != null )
            qcAccData.masthead_spending__c = inComeQCAccountData.masthead_spending;
        
        if(inComeQCAccountData.masthead_jscode_show != null )
            qcAccData.masthead_jscode_show__c = inComeQCAccountData.masthead_jscode_show;
        if(inComeQCAccountData.masthead_jscode_click != null )
            qcAccData.masthead_jscode_click__c = inComeQCAccountData.masthead_jscode_click;
        if(inComeQCAccountData.masthead_jscode_spending != null )
            qcAccData.masthead_jscode_spending__c = inComeQCAccountData.masthead_jscode_spending;
        
        if(inComeQCAccountData.video_click != null )
            qcAccData.video_click__c = inComeQCAccountData.video_click;
        if(inComeQCAccountData.video_show != null )
            qcAccData.video_show__c = inComeQCAccountData.video_show;
        if(inComeQCAccountData.video_spending != null )
            qcAccData.video_spending__c = inComeQCAccountData.video_spending;
        
        if(inComeQCAccountData.video_masthead_click != null )
            qcAccData.video_masthead_click__c = inComeQCAccountData.video_masthead_click;
        if(inComeQCAccountData.video_masthead_show != null )
            qcAccData.video_masthead_show__c = inComeQCAccountData.video_masthead_show;
        if(inComeQCAccountData.video_masthead_spending != null )
            qcAccData.video_masthead_spending__c = inComeQCAccountData.video_masthead_spending;
        
        if(inComeQCAccountData.mb_general_click != null )
            qcAccData.mb_general_click__c = inComeQCAccountData.mb_general_click;
        if(inComeQCAccountData.mb_general_show != null )
            qcAccData.mb_general_show__c = inComeQCAccountData.mb_general_show;
        if(inComeQCAccountData.mb_general_spending != null )
            qcAccData.mb_general_spending__c = inComeQCAccountData.mb_general_spending;
        
        if(inComeQCAccountData.single_zen_cards_click != null )
            qcAccData.single_zen_cards_click__c = inComeQCAccountData.single_zen_cards_click;
        if(inComeQCAccountData.single_zen_cards_show != null )
            qcAccData.single_zen_cards_show__c = inComeQCAccountData.single_zen_cards_show;
        if(inComeQCAccountData.single_zen_cards_spending != null )
            qcAccData.single_zen_cards_spending__c = inComeQCAccountData.single_zen_cards_spending;
        
        if(inComeQCAccountData.double_zen_cards_click != null )
            qcAccData.double_zen_cards_click__c = inComeQCAccountData.double_zen_cards_click;
        if(inComeQCAccountData.double_zen_cards_show != null )
            qcAccData.double_zen_cards_show__c = inComeQCAccountData.double_zen_cards_show;
        if(inComeQCAccountData.double_zen_cards_spending != null )
            qcAccData.double_zen_cards_spending__c = inComeQCAccountData.double_zen_cards_spending;
        
        if(inComeQCAccountData.other_show != null )
            qcAccData.other_show__c = inComeQCAccountData.other_show;
        if(inComeQCAccountData.other_click != null )
            qcAccData.other_click__c = inComeQCAccountData.other_click;
        if(inComeQCAccountData.other_spending != null )
            qcAccData.other_spending__c = inComeQCAccountData.other_spending;
        
        if(inComeQCAccountData.overspending != null )
            qcAccData.overspending__c = inComeQCAccountData.overspending;
        if(inComeQCAccountData.coupon_spending != null )
            qcAccData.coupon_spending__c = inComeQCAccountData.coupon_spending;
        if(inComeQCAccountData.real_spending != null )
            qcAccData.real_spending__c = inComeQCAccountData.real_spending;
 
        // if ( inComeQCAccountData.vast_skin_show != null ) 
            // qcAccData.vast_skin_show__c = inComeQCAccountData.vast_skin_show;
        // if ( inComeQCAccountData.vast_skin_click != null ) 
            // qcAccData.vast_skin_click__c = inComeQCAccountData.vast_skin_click;
        // if ( inComeQCAccountData.vast_skin_spending != null ) 
            // qcAccData.vast_skin_spending__c = inComeQCAccountData.vast_skin_spending;

        if ( inComeQCAccountData.native_content_ad_show != null ) 
            qcAccData.native_content_ad_show__c = inComeQCAccountData.native_content_ad_show;
        if ( inComeQCAccountData.native_content_ad_click != null ) 
            qcAccData.native_content_ad_click__c = inComeQCAccountData.native_content_ad_click;
        if ( inComeQCAccountData.native_content_ad_spending != null ) 
            qcAccData.native_content_ad_spending__c = inComeQCAccountData.native_content_ad_spending;

        if ( inComeQCAccountData.native_content_ad_external_show != null ) 
            qcAccData.native_content_ad_external_show__c = inComeQCAccountData.native_content_ad_external_show;
        if ( inComeQCAccountData.native_content_ad_external_click != null ) 
            qcAccData.native_content_ad_external_click__c = inComeQCAccountData.native_content_ad_external_click;
        if ( inComeQCAccountData.native_content_ad_external_spending != null ) 
            qcAccData.native_content_ad_external_spending__c = inComeQCAccountData.native_content_ad_external_spending;

        if ( inComeQCAccountData.real_Balance != null )
            qcAccData.real_Balance__c = inComeQCAccountData.real_Balance;
        if ( inComeQCAccountData.coupon_Balance != null ) 
            qcAccData.coupon_Balance__c = inComeQCAccountData.coupon_Balance; 
        if ( inComeQCAccountData.refund_Balance != null ) 
            qcAccData.refund_Balance__c = inComeQCAccountData.refund_Balance;


        //single_zen_cards_mobile
        if ( inComeQCAccountData.single_zen_cards_mobile_show != null ){
            qcAccData.single_zen_cards_mobile_show__c = inComeQCAccountData.single_zen_cards_mobile_show;
        }
            
        if ( inComeQCAccountData.single_zen_cards_mobile_click != null ){
            qcAccData.single_zen_cards_mobile_click__c = inComeQCAccountData.single_zen_cards_mobile_click;
        }
            
        if ( inComeQCAccountData.single_zen_cards_mobile_spending != null ){
            qcAccData.single_zen_cards_mobile_spending__c = inComeQCAccountData.single_zen_cards_mobile_spending;
        }
            


        Decimal TotalQCSpending    =  (inComeQCAccountData.serp_banners_spending ==null?0: inComeQCAccountData.serp_banners_spending) 
                                    + (inComeQCAccountData.double_zen_cards_spending ==null?0: inComeQCAccountData.double_zen_cards_spending) 
                                    + (inComeQCAccountData.skins_spending ==null?0: inComeQCAccountData.skins_spending) 
                                    + (inComeQCAccountData.serp_desktop_spending ==null?0: inComeQCAccountData.serp_desktop_spending) 
                                    + (inComeQCAccountData.icons_newtab_spending ==null?0: inComeQCAccountData.icons_newtab_spending) 
                                    + (inComeQCAccountData.masthead_spending ==null?0: inComeQCAccountData.masthead_spending) 
                                    + (inComeQCAccountData.video_masthead_spending ==null?0: inComeQCAccountData.video_masthead_spending) 
                                    + (inComeQCAccountData.maps_spending ==null?0: inComeQCAccountData.maps_spending) 
                                    + (inComeQCAccountData.mb_general_spending ==null?0: inComeQCAccountData.mb_general_spending) 
                                    + (inComeQCAccountData.serp_mobile_spending ==null?0: inComeQCAccountData.serp_mobile_spending) 
                                    + (inComeQCAccountData.new_tab_js_code_spending ==null?0: inComeQCAccountData.new_tab_js_code_spending) 
                                    + (inComeQCAccountData.new_tab_spending ==null?0: inComeQCAccountData.new_tab_spending) 
                                    + (inComeQCAccountData.serp_market_spending ==null?0: inComeQCAccountData.serp_market_spending) 
                                    + (inComeQCAccountData.single_zen_cards_spending ==null?0: inComeQCAccountData.single_zen_cards_spending)
                                    + (inComeQCAccountData.video_spending ==null?0: inComeQCAccountData.video_spending)
                                    + (inComeQCAccountData.masthead_jscode_spending ==null?0: inComeQCAccountData.masthead_jscode_spending)
                                    + (inComeQCAccountData.other_spending ==null?0: inComeQCAccountData.other_spending)
                                    + (inComeQCAccountData.vast_skin_spending ==null?0: inComeQCAccountData.vast_skin_spending)                                    
                                    + (inComeQCAccountData.native_content_ad_spending ==null?0: inComeQCAccountData.native_content_ad_spending)
                                    + (inComeQCAccountData.native_content_ad_external_spending ==null?0: inComeQCAccountData.native_content_ad_external_spending)           
                                    + (inComeQCAccountData.single_zen_cards_mobile_spending ==null?0: inComeQCAccountData.single_zen_cards_mobile_spending)                                                       
                                    ; 
        if(TotalQCSpending > 0 && TotalQCSpending != null){
            qcAccData.TotalQCSpending__c = TotalQCSpending;
        }

        Integer TotalQCClick       =  (inComeQCAccountData.serp_banners_click ==null?0: inComeQCAccountData.serp_banners_click) 
                                    + (inComeQCAccountData.double_zen_cards_click ==null?0: inComeQCAccountData.double_zen_cards_click) 
                                    + (inComeQCAccountData.skins_click ==null?0: inComeQCAccountData.skins_click) 
                                    + (inComeQCAccountData.serp_desktop_click ==null?0: inComeQCAccountData.serp_desktop_click) 
                                    + (inComeQCAccountData.icons_newtab_click ==null?0: inComeQCAccountData.icons_newtab_click) 
                                    + (inComeQCAccountData.masthead_click ==null?0: inComeQCAccountData.masthead_click) 
                                    + (inComeQCAccountData.video_masthead_click ==null?0: inComeQCAccountData.video_masthead_click) 
                                    + (inComeQCAccountData.maps_click ==null?0: inComeQCAccountData.maps_click) 
                                    + (inComeQCAccountData.mb_general_click ==null?0: inComeQCAccountData.mb_general_click) 
                                    + (inComeQCAccountData.serp_mobile_click ==null?0: inComeQCAccountData.serp_mobile_click) 
                                    + (inComeQCAccountData.new_tab_js_code_click ==null?0: inComeQCAccountData.new_tab_js_code_click) 
                                    + (inComeQCAccountData.new_tab_click ==null?0: inComeQCAccountData.new_tab_click) 
                                    + (inComeQCAccountData.serp_market_click ==null?0: inComeQCAccountData.serp_market_click) 
                                    + (inComeQCAccountData.single_zen_cards_click ==null?0: inComeQCAccountData.single_zen_cards_click)
                                    + (inComeQCAccountData.video_click ==null?0: inComeQCAccountData.video_click)
                                    + (inComeQCAccountData.masthead_jscode_click ==null?0: inComeQCAccountData.masthead_jscode_click)
                                    + (inComeQCAccountData.other_click ==null?0: inComeQCAccountData.other_click)
                                    + (inComeQCAccountData.vast_skin_click ==null?0: inComeQCAccountData.vast_skin_click)                                    
                                    + (inComeQCAccountData.native_content_ad_click ==null?0: inComeQCAccountData.native_content_ad_click)
                                    + (inComeQCAccountData.native_content_ad_external_click ==null?0: inComeQCAccountData.native_content_ad_external_click)
                                    + (inComeQCAccountData.single_zen_cards_mobile_click ==null?0: inComeQCAccountData.single_zen_cards_mobile_click)                                    
                                    ; 
        
        if(TotalQCClick > 0 && TotalQCClick != null){
            qcAccData.TotalQCClick__c = TotalQCClick;
        }
        

        Integer TotalQCImpression  =  (inComeQCAccountData.serp_banners_show ==null?0: inComeQCAccountData.serp_banners_show) 
                                    + (inComeQCAccountData.double_zen_cards_show ==null?0: inComeQCAccountData.double_zen_cards_show) 
                                    + (inComeQCAccountData.skins_show ==null?0: inComeQCAccountData.skins_show) 
                                    + (inComeQCAccountData.serp_desktop_show ==null?0: inComeQCAccountData.serp_desktop_show) 
                                    + (inComeQCAccountData.icons_newtab_show ==null?0: inComeQCAccountData.icons_newtab_show) 
                                    + (inComeQCAccountData.masthead_show ==null?0: inComeQCAccountData.masthead_show) 
                                    + (inComeQCAccountData.video_masthead_show ==null?0: inComeQCAccountData.video_masthead_show) 
                                    + (inComeQCAccountData.maps_show ==null?0: inComeQCAccountData.maps_show) 
                                    + (inComeQCAccountData.mb_general_show ==null?0: inComeQCAccountData.mb_general_show) 
                                    + (inComeQCAccountData.serp_mobile_show ==null?0: inComeQCAccountData.serp_mobile_show) 
                                    + (inComeQCAccountData.new_tab_js_code_show ==null?0: inComeQCAccountData.new_tab_js_code_show) 
                                    + (inComeQCAccountData.new_tab_show ==null?0: inComeQCAccountData.new_tab_show) 
                                    + (inComeQCAccountData.serp_market_show ==null?0: inComeQCAccountData.serp_market_show) 
                                    + (inComeQCAccountData.single_zen_cards_show ==null?0: inComeQCAccountData.single_zen_cards_show)
                                    + (inComeQCAccountData.video_show ==null?0: inComeQCAccountData.video_show)
                                    + (inComeQCAccountData.masthead_jscode_show ==null?0: inComeQCAccountData.masthead_jscode_show)
                                    + (inComeQCAccountData.other_show ==null?0: inComeQCAccountData.other_show)
                                    + (inComeQCAccountData.vast_skin_show ==null?0: inComeQCAccountData.vast_skin_show)                                    
                                    + (inComeQCAccountData.native_content_ad_show ==null?0: inComeQCAccountData.native_content_ad_show)
                                    + (inComeQCAccountData.native_content_ad_external_show ==null?0: inComeQCAccountData.native_content_ad_external_show) 
                                    + (inComeQCAccountData.single_zen_cards_mobile_show ==null?0: inComeQCAccountData.single_zen_cards_mobile_show)                                    
                                    ; 

        if(TotalQCImpression > 0 && TotalQCImpression != null){
            qcAccData.TotalQCImpression__c = TotalQCImpression;
        }
        
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
        if(string.isBlank(qc.industry__c) || string.isBlank(qc.Agency__c) || string.isBlank(qc.Sales__c) ){
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