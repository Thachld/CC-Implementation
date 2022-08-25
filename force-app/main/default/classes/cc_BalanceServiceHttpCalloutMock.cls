public with sharing class cc_BalanceServiceHttpCalloutMock implements HttpCalloutMock{
    public HttpResponse respond(HttpRequest req){
        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"BALANCES":[{"USER_ID":1122334455,"DATETIME":"2022-01-01T01:01:01","SUMMARY":{"COUPON_MONEY":"989029","REAL_MONEY":"4800000","REFUND_MONEY":"0.0","TOTAL_MONEY":"5789029"},"DETAIL":[{"BALANCE":989029,"ID":"1258d","TIMESTAMP":"Mar 21, 2014, 3:30:03 PM","TYPE":"COUPON"},{"BALANCE":4800000,"ID":"1258e","TIMESTAMP":"May 7, 2014, 5:30:34 PM","TYPE":"INCOME"}]}]}');
        res.setStatusCode(200);

        return res;
    }
}