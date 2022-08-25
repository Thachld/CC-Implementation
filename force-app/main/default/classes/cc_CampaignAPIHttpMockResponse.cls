@istest
global class cc_CampaignAPIHttpMockResponse implements HttpCalloutMock {    
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.      
            
        // Create a fake response
        HttpResponse res = new HttpResponse();           
        res.setHeader('Content-Type', 'application/json');      
        //res.setBody('{"success":true,"usage_limit":{ "used": 0.12, "limit": 1},"pagination": { "total": 12345, "limit": 50, "offset": 0},"data": [{"campaignId": 123,"statsTotal": {"clicks": 600, "impressions": 4000, "spendings": 300000 },"statsDetail": [{"date": "2020-12-31", "clicks": 100, "impressions": 1000,"spendings": 100000},{"date": "2020-12-01","clicks": 500, "impressions": 3000, "spendings": 200000}]}]}');      
        res.setBody('{"total":374,"items":[{"details":{"campaignId":12345},"stats":{"spending":3660724.32,"shows":252611,"clicks":800},"segments":{"items":[{"details":{"day":"10.01.2021"},"stats":{"spending":1001827.4301786107,"ctr":0.6747388852943895,"cpc":2744.7326854208513}}]}}],"stats":{"spending":71768079.89276312,"ctr":0.33122300581120906,"cpc":2128.1641577784635},"segments":{"items":[{"details":{"day":"10.01.2021"},"stats":{"spending":18894124.55190073,"ctr":0.31465437987388734,"cpc":1298.9223533549243}}]}}');
        
        res.setStatusCode(200);

            
        return res;
    }
    
}