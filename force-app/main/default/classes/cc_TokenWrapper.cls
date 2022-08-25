public class cc_TokenWrapper{
    public string token{get;set;}
    public String time_expire{get;set;}

    public static cc_TokenWrapper parse(String json) {
		return (cc_TokenWrapper) System.JSON.deserialize(json, cc_TokenWrapper.class);
	}
}