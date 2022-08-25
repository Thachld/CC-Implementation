global class cc_CreateFeedItemHttpCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest req){
        System.assertEquals('https://coccoc.atlassian.net/rest/api/3/issue/10000/comment', req.getEndpoint());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "id": "100001"}');
        res.setStatusCode(201);

        return res;
    }
}