global with sharing class cc_SyncJiraUserHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req) {

        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"self":"https://coccoc.atlassian.net/rest/api/3/user?accountId=5cd00a144401890dcab36189","accountId":"5cd00a144401890dcab36189","accountType":"atlassian","emailAddress":"thuy.nguyen@coccoc.com","displayName":"Thủy Nguyễn Thị Thu","active":false,"locale":"en_US"},{"self":"https://coccoc.atlassian.net/rest/api/3/user?accountId=5f277ba9cdb7b4001be85f56","accountId":"5f277ba9cdb7b4001be85f50","accountType":"atlassian","emailAddress":"hoangddtest@coccoc.com","displayName":"Hoang Do Duc","active":true,"locale":"en_US"}]');

        return res;
    }
}