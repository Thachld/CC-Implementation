public with sharing class cc_EnableCouponHttpCalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":{"id":11,"code":"b576953ec6151d6bb390","ownerId":null,"amount":30000,"usedBy":null,"timeUsed":null,"couponCampaignId":123,"expireDate":"2022-01-01","email":null,"poi_id":null,"spendingExpireDate":"2022-01-01","usedTransactionId":null,"timeIssued":"2021-05-18 17:50:21","status":"YES"}}');

        return res;
    }
}