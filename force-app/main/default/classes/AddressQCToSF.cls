public class AddressQCToSF {  
	public String customer_id {get;set;}
	public String customer_type{get;set;}
	public String name{get;set;}
	public String phone{get;set;}
    
    public String position {get;set;}
	public String representative{get;set;}
	public String company_type{get;set;}
	public String company_name{get;set;}
    public String official_address{get;set;}
	public String shipping_address{get;set;}
    
    public static AddressQCToSF parse(String json) {
		return (AddressQCToSF) System.JSON.deserialize(json, AddressQCToSF.class);
	}
	public class Responds{
        public string status{get;set;}
        public string message{get;set;}
    }
}