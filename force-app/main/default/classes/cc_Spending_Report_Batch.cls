global class cc_Spending_Report_Batch implements Database.Batchable<sObject>, Database.Stateful{
	
   global Map<string, Spending_Report__c> spendingReportMap {get;set;}
    public dateTime dtFrom {get;set;}
    public dateTime dtTo {get;set;}
    public set<id>     qcAccountSet {get;set;}
    public cc_Spending_Report_Batch(string strDate, set<Id> qcAccountSetTemp){
        spendingReportMap = new Map<string, Spending_Report__c>();
        qcAccountSet = qcAccountSetTemp;
        Datetime dtlastMonth = datetime.now();
        if( !string.isBlank(strDate)){
            string[] M = strDate.split('/');
            dtlastMonth = DateTime.NewInstance(integer.valueOf(M[2]), integer.valueOf(M[1]),integer.valueOf(M[0]));
        }
        else{
            dtlastMonth = dtlastMonth.addMonths(-1);
        }
        
        integer noOfDays = Date.daysInMonth(dtlastMonth.year(), dtlastMonth.month());
        //NewInstanceGMT
        dtFrom = DateTime.NewInstance( dtlastMonth.year(), dtlastMonth.month(), 1, 0,0,0);
        dtTo = DateTime.NewInstance( dtlastMonth.year(), dtlastMonth.month(), noOfDays,23,59,59);
       
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
       
       return database.getqueryLocator([select id, name,syn_date__c,QC_Account__r.Sale_Email__c ,QC_Account__r.Owner.Name, QC_Account__c,QC_Account__r.Name, QC_Account__r.AccountOwner__r.name,QC_Account__r.Agency_Email__c,QC_Account__r.Agency_QC_Account__r.QC_Account_Id__c, 
                                        Sale__r.name,serp_desktop_show__c, serp_desktop_click__c, serp_desktop_spending__c,
                                        serp_banners_show__c, serp_banners_click__c,serp_banners_spending__c,
                                        serp_mobile_show__c, serp_mobile_click__c,serp_mobile_spending__c, 
                                        new_tab_show__c, new_tab_click__c, new_tab_spending__c,
                                        icons_newtab_show__c, icons_newtab_click__c,icons_newtab_spending__c,
                                        maps_show__c, maps_click__c, maps_spending__c,
                                        skins_show__c, skins_click__c, skins_spending__c,
                                        serp_market_show__c, serp_market_click__c, serp_market_spending__c,
                                        mb_general_show__c, mb_general_click__c, mb_general_spending__c,
                                        single_zen_cards_show__c, single_zen_cards_click__c, single_zen_cards_spending__c,
                                        masthead_show__c, masthead_click__c, masthead_spending__c,
                                        skintool_masthead_video_view__c, skintool_masthead_video_click__c, skintool_masthead_video_spending__c,
                                        masthead_jscode_show__c, masthead_jscode_click__c, masthead_jscode_spending__c,
                                        double_zen_cards_show__c, double_zen_cards_click__c, double_zen_cards_spending__c,
                                        skintool_video_banner_view__c, skintool_video_banner_click__c, skintool_video_banner_spending__c,
                                        real_spending__c, coupon_spending__c,overspending__c,
                                        video_show__c, video_spending__c, video_click__c,
                                        video_masthead_show__c, video_masthead_click__c, video_masthead_spending__c,
                                        new_tab_js_code_show__c, new_tab_js_code_click__c, new_tab_js_code_spending__c,
                                        coupon_Balance__c,real_Balance__c
                                        // ,vast_skin_spending__c, 
                                        // vast_skin_click__c,
                                        // vast_skin_show__c
                                        from QC_Account_Data__c 
                                        where syn_date__c >=: dtFrom and syn_date__c <=: dtTo and QC_Account__c in:qcAccountSet
                                       order by syn_date__c desc]);
    }
     global void execute(Database.BatchableContext bc, List<QC_Account_Data__c> qcAccountDataList){
         for(QC_Account_Data__c item: qcAccountDataList){
             Spending_Report__c spReport;
             if(!spendingReportMap.containsKey(item.QC_Account__c)){
                 //spReport = initSPReport();
                 spReport = new Spending_Report__c();
                 setSPReportValue(spReport,item );
             }
             else{
                 spReport = spendingReportMap.get(item.QC_Account__c);
                 setSPReportValue(spReport,item );
             }
             spReport.Client_email__c= item.QC_Account__r.Name;
             spReport.Company_Name__c =  item.QC_Account__r.AccountOwner__r.name;
             spReport.Agency_Email__c = item.QC_Account__r.Agency_Email__c;
             if(!string.isBlank(item.QC_Account__r.Agency_QC_Account__r.QC_Account_Id__c)){
                 spReport.Agency_Id__c = Decimal.valueOf(item.QC_Account__r.Agency_QC_Account__r.QC_Account_Id__c);
             }
             
			 spReport.Sale_Email__c = item.QC_Account__r.Sale_Email__c;	   
             if(!spendingReportMap.containsKey(item.QC_Account__c)){
                 spendingReportMap.put(item.QC_Account__c, spReport);
             }
             spReport.QC_Accounts__c = item.QC_Account__c;
             spReport.Report_month__c = date.newInstance(dtFrom.year(), dtFrom.month(), dtFrom.day()) ;
         }
     }
     global void finish(Database.BatchableContext bc){ 
         
         Map<string, decimal> qcAccountPaymentin = new Map<string, decimal>();
         Map<string, decimal> qcAccountPaymentbonus = new Map<string, decimal>();
         Map<id,QC_Account__c> qcAccMap  = new Map<id,QC_Account__c>([select id, name, (select id, name, coupon_Balance__c ,real_Balance__c
                                                                                        from QC_Account_Datas__r
                                                                                       where syn_date__c <: dtFrom and coupon_Balance__c != null and real_Balance__c != null
                                                                                        order by syn_date__c desc
                                                                                        limit 1)
                                                                      from QC_Account__c 
                                                                     where id in: qcAccountSet]);
         
         for( Payment__c item: [select id, name, QC_Account__c,Final_Amount__c,RecordType.name,Payment_method__c,Type__c  from Payment__c 
                                      where Done_time__c >=: dtFrom and Done_time__c <=: dtTo and Stage__c = 'Done'
                                        and QC_Account__c in: spendingReportMap.keySet() and (((Type__c =: 'INCOME' or type__c =:'WITHDRAWAL_INCOME') and recordType.Name!= 'Real Payment' ) or Payment_method__c =:'Coupon') 
                                           ]){
                                                //and recordType.Name!= 'Refund payment')
             if( item.Payment_method__c !='Coupon' ){
                 if ( !qcAccountPaymentin.containsKey(item.QC_Account__c)){
                      decimal paymentin = item.Final_Amount__c == null? 0: item.Final_Amount__c;
                     if(item.type__c == 'WITHDRAWAL_INCOME'){
                         paymentin = -paymentin;
                     }
                      qcAccountPaymentin.put(item.QC_Account__c,paymentin);
                 }else{
                     if( item.Final_Amount__c != null){
                         decimal paymentin = qcAccountPaymentin.get(item.QC_Account__c);
                     	if(item.type__c == 'WITHDRAWAL_INCOME'){
                              paymentin += -item.Final_Amount__c;
                         }
                         else{
                             paymentin += item.Final_Amount__c;
                         }
                         
                         qcAccountPaymentin.remove(item.QC_Account__c);
                         qcAccountPaymentin.put(item.QC_Account__c, paymentin);
                     }
                 }
             }
             if(item.Payment_method__c =='Coupon'){
                 if ( !qcAccountPaymentbonus.containsKey(item.QC_Account__c)){
                      decimal paymentin = item.Final_Amount__c == null? 0: item.Final_Amount__c;
                      qcAccountPaymentbonus.put(item.QC_Account__c,paymentin);
                 }else{
                     if( item.Final_Amount__c != null){
                         decimal paymentin = qcAccountPaymentbonus.get(item.QC_Account__c);
                     
                         paymentin += item.Final_Amount__c;
                         qcAccountPaymentbonus.remove(item.QC_Account__c);
                         qcAccountPaymentbonus.put(item.QC_Account__c, paymentin);
                     }
                 }
             }
         }
         for(string item: spendingReportMap.keySet())
         {
             Spending_Report__c spReport = spendingReportMap.get(item);
             if(qcAccountPaymentin.containsKey(item) ){
                 spReport.Payment_in__c = qcAccountPaymentin.get(item);
             }
             if(qcAccountPaymentbonus.containsKey(item) ){
                 spReport.Bonus_in__c = qcAccountPaymentbonus.get(item);
             }
             QC_Account__c qc = qcAccMap.get(item);
             if(qc != null && qc.QC_Account_Datas__r != null && qc.QC_Account_Datas__r.size() >0){
                 spReport.Balance_coupon__c = qc.QC_Account_Datas__r.get(0).coupon_Balance__c;
                 spReport.Balance_real_money__c   = qc.QC_Account_Datas__r.get(0).real_Balance__c;
             }
             
         }
         database.insert(spendingReportMap.values());
      	
    }
    /*
    public Spending_Report__c initSPReport(){
        Spending_Report__c spReport = new Spending_Report__c();
       
        spReport.Balance_coupon__c =  0;
        spReport.Balance_real_money__c =  0;
        spReport.big_zenads_clicks__c =  0;
        spReport.big_zenads_price__c =  0;
        spReport.big_zenads_shows__c =  0;
        spReport.Bonus_in__c =  0;
        spReport.browser_skin_clicks__c =  0;
        spReport.browser_skin_price__c =  0;
        spReport.browser_skin_shows__c =  0;
       
        spReport.Coupon_spendings_in__c =  0;
        spReport.icon_clicks__c =  0;
        spReport.icon_price__c =  0;
        spReport.icon_shows__c =  0;
        spReport.kw_mobile_clicks__c =  0;
        spReport.kw_mobile_price__c =  0;
        spReport.kw_mobile_shows__c =  0;
        spReport.map_clicks__c =  0;
        spReport.map_price__c =  0;
        spReport.map_shows__c =  0;
        spReport.mb_clicks__c =  0;
        spReport.mb_price__c =  0;
        spReport.mb_shows__c =  0;
        spReport.mb_zen_clicks__c =  0;
        spReport.mb_zen_price__c =  0;
        spReport.mb_zen_shows__c =  0;
        spReport.mh_clicks__c =  0;
        spReport.mh_price__c =  0;
        spReport.mh_programmatic_clicks__c =  0;
        spReport.mh_programmatic_price__c =  0;
        spReport.mh_programmatic_shows__c =  0;
        spReport.mh_shows__c =  0;
        spReport.mh_video_clicks__c =  0;
        spReport.mh_video_price__c =  0;
        spReport.mh_video_shows__c =  0;
        spReport.nt_clicks__c =  0;
        spReport.nt_price__c =  0;
        spReport.nt_shows__c =  0;
        spReport.nt_video_clicks__c =  0;
        spReport.nt_video_price__c =  0;
        spReport.nt_video_shows__c =  0;
        spReport.Overspending_in__c =  0;
        spReport.Payment_in__c =  0;
        spReport.Bonus_in__c = 0;
        spReport.Real_spendings_in__c =  0;
       
        
        spReport.serp_desktop_clicks__c =  0;
        spReport.serp_desktop_price__c =  0;
        spReport.serp_desktop_shows__c =  0;
        spReport.serp_media_clicks__c =  0;
        spReport.serp_media_price__c =  0;
        spReport.serp_media_shows__c =  0;
       
        spReport.shopping_ads_clicks__c =  0;
        spReport.shopping_ads_price__c =  0;
        spReport.shopping_ads_shows__c =  0;  
        
        spReport.X1st_payment__c = 0;
        spReport.Total_Also_spending_until__c = 0;
        spReport.Total_bonuses_until__c = 0;
        spReport.Total_Spending_until__c = 0;
        spReport.Total_Also_spending_until__c = 0;
        spReport.shopping_browser_shows__c = 0;
        spReport.shopping_browser_clicks__c = 0;
        spReport.shopping_browser_price__c = 0;
        spReport.Real_spendings_until__c = 0;
        spReport.Coupon_spendings_until__c = 0;
        spReport.Overspending_until__c   = 0;
        return spReport;
    }
	*/
    public void setSPReportValue(Spending_Report__c spReport,QC_Account_Data__c item ){
		
        //spReport.Balance_real_money__c =  0;
        if( item.double_zen_cards_click__c != null){
            spReport.big_zenads_clicks__c = spReport.big_zenads_clicks__c == null? 0: spReport.big_zenads_clicks__c;
            spReport.big_zenads_clicks__c += item.double_zen_cards_click__c;
        }
        if(item.double_zen_cards_spending__c !=  null ){
            spReport.big_zenads_price__c = spReport.big_zenads_price__c == null? 0: spReport.big_zenads_price__c;
            spReport.big_zenads_price__c += item.double_zen_cards_spending__c;
        }
        if(item.double_zen_cards_show__c != null){
            spReport.big_zenads_shows__c = spReport.big_zenads_shows__c == null? 0: spReport.big_zenads_shows__c;
            spReport.big_zenads_shows__c += item.double_zen_cards_show__c;
        }
        
         
        //spReport.Bonus_in__c =  0;
        if(item.skins_click__c != null ){
            spReport.browser_skin_clicks__c = spReport.browser_skin_clicks__c == null ? 0: spReport.browser_skin_clicks__c;
            spReport.browser_skin_clicks__c += item.skins_click__c == null? 0 : item.skins_click__c;
            // spReport.browser_skin_clicks__c += item.vast_skin_click__c == null? 0 : item.vast_skin_click__c;
        }
        if(item.skins_spending__c != null 
        // || item.vast_skin_spending__c !=  null
        ){
            spReport.browser_skin_price__c = spReport.browser_skin_price__c == null ? 0: spReport.browser_skin_price__c;
            spReport.browser_skin_price__c += item.skins_spending__c == null? 0: item.skins_spending__c;
            // spReport.browser_skin_price__c += item.vast_skin_spending__c == null? 0: item.vast_skin_spending__c;
        }
         if(item.skins_show__c != null 
        //  || item.vast_skin_show__c != null
         ){
            spReport.browser_skin_shows__c = spReport.browser_skin_shows__c == null ? 0: spReport.browser_skin_shows__c;
            spReport.browser_skin_shows__c += item.skins_show__c == null? 0: item.skins_show__c;
            //  spReport.browser_skin_shows__c += item.vast_skin_show__c == null? 0: item.vast_skin_show__c;
        }
        
        if(item.coupon_spending__c != null){
            spReport.Coupon_spendings_in__c = spReport.Coupon_spendings_in__c == null ? 0: spReport.Coupon_spendings_in__c;
            spReport.Coupon_spendings_in__c += item.coupon_spending__c;
        }
        
        if(item.icons_newtab_click__c != null){
            spReport.icon_clicks__c = spReport.icon_clicks__c == null ? 0: spReport.icon_clicks__c;
            spReport.icon_clicks__c += item.icons_newtab_click__c;
        }
        if(item.icons_newtab_spending__c != null){
            spReport.icon_price__c = spReport.icon_price__c == null ? 0: spReport.icon_price__c;
            spReport.icon_price__c += item.icons_newtab_spending__c;
        }
        if(item.icons_newtab_show__c != null){
            spReport.icon_shows__c = spReport.icon_shows__c == null ? 0: spReport.icon_shows__c;
            spReport.icon_shows__c += item.icons_newtab_show__c;
        }
        
        if(item.serp_mobile_click__c != null){
            spReport.kw_mobile_clicks__c = spReport.kw_mobile_clicks__c == null ? 0: spReport.kw_mobile_clicks__c;
            spReport.kw_mobile_clicks__c += item.serp_mobile_click__c;
        }
         if(item.serp_mobile_spending__c != null){
            spReport.kw_mobile_price__c = spReport.kw_mobile_price__c == null ? 0: spReport.kw_mobile_price__c;
            spReport.kw_mobile_price__c += item.serp_mobile_spending__c;
        }
        if(item.serp_mobile_show__c != null){
            spReport.kw_mobile_shows__c = spReport.kw_mobile_shows__c == null ? 0: spReport.kw_mobile_shows__c;
            spReport.kw_mobile_shows__c += item.serp_mobile_show__c;
        }
        
        if(item.maps_click__c != null){
            spReport.map_clicks__c = spReport.map_clicks__c == null ? 0: spReport.map_clicks__c;
            spReport.map_clicks__c += item.maps_click__c;
        }
        if(item.maps_spending__c != null){
            spReport.map_price__c = spReport.map_price__c == null ? 0: spReport.map_price__c;
            spReport.map_price__c += item.maps_spending__c;
        }
        if(item.maps_show__c != null){
            spReport.map_shows__c = spReport.map_shows__c == null ? 0: spReport.map_shows__c;
            spReport.map_shows__c += item.maps_show__c;
        }
        
        
        
        if(item.mb_general_click__c != null){
            spReport.mb_clicks__c = spReport.mb_clicks__c == null ? 0: spReport.mb_clicks__c;
            spReport.mb_clicks__c += item.mb_general_click__c;
        }
        if(item.mb_general_spending__c != null){
            spReport.mb_price__c = spReport.mb_price__c == null ? 0: spReport.mb_price__c;
            spReport.mb_price__c += item.mb_general_spending__c;
        }
        if(item.mb_general_show__c != null){
            spReport.mb_shows__c = spReport.mb_shows__c == null ? 0: spReport.mb_shows__c;
            spReport.mb_shows__c += item.mb_general_show__c;
        }
        
        if(item.single_zen_cards_click__c != null){
            spReport.mb_zen_clicks__c = spReport.mb_zen_clicks__c == null ? 0: spReport.mb_zen_clicks__c;
            spReport.mb_zen_clicks__c += item.single_zen_cards_click__c;
        }
        if(item.single_zen_cards_spending__c != null){
            spReport.mb_zen_price__c = spReport.mb_zen_price__c == null ? 0: spReport.mb_zen_price__c;
            spReport.mb_zen_price__c += item.single_zen_cards_spending__c;
        }
		if(item.single_zen_cards_show__c != null){
            spReport.mb_zen_shows__c = spReport.mb_zen_shows__c == null ? 0: spReport.mb_zen_shows__c;
            spReport.mb_zen_shows__c += item.single_zen_cards_show__c;
        }        
        
        if(item.masthead_click__c != null){
            spReport.mh_clicks__c = spReport.mh_clicks__c == null ? 0: spReport.mh_clicks__c;
            spReport.mh_clicks__c += item.masthead_click__c;
        }  
        if(item.masthead_spending__c != null){
            spReport.mh_price__c = spReport.mh_price__c == null ? 0: spReport.mh_price__c;
            spReport.mh_price__c += item.masthead_spending__c;
        } 
         if(item.masthead_show__c != null){
            spReport.mh_shows__c = spReport.mh_shows__c == null ? 0: spReport.mh_shows__c;
            spReport.mh_shows__c += item.masthead_show__c;
        }
        
        if(item.masthead_jscode_click__c != null){
            spReport.mh_programmatic_clicks__c = spReport.mh_programmatic_clicks__c == null ? 0: spReport.mh_programmatic_clicks__c;
            spReport.mh_programmatic_clicks__c += item.masthead_jscode_click__c;
        }
        if(item.masthead_jscode_spending__c != null){
            spReport.mh_programmatic_price__c = spReport.mh_programmatic_price__c == null ? 0: spReport.mh_programmatic_price__c;
            spReport.mh_programmatic_price__c += item.masthead_jscode_spending__c;
        }
        if(item.masthead_jscode_show__c != null){
            spReport.mh_programmatic_shows__c = spReport.mh_programmatic_shows__c == null ? 0: spReport.mh_programmatic_shows__c;
            spReport.mh_programmatic_shows__c += item.masthead_jscode_show__c;
        }
        
        
        if(item.video_masthead_click__c != null){
            spReport.mh_video_clicks__c = spReport.mh_video_clicks__c == null ? 0: spReport.mh_video_clicks__c;
            spReport.mh_video_clicks__c += item.video_masthead_click__c;
        }
        if(item.video_masthead_spending__c != null){
            spReport.mh_video_price__c = spReport.mh_video_price__c == null ? 0: spReport.mh_video_price__c;
            spReport.mh_video_price__c += item.video_masthead_spending__c;
        }
        if(item.video_masthead_show__c != null){
            spReport.mh_video_shows__c = spReport.mh_video_shows__c == null ? 0: spReport.mh_video_shows__c;
            spReport.mh_video_shows__c += item.video_masthead_show__c;
        }
        
        
        if(item.new_tab_click__c != null || item.new_tab_js_code_click__c !=  null){
            spReport.nt_clicks__c = spReport.nt_clicks__c == null ? 0: spReport.nt_clicks__c;
            spReport.nt_clicks__c += item.new_tab_click__c == null ? 0: item.new_tab_click__c;
            spReport.nt_clicks__c += item.new_tab_js_code_click__c == null ? 0: item.new_tab_js_code_click__c;
        }
        if(item.new_tab_spending__c != null || item.new_tab_js_code_spending__c !=  null){
            spReport.nt_price__c = spReport.nt_price__c == null ? 0: spReport.nt_price__c;
            spReport.nt_price__c += item.new_tab_spending__c == null ? 0: item.new_tab_spending__c;
            spReport.nt_price__c += item.new_tab_js_code_spending__c == null ? 0: item.new_tab_js_code_spending__c;
        }
         if(item.new_tab_show__c != null || item.new_tab_js_code_show__c !=  null){
            spReport.nt_shows__c = spReport.nt_shows__c == null ? 0: spReport.nt_shows__c;
            spReport.nt_shows__c += item.new_tab_show__c == null ? 0: item.new_tab_show__c;
            spReport.nt_shows__c += item.new_tab_js_code_show__c == null ? 0: item.new_tab_js_code_show__c;
        }
        
        
         if(item.video_click__c != null){
            spReport.nt_video_clicks__c = spReport.nt_video_clicks__c == null ? 0: spReport.nt_video_clicks__c;
            spReport.nt_video_clicks__c += item.video_click__c;
        }
        if(item.video_spending__c != null){
            spReport.nt_video_price__c = spReport.nt_video_price__c == null ? 0: spReport.nt_video_price__c;
            spReport.nt_video_price__c += item.video_spending__c;
        }
         /*if(item.video_spending__c != null){
            spReport.nt_video_price__c = spReport.nt_video_price__c == null ? 0: spReport.nt_video_price__c;
            spReport.nt_video_price__c += item.video_spending__c;
        }*/
         if(item.video_show__c != null){
            spReport.nt_video_shows__c = spReport.nt_video_shows__c == null ? 0: spReport.nt_video_shows__c;
            spReport.nt_video_shows__c += item.video_show__c;
        }
        
        if(item.overspending__c != null){
            spReport.Overspending_in__c = spReport.Overspending_in__c == null ? 0: spReport.Overspending_in__c;
            spReport.Overspending_in__c += item.overspending__c;
        }
        
        //spReport.Payment_in__c =  0;
        
        if(item.real_spending__c != null){
            spReport.Real_spendings_in__c = spReport.Real_spendings_in__c == null ? 0: spReport.Real_spendings_in__c;
            spReport.Real_spendings_in__c += item.real_spending__c;
        }
              
         if(item.serp_desktop_click__c != null){
            spReport.serp_desktop_clicks__c = spReport.serp_desktop_clicks__c == null ? 0: spReport.serp_desktop_clicks__c;
            spReport.serp_desktop_clicks__c += item.serp_desktop_click__c;
        }
        if(item.serp_desktop_spending__c != null){
            spReport.serp_desktop_price__c = spReport.serp_desktop_price__c == null ? 0: spReport.serp_desktop_price__c;
            spReport.serp_desktop_price__c += item.serp_desktop_spending__c;
        }
        if(item.serp_desktop_show__c != null){
            spReport.serp_desktop_shows__c = spReport.serp_desktop_shows__c == null ? 0: spReport.serp_desktop_shows__c;
            spReport.serp_desktop_shows__c += item.serp_desktop_show__c;
        }
        
        if(item.serp_banners_click__c != null){
            spReport.serp_media_clicks__c = spReport.serp_media_clicks__c == null ? 0: spReport.serp_media_clicks__c;
            spReport.serp_media_clicks__c += item.serp_banners_click__c;
        }
       
        if(item.serp_banners_spending__c != null){
            spReport.serp_media_price__c = spReport.serp_media_price__c == null ? 0: spReport.serp_media_price__c;
            spReport.serp_media_price__c += item.serp_banners_spending__c;
        }
        if(item.serp_banners_show__c != null){
            spReport.serp_media_shows__c = spReport.serp_media_shows__c == null ? 0: spReport.serp_media_shows__c;
            spReport.serp_media_shows__c += item.serp_banners_show__c;
        }
        
        if(item.serp_market_click__c != null){
            spReport.shopping_ads_clicks__c = spReport.shopping_ads_clicks__c == null ? 0: spReport.shopping_ads_clicks__c;
            spReport.shopping_ads_clicks__c += item.serp_market_click__c;
        }
        if(item.serp_market_spending__c != null){
            spReport.shopping_ads_price__c = spReport.shopping_ads_price__c == null ? 0: spReport.shopping_ads_price__c;
            spReport.shopping_ads_price__c += item.serp_market_spending__c;
        }
        if(item.serp_market_show__c != null){
            spReport.shopping_ads_shows__c = spReport.shopping_ads_shows__c == null ? 0: spReport.shopping_ads_shows__c;
            spReport.shopping_ads_shows__c += item.serp_market_show__c;
        }     
    }
     
    
     
}