global class SyncMobileSpendingHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"total":3,"items":[{"details":{"campaign_type":29,"campaign_name":"CPD campaign test","campaign_id":57162,"date":"2022-03-15","client_id":75},"stats":{"spending":30000,"shows":15,"clicks":1,"ctr":6.666666666666667}},{"details":{"campaign_type":29,"campaign_name":"CPD campaign test","campaign_id":57162,"date":"2022-03-16","client_id":75},"stats":{"spending":30000,"shows":9,"clicks":0,"ctr":0}},{"details":{"campaign_type":29,"campaign_name":"CPD campaign test","campaign_id":57162,"date":"2022-03-15","client_id":76},"stats":{"spending":30000,"shows":26,"clicks":0,"ctr":0}}]}');

        
        return res;
    }
}