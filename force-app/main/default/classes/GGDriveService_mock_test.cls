global class GGDriveService_mock_test implements HttpCalloutMock{
    HttpResponse response;
    global GGDriveService_mock_test() {
    	
    }
     global HTTPResponse respond(HTTPRequest req) {
        string body =  '{ "id" : "1"}'; 
		 HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody(body);
         system.debug('tndebug:1');
        return res;
    }
}