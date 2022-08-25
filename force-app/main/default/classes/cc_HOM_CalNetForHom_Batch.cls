//Author: ThachLe
//Date : 09/21/2020
//Description: Caculation for HOMs without Contract, HOMs Contract Prepaid
global class cc_HOM_CalNetForHom_Batch implements Database.Batchable<sObject>{
    public date minDate {get;set;}
    public date maxDate {get;set;}
    public boolean isUpdateToPreviousCoupond {get;set;}    
    public String HOMperiod {get;set;}   
    public String year {get;set;}   
    public datetime minDateTime {get;set;}
    public datetime maxDateTime {get;set;}
    Map<String,Set<String>> mapQCAcc  {get;set;}  
    List<cc_DMLResult_wrapper> lserrors  {get;set;} 
    public Set<String> homIds {get;set;}  

    
    public cc_HOM_CalNetForHom_Batch(  String pperiod, 
                                        Date pminDate,
                                        Date pmaxDate,
                                        Datetime pminDateTime,
                                        Datetime pmaxDateTime,                                     
                                        Set<String> pHomIds,
                                        Map<String,Set<String>> pmapQcAcc,
                                        boolean pisUpdateToPreviousCoupond) {
        this.HOMperiod = pperiod;
        this.isUpdateToPreviousCoupond = pisUpdateToPreviousCoupond;
        this.homIds = pHomIds;
        this.minDate = pminDate;
        this.maxDate = pmaxDate;
        this.year = String.valueOf(pminDate.year());
        this.mapQCAcc = pmapQcAcc;

        this.minDateTime = pminDateTime;
        this.maxDateTime = pmaxDateTime; 
        this.lserrors = new  List<cc_DMLResult_wrapper>();

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([ SELECT Id,Name,Status__c, 
                                            HOM_Number__c,    
                                            Net_spending__c,
                                            Total_Spending__c, 
                                            real_spending__c,
                                            overspending__c,
                                            Coupon_spending__c,
                                            Start_date__c, 
                                            End_date__c ,
                                            Account__c,
                                            Custom_Contract__c ,
                                            Custom_Contract__r.Type__c,                                
                                            Custom_Contract__r.DiscountBonus_as_Policy__c,
                                            Custom_Contract__r.Special_discount__c, 
                                            Custom_Contract__r.Payment_method__c, 
                                            Custom_Contract__r.Previous_Coupon__c, 
                                            Custom_Contract__r.Current_Coupon__c, 
                                            Custom_Contract__r.Contract_Start_Date__c                                                                                                                                    
                                            FROM HandOver_Minute__c 
                                            WHERE id IN: this.homIds
                                        ]); 
    }

    global void execute(Database.BatchableContext bc, List<HandOver_Minute__c> scope){

        System.debug('mapQCAcc =>' + mapQCAcc.size());
        System.debug('homIds =>' + homIds.size());
        Map<String, Set<String>> mapMQc = new Map<String, Set<String>>();
        List<HomDetail__c> homdls = new List<HomDetail__c>();  
        Set<String> processHomIds = new Set<String>();
        List<HandOver_Minute__c> homs = new List<HandOver_Minute__c>();  
        Map<String,QC_Account_Data__c> mapQCData = new Map<String,QC_Account_Data__c>(); 
        Set<String> processQcIds = new Set<String>();

        for(HandOver_Minute__c hom : scope){
            Set<String> qcids = new Set<String>();
                        qcids = this.mapQCAcc.get(hom.Id);

            System.debug('hom.Id =>' + hom.Id);
            System.debug('qcids =>' + qcids);            
            if(qcids != null){
                processQcIds.addall(qcids);   
                processHomIds.add(hom.Id);             
            }
            
        }
        System.debug('processQcIds =>' + processQcIds.size());
        System.debug('processHomIds =>' + processHomIds.size());
        //Agency QC Case

        for(QC_Account__c qc : [SELECT Agency_QC_Account__c, Id, Name   
                                FROM QC_Account__c 
                                WHERE Agency_QC_Account__c IN : processQcIds]){
            
            if(mapMQc.containsKey(qc.Agency_QC_Account__c)){
                mapMQc.get(qc.Agency_QC_Account__c).add(qc.Id);
            }else{
                mapMQc.put(qc.Agency_QC_Account__c, new Set<String>{qc.Id});
            }                
        }
       
        
        for(String homId: processHomIds){
            Set<String> qcMCCIds = this.mapQCAcc.get(homId);

            if(qcMCCIds != null){
                for( String mcQCId: qcMCCIds){                
                    if (mapMQc.containsKey(mcQCId)){     
                        Set<String> mccQcIds = mapMQc.get(mcQCId);
                        if(mccQcIds != null){
                            System.debug('mccQcIds =>' + mccQcIds);
                            this.mapQCAcc.get(homId).addAll(mccQcIds);  

                            if(mapQCAcc.get(homId).contains(mcQCId)){             
                                this.mapQCAcc.get(homId).remove(mcQCId); 
                            } 
                        }                                     
                    }
                }
            }
        }          

        //Get QC Data transaction group by QC_Account__c
        for(AggregateResult arr  :  [SELECT QC_Account__c QC_Account__c,
                                        SUM(real_spending__c) real_spending__c, 
                                        SUM(Coupon_spending__c) Coupon_spending__c, 
                                        SUM(overspending__c) overspending__c, 
                                        SUM(Total_Spending__c) Total_Spending__c,
                                        SUM(serp_desktop_spending__c) serp_desktop_spending__c, 
                                        SUM(serp_mobile_spending__c) serp_mobile_spending__c,
                                        SUM(serp_banners_spending__c) serp_banners_spending__c, 
                                        SUM(serp_market_spending__c) serp_market_spending__c,
                                        SUM(maps_spending__c) maps_spending__c, 
                                        SUM(icons_newtab_spending__c) icons_newtab_spending__c,
                                        SUM(new_tab_spending__c) new_tab_spending__c, 
                                        SUM(new_tab_js_code_spending__c) new_tab_js_code_spending__c,
                                        SUM(skins_spending__c) skins_spending__c, 
                                        SUM(skintool_masthead_spending__c) skintool_masthead_spending__c,
                                        SUM(masthead_spending__c) masthead_spending__c, 
                                        SUM(video_spending__c) video_spending__c,
                                        SUM(mb_general_spending__c) mb_general_spending__c, 
                                        SUM(single_zen_cards_spending__c) single_zen_cards_spending__c,
                                        SUM(double_zen_cards_spending__c) double_zen_cards_spending__c, 
                                        SUM(video_masthead_spending__c) video_masthead_spending__c,
                                        SUM(masthead_jscode_spending__c) masthead_jscode_spending__c, 
                                        // SUM(vast_skin_spending__c) vast_skin_spending__c,
                                        SUM(skintool_skin_spending__c) skintool_skin_spending__c, 
                                        SUM(skintool_video_skin_spending__c) skintool_video_skin_spending__c,
                                        SUM(skintool_masthead_video_spending__c) skintool_masthead_video_spending__c, 
                                        SUM(skintool_iconsidebar_spending__c) skintool_iconsidebar_spending__c,
                                        SUM(skintool_video_banner_spending__c) skintool_video_banner_spending__c,
                                        SUM(serp_desktop_show__c) serp_desktop_show__c, 
                                        SUM(serp_mobile_show__c) serp_mobile_show__c,
                                        SUM(serp_banners_show__c) serp_banners_show__c, 
                                        SUM(serp_market_show__c) serp_market_show__c,
                                        SUM(maps_show__c) maps_show__c, 
                                        SUM(icons_newtab_show__c) icons_newtab_show__c,
                                        SUM(new_tab_show__c) new_tab_show__c, 
                                        SUM(new_tab_js_code_show__c) new_tab_js_code_show__c,
                                        SUM(skins_show__c) skins_show__c, 
                                        SUM(skintool_masthead_view__c) skintool_masthead_view__c,
                                        SUM(masthead_show__c) masthead_show__c, 
                                        SUM(video_show__c) video_show__c,
                                        SUM(mb_general_show__c) mb_general_show__c, 
                                        SUM(single_zen_cards_show__c) single_zen_cards_show__c,
                                        SUM(double_zen_cards_show__c) double_zen_cards_show__c, 
                                        SUM(video_masthead_show__c) video_masthead_show__c,
                                        SUM(masthead_jscode_show__c) masthead_jscode_show__c, 
                                        // SUM(vast_skin_show__c) vast_skin_show__c,
                                        SUM(skintool_skin_view__c) skintool_skin_view__c, 
                                        SUM(skintool_video_skin_view__c) skintool_video_skin_view__c,
                                        SUM(skintool_masthead_video_view__c) skintool_masthead_video_view__c, 
                                        SUM(skintool_iconsidebar_view__c) skintool_iconsidebar_view__c,
                                        SUM(skintool_video_banner_view__c) skintool_video_banner_view__c,
                                        SUM(serp_desktop_click__c) serp_desktop_click__c, 
                                        SUM(serp_mobile_click__c) serp_mobile_click__c,
                                        SUM(serp_banners_click__c) serp_banners_click__c, 
                                        SUM(serp_market_click__c) serp_market_click__c,
                                        SUM(maps_click__c) maps_click__c, 
                                        SUM(icons_newtab_click__c) icons_newtab_click__c,
                                        SUM(new_tab_click__c) new_tab_click__c, 
                                        SUM(new_tab_js_code_click__c) new_tab_js_code_click__c ,
                                        SUM(skins_click__c) skins_click__c, 
                                        SUM(skintool_masthead_click__c) skintool_masthead_click__c,
                                        SUM(masthead_click__c) masthead_click__c, 
                                        SUM(video_click__c) video_click__c,
                                        SUM(mb_general_click__c) mb_general_click__c, 
                                        SUM(single_zen_cards_click__c) single_zen_cards_click__c,
                                        SUM(double_zen_cards_click__c) double_zen_cards_click__c, 
                                        SUM(video_masthead_click__c) video_masthead_click__c,
                                        SUM(masthead_jscode_click__c) masthead_jscode_click__c, 
                                        // SUM(vast_skin_click__c) vast_skin_click__c,
                                        SUM(skintool_skin_click__c) skintool_skin_click__c, 
                                        SUM(skintool_video_skin_click__c) skintool_video_skin_click__c,
                                        SUM(skintool_masthead_video_click__c) skintool_masthead_video_click__c, 
                                        SUM(skintool_iconsidebar_click__c) skintool_iconsidebar_click__c,
                                        SUM(skintool_video_banner_click__c) skintool_video_banner_click__c
                                          
                                        FROM QC_Account_Data__c 
                                        WHERE syn_date__c >=: minDateTime 
                                            AND syn_date__c <=:  maxDateTime  
                                            AND QC_Account__c IN: processQcIds
                                        GROUP BY QC_Account__c]){

            QC_Account_Data__c qc  = new  QC_Account_Data__c();  

            qc.real_spending__c =  (Decimal)arr.get('real_spending__c');
            qc.Coupon_spending__c =  (Decimal)arr.get('Coupon_spending__c');
            qc.overspending__c = (Decimal)arr.get('overspending__c');
            qc.Total_Calculation__c = (Decimal)arr.get('Total_Spending__c');

            qc.serp_desktop_spending__c = (Decimal)arr.get('serp_desktop_spending__c');
            qc.serp_mobile_spending__c = (Decimal)arr.get('serp_mobile_spending__c');
            qc.serp_banners_spending__c = (Decimal)arr.get('serp_banners_spending__c');
            qc.serp_market_spending__c = (Decimal)arr.get('serp_market_spending__c');

            qc.maps_spending__c = (Decimal)arr.get('maps_spending__c');
            qc.icons_newtab_spending__c = (Decimal)arr.get('icons_newtab_spending__c');
            qc.new_tab_spending__c = (Decimal)arr.get('new_tab_spending__c');
            qc.new_tab_js_code_spending__c = (Decimal)arr.get('new_tab_js_code_spending__c');
            qc.skins_spending__c = (Decimal)arr.get('skins_spending__c');
            qc.skintool_masthead_spending__c = (Decimal)arr.get('skintool_masthead_spending__c');
            qc.masthead_spending__c = (Decimal)arr.get('masthead_spending__c');
            qc.mb_general_spending__c = (Decimal)arr.get('mb_general_spending__c');
            qc.single_zen_cards_spending__c = (Decimal)arr.get('single_zen_cards_spending__c');
            qc.double_zen_cards_spending__c = (Decimal)arr.get('double_zen_cards_spending__c');
            qc.video_masthead_spending__c = (Decimal)arr.get('video_masthead_spending__c');
            qc.masthead_jscode_spending__c = (Decimal)arr.get('masthead_jscode_spending__c');
            // qc.vast_skin_spending__c = (Decimal)arr.get('vast_skin_spending__c');

            qc.skintool_skin_spending__c = (Decimal)arr.get('skintool_skin_spending__c');
            qc.skintool_video_skin_spending__c = (Decimal)arr.get('skintool_video_skin_spending__c');
            qc.skintool_masthead_video_spending__c = (Decimal)arr.get('skintool_masthead_video_spending__c');
            qc.skintool_iconsidebar_spending__c = (Decimal)arr.get('skintool_iconsidebar_spending__c');
            qc.skintool_video_banner_spending__c = (Decimal)arr.get('skintool_video_banner_spending__c');

            qc.serp_desktop_show__c = (Decimal)arr.get('serp_desktop_show__c');
            qc.serp_mobile_show__c = (Decimal)arr.get('serp_mobile_show__c');
            qc.serp_banners_show__c = (Decimal)arr.get('serp_banners_show__c');
            qc.serp_market_show__c = (Decimal)arr.get('serp_market_show__c');

            qc.maps_show__c = (Decimal)arr.get('maps_show__c');
            qc.icons_newtab_show__c = (Decimal)arr.get('icons_newtab_show__c');
            qc.new_tab_show__c = (Decimal)arr.get('new_tab_show__c');
            qc.new_tab_js_code_show__c = (Decimal)arr.get('new_tab_js_code_show__c');
            qc.skins_show__c = (Decimal)arr.get('skins_show__c');
            qc.skintool_masthead_view__c = (Decimal)arr.get('skintool_masthead_view__c');
            qc.masthead_show__c = (Decimal)arr.get('masthead_show__c');
            qc.video_show__c = (Decimal)arr.get('video_show__c');
            qc.mb_general_show__c = (Decimal)arr.get('mb_general_show__c');
            qc.single_zen_cards_show__c = (Decimal)arr.get('single_zen_cards_show__c');
            qc.double_zen_cards_show__c = (Decimal)arr.get('double_zen_cards_show__c');
            qc.video_masthead_show__c = (Decimal)arr.get('video_masthead_show__c');
            qc.masthead_jscode_show__c = (Decimal)arr.get('masthead_jscode_show__c');
            // qc.vast_skin_show__c = (Decimal)arr.get('vast_skin_show__c');
            qc.skintool_skin_view__c = (Decimal)arr.get('skintool_skin_view__c');
            qc.skintool_video_skin_view__c = (Decimal)arr.get('skintool_video_skin_view__c');                                
            qc.skintool_masthead_video_view__c = (Decimal)arr.get('skintool_masthead_video_view__c');
            qc.skintool_iconsidebar_view__c = (Decimal)arr.get('skintool_iconsidebar_view__c');
            qc.skintool_video_banner_view__c = (Decimal)arr.get('skintool_video_banner_view__c');
            qc.serp_desktop_click__c = (Decimal)arr.get('serp_desktop_click__c');
            qc.serp_mobile_click__c = (Decimal)arr.get('serp_mobile_click__c');
            qc.serp_banners_click__c = (Decimal)arr.get('serp_banners_click__c');
            qc.serp_market_click__c = (Decimal)arr.get('serp_market_click__c');
            qc.maps_click__c = (Decimal)arr.get('maps_click__c');
            qc.icons_newtab_click__c = (Decimal)arr.get('icons_newtab_click__c');    
            qc.new_tab_click__c = (Decimal)arr.get('new_tab_click__c');
            qc.new_tab_js_code_click__c = (Decimal)arr.get('new_tab_js_code_click__c');
            qc.skins_click__c = (Decimal)arr.get('skins_click__c');
            qc.skintool_masthead_click__c = (Decimal)arr.get('skintool_masthead_click__c');
            qc.masthead_click__c = (Decimal)arr.get('masthead_click__c');
            qc.video_click__c = (Decimal)arr.get('video_click__c');
            qc.mb_general_click__c = (Decimal)arr.get('mb_general_click__c');
            qc.single_zen_cards_click__c = (Decimal)arr.get('single_zen_cards_click__c');
            qc.double_zen_cards_click__c = (Decimal)arr.get('double_zen_cards_click__c');      
            qc.video_masthead_click__c = (Decimal)arr.get('video_masthead_click__c');                           
            qc.masthead_jscode_click__c = (Decimal)arr.get('masthead_jscode_click__c');      
            // qc.vast_skin_click__c = (Decimal)arr.get('vast_skin_click__c');      
            qc.skintool_skin_click__c = (Decimal)arr.get('skintool_skin_click__c');      
            qc.skintool_video_skin_click__c = (Decimal)arr.get('skintool_video_skin_click__c');      
            qc.skintool_masthead_video_click__c = (Decimal)arr.get('skintool_masthead_video_click__c');   
            qc.skintool_iconsidebar_click__c = (Decimal)arr.get('skintool_iconsidebar_click__c');    
            qc.skintool_video_banner_click__c = (Decimal)arr.get('skintool_video_banner_click__c');     
            
            String qcAccount = (String) arr.get('QC_Account__c');
            mapQCData.put(qcAccount, qc);
        }                                
            
        for(HandOver_Minute__c hom: scope){  
            //HOM with out contract                
            Decimal realSpending = 0;
            Decimal totalSpending = 0;
            Decimal percent = 0; 
            Decimal netSpending = 0;
            Decimal policyRate = 0;
            initHOM(hom);
            hom.LastRunningDatetime__c = System.now();

            Set<String> qcIds = new Set<String>();
                        qcIds = this.mapQCAcc.get(hom.Id);

            if(qcIds != null){
                for(String qcId: this.mapQCAcc.get(hom.Id)){
                    QC_Account_Data__c qcdata = mapQCData.get(qcId);   
                    if(qcdata != null ){
                        totalSpending +=  (qcdata.Total_Spending__c == null? 0:qcdata.Total_Spending__c);
                        realSpending +=  (qcdata.Real_Spending__c == null? 0:qcdata.Real_Spending__c); 
                    }
                                       
                }
            

                if( hom.Custom_Contract__c != null && hom.Custom_Contract__r.Payment_method__c == 'Prepaid' ){
                    //discount as policy
                    if( hom.Custom_Contract__r.DiscountBonus_as_Policy__c){
                        policyRate = hom.Custom_Contract__r.Special_discount__c == null?0 : hom.Custom_Contract__r.Special_discount__c;
                    } 
                } 

                if( ( String.isBlank(hom.Custom_Contract__c) & !String.isBlank(hom.Account__c))
                    || (!String.isBlank(hom.Custom_Contract__c) && hom.Custom_Contract__r.Payment_method__c == 'Prepaid')){
                        netSpending = realSpending == null?0: realSpending;     
                        percent = totalSpending == 0?1 : netSpending / totalSpending;
                }else{
                    netSpending = realSpending == null?0: realSpending;     
                    percent = 1;
                }
                

                for(String qcId: this.mapQCAcc.get(hom.Id)){
                    HomDetail__c homdtl = new HomDetail__c();
                    initHOMDtl(homdtl);

                    homdtl.HandOverMinute__c = hom.Id;
                    homdtl.QC_Account__c = qcId;    
                    
                    System.debug('hom.Id =>' + hom.Id);
                    System.debug('qcId =>' + qcId);   
                    if(mapQCData.containsKey(qcId)){
                        QC_Account_Data__c qcdata = mapQCData.get(qcId);
                        
                        System.debug('qcdata =>' + qcdata);   
                        if(qcdata != null ){
                            setGrossspendingforHOMDetail(homdtl, qcdata);  
                            setnetSpendingforHOMDetail(homdtl, percent, policyRate);
                            setnetSpendingforHOM(hom, homdtl);                
                            
                            homdls.add(homdtl);
                        }
                       
                    }               
                }

                homs.add(hom);
            }else {
                homs.add(hom);
            }    
            
        }

        //Update HandOver Minute
        System.debug('Update homs => ' + homs.size());
        if(homs.size() > 0){            
            delete [SELECT Id FROM HomDetail__c WHERE HandOverMinute__c IN :processHomIds];
            Database.SaveResult[] results = Database.update(homs,false);

            for(Database.SaveResult rs: results){
                if (!rs.isSuccess()){
                    cc_DMLResult_wrapper err = new cc_DMLResult_wrapper();
                    err.Errors  = JSON.serialize(rs.getErrors()) ;  
                    this.lserrors.add(err);                 
                }
            }
        }
        
        //Update HandOver Minute Detail
        System.debug('Insert homdls => ' + homdls.size());
        if(homdls.size() > 0){
            Database.SaveResult[] results = Database.insert(homdls,false);

            for(Database.SaveResult rs: results){
                if (!rs.isSuccess()){
                    cc_DMLResult_wrapper err = new cc_DMLResult_wrapper();
                    err.Errors  = JSON.serialize(rs.getErrors()) ;    
                    this.lserrors.add(err);                 
                }
            }
        }    

    }

    global void finish(Database.BatchableContext bc){

        //Catch Error
        if(this.lserrors.size() > 0){

            AsyncApexJob asyn = [SELECT id, ApexClassId, ApexClass.name,
                                    JobItemsProcessed, TotalJobItems,
                                    NumberOfErrors, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE Id = :bc.getJobId()];

            Integer successed = 0;
            BatchJobLog__c batchlog = new BatchJobLog__c();
            batchlog.BatchClassName__c = asyn.ApexClass.name;
            batchlog.JobId__c = bc.getJobId();
            batchlog.Period__c = this.HOMperiod;
            batchlog.RunningUser__c = UserInfo.getUserId();
            insert batchlog;

            List<BatchJobLogDetail__c> errsLog = new List<BatchJobLogDetail__c>();
            for(cc_DMLResult_wrapper err: this.lserrors){
                
                BatchJobLogDetail__c log = new BatchJobLogDetail__c();
                log.IsCreated__c = true;                
                log.ErrorLog__c = err.Errors;
                log.BatchJobLog__c = batchlog.Id;

                errsLog.add(log);

            } 
            
            if (errsLog.size() > 0){   
                insert errsLog;
            }
        }
    }

    public void setGrossspendingforHOMDetail(HomDetail__c hom, QC_Account_Data__c qcData){       

        //internal        
        hom.real_spending__c = qcData.real_spending__c == null? 0: qcData.real_spending__c;
        hom.overspending__c =  qcData.overspending__c == null? 0: qcData.overspending__c ; 
        hom.Total_Spending__c =  qcData.Total_Calculation__c == null? 0: qcData.Total_Calculation__c;
        hom.Coupon_spending__c =  qcData.Coupon_spending__c == null? 0: qcData.Coupon_spending__c;

        hom.it_serp_desktop__c = qcData.serp_desktop_spending__c == null?0 : qcData.serp_desktop_spending__c ;
        hom.it_serp_mobile__c =  qcData.serp_mobile_spending__c == null?0 : qcData.serp_mobile_spending__c;        
        hom.it_serp_banners__c = qcData.serp_banners_spending__c == null?0 : qcData.serp_banners_spending__c;
        hom.it_serp_market__c = qcData.serp_market_spending__c == null?0 : qcData.serp_market_spending__c;
        hom.it_maps__c = qcData.maps_spending__c == null?0 : qcData.maps_spending__c;
        hom.it_icons__c = qcData.icons_newtab_spending__c  == null?0 : qcData.icons_newtab_spending__c;
        hom.it_Newtab_spending__c = qcData.new_tab_spending__c == null?0 : qcData.new_tab_spending__c;
        hom.it_Newtab_JS_Code_spending__c = qcData.new_tab_js_code_spending__c  == null?0 : qcData.new_tab_js_code_spending__c;
        hom.it_skins__c = qcData.skins_spending__c == null?0 : qcData.skins_spending__c;

        hom.it_masthead__c  = (qcData.masthead_spending__c == null? 0: qcData.masthead_spending__c) 
                            + (qcData.skintool_masthead_spending__c == null? 0: qcData.skintool_masthead_spending__c);
        hom.it_video__c = qcData.video_spending__c == null?0 : qcData.video_spending__c;
        hom.it_mb_general__c = qcData.mb_general_spending__c  == null?0 : qcData.mb_general_spending__c;
        hom.it_single_zen_cards__c = qcData.single_zen_cards_spending__c == null?0 :qcData.single_zen_cards_spending__c;
        hom.it_double_zen_cards__c = qcData.double_zen_cards_spending__c == null?0 :qcData.double_zen_cards_spending__c;
        hom.it_Video_masthead__c = qcData.video_masthead_spending__c == null?0 :qcData.video_masthead_spending__c;
        hom.it_Masthead_JScode__c = qcData.masthead_jscode_spending__c == null?0 :qcData.masthead_jscode_spending__c ;
        // hom.it_VAST_Skin__c = qcData.vast_skin_spending__c == null?0 :qcData.vast_skin_spending__c;
        hom.it_Skin__c = qcData.skintool_skin_spending__c == null?0 :qcData.skintool_skin_spending__c;
        hom.it_Video_skin__c = qcData.skintool_video_skin_spending__c == null?0 :qcData.skintool_video_skin_spending__c;
        hom.it_Masthead_video__c = qcData.skintool_masthead_video_spending__c == null?0 :qcData.skintool_masthead_video_spending__c;
        hom.it_Icon_sidebar__c = qcData.skintool_iconsidebar_spending__c == null?0 :qcData.skintool_iconsidebar_spending__c;
        hom.it_Video_banner__c = qcData.skintool_video_banner_spending__c == null?0 :qcData.skintool_video_banner_spending__c;
       
        //customer        
        if(qcData.serp_desktop_spending__c != null || qcData.serp_mobile_spending__c != null){            
            double spending = 0;
            spending = (qcData.serp_desktop_spending__c == null? 0: qcData.serp_desktop_spending__c)
                     + (qcData.serp_mobile_spending__c == null? 0: qcData.serp_mobile_spending__c);

            hom.cm_SEARCH_AD__c = spending == null? 0: spending;     
            hom.cm_SEARCH_AD_gross__c = spending == null? 0: spending; 
            hom.cm_SEARCH_AD_click__c = (qcData.serp_desktop_click__c == null? 0: qcData.serp_desktop_click__c) 
                                      + (qcData.serp_mobile_click__c == null? 0: qcData.serp_mobile_click__c);
            hom.cm_SEARCH_AD_view__c = (qcData.serp_desktop_show__c == null? 0: qcData.serp_desktop_show__c) 
                                     + (qcData.serp_mobile_show__c == null? 0: qcData.serp_mobile_show__c);
            
        }
        
        if(qcData.serp_banners_spending__c != null ){            
            hom.cm_SEARCH_BANNER__c = qcData.serp_banners_spending__c == null? 0: qcData.serp_banners_spending__c;
            hom.cm_SEARCH_BANNER_gross__c = qcData.serp_banners_spending__c == null? 0: qcData.serp_banners_spending__c;
            hom.cm_SEARCH_BANNER_click__c = qcData.serp_banners_click__c == null? 0: qcData.serp_banners_click__c;
            hom.cm_SEARCH_BANNER_view__c = qcData.serp_banners_show__c == null? 0: qcData.serp_banners_show__c;
        }
        if(qcData.serp_market_spending__c != null ){            
            hom.cm_Shopping_Ads__c = qcData.serp_market_spending__c == null? 0:qcData.serp_market_spending__c  ;            
            hom.cm_Shopping_Ads_gross__c = qcData.serp_market_spending__c == null? 0: qcData.serp_market_spending__c;
            hom.cm_Shopping_Ads_click__c = qcData.serp_market_click__c == null? 0: qcData.serp_market_click__c;  
            hom.cm_Shopping_Ads_view__c = qcData.serp_market_show__c == null? 0: qcData.serp_market_show__c;
        }
        if(qcData.icons_newtab_spending__c != null ){            
            hom.cm_Icon_Ads__c = qcData.icons_newtab_spending__c == null? 0: qcData.icons_newtab_spending__c;
            hom.cm_Icon_Ads_gross__c = qcData.icons_newtab_spending__c == null? 0: qcData.icons_newtab_spending__c;
            hom.cm_Icon_Ads_click__c = qcData.icons_newtab_click__c == null? 0: qcData.icons_newtab_click__c;   
            hom.cm_Icon_Ads_view__c = qcData.icons_newtab_show__c == null? 0: qcData.icons_newtab_show__c;
            
        }
        if(qcData.new_tab_js_code_spending__c != null ){            
            hom.cm_Newtab_JScode__c = qcData.new_tab_js_code_spending__c == null? 0:qcData.new_tab_js_code_spending__c;
            hom.cm_Newtab_JScode_gross__c = qcData.new_tab_js_code_spending__c == null? 0:qcData.new_tab_js_code_spending__c;
            hom.cm_Newtab_JScode_click__c = qcData.new_tab_js_code_click__c == null? 0: qcData.new_tab_js_code_click__c;
            hom.cm_Newtab_JScode_view__c = qcData.new_tab_js_code_show__c == null? 0: qcData.new_tab_js_code_show__c;
        }
        if(qcData.new_tab_spending__c != null ){            
            hom.cm_Newtab_Banner__c = qcData.new_tab_spending__c == null? 0: qcData.new_tab_spending__c;
            hom.cm_Newtab_Banner_gross__c = qcData.new_tab_spending__c == null? 0: qcData.new_tab_spending__c;
            hom.cm_Newtab_Banner_click__c = qcData.new_tab_click__c == null? 0: qcData.new_tab_click__c;
            hom.cm_Newtab_Banner_view__c = qcData.new_tab_show__c == null? 0: qcData.new_tab_show__c;
        }
        
        if(qcData.skins_spending__c != null || qcData.skintool_skin_spending__c != null){            
            double spending = 0;
            spending = (qcData.skins_spending__c == null? 0: qcData.skins_spending__c) 
                     + (qcData.skintool_skin_spending__c == null? 0: qcData.skintool_skin_spending__c);
            hom.cm_Brower_Skin_Ads__c  = spending ==  null?0 :spending;
            hom.cm_Brower_Skin_Ads_gross__c = spending ==  null?0 :spending;
            hom.cm_Brower_Skin_Ads_click__c = (qcData.skins_click__c == null? 0: qcData.skins_click__c) 
                                            + (qcData.skintool_skin_click__c == null? 0: qcData.skintool_skin_click__c);
            hom.cm_Brower_Skin_Ads_view__c = (qcData.skins_show__c == null? 0: qcData.skins_show__c) 
                                            + (qcData.skintool_skin_view__c == null? 0: qcData.skintool_skin_view__c);

        }
        if(qcData.video_spending__c != null || qcData.skintool_video_banner_spending__c != null){            
            double spending = 0;
            spending = (qcData.video_spending__c == null? 0: qcData.video_spending__c) 
                     + (qcData.skintool_video_banner_spending__c == null? 0: qcData.skintool_video_banner_spending__c);
            hom.cm_Newtab_video__c = spending ==  null?0 :spending;
            hom.cm_Newtab_video_gross__c = spending ==  null?0 :spending;
            hom.cm_Newtab_video_click__c = (qcData.video_click__c == null? 0: qcData.video_click__c) 
                                         + (qcData.skintool_video_banner_click__c == null? 0: qcData.skintool_video_banner_click__c);
            hom.cm_Newtab_video_view__c  = (qcData.video_show__c == null? 0: qcData.video_show__c)
                                         + (qcData.skintool_video_banner_view__c == null? 0: qcData.skintool_video_banner_view__c);
        }
        if(qcData.mb_general_spending__c != null || qcData.single_zen_cards_spending__c != null){            
            double spending = 0;
            spending = (qcData.mb_general_spending__c == null? 0: qcData.mb_general_spending__c)
                     + (qcData.single_zen_cards_spending__c == null? 0: qcData.single_zen_cards_spending__c);
            hom.cm_Small_Native_In_feed_banner__c = spending ==  null?0 :spending;           
            hom.cm_Small_Native_In_feed_banner_gross__c  = spending ==  null?0 :spending;
            
            hom.cm_Small_Native_In_feed_banner_click__c = (qcData.mb_general_click__c == null? 0: qcData.mb_general_click__c)
                                                        + (qcData.single_zen_cards_click__c == null? 0: qcData.single_zen_cards_click__c);
            
            hom.cm_Small_Native_In_feed_banner_view__c = (qcData.mb_general_show__c == null? 0: qcData.mb_general_show__c)
                                                       + (qcData.single_zen_cards_show__c == null? 0: qcData.single_zen_cards_show__c);
        }
        if(qcData.double_zen_cards_spending__c != null ){            
            hom.cm_Big_In_feed_banner__c = qcData.double_zen_cards_spending__c == null? 0:qcData.double_zen_cards_spending__c;  
            hom.cm_Big_In_feed_banner_gross__c = qcData.double_zen_cards_spending__c == null? 0:qcData.double_zen_cards_spending__c;
            hom.cm_Big_In_feed_banner_click__c = qcData.double_zen_cards_click__c == null? 0: qcData.double_zen_cards_click__c;
            hom.cm_Big_In_feed_banner_view__c = qcData.double_zen_cards_show__c == null? 0: qcData.double_zen_cards_show__c;
        }
        if(qcData.video_masthead_spending__c != null ){
            hom.cm_Magnetic_masthead_video__c = qcData.video_masthead_spending__c == null? 0:qcData.video_masthead_spending__c;
            hom.cm_Magnetic_masthead_video_gross__c = qcData.video_masthead_spending__c == null? 0:qcData.video_masthead_spending__c;
            hom.cm_Magnetic_masthead_video_click__c = qcData.video_masthead_click__c == null? 0: qcData.video_masthead_click__c;            
            hom.cm_Magnetic_masthead_video_view__c = qcData.video_masthead_show__c == null? 0: qcData.video_masthead_show__c;
        }
        if(qcData.masthead_jscode_spending__c != null ){
            hom.cm_Magnetic_Masthead_JScode__c = qcData.masthead_jscode_spending__c == null? 0:qcData.masthead_jscode_spending__c;            
            hom.cm_Magnetic_Masthead_JScode_gross__c = qcData.masthead_jscode_spending__c == null? 0:qcData.masthead_jscode_spending__c;            
            hom.cm_Magnetic_Masthead_JScode_click__c = qcData.masthead_jscode_click__c == null? 0: qcData.masthead_jscode_click__c;
            hom.cm_Magnetic_Masthead_JScode_view__c = qcData.masthead_jscode_show__c == null? 0: qcData.masthead_jscode_show__c;
        }
        // if(qcData.vast_skin_spending__c != null ){
        //     hom.cm_VAST_skin__c = qcData.vast_skin_spending__c == null? 0:qcData.vast_skin_spending__c;            
        //     hom.cm_VAST_skin_gross__c = qcData.vast_skin_spending__c == null? 0:qcData.vast_skin_spending__c;            
        //     hom.cm_VAST_skin_click__c = qcData.vast_skin_click__c == null? 0: qcData.vast_skin_click__c;            
        //     hom.cm_VAST_skin_view__c = qcData.vast_skin_show__c == null? 0: qcData.vast_skin_show__c;
        // }
        if(qcData.skintool_video_skin_spending__c != null ){
            hom.cm_Video_skin__c = qcData.skintool_video_skin_spending__c == null? 0:qcData.skintool_video_skin_spending__c;            
            hom.cm_Video_skin_gross__c = qcData.skintool_video_skin_spending__c == null? 0:qcData.skintool_video_skin_spending__c;            
            hom.cm_Video_skin_click__c = qcData.skintool_video_skin_click__c == null? 0: qcData.skintool_video_skin_click__c;
            hom.cm_Video_skin_view__c = qcData.skintool_video_skin_view__c == null? 0: qcData.skintool_video_skin_view__c;
        }
        if(qcData.skintool_masthead_spending__c != null || qcData.skintool_masthead_video_spending__c != null || qcData.masthead_spending__c != null){
            
            double spending = 0;
            spending    = (qcData.skintool_masthead_spending__c == null? 0: qcData.skintool_masthead_spending__c)
                        + (qcData.skintool_masthead_video_spending__c == null? 0: qcData.skintool_masthead_video_spending__c)
                        + (qcData.masthead_spending__c == null? 0: qcData.masthead_spending__c);
            hom.cm_Magnetic_Masthead__c = spending ==  null?0 :spending;         
            hom.cm_Magnetic_Masthead_gross__c = spending ==  null?0 :spending;
            
            hom.cm_Magnetic_Masthead_click__c = (qcData.skintool_masthead_click__c == null? 0: qcData.skintool_masthead_click__c)
                                              + (qcData.skintool_masthead_video_click__c == null? 0: qcData.skintool_masthead_video_click__c);
            
            hom.cm_Magnetic_Masthead_view__c = (qcData.skintool_masthead_view__c == null? 0: qcData.skintool_masthead_view__c)
                                             + (qcData.skintool_masthead_video_view__c == null?0:qcData.skintool_masthead_video_view__c);
        }
        if(qcData.skintool_iconsidebar_spending__c != null ){            
            hom.cm_Sidebar_Icon__c = qcData.skintool_iconsidebar_spending__c == null? 0: qcData.skintool_iconsidebar_spending__c;            
            hom.cm_Sidebar_Icon_gross__c = qcData.skintool_iconsidebar_spending__c == null? 0: qcData.skintool_iconsidebar_spending__c ;            
            hom.cm_Sidebar_Icon_click__c = qcData.skintool_iconsidebar_click__c == null? 0:qcData.skintool_iconsidebar_click__c ;
            hom.cm_Sidebar_Icon_view__c = qcData.skintool_iconsidebar_view__c == null? 0: qcData.skintool_iconsidebar_view__c;
        }
        if(qcData.maps_spending__c != null ){
            hom.cm_maps__c = qcData.maps_spending__c == null? 0: qcData.maps_spending__c;            
            hom.cm_maps_gross__c = qcData.maps_spending__c == null? 0: qcData.maps_spending__c;            
            hom.cm_maps_click__c = qcData.maps_click__c == null? 0: qcData.maps_click__c;            
            hom.cm_maps_view__c = qcData.maps_show__c == null? 0: qcData.maps_show__c;            
        }
    }

    public void setnetSpendingforHOMDetail(HomDetail__c hom, Decimal percent, Decimal policyRate){
        
        hom.Net_spending__c = hom.real_spending__c == null? 0: hom.real_spending__c;
        hom.Policy_Discount__c  = hom.real_spending__c == null? 0: hom.real_spending__c * policyRate;

        hom.it_serp_desktop__c = hom.it_serp_desktop__c == null? 0: hom.it_serp_desktop__c * percent;
        hom.it_serp_mobile__c = hom.it_serp_mobile__c == null? 0: hom.it_serp_mobile__c * percent;
        hom.it_serp_banners__c = hom.it_serp_banners__c == null? 0: hom.it_serp_banners__c *percent;
        hom.it_serp_market__c = hom.it_serp_market__c == null? 0: hom.it_serp_market__c *percent;
        hom.it_maps__c = hom.it_maps__c == null? 0: hom.it_maps__c *percent;       
        hom.it_icons__c = hom.it_icons__c == null? 0: hom.it_icons__c *percent;
        hom.it_Newtab_spending__c = hom.it_Newtab_spending__c == null? 0: hom.it_Newtab_spending__c *percent; 
        hom.it_Newtab_JS_Code_spending__c = hom.it_Newtab_JS_Code_spending__c == null? 0: hom.it_Newtab_JS_Code_spending__c *percent;
        hom.it_skins__c = hom.it_skins__c == null? 0: hom.it_skins__c *percent;
        hom.it_masthead__c = hom.it_masthead__c == null? 0: hom.it_masthead__c *percent;
        hom.it_video__c = hom.it_video__c == null? 0: hom.it_video__c *percent;
        hom.it_mb_general__c = hom.it_mb_general__c == null? 0: hom.it_mb_general__c *percent;
        hom.it_single_zen_cards__c = hom.it_single_zen_cards__c == null? 0: hom.it_single_zen_cards__c *percent;
        hom.it_double_zen_cards__c = hom.it_double_zen_cards__c == null? 0: hom.it_double_zen_cards__c *percent;
        
        hom.it_Video_masthead__c = hom.it_Video_masthead__c == null? 0: hom.it_Video_masthead__c *percent;
        hom.it_Masthead_JScode__c = hom.it_Masthead_JScode__c == null? 0: hom.it_Masthead_JScode__c *percent;
        // hom.it_VAST_Skin__c = hom.it_VAST_Skin__c == null? 0: hom.it_VAST_Skin__c *percent;
        hom.it_Skin__c = hom.it_Skin__c == null? 0: hom.it_Skin__c *percent;
        hom.it_Video_skin__c = hom.it_Video_skin__c == null? 0: hom.it_Video_skin__c *percent;
        hom.it_Masthead_video__c = hom.it_Masthead_video__c == null? 0: hom.it_Masthead_video__c *percent;
        hom.it_Icon_sidebar__c = hom.it_Icon_sidebar__c == null? 0: hom.it_Icon_sidebar__c *percent;
        hom.it_Video_banner__c = hom.it_Video_banner__c == null? 0: hom.it_Video_banner__c *percent;
        //customer
        hom.cm_SEARCH_AD__c = hom.cm_SEARCH_AD__c == null? 0: hom.cm_SEARCH_AD__c *percent;
        hom.cm_SEARCH_BANNER__c = hom.cm_SEARCH_BANNER__c == null? 0: hom.cm_SEARCH_BANNER__c *percent;
        hom.cm_Shopping_Ads__c = hom.cm_Shopping_Ads__c == null? 0: hom.cm_Shopping_Ads__c *percent;
        hom.cm_Icon_Ads__c = hom.cm_Icon_Ads__c == null? 0: hom.cm_Icon_Ads__c *percent;
        hom.cm_Newtab_JScode__c = hom.cm_Newtab_JScode__c == null? 0: hom.cm_Newtab_JScode__c *percent;
        hom.cm_Newtab_Banner__c = hom.cm_Newtab_Banner__c == null? 0: hom.cm_Newtab_Banner__c *percent;
        hom.cm_Brower_Skin_Ads__c = hom.cm_Brower_Skin_Ads__c == null? 0: hom.cm_Brower_Skin_Ads__c *percent;
        hom.cm_Newtab_video__c = hom.cm_Newtab_video__c == null? 0: hom.cm_Newtab_video__c *percent;
        hom.cm_Small_Native_In_feed_banner__c = hom.cm_Small_Native_In_feed_banner__c == null? 0: hom.cm_Small_Native_In_feed_banner__c *percent;
        hom.cm_Big_In_feed_banner__c = hom.cm_Big_In_feed_banner__c == null? 0: hom.cm_Big_In_feed_banner__c *percent;
        hom.cm_Magnetic_masthead_video__c = hom.cm_Magnetic_masthead_video__c == null? 0: hom.cm_Magnetic_masthead_video__c *percent;
        hom.cm_Magnetic_Masthead_JScode__c = hom.cm_Magnetic_Masthead_JScode__c == null? 0: hom.cm_Magnetic_Masthead_JScode__c *percent;
        // hom.cm_VAST_skin__c = hom.cm_VAST_skin__c == null? 0: hom.cm_VAST_skin__c *percent;
        hom.cm_Video_skin__c = hom.cm_Video_skin__c == null? 0: hom.cm_Video_skin__c *percent;
        hom.cm_Magnetic_Masthead__c = hom.cm_Magnetic_Masthead__c == null? 0: hom.cm_Magnetic_Masthead__c *percent;
        hom.cm_Sidebar_Icon__c = hom.cm_Sidebar_Icon__c == null? 0: hom.cm_Sidebar_Icon__c *percent;
        hom.cm_maps__c = hom.cm_maps__c == null? 0: hom.cm_maps__c *percent;
        
    }

    public void setnetSpendingforHOM(HandOver_Minute__c hom, HomDetail__c homdtl){        
        
        //internal        
        hom.Net_spending__c += ( homdtl.Net_spending__c == null ?0 : homdtl.Net_spending__c );        
        hom.Total_Spending__c += ( homdtl.Total_Spending__c == null ?0 : homdtl.Total_Spending__c ); 
        
        hom.real_spending__c += ( homdtl.real_spending__c == null ?0 : homdtl.real_spending__c );   
        hom.overspending__c +=  ( homdtl.overspending__c == null ?0 : homdtl.overspending__c );           
        hom.Coupon_spending__c += ( homdtl.Coupon_spending__c == null ?0 : homdtl.Coupon_spending__c );        

        hom.it_serp_desktop__c += ( homdtl.it_serp_desktop__c == null ?0 : homdtl.it_serp_desktop__c);
        hom.it_serp_mobile__c += ( homdtl.it_serp_mobile__c == null ?0 : homdtl.it_serp_mobile__c);
        hom.it_serp_banners__c += ( homdtl.it_serp_banners__c == null ?0 : homdtl.it_serp_banners__c);
        hom.it_serp_market__c += ( homdtl.it_serp_market__c == null ?0 : homdtl.it_serp_market__c);
        hom.it_maps__c += ( homdtl.it_maps__c ==null ?0 : homdtl.it_maps__c);
        hom.it_icons__c += ( homdtl.it_icons__c ==null ?0 : homdtl.it_icons__c);
        hom.it_Newtab_spending__c += ( homdtl.it_Newtab_spending__c ==null ?0 : homdtl.it_Newtab_spending__c);
        hom.it_Newtab_JS_Code_spending__c += ( homdtl.it_Newtab_JS_Code_spending__c ==null ?0 : homdtl.it_Newtab_JS_Code_spending__c);
        hom.it_skins__c += ( homdtl.it_skins__c ==null ?0 : homdtl.it_skins__c);

        hom.it_masthead__c  += ( homdtl.it_masthead__c ==null ?0 : homdtl.it_masthead__c);
        hom.it_video__c += ( homdtl.it_video__c ==null ?0 : homdtl.it_video__c);
        hom.it_mb_general__c += ( homdtl.it_mb_general__c ==null ?0 : homdtl.it_mb_general__c);
        hom.it_single_zen_cards__c += ( homdtl.it_single_zen_cards__c ==null ?0 : homdtl.it_single_zen_cards__c);
        hom.it_double_zen_cards__c += ( homdtl.it_double_zen_cards__c ==null ?0 : homdtl.it_double_zen_cards__c);
        hom.it_Video_masthead__c += ( homdtl.it_Video_masthead__c ==null ?0 : homdtl.it_Video_masthead__c);
        hom.it_Masthead_JScode__c += ( homdtl.it_Masthead_JScode__c ==null ?0 : homdtl.it_Masthead_JScode__c);
        // hom.it_VAST_Skin__c += ( homdtl.it_VAST_Skin__c ==null ?0 : homdtl.it_VAST_Skin__c);
        hom.it_Skin__c += ( homdtl.it_Skin__c ==null ?0 : homdtl.it_Skin__c);
        hom.it_Video_skin__c += ( homdtl.it_Video_skin__c ==null ?0 : homdtl.it_Video_skin__c);
        hom.it_Masthead_video__c += ( homdtl.it_Masthead_video__c ==null ?0 : homdtl.it_Masthead_video__c);
        hom.it_Icon_sidebar__c += ( homdtl.it_Icon_sidebar__c ==null ?0 : homdtl.it_Icon_sidebar__c);
        hom.it_Video_banner__c += ( homdtl.it_Video_banner__c ==null ?0 : homdtl.it_Video_banner__c);
       
        //customer 
        hom.cm_SEARCH_AD__c += ( homdtl.cm_SEARCH_AD__c==null?0 : homdtl.cm_SEARCH_AD__c);
        hom.cm_SEARCH_AD_gross__c += ( homdtl.cm_SEARCH_AD_gross__c==null?0 : homdtl.cm_SEARCH_AD_gross__c);
        hom.cm_SEARCH_AD_click__c += ( homdtl.cm_SEARCH_AD_click__c==null?0 : homdtl.cm_SEARCH_AD_click__c);
        hom.cm_SEARCH_AD_view__c += ( homdtl.cm_SEARCH_AD_view__c==null?0 : homdtl.cm_SEARCH_AD_view__c);

        hom.cm_SEARCH_BANNER__c += ( homdtl.cm_SEARCH_BANNER__c==null?0 : homdtl.cm_SEARCH_BANNER__c);
        hom.cm_SEARCH_BANNER_gross__c += ( homdtl.cm_SEARCH_BANNER_gross__c==null?0 : homdtl.cm_SEARCH_BANNER_gross__c); 
        hom.cm_SEARCH_BANNER_click__c += ( homdtl.cm_SEARCH_BANNER_click__c==null?0 : homdtl.cm_SEARCH_BANNER_click__c);
        hom.cm_SEARCH_BANNER_view__c += ( homdtl.cm_SEARCH_BANNER_view__c==null?0 : homdtl.cm_SEARCH_BANNER_view__c);

        hom.cm_Shopping_Ads__c += ( homdtl.cm_Shopping_Ads__c==null?0 : homdtl.cm_Shopping_Ads__c);
        hom.cm_Shopping_Ads_gross__c += ( homdtl.cm_Shopping_Ads_gross__c==null?0 : homdtl.cm_Shopping_Ads_gross__c);
        hom.cm_Shopping_Ads_click__c += ( homdtl.cm_Shopping_Ads_click__c==null?0 : homdtl.cm_Shopping_Ads_click__c);
        hom.cm_Shopping_Ads_view__c += ( homdtl.cm_Shopping_Ads_view__c==null?0 : homdtl.cm_Shopping_Ads_view__c);

        hom.cm_Icon_Ads__c += ( homdtl.cm_Icon_Ads__c==null?0 : homdtl.cm_Icon_Ads__c);
        hom.cm_Icon_Ads_gross__c += ( homdtl.cm_Icon_Ads_gross__c==null?0 : homdtl.cm_Icon_Ads_gross__c);
        hom.cm_Icon_Ads_click__c += ( homdtl.cm_Icon_Ads_click__c==null?0 : homdtl.cm_Icon_Ads_click__c);
        hom.cm_Icon_Ads_view__c += ( homdtl.cm_Icon_Ads_view__c==null?0 : homdtl.cm_Icon_Ads_view__c);

        hom.cm_Newtab_JScode__c += ( homdtl.cm_Newtab_JScode__c==null?0 : homdtl.cm_Newtab_JScode__c);
        hom.cm_Newtab_JScode_gross__c += ( homdtl.cm_Newtab_JScode_gross__c==null?0 : homdtl.cm_Newtab_JScode_gross__c);
        hom.cm_Newtab_JScode_click__c += ( homdtl.cm_Newtab_JScode_click__c==null?0 : homdtl.cm_Newtab_JScode_click__c);
        hom.cm_Newtab_JScode_view__c += ( homdtl.cm_Newtab_JScode_view__c==null?0 : homdtl.cm_Newtab_JScode_view__c);

        hom.cm_Newtab_Banner__c += ( homdtl.cm_Newtab_Banner__c==null?0 : homdtl.cm_Newtab_Banner__c);
        hom.cm_Newtab_Banner_gross__c += ( homdtl.cm_Newtab_Banner_gross__c==null?0 : homdtl.cm_Newtab_Banner_gross__c);
        hom.cm_Newtab_Banner_click__c += ( homdtl.cm_Newtab_Banner_click__c==null?0 : homdtl.cm_Newtab_Banner_click__c);
        hom.cm_Newtab_Banner_view__c += ( homdtl.cm_Newtab_Banner_view__c==null?0 : homdtl.cm_Newtab_Banner_view__c);

       
        hom.cm_Brower_Skin_Ads__c += ( homdtl.cm_Brower_Skin_Ads__c==null?0 : homdtl.cm_Brower_Skin_Ads__c);
        hom.cm_Brower_Skin_Ads_gross__c += ( homdtl.cm_Brower_Skin_Ads_gross__c==null?0 : homdtl.cm_Brower_Skin_Ads_gross__c);
        hom.cm_Brower_Skin_Ads_click__c += ( homdtl.cm_Brower_Skin_Ads_click__c==null?0 : homdtl.cm_Brower_Skin_Ads_click__c);
        hom.cm_Brower_Skin_Ads_view__c += ( homdtl.cm_Brower_Skin_Ads_view__c==null?0 : homdtl.cm_Brower_Skin_Ads_view__c);

        hom.cm_Newtab_video__c += ( homdtl.cm_Newtab_video__c==null?0 : homdtl.cm_Newtab_video__c);
        hom.cm_Newtab_video_gross__c += ( homdtl.cm_Newtab_video_gross__c==null?0 : homdtl.cm_Newtab_video_gross__c);
        hom.cm_Newtab_video_click__c += ( homdtl.cm_Newtab_video_click__c==null?0 : homdtl.cm_Newtab_video_click__c);
        hom.cm_Newtab_video_view__c += ( homdtl.cm_Newtab_video_view__c==null?0 : homdtl.cm_Newtab_video_view__c);

        hom.cm_Small_Native_In_feed_banner__c += ( homdtl.cm_Small_Native_In_feed_banner__c==null?0 : homdtl.cm_Small_Native_In_feed_banner__c);
        hom.cm_Small_Native_In_feed_banner_gross__c += ( homdtl.cm_Small_Native_In_feed_banner_gross__c==null?0 : homdtl.cm_Small_Native_In_feed_banner_gross__c);
        hom.cm_Small_Native_In_feed_banner_click__c += ( homdtl.cm_Small_Native_In_feed_banner_click__c==null?0 : homdtl.cm_Small_Native_In_feed_banner_click__c);
        hom.cm_Small_Native_In_feed_banner_view__c += ( homdtl.cm_Small_Native_In_feed_banner_view__c==null?0 : homdtl.cm_Small_Native_In_feed_banner_view__c);

        hom.cm_Big_In_feed_banner__c += ( homdtl.cm_Big_In_feed_banner__c==null?0 : homdtl.cm_Big_In_feed_banner__c);
        hom.cm_Big_In_feed_banner_gross__c += ( homdtl.cm_Big_In_feed_banner_gross__c==null?0 : homdtl.cm_Big_In_feed_banner_gross__c);
        hom.cm_Big_In_feed_banner_click__c += ( homdtl.cm_Big_In_feed_banner_click__c==null?0 : homdtl.cm_Big_In_feed_banner_click__c);
        hom.cm_Big_In_feed_banner_view__c += ( homdtl.cm_Big_In_feed_banner_view__c==null?0 : homdtl.cm_Big_In_feed_banner_view__c);

        hom.cm_Magnetic_masthead_video__c += ( homdtl.cm_Magnetic_masthead_video__c==null?0 : homdtl.cm_Magnetic_masthead_video__c);
        hom.cm_Magnetic_masthead_video_gross__c += ( homdtl.cm_Magnetic_masthead_video_gross__c==null?0 : homdtl.cm_Magnetic_masthead_video_gross__c);
        hom.cm_Magnetic_masthead_video_click__c += ( homdtl.cm_Magnetic_masthead_video_click__c==null?0 : homdtl.cm_Magnetic_masthead_video_click__c);
        hom.cm_Magnetic_masthead_video_view__c += ( homdtl.cm_Magnetic_masthead_video_view__c==null?0 : homdtl.cm_Magnetic_masthead_video_view__c);
        
        hom.cm_Magnetic_Masthead_JScode__c += ( homdtl.cm_Magnetic_Masthead_JScode__c==null?0 : homdtl.cm_Magnetic_Masthead_JScode__c);
        hom.cm_Magnetic_Masthead_JScode_gross__c += ( homdtl.cm_Magnetic_Masthead_JScode_gross__c==null?0 : homdtl.cm_Magnetic_Masthead_JScode_gross__c);
        hom.cm_Magnetic_Masthead_JScode_click__c += ( homdtl.cm_Magnetic_Masthead_JScode_click__c==null?0 : homdtl.cm_Magnetic_Masthead_JScode_click__c);
        hom.cm_Magnetic_Masthead_JScode_view__c += ( homdtl.cm_Magnetic_Masthead_JScode_view__c==null?0 : homdtl.cm_Magnetic_Masthead_JScode_view__c);

        // hom.cm_VAST_skin__c += ( homdtl.cm_VAST_skin__c==null?0 : homdtl.cm_VAST_skin__c);
        // hom.cm_VAST_skin_gross__c += ( homdtl.cm_VAST_skin_gross__c==null?0 : homdtl.cm_VAST_skin_gross__c);
        // hom.cm_VAST_skin_click__c += ( homdtl.cm_VAST_skin_click__c==null?0 : homdtl.cm_VAST_skin_click__c);
        // hom.cm_VAST_skin_view__c += ( homdtl.cm_VAST_skin_view__c==null?0 : homdtl.cm_VAST_skin_view__c);

        hom.cm_Video_skin__c += ( homdtl.cm_Video_skin__c==null?0 : homdtl.cm_Video_skin__c);
        hom.cm_Video_skin_gross__c += ( homdtl.cm_Video_skin_gross__c==null?0 : homdtl.cm_Video_skin_gross__c);
        hom.cm_Video_skin_click__c += ( homdtl.cm_Video_skin_click__c==null?0 : homdtl.cm_Video_skin_click__c);
        hom.cm_Video_skin_view__c += ( homdtl.cm_Video_skin_view__c==null?0 : homdtl.cm_Video_skin_view__c);
        
        hom.cm_Magnetic_Masthead__c += ( homdtl.cm_Magnetic_Masthead__c==null?0 : homdtl.cm_Magnetic_Masthead__c);
        hom.cm_Magnetic_Masthead_gross__c += ( homdtl.cm_Magnetic_Masthead_gross__c==null?0 : homdtl.cm_Magnetic_Masthead_gross__c);
        hom.cm_Magnetic_Masthead_click__c += ( homdtl.cm_Magnetic_Masthead_click__c==null?0 : homdtl.cm_Magnetic_Masthead_click__c);
        hom.cm_Magnetic_Masthead_view__c += ( homdtl.cm_Magnetic_Masthead_view__c==null?0 : homdtl.cm_Magnetic_Masthead_view__c);


        hom.cm_Sidebar_Icon__c += ( homdtl.cm_Sidebar_Icon__c==null?0 : homdtl.cm_Sidebar_Icon__c);
        hom.cm_Sidebar_Icon_gross__c += ( homdtl.cm_Sidebar_Icon_gross__c==null?0 : homdtl.cm_Sidebar_Icon_gross__c);
        hom.cm_Sidebar_Icon_click__c += ( homdtl.cm_Sidebar_Icon_click__c==null?0 : homdtl.cm_Sidebar_Icon_click__c);
        hom.cm_Sidebar_Icon_view__c += ( homdtl.cm_Sidebar_Icon_view__c==null?0 : homdtl.cm_Sidebar_Icon_view__c);


        hom.cm_maps__c += ( homdtl.cm_maps__c==null?0 : homdtl.cm_maps__c);
        hom.cm_maps_gross__c += ( homdtl.cm_maps_gross__c==null?0 : homdtl.cm_maps_gross__c);
        hom.cm_maps_click__c += ( homdtl.cm_maps_click__c==null?0 : homdtl.cm_maps_click__c);
        hom.cm_maps_view__c += ( homdtl.cm_maps_view__c==null?0 : homdtl.cm_maps_view__c);       
    }

    public void initHOMDtl(HomDetail__c hom){
        hom.it_serp_desktop__c = 0;
        hom.it_serp_mobile__c = 0;
        hom.it_serp_banners__c = 0;
        hom.it_serp_market__c = 0;
        hom.it_maps__c = 0;
        hom.it_maps__c = 0;
        hom.it_icons__c = 0;
        hom.it_Newtab_spending__c = 0;
        hom.it_Newtab_JS_Code_spending__c = 0;
        hom.it_skins__c = 0;
        hom.it_masthead__c = 0;
        hom.it_video__c = 0;
        hom.it_mb_general__c = 0;
        hom.it_single_zen_cards__c = 0;
        hom.it_double_zen_cards__c = 0;
        
        hom.it_Video_masthead__c = 0;
        hom.it_Masthead_JScode__c = 0;
        // hom.it_VAST_Skin__c = 0;
        hom.it_Skin__c = 0;
        hom.it_Video_skin__c = 0;
        hom.it_Masthead_video__c = 0;
        hom.it_Icon_sidebar__c = 0;
        hom.it_Video_banner__c =0;
        //customer Net
        hom.cm_SEARCH_AD__c = 0;
        hom.cm_SEARCH_BANNER__c = 0;
        hom.cm_Shopping_Ads__c = 0;
        hom.cm_Icon_Ads__c = 0;
        hom.cm_Newtab_JScode__c = 0;
        hom.cm_Newtab_Banner__c = 0;
        hom.cm_Brower_Skin_Ads__c = 0;
        hom.cm_Newtab_video__c = 0;
        hom.cm_Small_Native_In_feed_banner__c = 0;
        hom.cm_Big_In_feed_banner__c = 0;
        hom.cm_Magnetic_masthead_video__c = 0;
        hom.cm_Magnetic_Masthead_JScode__c = 0;
        hom.cm_VAST_skin__c = 0;
        hom.cm_Video_skin__c = 0;
        hom.cm_Magnetic_Masthead__c = 0;
        hom.cm_Sidebar_Icon__c = 0;
        hom.cm_maps__c = 0;
        //customer gross
        hom.cm_SEARCH_AD_gross__c = 0;
        hom.cm_SEARCH_BANNER_gross__c = 0;
        hom.cm_Shopping_Ads_gross__c = 0;
        hom.cm_Icon_Ads_gross__c = 0;
        hom.cm_Newtab_JScode_gross__c = 0;
        hom.cm_Newtab_Banner_gross__c = 0;
        hom.cm_Brower_Skin_Ads_gross__c = 0;
        hom.cm_Newtab_video_gross__c = 0;
        hom.cm_Small_Native_In_feed_banner_gross__c = 0;
        hom.cm_Big_In_feed_banner_gross__c = 0;
        hom.cm_Magnetic_masthead_video_gross__c = 0;
        hom.cm_Magnetic_Masthead_JScode_gross__c = 0;
        // hom.cm_VAST_skin_gross__c = 0;
        hom.cm_Video_skin_gross__c = 0;
        hom.cm_Magnetic_Masthead_gross__c = 0;
        hom.cm_Sidebar_Icon_gross__c = 0;
        hom.cm_maps_gross__c = 0;
        //customer click
        hom.cm_SEARCH_AD_click__c = 0;
        hom.cm_SEARCH_BANNER_click__c = 0;
        hom.cm_Shopping_Ads_click__c = 0;
        hom.cm_Icon_Ads_click__c = 0;
        hom.cm_Newtab_JScode_click__c = 0;
        hom.cm_Newtab_Banner_click__c = 0;
        hom.cm_Brower_Skin_Ads_click__c = 0;
        hom.cm_Newtab_video_click__c = 0;
        hom.cm_Small_Native_In_feed_banner_click__c = 0;
        hom.cm_Big_In_feed_banner_click__c = 0;
        hom.cm_Magnetic_masthead_video_click__c = 0;
        hom.cm_Magnetic_Masthead_JScode_click__c = 0;
        // hom.cm_VAST_skin_click__c = 0;
        hom.cm_Video_skin_click__c = 0;
        hom.cm_Magnetic_Masthead_click__c = 0;
        hom.cm_Sidebar_Icon_click__c = 0;
        hom.cm_maps_click__c = 0;
        
        hom.cm_Big_In_feed_banner_view__c=0;
        hom.cm_Brower_Skin_Ads_view__c=0;
        hom.cm_Icon_Ads_view__c=0;
        hom.cm_Magnetic_Masthead_view__c=0;
        hom.cm_Magnetic_Masthead_JScode_view__c=0;
        hom.cm_Magnetic_masthead_video_view__c=0;
        hom.cm_Newtab_Banner_view__c=0;
        hom.cm_Newtab_JScode_view__c=0;
        hom.cm_Newtab_video_view__c=0;
        hom.cm_SEARCH_AD_view__c=0;
        hom.cm_SEARCH_BANNER_view__c=0;
        hom.cm_Shopping_Ads_view__c=0;
        hom.cm_Sidebar_Icon_view__c=0;
        hom.cm_Small_Native_In_feed_banner_view__c=0;
        // hom.cm_VAST_skin_view__c=0;
        hom.cm_Video_skin_view__c=0;
		hom.cm_maps_view__c = 0;
        
    }

    public void initHOM(HandOver_Minute__c hom){
        hom.Net_spending__c  = 0;
        hom.Total_Spending__c  = 0;
        hom.real_spending__c = 0;  
        hom.overspending__c = 0;          
        hom.Coupon_spending__c = 0;

        hom.it_serp_desktop__c = 0;
        hom.it_serp_mobile__c = 0;
        hom.it_serp_banners__c = 0;
        hom.it_serp_market__c = 0;
        hom.it_maps__c = 0;
        hom.it_maps__c = 0;
        hom.it_icons__c = 0;
        hom.it_Newtab_spending__c = 0;
        hom.it_Newtab_JS_Code_spending__c = 0;
        hom.it_skins__c = 0;
        hom.it_masthead__c = 0;
        hom.it_video__c = 0;
        hom.it_mb_general__c = 0;
        hom.it_single_zen_cards__c = 0;
        hom.it_double_zen_cards__c = 0;
        
        hom.it_Video_masthead__c = 0;
        hom.it_Masthead_JScode__c = 0;
        // hom.it_VAST_Skin__c = 0;
        hom.it_Skin__c = 0;
        hom.it_Video_skin__c = 0;
        hom.it_Masthead_video__c = 0;
        hom.it_Icon_sidebar__c = 0;
        hom.it_Video_banner__c =0;
        //customer Net
        hom.cm_SEARCH_AD__c = 0;
        hom.cm_SEARCH_BANNER__c = 0;
        hom.cm_Shopping_Ads__c = 0;
        hom.cm_Icon_Ads__c = 0;
        hom.cm_Newtab_JScode__c = 0;
        hom.cm_Newtab_Banner__c = 0;
        hom.cm_Brower_Skin_Ads__c = 0;
        hom.cm_Newtab_video__c = 0;
        hom.cm_Small_Native_In_feed_banner__c = 0;
        hom.cm_Big_In_feed_banner__c = 0;
        hom.cm_Magnetic_masthead_video__c = 0;
        hom.cm_Magnetic_Masthead_JScode__c = 0;
        // hom.cm_VAST_skin__c = 0;
        hom.cm_Video_skin__c = 0;
        hom.cm_Magnetic_Masthead__c = 0;
        hom.cm_Sidebar_Icon__c = 0;
        hom.cm_maps__c = 0;
        //customer gross
        hom.cm_SEARCH_AD_gross__c = 0;
        hom.cm_SEARCH_BANNER_gross__c = 0;
        hom.cm_Shopping_Ads_gross__c = 0;
        hom.cm_Icon_Ads_gross__c = 0;
        hom.cm_Newtab_JScode_gross__c = 0;
        hom.cm_Newtab_Banner_gross__c = 0;
        hom.cm_Brower_Skin_Ads_gross__c = 0;
        hom.cm_Newtab_video_gross__c = 0;
        hom.cm_Small_Native_In_feed_banner_gross__c = 0;
        hom.cm_Big_In_feed_banner_gross__c = 0;
        hom.cm_Magnetic_masthead_video_gross__c = 0;
        hom.cm_Magnetic_Masthead_JScode_gross__c = 0;
        // hom.cm_VAST_skin_gross__c = 0;
        hom.cm_Video_skin_gross__c = 0;
        hom.cm_Magnetic_Masthead_gross__c = 0;
        hom.cm_Sidebar_Icon_gross__c = 0;
        hom.cm_maps_gross__c = 0;
        //customer click
        hom.cm_SEARCH_AD_click__c = 0;
        hom.cm_SEARCH_BANNER_click__c = 0;
        hom.cm_Shopping_Ads_click__c = 0;
        hom.cm_Icon_Ads_click__c = 0;
        hom.cm_Newtab_JScode_click__c = 0;
        hom.cm_Newtab_Banner_click__c = 0;
        hom.cm_Brower_Skin_Ads_click__c = 0;
        hom.cm_Newtab_video_click__c = 0;
        hom.cm_Small_Native_In_feed_banner_click__c = 0;
        hom.cm_Big_In_feed_banner_click__c = 0;
        hom.cm_Magnetic_masthead_video_click__c = 0;
        hom.cm_Magnetic_Masthead_JScode_click__c = 0;
        // hom.cm_VAST_skin_click__c = 0;
        hom.cm_Video_skin_click__c = 0;
        hom.cm_Magnetic_Masthead_click__c = 0;
        hom.cm_Sidebar_Icon_click__c = 0;
        hom.cm_maps_click__c = 0;
        
        hom.cm_Big_In_feed_banner_view__c=0;
        hom.cm_Brower_Skin_Ads_view__c=0;
        hom.cm_Icon_Ads_view__c=0;
        hom.cm_Magnetic_Masthead_view__c=0;
        hom.cm_Magnetic_Masthead_JScode_view__c=0;
        hom.cm_Magnetic_masthead_video_view__c=0;
        hom.cm_Newtab_Banner_view__c=0;
        hom.cm_Newtab_JScode_view__c=0;
        hom.cm_Newtab_video_view__c=0;
        hom.cm_SEARCH_AD_view__c=0;
        hom.cm_SEARCH_BANNER_view__c=0;
        hom.cm_Shopping_Ads_view__c=0;
        hom.cm_Sidebar_Icon_view__c=0;
        hom.cm_Small_Native_In_feed_banner_view__c=0;
        // hom.cm_VAST_skin_view__c=0;
        hom.cm_Video_skin_view__c=0;
		hom.cm_maps_view__c = 0;
        
    }   
}