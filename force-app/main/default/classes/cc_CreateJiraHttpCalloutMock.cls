global class cc_CreateJiraHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
        System.assertEquals('https://coccoc.atlassian.net/rest/api/3/issue', req.getEndpoint());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "id": "10000","key": "FS-24","self": "https://coccoc.atlassian.net/rest/api/3/issue/10000"}');
        res.setStatusCode(201);

        return res;
    }
}