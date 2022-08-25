public  class cc_DMPLeadWrapper {  
	public metrics_30d metrics_30d;
	public String domain;	//zshop.vn
	public String phone;	//0979186277
	public String[] industry;
	public String[] topics;
	public String[] user_preferred_categories;
	public String event_date;	//2021-08-07
	public String id;	//domain:zshop.vn
	public String sfid;

	public class metrics_30d {
		public google_serp google_serp;
	}

	public class google_serp {
		public Integer ads_unique_user;	//1484
		public Integer ads_median_pos;	//2
		public Integer ads_impression;	//3142
		public Integer ads_click;	//172
		public Integer ads_unique_user_click;	//148
		public Integer serp_unique_user;	//277
		public Integer serp_median_pos;	//3
		public Integer serp_impression;	//453
		public Integer serp_click;	//1550
		public Integer serp_unique_user_click;	//1074
	}
	
	public static List<cc_DMPLeadWrapper> parse(String json){
		return (List<cc_DMPLeadWrapper>) System.JSON.deserialize(json, List<cc_DMPLeadWrapper>.class);
	}
}