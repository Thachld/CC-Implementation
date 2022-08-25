public class cc_HttpCallout {
    
    public static HttpResponse makeRequest(HttpRequest req) {
        HttpResponse res;
        try {
            res = new Http().send(req);
        } catch(Exception ex) {
            //or you could just throw ...
            res = new HttpResponse();
            res.setStatusCode(503);
            res.setBody(ex.getMessage());
        }
        return res;
    }

    public static HttpRequest setupHttpRequest(cc_Callout callout) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(callout.Endpoint);
        req.setMethod(callout.RestMethod);
        req.setTimeout(callout.Timeout);
        req.setHeader('Content-Type', 'application/json');
        if(callout.RestMethod != 'GET'){
            req.setBody(callout.BodyString);
        }       
        if(String.isNotBlank(callout.Token)) {
            req.setHeader('Credential', callout.Token);
        }
        return req;
    }

    public static HttpRequest setupHttpRequestToQCByOrgDefault(cc_Callout callout) {
        HttpRequest req = coccoc.ManageQCCredential.setupHttpRequestByOrgDefalut(callout.Endpoint, callout.RestMethod, callout.Timeout, callout.BodyString, 'application/json');
        return req;
    }

    public static HttpRequest setupHttpRequestToQCByProfileOrUser(cc_Callout callout, String userIdOrProfileId) {
        HttpRequest req = coccoc.ManageQCCredential.setupHttpRequestByProfileOrUser(callout.Endpoint, callout.RestMethod, callout.Timeout, callout.BodyString, 'application/json', userIdOrProfileId);
        return req;
    }
}