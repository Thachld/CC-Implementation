global with sharing class SpendingBonusFailedHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(403);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":false,"error":{"code":403,"message":"Unknown token"}}');

        
        return res;
    }
}