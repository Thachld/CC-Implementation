public class AccountToQCWrapper {
	
    public String Name {get;set;}
	public String Customer_email{get;set;}
	public String Phone_Number{get;set;}
	public String Customer_id{get;set;}
	public long Register_time{get;set;}
	public string Sale_email  {get;set;}
    public string Support_email {get;set;}
    public string profile_id {get;set;}
    public string Website {get;set;}
    public string agency_email {get;set;}
	public string mcc_email {get;set;}
    
	public static AccountToQCWrapper parse(String json) {
		return (AccountToQCWrapper) System.JSON.deserialize(json, AccountToQCWrapper.class);
	}
	public class Responds{
        public string status{get;set;}
        public string message{get;set;}
    }
}