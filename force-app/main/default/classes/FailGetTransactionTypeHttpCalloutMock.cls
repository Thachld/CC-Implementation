global class FailGetTransactionTypeHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(404);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"statusCode": 404, "message": "Resource not found"}');

        
        return res;
    }
}