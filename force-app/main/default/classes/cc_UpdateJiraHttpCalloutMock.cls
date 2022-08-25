global class cc_UpdateJiraHttpCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){

        System.assertEquals('https://coccoc.atlassian.net/rest/api/3/issue/10000', req.getEndpoint());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{}');
        res.setStatusCode(204);

        return res;
    }
}