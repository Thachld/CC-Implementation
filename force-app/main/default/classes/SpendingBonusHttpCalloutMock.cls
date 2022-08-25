global with sharing class SpendingBonusHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":{"total":2,"items":[{"id":1298260,"code":"0b4873b6e7d16d7c01c8","ownerId":null,"amount":10000,"usedBy":null,"timeUsed":null,"couponCampaignId":null,"expireDate":"2022-01-18","email":"testspendingbonus1@coccoc.com.test","spendingExpireDate":null,"usedTransactionId":null,"transactionTypeMappingId":29,"conditionContent":null,"intervalSpendingDays":365},{"id":1298263,"code":"1af7032f07ee74706a13","ownerId":null,"amount":10000,"usedBy":null,"timeUsed":null,"couponCampaignId":null,"expireDate":"2022-01-18","email":"testspendingbonus2@coccoc.com.test","spendingExpireDate":null,"usedTransactionId":null,"transactionTypeMappingId":29,"conditionContent":null,"intervalSpendingDays":365}]},"failed":{"total":2,"items":[{"email":"testspendingbonus3@coccoc.com.test","errorMessage":"Amount is too small"},{"email":"testspendingbonus4@coccoc.com.test","errorMessage":"amount is not integer value"}]}}');

        
        return res;
    }
}