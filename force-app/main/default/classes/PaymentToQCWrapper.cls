public class PaymentToQCWrapper {
	public String Customer_email{get;set;}
	public String Customer_id{get;set;}
	public String Transaction_id{get;set;}
    public string Salesforce_id {get;set;}
	public long Transaction_amount{get;set;}
    public String Payment_method{get;set;}
	public String Transaction_status{get;set;}
	public String Transaction_type{get;set;}
	public long Timestamp{get;set;}
    public string Note {get;set;}
    public string Time_collect_money {get;set;}
    public long Date_collect_money {get;set;}
    public string Address {get;set;}
    public string coupon_id {get;set;}
    public string coupon_campaign_id {get;set;}
    
    
    public static PaymentToQCWrapper parse(String json) {
		return (PaymentToQCWrapper) System.JSON.deserialize(json, PaymentToQCWrapper.class);
	}
	public class Responds{
        public string status{get;set;}
        public string message{get;set;}
    }
}