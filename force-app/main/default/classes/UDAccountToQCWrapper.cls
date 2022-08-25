public class UDAccountToQCWrapper {
	public String Customer_id {get;set;}
	public String Customer_industry{get;set;}
	public String Customer_sale_email{get;set;}
	public String Customer_support_email{get;set;}
    public String Customer_mcc_email{get;set;}
    public string Customer_agency_email {get;set;}
    public static UDAccountToQCWrapper parse(String json) {
		return (UDAccountToQCWrapper) System.JSON.deserialize(json, UDAccountToQCWrapper.class);
	}
	public class Responds{
        public string status{get;set;}
        public string message{get;set;}
    }
}