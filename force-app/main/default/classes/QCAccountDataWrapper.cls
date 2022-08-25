public class QCAccountDataWrapper {
    public string customer_id;
	public long syn_date;
	public Integer serp_desktop_click;
	public Integer serp_desktop_show;
	public Double serp_desktop_spending;
	public Integer serp_banners_click;
	public Integer serp_banners_show;
	public Double serp_banners_spending;
	public Integer serp_market_click;
	public Integer serp_market_show;
	public Double serp_market_spending;
    public Integer serp_mobile_click;
	public Integer serp_mobile_show;
	public Double serp_mobile_spending;
	public Integer maps_click;
	public Integer maps_show;
	public Double maps_spending;
	public Integer icons_newtab_click;
	public Integer icons_newtab_show;
	public Double icons_newtab_spending;
	public Integer new_tab_click;
	public Integer new_tab_show;
	public Double new_tab_spending;
    public Integer new_tab_js_code_click;
    public Integer new_tab_js_code_show;
    public Double new_tab_js_code_spending;
	public Integer skins_click;
	public Integer skins_show;
	public Double skins_spending;
	public Integer masthead_click;
	public Integer masthead_show;
	public Double masthead_spending;
    public Integer masthead_jscode_show;
    public Integer masthead_jscode_click;
    public Double masthead_jscode_spending;
    public Integer video_masthead_click;
	public Integer video_masthead_show;
	public Double video_masthead_spending;
	public Integer video_click;
	public Integer video_show;
	public Double video_spending;
	public Integer mb_general_click;
	public Integer mb_general_show;
	public Double mb_general_spending;
	public Integer single_zen_cards_click;
	public Integer single_zen_cards_show;
	public Double single_zen_cards_spending;
	public Integer double_zen_cards_click;
	public Integer double_zen_cards_show;
	public Double double_zen_cards_spending;
    public Integer other_show;
	public Integer other_click;
	public Double other_spending;
    public Double overspending;
	public Double coupon_spending;
    public Double real_spending;
   	public Double real_Balance;
    public Double coupon_Balance;
    public Double refund_Balance;
    public Integer skintool_skin_view;
    public Integer skintool_skin_click;
    public Double skintool_skin_price;
    public Double skintool_skin_spending;
    public Integer  skintool_video_skin_view;
    public Integer skintool_video_skin_click;
    public Double skintool_video_skin_price;
    public Double skintool_video_skin_spending;
    public Integer skintool_masthead_view;
    public Integer skintool_masthead_click;
    public Double skintool_masthead_price;
    public Double skintool_masthead_spending;
    public Integer skintool_masthead_video_view;
    public Integer skintool_masthead_video_click;
    public Double skintool_masthead_video_price ;
    public Double skintool_masthead_video_spending;
    public Integer skintool_iconsidebar_view;
    public Integer skintool_iconsidebar_click;
    public Double skintool_iconsidebar_price;
    public Double skintool_iconsidebar_spending;
    public Integer skintool_video_banner_view;
    public Integer skintool_video_banner_click;
    public Double skintool_video_banner_price;
    public Double skintool_video_banner_spending;  

    public Integer skintool_vast_skin_view;
    public Integer skintool_vast_skin_click;
    public Double skintool_vast_skin_price;
    public Double skintool_vast_skin_spending;  

    public Integer vast_skin_show;
    public Integer vast_skin_click;
    public Double vast_skin_spending;
    public Integer native_content_ad_show;
    public Integer native_content_ad_click;
    public Double native_content_ad_spending;
    
    public Integer native_content_ad_external_show;
    public Integer native_content_ad_external_click;
    public Double native_content_ad_external_spending;

    public Integer single_zen_cards_mobile_show;
    public Integer single_zen_cards_mobile_click;
    public Double single_zen_cards_mobile_spending;

    
    private datetime synDateTemp;
    public datetime synDate{
        get{
            if( synDateTemp == null){
                synDateTemp = syn_date == null ? null : datetime.newInstance(syn_date);
            }
            return synDateTemp;
        }
    }
    private string synDateTempString;
    public string synDateString{
        get{
            if( synDateTempString == null){
                synDateTempString = synDate.format('dd/MM/yyyy');
            }
            return synDateTempString;
        }
    }
    
	public static List<QCAccountDataWrapper> parse(String json) {
		return (List<QCAccountDataWrapper>) System.JSON.deserialize(json, List<QCAccountDataWrapper>.class);
	}
	public class Responds{
        public Responds(){
            qcAccountError = new List<QCAccountDataError>();
            qcAccountSuccess = new List<QCAccountDataSuscess>();
        }
        public List<QCAccountDataError> qcAccountError;
        public Integer totalqcAccount {get;set;}
        public Integer totalSuccess {get;set;}
        public Integer totalFail{get;set;}
        public String error{get;set;}
        public List<QCAccountDataSuscess> qcAccountSuccess;
    }
    public class QCAccountDataSuscess{
        public String Customer_id;
    }
    
    public class QCAccountDataError {
        public QCAccountDataWrapper incomeError;
        public String insertError;
        public string updateError;
    }
}