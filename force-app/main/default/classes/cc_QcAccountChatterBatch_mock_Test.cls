global class cc_QcAccountChatterBatch_mock_Test implements HttpCalloutMock{
	HttpResponse response;
    global cc_QcAccountChatterBatch_mock_Test() {
    	
    }
     global HTTPResponse respond(HTTPRequest req) {
        string body =  '{ "id" : "1"}'; 
		HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(body);
        return res;
    }
}