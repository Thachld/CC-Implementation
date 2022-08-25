global class UpdateCaseFeedHttpCalloutMock implements HttpCalloutMock{
    private String commentId {get;set;}

    public UpdateCaseFeedHttpCalloutMock(String commId){
        this.commentId = commId;
    }

    global HttpResponse respond(HttpRequest req){  

        HttpResponse res = new HttpResponse();        
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"id":"' + this.commentId + '","author":{"accountId":"5d42a1ad5e485d0dab01f236","emailAddress":"kiennpb@coccoc.com"},"body":{"content":[{"type":"paragraph","content":[{"type":"text","text":"Hi team, "}]},{"type":"paragraph","content":[{"type":"text","text":"We dont know which keywords have knowledge graph when we planned for client but budget & keywords list already confirmed by client. And search banner dont show with shopping graph too. So pls help me to find solution for these situations."}]},{"type":"paragraph","content":[{"type":"text","text":"Moreover, almost keywords with knowledge graph have quite large volume search, if we cant show them together with ads, we cant spend more for this format."}]},{"type":"paragraph","content":[{"type":"text","text":"Thanks!"}]}],"type":"doc","version":1},"created":"2021-06-18T15:42:43.775+0700","updated":"2021-06-18T16:20:31.249+0700","jsdPublic":true}');
        res.setStatusCode(200);

        return res;
    }
}