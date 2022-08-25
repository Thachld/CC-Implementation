public class cc_UpdateQCSpending_Batch implements Database.Batchable<SObject>{
    private Datetime fromDT;
    private Datetime toDT;
    
    public cc_UpdateQCSpending_Batch(Date pfrom, Date pto) {
        this.fromDT = Datetime.newInstance(pfrom.year(), pfrom.month(), pfrom.day(), 0,0,0);       
        this.toDT = Datetime.newInstance(pto.year(), pto.month(), pto.day(), 23,59,59); 
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,
                                                TotalSkintoolSpending__c,
                                                TotalSkintoolClick__c,
                                                TotalSkintoolImpression__c,
                                                TotalQCImpression__c,
                                                TotalQCClick__c,
                                                TotalQCSpending__c,
                                                serp_banners_spending__c,
                                                double_zen_cards_spending__c,
                                                skins_spending__c,
                                                serp_desktop_spending__c,
                                                icons_newtab_spending__c,
                                                masthead_spending__c,
                                                video_masthead_spending__c,
                                                maps_spending__c,
                                                mb_general_spending__c,
                                                serp_mobile_spending__c,
                                                new_tab_js_code_spending__c,
                                                new_tab_spending__c,
                                                serp_market_spending__c,
                                                single_zen_cards_spending__c,
                                                video_spending__c,
                                                masthead_jscode_spending__c,
                                                other_spending__c,
                                                vast_skin_spending__c,                              
                                                native_content_ad_spending__c,
                                                native_content_ad_external_spending__c,
                                                single_zen_cards_mobile_spending__c,
                                                serp_banners_click__c,
                                                double_zen_cards_click__c,
                                                skins_click__c,
                                                serp_desktop_click__c,
                                                icons_newtab_click__c,
                                                masthead_click__c,
                                                video_masthead_click__c,
                                                maps_click__c,
                                                mb_general_click__c,
                                                serp_mobile_click__c,
                                                new_tab_js_code_click__c,
                                                new_tab_click__c,
                                                serp_market_click__c,
                                                single_zen_cards_click__c,
                                                video_click__c,
                                                masthead_jscode_click__c,
                                                other_click__c,
                                                vast_skin_click__c,                 
                                                native_content_ad_click__c,
                                                native_content_ad_external_click__c,
                                                single_zen_cards_mobile_click__c,  
                                                serp_banners_show__c,
                                                double_zen_cards_show__c,
                                                skins_show__c,
                                                serp_desktop_show__c,
                                                icons_newtab_show__c,
                                                masthead_show__c,
                                                video_masthead_show__c,
                                                maps_show__c,
                                                mb_general_show__c,
                                                serp_mobile_show__c,
                                                new_tab_js_code_show__c,
                                                new_tab_show__c,
                                                serp_market_show__c, 
                                                single_zen_cards_show__c,
                                                video_show__c,
                                                masthead_jscode_show__c,
                                                other_show__c,
                                                vast_skin_show__c,                          
                                                native_content_ad_show__c,
                                                native_content_ad_external_show__c,
                                                single_zen_cards_mobile_show__c,
                                                skintool_iconsidebar_spending__c,
                                                skintool_masthead_spending__c,
                                                skintool_masthead_video_spending__c,
                                                skintool_skin_spending__c,
                                                Skintool_Video_Banner_spending__c,
                                                skintool_video_skin_spending__c,
                                                skintool_iconsidebar_click__c,
                                                skintool_masthead_click__c,
                                                skintool_masthead_video_click__c,
                                                skintool_skin_click__c,
                                                Skintool_Video_Banner_click__c,
                                                skintool_video_skin_click__c,
                                                skintool_iconsidebar_view__c,
                                                skintool_masthead_view__c,
                                                skintool_masthead_video_view__c,
                                                skintool_skin_view__c,
                                                Skintool_Video_Banner_view__c,
                                                skintool_video_skin_view__c								
                                            FROM QC_Account_Data__c 
                                            WHERE syn_date__c >= :this.fromDT 
                                                AND syn_date__c <= :this.toDT]);

    }

    public void execute(Database.BatchableContext bc, List<QC_Account_Data__c> scope){
        List<QC_Account_Data__c> updateList = new List<QC_Account_Data__c>();

        for(QC_Account_Data__c qcData: scope){
            QC_Account_Data__c newdata = new QC_Account_Data__c();
            newdata.Id = qcData.Id;

           
            newdata.TotalQCSpending__c  =  (qcData.serp_banners_spending__c ==null?0: qcData.serp_banners_spending__c) 
                                    + (qcData.double_zen_cards_spending__c ==null?0: qcData.double_zen_cards_spending__c) 
                                    + (qcData.skins_spending__c ==null?0: qcData.skins_spending__c) 
                                    + (qcData.serp_desktop_spending__c ==null?0: qcData.serp_desktop_spending__c) 
                                    + (qcData.icons_newtab_spending__c ==null?0: qcData.icons_newtab_spending__c) 
                                    + (qcData.masthead_spending__c ==null?0: qcData.masthead_spending__c) 
                                    + (qcData.video_masthead_spending__c ==null?0: qcData.video_masthead_spending__c) 
                                    + (qcData.maps_spending__c ==null?0: qcData.maps_spending__c) 
                                    + (qcData.mb_general_spending__c ==null?0: qcData.mb_general_spending__c) 
                                    + (qcData.serp_mobile_spending__c ==null?0: qcData.serp_mobile_spending__c) 
                                    + (qcData.new_tab_js_code_spending__c ==null?0: qcData.new_tab_js_code_spending__c) 
                                    + (qcData.new_tab_spending__c ==null?0: qcData.new_tab_spending__c) 
                                    + (qcData.serp_market_spending__c ==null?0: qcData.serp_market_spending__c) 
                                    + (qcData.single_zen_cards_spending__c ==null?0: qcData.single_zen_cards_spending__c)
                                    + (qcData.video_spending__c ==null?0: qcData.video_spending__c)
                                    + (qcData.masthead_jscode_spending__c ==null?0: qcData.masthead_jscode_spending__c)
                                    + (qcData.other_spending__c ==null?0: qcData.other_spending__c)
                                    + (qcData.vast_skin_spending__c ==null?0: qcData.vast_skin_spending__c)                                    
                                    + (qcData.native_content_ad_spending__c ==null?0: qcData.native_content_ad_spending__c)
                                    + (qcData.native_content_ad_external_spending__c ==null?0: qcData.native_content_ad_external_spending__c)           
                                    + (qcData.single_zen_cards_mobile_spending__c ==null?0: qcData.single_zen_cards_mobile_spending__c)
                                    ; 

            newdata.TotalQCClick__c  =  (qcData.serp_banners_click__c ==null?0: qcData.serp_banners_click__c) 
                                    + (qcData.double_zen_cards_click__c ==null?0: qcData.double_zen_cards_click__c) 
                                    + (qcData.skins_click__c ==null?0: qcData.skins_click__c) 
                                    + (qcData.serp_desktop_click__c ==null?0: qcData.serp_desktop_click__c) 
                                    + (qcData.icons_newtab_click__c ==null?0: qcData.icons_newtab_click__c) 
                                    + (qcData.masthead_click__c ==null?0: qcData.masthead_click__c) 
                                    + (qcData.video_masthead_click__c ==null?0: qcData.video_masthead_click__c) 
                                    + (qcData.maps_click__c ==null?0: qcData.maps_click__c) 
                                    + (qcData.mb_general_click__c ==null?0: qcData.mb_general_click__c) 
                                    + (qcData.serp_mobile_click__c ==null?0: qcData.serp_mobile_click__c) 
                                    + (qcData.new_tab_js_code_click__c ==null?0: qcData.new_tab_js_code_click__c) 
                                    + (qcData.new_tab_click__c ==null?0: qcData.new_tab_click__c) 
                                    + (qcData.serp_market_click__c ==null?0: qcData.serp_market_click__c) 
                                    + (qcData.single_zen_cards_click__c ==null?0: qcData.single_zen_cards_click__c)
                                    + (qcData.video_click__c ==null?0: qcData.video_click__c)
                                    + (qcData.masthead_jscode_click__c ==null?0: qcData.masthead_jscode_click__c)
                                    + (qcData.other_click__c ==null?0: qcData.other_click__c)
                                    + (qcData.vast_skin_click__c ==null?0: qcData.vast_skin_click__c)                                    
                                    + (qcData.native_content_ad_click__c ==null?0: qcData.native_content_ad_click__c)
                                    + (qcData.native_content_ad_external_click__c ==null?0: qcData.native_content_ad_external_click__c)
                                    + (qcData.single_zen_cards_mobile_click__c ==null?0: qcData.single_zen_cards_mobile_click__c); 
        
            newdata.TotalQCImpression__c  =  (qcData.serp_banners_show__c ==null?0: qcData.serp_banners_show__c) 
                                    + (qcData.double_zen_cards_show__c ==null?0: qcData.double_zen_cards_show__c) 
                                    + (qcData.skins_show__c ==null?0: qcData.skins_show__c) 
                                    + (qcData.serp_desktop_show__c ==null?0: qcData.serp_desktop_show__c) 
                                    + (qcData.icons_newtab_show__c ==null?0: qcData.icons_newtab_show__c) 
                                    + (qcData.masthead_show__c ==null?0: qcData.masthead_show__c) 
                                    + (qcData.video_masthead_show__c ==null?0: qcData.video_masthead_show__c) 
                                    + (qcData.maps_show__c ==null?0: qcData.maps_show__c) 
                                    + (qcData.mb_general_show__c ==null?0: qcData.mb_general_show__c) 
                                    + (qcData.serp_mobile_show__c ==null?0: qcData.serp_mobile_show__c) 
                                    + (qcData.new_tab_js_code_show__c ==null?0: qcData.new_tab_js_code_show__c) 
                                    + (qcData.new_tab_show__c ==null?0: qcData.new_tab_show__c) 
                                    + (qcData.serp_market_show__c ==null?0: qcData.serp_market_show__c) 
                                    + (qcData.single_zen_cards_show__c ==null?0: qcData.single_zen_cards_show__c)
                                    + (qcData.video_show__c ==null?0: qcData.video_show__c)
                                    + (qcData.masthead_jscode_show__c ==null?0: qcData.masthead_jscode_show__c)
                                    + (qcData.other_show__c ==null?0: qcData.other_show__c)
                                    + (qcData.vast_skin_show__c ==null?0: qcData.vast_skin_show__c)                                    
                                    + (qcData.native_content_ad_show__c ==null?0: qcData.native_content_ad_show__c)
                                    + (qcData.native_content_ad_external_show__c ==null?0: qcData.native_content_ad_external_show__c) 
                                    + (qcData.single_zen_cards_mobile_show__c ==null?0: qcData.single_zen_cards_mobile_show__c); 

            newdata.TotalSkintoolSpending__c = (qcData.skintool_iconsidebar_spending__c ==null? 0 : qcData.skintool_iconsidebar_spending__c) 
                                    + (qcData.skintool_masthead_spending__c ==null? 0 : qcData.skintool_masthead_spending__c)
                                    + (qcData.skintool_masthead_video_spending__c ==null? 0 : qcData.skintool_masthead_video_spending__c)
                                    + (qcData.skintool_skin_spending__c ==null? 0 : qcData.skintool_skin_spending__c)
                                    + (qcData.Skintool_Video_Banner_spending__c ==null? 0 : qcData.Skintool_Video_Banner_spending__c)
                                    + (qcData.skintool_video_skin_spending__c ==null? 0 : qcData.skintool_video_skin_spending__c);

            newdata.TotalSkintoolClick__c = (qcData.skintool_iconsidebar_click__c ==null? 0 : qcData.skintool_iconsidebar_click__c) 
                                    + (qcData.skintool_masthead_click__c ==null? 0 : qcData.skintool_masthead_click__c)
                                    + (qcData.skintool_masthead_video_click__c ==null? 0 : qcData.skintool_masthead_video_click__c)
                                    + (qcData.skintool_skin_click__c ==null? 0 : qcData.skintool_skin_click__c)
                                    + (qcData.Skintool_Video_Banner_click__c ==null? 0 : qcData.Skintool_Video_Banner_click__c)
                                    + (qcData.skintool_video_skin_click__c ==null? 0 : qcData.skintool_video_skin_click__c);

            newdata.TotalSkintoolImpression__c = (qcData.skintool_iconsidebar_view__c==null? 0 : qcData.skintool_iconsidebar_view__c) 
                                    + (qcData.skintool_masthead_view__c ==null? 0 : qcData.skintool_masthead_view__c)
                                    + (qcData.skintool_masthead_video_view__c ==null? 0 : qcData.skintool_masthead_video_view__c)
                                    + (qcData.skintool_skin_view__c ==null? 0 : qcData.skintool_skin_view__c)
                                    + (qcData.Skintool_Video_Banner_view__c ==null? 0 : qcData.Skintool_Video_Banner_view__c)
                                    + (qcData.skintool_video_skin_view__c ==null? 0 : qcData.skintool_video_skin_view__c);

            updateList.add(newdata);
        }

        System.debug('updateList=>' + updateList.size());
        if(updateList.size() > 0){
            Database.update(updateList,true);
        }


    }

    public void finish(Database.BatchableContext bc){

    }
}