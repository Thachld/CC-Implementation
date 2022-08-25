/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 07-12-2022
 * @last modified by  : @Thach Le
**/

/********************************************************************************************************
* @author        CocCoc - THACHLD
* @date          2022 May 30
* @description   Rest service for update Case from Jira webhook
* @param   jiraId - Jira Ticket Id.
*********************************************************************************************************/
@RestResource(urlMapping='/jiratocaseaddfeed/*')
global class CreateCaseFeedFromJiraRest {
    @Httppost
    global static String doAddCaseFeed(){
        PaymentToQCWrapper.Responds rp = new PaymentToQCWrapper.Responds();
        RestRequest restReq = RestContext.request;   
        Map<String,JiraCommentAPIWrapper> mapCaseFeed = new Map<String,JiraCommentAPIWrapper>();

        try {
            String jiraId = restReq.params.get('jiraId');       
            System.debug('jiraId=>' + jiraId);
            Case cs = [SELECT Id, JiraId__c FROM Case WHERE JiraId__c = :jiraId ];
            if(cs != null){            
                String rqbody = restReq.requestBody.tostring();
                System.debug('rqbody=>' + rqbody);

                JiraCommentAPIWrapper comment = JiraCommentAPIWrapper.parseCommentAPI(rqbody);
                System.debug('comment=>' + comment);
                if(comment != null){
                    comment.jiraId = jiraId;
                    Boolean isExists = checkExists(cs.Id, comment.commentId);
                    if(!isExists){
                        mapCaseFeed.put(cs.Id, comment);
                    }                    
                }

                if(mapCaseFeed.size() > 0){
                    CaseFeedSyncFromJira.syncCreateCaseFeed(mapCaseFeed);                   
                }

                rp.status = 'success';
                rp.message = '';
            }else {
                rp.status = 'fail';
                rp.message = 'Case not found';                             
            }

        } catch(Exception ex){
            rp.status = 'fail';
            rp.message = ex.getMessage();        
        }

        if (rp.status == 'fail'){
            cc_Util.writeLog('jiratocaseaddfeed',rp.message, RestContext.request.requestBody.tostring());
        }        

        System.debug('rp=>' + rp);
        String str = system.JSON.serialize(rp);
        return str;
    }

    public static Boolean checkExists(Id caseId, String commentId){
        Boolean result = false;

        List<JiraCommentMapping__c> listMapping = [SELECT Id FROM JiraCommentMapping__c WHERE CaseId__c = :caseId AND JiraCommentId__c = : commentId];
        if(listMapping != null && listMapping.size() > 0){
            result = true;
        }

        return result;
    }
}