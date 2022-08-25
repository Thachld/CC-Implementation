/**
 * @description       : Agency Report
 * @author            : @Thach Le
 * @group             : Data Accumulation
 * @last modified on  : 08-09-2022
 * @last modified by  : @Thach Le
**/
public with sharing class AgencyReportMonthly_Batch implements Database.Batchable<SObject> {
    private Datetime startDt {get;set;}
    private Datetime endDt {get;set;}
    private Date startdate {get;set;}
    private Date enddate {get;set;}
    private Boolean isOverride {get;set;}
    private String period {get;set;}
    private Set<String> Ids {get;set;}
    private String strSQL {get;set;}

    /* Parameters
        @pstartdate     From date
        @pendate        To Date
        @pdeleteOldPeriod Option to delete old operid if meet same time interval
    */
    public AgencyReportMonthly_Batch(String pperiod, Boolean pIsOverride, Set<String> pIds) {   
        
        Date pstartdate;
        date pendate;
        if(!string.isBlank(pperiod)){    
            string[] M = pperiod.split('-');
            pstartdate = date.NewInstance(integer.valueOf(M[1]), integer.valueOf(M[0]), 1 );     
            pendate = pstartdate.addMonths(1).addDays(-1);     
        }

        this.startDt = Datetime.newInstance(pstartdate.year(), pstartdate.month(), pstartdate.day(), 0,0,0);       
        this.endDt = Datetime.newInstance(pendate.year(), pendate.month(), pendate.day(), 23,59,59);        

        this.startdate = pstartdate;
        this.enddate = pendate;
        this.isOverride = pIsOverride;      
        this.period = pperiod;  
        this.Ids = pIds;
        if(pIds != null && pIds.size() > 0){
            this.strSQL = 'SELECT Id, Agency_QC_Account__c FROM QC_Account__c WHERE source__c = \'QC\' AND Agency_QC_Account__c != null AND Id IN :Ids';
        }else {
            this.strSQL = 'SELECT Id, Agency_QC_Account__c FROM QC_Account__c WHERE source__c = \'QC\' AND Agency_QC_Account__c != null';
        }
    }


    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(this.strSQL);
    }

    public void execute(Database.BatchableContext bc, List<QC_Account__c> scope){
        List<Agency_report__c> recordsToInsert = new List<Agency_report__c>();        
        Map<String, QC_Account__c> mapQC = new Map<String, QC_Account__c>();
        List<Agency_report__c> oldRecords = new List<Agency_report__c>();

        for(QC_Account__c qcacc: scope){
            if(!String.isBlank(qcacc.Id) && !String.isBlank(qcacc.Agency_QC_Account__c)){
                mapQC.put(qcacc.Id, qcacc);
            }
        }

        System.debug('startDt' + this.startDt);
        System.debug('endDt' + this.endDt);
        System.debug('startdate' + this.startdate);
        System.debug('enddate' + this.enddate);
        System.debug('qcIds' + mapQC.size());

        //query spending data
        for (AggregateResult qc : [SELECT qc_account__c qc_account__c,
                                        SUM(native_content_ad_external_click__c) native_content_ad_external_click__c,
                                        SUM(native_content_ad_external_show__c) native_content_ad_external_show__c,
                                        SUM(native_content_ad_external_spending__c) native_content_ad_external_spending__c,

                                        SUM(native_content_ad_click__c) native_content_ad_click__c,
                                        SUM(native_content_ad_show__c) native_content_ad_show__c,
                                        SUM(native_content_ad_spending__c) native_content_ad_spending__c,

                                        SUM(double_zen_cards_click__c) double_zen_cards_click__c,
                                        SUM(double_zen_cards_show__c) double_zen_cards_show__c,
                                        SUM(double_zen_cards_spending__c) double_zen_cards_spending__c,

                                        SUM(masthead_jscode_click__c) masthead_jscode_click__c,
                                        SUM(masthead_jscode_show__c) masthead_jscode_show__c,
                                        SUM(masthead_jscode_spending__c) masthead_jscode_spending__c,

                                        SUM(masthead_click__c) masthead_click__c,
                                        SUM(masthead_show__c) masthead_show__c,
                                        SUM(masthead_spending__c) masthead_spending__c,

                                        SUM(video_masthead_click__c) video_masthead_click__c,
                                        SUM(video_masthead_show__c) video_masthead_show__c,
                                        SUM(video_masthead_spending__c) video_masthead_spending__c,

                                        SUM(new_tab_click__c) new_tab_click__c,
                                        SUM(new_tab_show__c) new_tab_show__c,
                                        SUM(new_tab_spending__c) new_tab_spending__c,

                                        SUM(icons_newtab_click__c) icons_newtab_click__c,
                                        SUM(icons_newtab_show__c) icons_newtab_show__c,
                                        SUM(icons_newtab_spending__c) icons_newtab_spending__c,

                                        SUM(new_tab_js_code_click__c) new_tab_js_code_click__c,
                                        SUM(new_tab_js_code_show__c) new_tab_js_code_show__c,
                                        SUM(new_tab_js_code_spending__c) new_tab_js_code_spending__c,

                                        SUM(skins_click__c) skins_click__c,
                                        SUM(skins_show__c) skins_show__c,
                                        SUM(skins_spending__c) skins_spending__c,

                                        SUM(video_click__c) video_click__c,
                                        SUM(video_show__c) video_show__c,
                                        SUM(video_spending__c) video_spending__c,

                                        SUM(serp_desktop_click__c) serp_desktop_click__c,
                                        SUM(serp_desktop_show__c) serp_desktop_show__c,
                                        SUM(serp_desktop_spending__c) serp_desktop_spending__c,

                                        SUM(maps_click__c) maps_click__c,
                                        SUM(maps_show__c) maps_show__c,
                                        SUM(maps_spending__c) maps_spending__c,

                                        SUM(serp_mobile_click__c) serp_mobile_click__c,
                                        SUM(serp_mobile_show__c) serp_mobile_show__c,
                                        SUM(serp_mobile_spending__c) serp_mobile_spending__c,

                                        SUM(serp_banners_click__c) serp_banners_click__c,
                                        SUM(serp_banners_show__c) serp_banners_show__c,
                                        SUM(serp_banners_spending__c) serp_banners_spending__c,

                                        SUM(serp_market_click__c) serp_market_click__c,
                                        SUM(serp_market_show__c) serp_market_show__c,
                                        SUM(serp_market_spending__c) serp_market_spending__c,

                                        SUM(single_zen_cards_click__c) single_zen_cards_click__c,
                                        SUM(single_zen_cards_show__c) single_zen_cards_show__c,
                                        SUM(single_zen_cards_spending__c) single_zen_cards_spending__c,

                                        SUM(single_zen_cards_mobile_click__c) single_zen_cards_mobile_click__c,
                                        SUM(single_zen_cards_mobile_show__c) single_zen_cards_mobile_show__c,
                                        SUM(single_zen_cards_mobile_spending__c) single_zen_cards_mobile_spending__c

                                        FROM QC_Account_data__c
                                        WHERE syn_date__c >= :this.startDt
                                        AND syn_date__c <= : this.endDt
                                        AND qc_account__c IN : mapQC.keyset()                                        
                                        GROUP BY qc_account__c]){


            String qcaccount =  (String)qc.get('qc_account__c');            
                                            
            if(!String.isBlank(qcaccount)){

                String agencyAccount = mapQC.get(qcaccount).Agency_QC_account__c;
                if (Integer.valueof(qc.get('native_content_ad_external_spending__c')) > 0 
                    || Integer.valueof(qc.get('native_content_ad_external_click__c')) > 0
                    || Integer.valueof(qc.get('native_content_ad_external_show__c')) > 0 ) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('native_content_ad_external_show__c'));
                    report.Click__c = Integer.valueof(qc.get('native_content_ad_external_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('native_content_ad_external_spending__c'));
                    report.Ads_type__c = 'Audience Network External';
                    report.UpsertID__c = this.period + qcaccount + 'native_content_ad_external';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('native_content_ad_spending__c')) > 0
                    || Integer.valueof(qc.get('native_content_ad_click__c')) > 0
                    || Integer.valueof(qc.get('native_content_ad_show__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('native_content_ad_show__c'));
                    report.Click__c = Integer.valueof(qc.get('native_content_ad_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('native_content_ad_spending__c'));
                    report.Ads_type__c = 'Audience Network Native Content Ad';
                    report.UpsertID__c = this.period + qcaccount + 'native_content_ad';
                    recordsToInsert.add(report);
                }
                
                if (Integer.valueof(qc.get('double_zen_cards_spending__c')) > 0
                    || Integer.valueof(qc.get('double_zen_cards_show__c')) > 0
                    || Integer.valueof(qc.get('double_zen_cards_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('double_zen_cards_show__c'));
                    report.Click__c = Integer.valueof(qc.get('double_zen_cards_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('double_zen_cards_spending__c'));
                    report.Ads_type__c = 'Big Native In-feed Banner';
                    report.UpsertID__c = this.period + qcaccount + 'double_zen_cards';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('masthead_jscode_spending__c')) > 0
                    || Integer.valueof(qc.get('masthead_jscode_show__c')) > 0
                    || Integer.valueof(qc.get('masthead_jscode_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('masthead_jscode_show__c'));
                    report.Click__c = Integer.valueof(qc.get('masthead_jscode_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('masthead_jscode_spending__c'));
                    report.Ads_type__c = 'Magnetic Masthead JScode';
                    report.UpsertID__c = this.period + qcaccount + 'masthead_jscode';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('masthead_spending__c')) > 0
                    || Integer.valueof(qc.get('masthead_show__c')) > 0
                    || Integer.valueof(qc.get('masthead_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('masthead_show__c'));
                    report.Click__c = Integer.valueof(qc.get('masthead_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('masthead_spending__c'));
                    report.Ads_type__c = 'Magnetic Masthead';
                    report.UpsertID__c = this.period + qcaccount + 'masthead';
                    recordsToInsert.add(report);
                }
                
                if (Integer.valueof(qc.get('video_masthead_spending__c')) > 0
                    || Integer.valueof(qc.get('video_masthead_show__c')) > 0
                    || Integer.valueof(qc.get('video_masthead_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('video_masthead_show__c'));
                    report.Click__c = Integer.valueof(qc.get('video_masthead_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('video_masthead_spending__c'));
                    report.Ads_type__c = 'Magnetic Masthead Video';
                    report.UpsertID__c = this.period + qcaccount + 'video_masthead';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('new_tab_spending__c')) > 0
                    || Integer.valueof(qc.get('new_tab_show__c')) > 0
                    || Integer.valueof(qc.get('new_tab_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('new_tab_show__c'));
                    report.Click__c = Integer.valueof(qc.get('new_tab_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('new_tab_spending__c'));
                    report.Ads_type__c = 'Newtab Banner';
                    report.UpsertID__c = this.period + qcaccount + 'new_tab';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('icons_newtab_spending__c')) > 0
                    || Integer.valueof(qc.get('icons_newtab_show__c')) > 0
                    || Integer.valueof(qc.get('icons_newtab_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('icons_newtab_show__c'));
                    report.Click__c = Integer.valueof(qc.get('icons_newtab_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('icons_newtab_spending__c'));
                    report.Ads_type__c = 'Newtab Icon';
                    report.UpsertID__c = this.period + qcaccount + 'icons_newtab';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('new_tab_js_code_spending__c')) > 0
                    || Integer.valueof(qc.get('new_tab_js_code_show__c')) > 0
                    || Integer.valueof(qc.get('new_tab_js_code_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('new_tab_js_code_show__c'));
                    report.Click__c = Integer.valueof(qc.get('new_tab_js_code_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('new_tab_js_code_spending__c'));
                    report.Ads_type__c = 'Newtab JScode Banner';
                    report.UpsertID__c = this.period + qcaccount + 'new_tab_js_code';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('skins_spending__c')) > 0
                    || Integer.valueof(qc.get('skins_show__c')) > 0
                    || Integer.valueof(qc.get('skins_click__c')) > 0 ) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('skins_show__c'));
                    report.Click__c = Integer.valueof(qc.get('skins_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('skins_spending__c'));
                    report.Ads_type__c = 'Newtab Skin';
                    report.UpsertID__c = this.period + qcaccount + 'skins';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('video_spending__c')) > 0
                    || Integer.valueof(qc.get('video_show__c')) > 0
                    || Integer.valueof(qc.get('video_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('video_show__c'));
                    report.Click__c = Integer.valueof(qc.get('video_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('video_spending__c'));
                    report.Ads_type__c = 'Newtab Video Banner';
                    report.UpsertID__c = this.period + qcaccount + 'video';
                    recordsToInsert.add(report);
                }               

                if (Integer.valueof(qc.get('serp_desktop_spending__c')) > 0
                    || Integer.valueof(qc.get('serp_desktop_show__c')) > 0
                    || Integer.valueof(qc.get('serp_desktop_click__c')) > 0
                    || Integer.valueof(qc.get('maps_spending__c')) > 0
                    || Integer.valueof(qc.get('maps_show__c')) > 0
                    || Integer.valueof(qc.get('maps_click__c')) > 0
                    || Integer.valueof(qc.get('serp_mobile_spending__c')) > 0
                    || Integer.valueof(qc.get('serp_mobile_show__c')) > 0
                    || Integer.valueof(qc.get('serp_mobile_click__c')) > 0
                    ) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;

                    Integer show = (Integer.valueof(qc.get('serp_desktop_show__c')) == null?0 : Integer.valueof(qc.get('serp_desktop_show__c')))
                                    + (Integer.valueof(qc.get('maps_show__c')) == null?0 : Integer.valueof(qc.get('maps_show__c')) )
                                    + (Integer.valueof(qc.get('serp_mobile_show__c')) == null?0 : Integer.valueof(qc.get('serp_mobile_show__c')));

                    Integer click = (Integer.valueof(qc.get('serp_desktop_click__c')) == null?0 : Integer.valueof(qc.get('serp_desktop_click__c')))
                                    + (Integer.valueof(qc.get('maps_click__c')) == null?0 : Integer.valueof(qc.get('maps_click__c')) )
                                    + (Integer.valueof(qc.get('serp_mobile_click__c')) == null?0 : Integer.valueof(qc.get('serp_mobile_click__c')));

                    Integer spending = (Integer.valueof(qc.get('serp_desktop_spending__c')) == null?0 : Integer.valueof(qc.get('serp_desktop_spending__c')))
                                    + (Integer.valueof(qc.get('maps_spending__c')) == null?0 : Integer.valueof(qc.get('maps_spending__c')) )
                                    + (Integer.valueof(qc.get('serp_mobile_spending__c')) == null?0 : Integer.valueof(qc.get('serp_mobile_spending__c')));


                    report.Show__c = show;
                    report.Click__c = click;
                    report.Spending__c = spending;                   
                    report.Ads_type__c = 'Search Ads';
                    report.UpsertID__c = this.period + qcaccount + 'search_ads';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('serp_banners_spending__c')) > 0
                    || Integer.valueof(qc.get('serp_banners_show__c')) > 0
                    || Integer.valueof(qc.get('serp_banners_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('serp_banners_show__c'));
                    report.Click__c = Integer.valueof(qc.get('serp_banners_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('serp_banners_spending__c'));
                    report.Ads_type__c = 'Search Banner';
                    report.UpsertID__c = this.period + qcaccount + 'serp_banners';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('serp_market_spending__c')) > 0
                    || Integer.valueof(qc.get('serp_market_show__c')) > 0
                    || Integer.valueof(qc.get('serp_market_click__c')) > 0)
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('serp_market_show__c'));
                    report.Click__c = Integer.valueof(qc.get('serp_market_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('serp_market_spending__c'));
                    report.Ads_type__c = 'Shopping Ads';
                    report.UpsertID__c = this.period + qcaccount + 'serp_market';
                    recordsToInsert.add(report);
                }

                if (Integer.valueof(qc.get('single_zen_cards_spending__c')) > 0
                    || Integer.valueof(qc.get('single_zen_cards_show__c')) > 0 
                    || Integer.valueof(qc.get('single_zen_cards_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('single_zen_cards_show__c'));
                    report.Click__c = Integer.valueof(qc.get('single_zen_cards_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('single_zen_cards_spending__c'));
                    report.Ads_type__c = 'Small Native In-feed Banner';
                    report.UpsertID__c = this.period + qcaccount + 'single_zen_cards';
                    recordsToInsert.add(report);
                }   
                
                if (Integer.valueof(qc.get('single_zen_cards_mobile_spending__c')) > 0
                    || Integer.valueof(qc.get('single_zen_cards_mobile_show__c')) > 0
                    || Integer.valueof(qc.get('single_zen_cards_mobile_click__c')) > 0) 
                {
                    Agency_report__c report = new Agency_report__c();
                    report.Date__c = this.startdate;
                    report.To_Date__c = this.enddate;
                    report.Qc_account__c = qcaccount;
                    report.Agency_QC_account__c = agencyAccount;
                    report.Show__c = Integer.valueof(qc.get('single_zen_cards_mobile_show__c'));
                    report.Click__c = Integer.valueof(qc.get('single_zen_cards_mobile_click__c'));
                    report.Spending__c = Integer.valueof(qc.get('single_zen_cards_mobile_spending__c'));
                    report.Ads_type__c = 'Small Native In-feed Mobile';
                    report.UpsertID__c = this.period + qcaccount + 'single_zen_cards_mobile';
                    recordsToInsert.add(report);
                }   
            }    
        }


        if(recordsToInsert.size() > 0){
            if(this.isOverride){
                Schema.SObjectField f = Agency_report__c.Fields.UpsertID__c;
                Database.upsert(recordsToInsert, f, true);           
            }else{
                Database.insert(recordsToInsert, true);          
            }
        }

    }


    public void finish(Database.BatchableContext bc){       
    }
}