global with sharing class cc_CampaignHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        //System.assertEquals('', req.getEndpoint());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":{"id":123,"name":"Campaign Test","multiple_usage":"YES"}}');
        res.setStatusCode(200);

        return res;
    }
}