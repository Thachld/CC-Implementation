global with sharing class cc_GetCouponHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":{"id":11,"code":"b576953ec6151d6bb390","ownerId":null,"amount":30000,"usedBy":null,"timeUsed":null,"couponCampaignId":123,"expireDate":"2022-01-01","email":"testclient@qc.coccoc.com","poi_id":null,"spendingExpireDate":"2022-01-01","usedTransactionId":null,"timeIssued":"2021-05-17 17:47:10","status":"YES"}}');

        return res;
    }
}