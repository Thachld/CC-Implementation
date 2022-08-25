public with sharing class BalanceServiceHttpCalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest req){
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"BALANCES":[{"USER_ID":1122334455,"DATETIME":"2022-01-01T01:01:01","SUMMARY":{"COUPON_MONEY":4000000,"REAL_MONEY":60000000,"REFUND_MONEY":10000,"TOTAL_MONEY":63990000},"DETAIL":[{"TYPE":"COUPON","INTERNAL_TYPE":"PROMOTION","BALANCE":4000000,"ID":"1258d","TIMESTAMP":"Sep 20, 2021, 11:04:00 AM"},{"TYPE":"INCOME","INTERNAL_TYPE":"PAID_AMOUNT","BALANCE":60000000,"ID":"1258e","TIMESTAMP":"Sep 20, 2021, 11:04:00 AM"},{"TYPE":"COUPON","INTERNAL_TYPE":"REFUND","BALANCE":10000,"ID":"1258f","TIMESTAMP":"Oct 6, 2021, 9:00:00 AM"}]}]}');
        res.setStatusCode(200);

        return res;
    }
}