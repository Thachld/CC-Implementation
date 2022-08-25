global with sharing class cc_CreateCouponHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":[{"id":11,"code":"a9fd2369e41bde43fc56","ownerId":null,"amount":10,"usedBy":null,"timeUsed":null,"couponCampaignId":123,"expireDate":"2022-01-01","email":"testclient@qc.coccoc.com","poi_id":null,"spendingExpireDate":"2022-01-01","usedTransactionId":null}]}');

        return res;
    }
}