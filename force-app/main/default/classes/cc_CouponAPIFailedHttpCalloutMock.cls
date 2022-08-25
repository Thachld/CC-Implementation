global with sharing class cc_CouponAPIFailedHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":false,"error":{"code":422,"message":"Test Failed Message","invalid_fields":[{"field":"name","code":160705,"message":"New campaign Coupon campaign sf 03 already exist"}]}}');

        return res;
    }
}