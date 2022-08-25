public class cc_ChatterBatchWrapper {
    public List<id> idList{get;set;}
    public string message{get;set;}
    public id recordId {get;set;}
    public string title {get;set;}
    public boolean isEmail {get;set;}
    public string body {get;set;}
    public string toEmail {get;set;}
    public string ccEmail {get;set;}
    public string key {get;set;}
    public cc_ChatterBatchWrapper(){
        idList = new List<id>();
        isEmail = false;
    }
}