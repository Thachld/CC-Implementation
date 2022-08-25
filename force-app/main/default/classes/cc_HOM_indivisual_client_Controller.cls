public class cc_HOM_indivisual_client_Controller {
    public id homId {get;set;} 
    public QC_Account__c qcAccount {get;set;}
    public HandOver_Minute__c hom {get;set;}
    public List<homValuesMapWrapper> hombyAds {get;set;}
    public double sum{get;set;}
    public cc_HOM_indivisual_client_Controller(){
        try{
            sum = 0;
            hombyAds = new List<homValuesMapWrapper>();
            homId = ApexPages.currentPage().getParameters().get('id');
            if( Test.isRunningTest()){
                getHom();
            }
            
           
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,ex.getMessage()));
        }
       
    }
    public PageReference  getHom(){
        hom = [select id,Name,Account__c, Account__r.RecordType.Name , Custom_Contract__c ,Net_spending__c, Start_date__c, End_date__c ,Custom_Contract__r.Type__c,monthly_key__c,
               Custom_Contract__r.DiscountBonus_as_Policy__c,Custom_Contract__r.Special_discount__c, Custom_Contract__r.Payment_method__c, 
               Custom_Contract__r.Previous_Coupon__c, Custom_Contract__r.Current_Coupon__c, Custom_Contract__r.Contract_Start_Date__c, 
               cm_SEARCH_AD__c,cm_SEARCH_BANNER__c,
               cm_Shopping_Ads__c,cm_Icon_Ads__c,cm_Newtab_JScode__c,
               cm_Newtab_Banner__c,cm_Brower_Skin_Ads__c,cm_Newtab_video__c,
               cm_Small_Native_In_feed_banner__c,cm_Big_In_feed_banner__c,
               cm_Magnetic_masthead_video__c,cm_Magnetic_Masthead_JScode__c,cm_VAST_skin__c,
               cm_Video_skin__c,cm_Magnetic_Masthead__c,cm_Sidebar_Icon__c,cm_maps__c,
               cm_Big_In_feed_banner_view__c, cm_Brower_Skin_Ads_view__c,
               cm_Icon_Ads_view__c,cm_Magnetic_Masthead_view__c,
               cm_Magnetic_Masthead_JScode_view__c,cm_Magnetic_masthead_video_view__c,
               cm_Newtab_Banner_view__c,cm_Newtab_JScode_view__c,
               cm_Newtab_video_view__c, cm_SEARCH_AD_view__c,
               cm_SEARCH_BANNER_view__c, cm_Shopping_Ads_view__c,
               cm_Sidebar_Icon_view__c,  cm_Small_Native_In_feed_banner_view__c,
               cm_VAST_skin_view__c,cm_Video_skin_view__c,cm_maps_view__c,
               cm_Big_In_feed_banner_click__c, cm_Brower_Skin_Ads_click__c,
               cm_Icon_Ads_click__c, cm_Magnetic_Masthead_click__c,
               cm_Magnetic_Masthead_JScode_click__c,cm_Magnetic_masthead_video_click__c,
               cm_Newtab_Banner_click__c, cm_Newtab_JScode_click__c,
               cm_Newtab_video_click__c, cm_SEARCH_AD_click__c,
               cm_SEARCH_BANNER_click__c, cm_Shopping_Ads_click__c,
               cm_Sidebar_Icon_click__c,cm_Small_Native_In_feed_banner_click__c,
               cm_VAST_skin_click__c, cm_Video_skin_click__c,cm_maps_click__c,
               cm_Big_In_feed_banner_gross__c,cm_Brower_Skin_Ads_gross__c,
               cm_Icon_Ads_gross__c,cm_Magnetic_Masthead_gross__c,
               cm_Magnetic_Masthead_JScode_gross__c,cm_Magnetic_masthead_video_gross__c,
               cm_Newtab_Banner_gross__c,cm_Newtab_JScode_gross__c,
               cm_Newtab_video_gross__c,cm_SEARCH_AD_gross__c,
               cm_SEARCH_BANNER_gross__c,cm_Shopping_Ads_gross__c,
               cm_Sidebar_Icon_gross__c,cm_Small_Native_In_feed_banner_gross__c,
               cm_VAST_skin_gross__c,cm_Video_skin_gross__c,cm_maps_gross__c
              
               from HandOver_Minute__c 
               where id  =: homId
              ];
         if(string.isBlank(hom.Custom_Contract__c) && !string.isBlank(hom.Account__c )){
                if( hom.Account__r.RecordType.Name != 'Person Account'){
                      PageReference companyPage = new PageReference('/apex/cc_hom_company_client?id=' + homId);
                        companyPage.setRedirect(true);
                        return companyPage;
	           }
            }
        
        if(hom.cm_Big_In_feed_banner__c != null && hom.cm_Big_In_feed_banner__c != 0){
            hombyAds.add(setValueforAds('Big In-feed banner',(integer) hom.cm_Big_In_feed_banner_view__c,(integer) hom.cm_Big_In_feed_banner_click__c, hom.cm_Big_In_feed_banner__c, hom.cm_Big_In_feed_banner_gross__c));
        }
         if(hom.cm_Brower_Skin_Ads__c != null && hom.cm_Brower_Skin_Ads__c != 0){
            hombyAds.add(setValueforAds('Brower Skin Ads',(integer) hom.cm_Brower_Skin_Ads_view__c,(integer) hom.cm_Brower_Skin_Ads_click__c, hom.cm_Brower_Skin_Ads__c, hom.cm_Brower_Skin_Ads_gross__c));
        }
        if(hom.cm_Icon_Ads__c != null && hom.cm_Icon_Ads__c != 0){
            hombyAds.add(setValueforAds('Icon Ads',(integer) hom.cm_Icon_Ads_view__c,(integer) hom.cm_Icon_Ads_click__c, hom.cm_Icon_Ads__c, hom.cm_Icon_Ads_gross__c));
        }
        if(hom.cm_Magnetic_Masthead__c != null && hom.cm_Magnetic_Masthead__c != 0){
            hombyAds.add(setValueforAds('Magnetic Masthead',(integer) hom.cm_Magnetic_Masthead_view__c,(integer) hom.cm_Magnetic_Masthead_click__c, hom.cm_Magnetic_Masthead__c, hom.cm_Magnetic_Masthead_gross__c));
        }
       if(hom.cm_Magnetic_Masthead_JScode__c != null && hom.cm_Magnetic_Masthead_JScode__c != 0){
            hombyAds.add(setValueforAds('Magnetic Masthead JScode',(integer) hom.cm_Magnetic_Masthead_JScode_view__c,(integer) hom.cm_Magnetic_Masthead_JScode_click__c, hom.cm_Magnetic_Masthead_JScode__c, hom.cm_Magnetic_Masthead_JScode_gross__c));
        }
        if(hom.cm_Magnetic_masthead_video__c != null && hom.cm_Magnetic_masthead_video__c != 0){
            hombyAds.add(setValueforAds('Magnetic masthead video',(integer) hom.cm_Magnetic_masthead_video_view__c,(integer) hom.cm_Magnetic_masthead_video_click__c, hom.cm_Magnetic_masthead_video__c, hom.cm_Magnetic_masthead_video_gross__c));
        }
         if(hom.cm_Newtab_Banner__c != null && hom.cm_Newtab_Banner__c != 0){
            hombyAds.add(setValueforAds('Newtab Banner',(integer) hom.cm_Newtab_Banner_view__c,(integer) hom.cm_Newtab_Banner_click__c, hom.cm_Newtab_Banner__c, hom.cm_Newtab_Banner_gross__c));
        }
        if(hom.cm_Newtab_JScode__c != null && hom.cm_Newtab_JScode__c != 0){
            hombyAds.add(setValueforAds('Newtab JScode',(integer) hom.cm_Newtab_JScode_view__c,(integer) hom.cm_Newtab_JScode_click__c, hom.cm_Newtab_JScode__c, hom.cm_Newtab_JScode_gross__c));
        }
        if(hom.cm_Newtab_video__c != null && hom.cm_Newtab_video__c != 0){
            hombyAds.add(setValueforAds('Newtab video',(integer) hom.cm_Newtab_video_view__c,(integer) hom.cm_Newtab_video_click__c, hom.cm_Newtab_video__c, hom.cm_Newtab_video_gross__c));
        }
         if(hom.cm_SEARCH_AD__c != null && hom.cm_SEARCH_AD__c != 0){
            hombyAds.add(setValueforAds('SEARCH AD',(integer) hom.cm_SEARCH_AD_view__c,(integer) hom.cm_SEARCH_AD_click__c, hom.cm_SEARCH_AD__c, hom.cm_SEARCH_AD_gross__c));
         }
             if(hom.cm_SEARCH_BANNER__c != null && hom.cm_SEARCH_BANNER__c != 0){
                 hombyAds.add(setValueforAds('SEARCH BANNER',(integer) hom.cm_SEARCH_BANNER_view__c,(integer) hom.cm_SEARCH_BANNER_click__c, hom.cm_SEARCH_BANNER__c, hom.cm_SEARCH_BANNER_gross__c));
        }
        if(hom.cm_Shopping_Ads__c != null && hom.cm_Shopping_Ads__c != 0){
            hombyAds.add(setValueforAds('Shopping Ads',(integer) hom.cm_Shopping_Ads_view__c,(integer) hom.cm_Shopping_Ads_click__c, hom.cm_Shopping_Ads__c, hom.cm_Shopping_Ads_gross__c));
         }
        if(hom.cm_Sidebar_Icon__c != null && hom.cm_Sidebar_Icon__c != 0){
            hombyAds.add(setValueforAds('Sidebar Icon',(integer) hom.cm_Sidebar_Icon_view__c,(integer) hom.cm_Sidebar_Icon_click__c, hom.cm_Sidebar_Icon__c, hom.cm_Sidebar_Icon_gross__c));
         }
        
        if(hom.cm_Small_Native_In_feed_banner__c != null && hom.cm_Small_Native_In_feed_banner__c != 0){
            hombyAds.add(setValueforAds('Small Native In-feed banner',(integer) hom.cm_Small_Native_In_feed_banner_view__c,(integer) hom.cm_Small_Native_In_feed_banner_click__c, hom.cm_Small_Native_In_feed_banner__c, hom.cm_Small_Native_In_feed_banner_gross__c));
         }
         if(hom.cm_VAST_skin__c != null && hom.cm_VAST_skin__c != 0){
            hombyAds.add(setValueforAds('VAST skin',(integer) hom.cm_VAST_skin_view__c,(integer) hom.cm_VAST_skin_click__c, hom.cm_VAST_skin__c, hom.cm_VAST_skin_gross__c));
         }
         if(hom.cm_Video_skin__c != null && hom.cm_Video_skin__c != 0){
            hombyAds.add(setValueforAds('Video skin',(integer) hom.cm_Video_skin_view__c,(integer) hom.cm_Video_skin_click__c, hom.cm_Video_skin__c, hom.cm_Video_skin_gross__c));
         }
        if(hom.cm_maps__c != null && hom.cm_maps__c != 0){
            hombyAds.add(setValueforAds('Map',(integer) hom.cm_maps_view__c,(integer) hom.cm_maps_click__c, hom.cm_maps__c, hom.cm_maps_gross__c));
        }
        
         qcAccount = [select id, name, QC_Account_Id__c, Individual_Phone__c,Phone__c    from QC_Account__c 
                         where AccountOwner__c =: hom.Account__c limit 1];
        return null;
    }
    public homValuesMapWrapper setValueforAds(string name, integer show, integer click, Decimal netspending, Decimal grossspending){
        homValuesMapWrapper temp = new homValuesMapWrapper(name);
        if(show != null )
            temp.show = show;
        if(click != null)
        	temp.click = click;
        if(netspending != null){
            temp.netspending = netspending;
            sum +=  temp.netspending;
        }
            
        if(grossspending != null)
            temp.grossspending = grossspending;
        if(temp.grossspending != null && temp.netspending != null)
            temp.discount = temp.grossspending - temp.netspending;
       
       
        return temp;
    }
}