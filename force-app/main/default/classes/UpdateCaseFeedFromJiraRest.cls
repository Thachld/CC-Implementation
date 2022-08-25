/********************************************************************************************************
* @author        CocCoc - THACHLD
* @date          2022 May 30
* @description   Rest service for update Case's feed from Jira webhook
* @param   jiraId - Jira Ticket Id.
*********************************************************************************************************/
@RestResource(urlMapping='/jiratocaseeditfeed/*')
global class UpdateCaseFeedFromJiraRest {
    @Httpput
    global static String doUpdateCaseFeed(){
        PaymentToQCWrapper.Responds rp = new PaymentToQCWrapper.Responds();
        RestRequest restReq = RestContext.request;   
        Map<String,JiraCommentAPIWrapper> mapCaseFeed = new Map<String,JiraCommentAPIWrapper>();       
        try {
            String jiraId = restReq.params.get('jiraId');       
            System.debug('jiraId=>' + jiraId);
            Case cs = [SELECT Id, JiraId__c FROM Case WHERE JiraId__c = :jiraId LIMIT 1];
            System.debug('cs=>' + cs);
            if(cs != null){            
                String rqbody = restReq.requestBody.tostring();
                System.debug('rqbody=>' + rqbody);

                JiraCommentAPIWrapper comment = JiraCommentAPIWrapper.parseCommentAPI(rqbody);
                System.debug('comment=>' + comment);
                if(comment != null){
                    comment.jiraId = jiraId;
                    mapCaseFeed.put(cs.Id, comment);

                }

                if(mapCaseFeed.size() > 0){
                    CaseFeedSyncFromJira.syncUpdateCaseFeed(mapCaseFeed);                    
                }

                rp.status = 'success';
                rp.message = '';
            }else {
                rp.status = 'fail';
                rp.message = 'Case not found';                             
            }

        }catch(Exception ex){
            rp.status = 'fail';
            rp.message = ex.getMessage();        
        }

        if (rp.status == 'fail'){
            cc_Util.writeLog('jiratocaseeditfeed',rp.message, RestContext.request.requestBody.tostring());
        }        

        System.debug('rp=>' + rp);
        String str = system.JSON.serialize(rp);
        return str;
    }

}