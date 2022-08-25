global class GetTransactionTypeHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"success":true,"data":{"total":2,"items":[{"id":1,"internal_type":"PAID_AMOUNT","priority":0,"label":"PAID_AMOUNT","comment":"The real money by clients","is_enabled":"YES","allow_coupon":"YES","created_time":"2021-11-01 00:00:00","updated_time":"2021-11-01 00:00:00"},{"id":2,"internal_type":"ADVANCE","priority":0,"label":"ADVANCE","comment":"The money by CocCoc. Then based on spending, the clients may enjoy discounts (must be discounts or chiết khấu in terms of wording) - now manually calculated","is_enabled":"YES","allow_coupon":"YES","created_time":"2021-11-01 00:00:00","updated_time":"2021-11-01 00:00:00"}]}}');

        
        return res;
    }
}