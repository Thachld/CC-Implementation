global with sharing class ActivateCouponHttpCalloutMock implements HttpCalloutMock{

    global HttpResponse respond(HttpRequest req) {
        //System.assertEquals('', req.getEndpoint());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":{"id":32393,"code":"b1d4cefcaa735fb0f4f2","ownerId":null,"amount":60000,"usedBy":1312,"timeUsed":"2021-08-12 23:28:34","couponCampaignId":null,"expireDate":"2021-08-12","email":"user_test@test.qc.coccoc.com","poi_id":null,"spendingExpireDate":"2021-08-12","usedTransactionId":49626,"conditionContent":"content","intervalSpendingDays":1,"timeIssued":"2021-07-13 01:12:29","status":"YES","usedTransactionStatus":"CONFIRMED"}}');
        res.setStatusCode(200);

        return res;
    }
}