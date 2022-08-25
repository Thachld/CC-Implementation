public class cc_Callout {

    private static final Integer DEFAULT_TIMEOUT = 10000;

    public cc_Callout(String jsonString, String endpoint, String method, Integer millisecondTimeout, Type callbackType) {
        this.BodyString = jsonString;
        //Type.forName throws for nulls, alas
        this.CallbackName = callbackType == null ? '' : callbackType.getName();
        this.Endpoint = endpoint;
        this.RestMethod = method;
        this.Timeout = millisecondTimeout;
    }

    public cc_Callout(String jsonString, String endpoint, String method, Type callbackType) {
        //10 seconds is the default timeout
        this(jsonString, endpoint, method, DEFAULT_TIMEOUT, callbackType);
    }

    public cc_Callout (String jsonString, String endpoint, String method) {
        this(jsonString, endpoint, method, null);
    }

    //sometimes an api key is supplied as part of the URL ...
    //because it's not always necessary, we make it a public member of the class
    public String Token { get; set; }

    public String BodyString { get; private set; }
    public String CallbackName { get; private set; }
    public String Endpoint { get; private set; }
    public String RestMethod { get; private set; }
    public Integer Timeout { get; private set; }
    public enum RestMethod { GET, PATCH, POST, PUT }

}