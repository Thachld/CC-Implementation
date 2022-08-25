public with sharing class JiraUserWrapper {
    public String accountId;
    public String accountType;
    public String emailAddress;
    public String displayName;
    public Boolean active;
    public String locale;

    public static List<JiraUserWrapper> parseListUser(String jsString){
        List<JiraUserWrapper> result = (List<JiraUserWrapper>)JSON.deserialize(jsString, List<JiraUserWrapper>.class);
        return result;
    }

}