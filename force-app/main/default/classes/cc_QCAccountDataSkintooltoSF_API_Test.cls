@isTest
public class cc_QCAccountDataSkintooltoSF_API_Test {
	@isTest
     public static void testQCtoSF(){
          cc_setting__c setting = cc_initData.initCustomeSetting();
         insert setting;
         QC_Account__c qcAccount = cc_initData.initQCAccount();
         qcAccount.name = 'test@gmail.com';
         qcAccount.QC_Account_Id__c = '810';
         insert qcAccount;
          Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
         RestRequest req = new RestRequest(); 
         RestResponse res = new RestResponse(); 
         req.requestURI  = '/services/apexrest/qctosf';
         //req.requestURI = '<a target="_blank" href="/services/apexrest/user" rel="nofollow">/services/apexrest/user</a>';
         req.httpMethod = 'POST';    
         RestContext.request = req;
         RestContext.response= res;
         req.requestBody = Blob.valueof(getJsonCase1(qcAccount.id));
         
         
         string str = cc_QCAccountDataSkintooltoSF_API.doPostAccountFromQCSystem();
         req.requestBody = Blob.valueof('');
         str = cc_QCAccountDataSkintooltoSF_API.doPostAccountFromQCSystem();
         
     }
      public static string getJsonCase1(string qcId){
         return '[{"customer_id":"' + qcId +'","syn_date":1575910800000,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1,"skintool_video_banner_view":1,"skintool_video_banner_click":1,"skintool_video_banner_price":1,"skintool_video_banner_spending":1,"skintool_vast_skin_view":1,"skintool_vast_skin_click":1,"skintool_vast_skin_price":1,"skintool_vast_skin_spending":1}]';
     }

}