global class SyncJiraToCaseHttpCalloutMock implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest req){
       
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"10001","key":"FS-01","fields":{"issuetype":{"name":"Task"},"project":{"key":"FS","name":"Frontline Support"},"priority":{"name":"Highest"},"labels":["campaign_transfer","custom_category","data_export"],"assignee":{"accountId":"123456789"},"updated":"2022-04-19T17:06:59.007+0700","status":{"name":"To Do"},"customfield_10049":{"value":"Blocker"},"summary":"SF Issue Test4","duedate":"2021-03-20"}}');
        res.setStatusCode(200);

        return res;
    }
}