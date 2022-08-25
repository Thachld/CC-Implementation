public with sharing class JiraFieldChangeWrapper {
    public String fieldId;
    public String field;
    public String fieldType;
    public String fromValue;
    public String fromString;
    public String toValue;
    public String toString;

    public static JiraFieldChangeWrapper parse(String json){
		return (JiraFieldChangeWrapper) System.JSON.deserialize(json, JiraFieldChangeWrapper.class);    
	}
}