public with sharing class PaymentChatterHelper {
    public static void postChatter(Map<string,qc_Account__c> qcAccountValIdInvalIdMap, List<cc_ChatterBatchWrapper> chatterPosts, cc_setting__c setting){
        List<cc_ChatterBatchWrapper> sendEmailList = new List<cc_ChatterBatchWrapper>();        

        if(qcAccountValidInvalidMap.size() > 0){
            
            Set<string> qcIdInvalidList = qcAccountValidInvalidMap.keySet();
            List<string> generalIdList = setting.Fixing_Payment_and_Spending__c.split(',');
            Set<string> generalIdSet = new Set<string>();
            string generalIdZero = '';
            for(string item: generalIdList){
                generalIdSet.add(item);
                if( generalIdZero == '')
                    generalIdZero = item;
            }
                
            string hotlineTeam = [select id from Group where Type =:'Queue' and name =: 'Hotline'].Id;
            for(String item: qcIdInvalidList){
                qc_Account__c qcInvalid = qcAccountValidInvalidMap.get(item);
                
                Id notifyToId;
            
                string error ='QC Account:' + qcInvalid.Name + '\n\t';
            
                if( string.isBlank(qcInvalid.OwnerId)){
                    notifyToId = generalIdZero;
                }
                if( !string.isBlank(qcInvalid.OwnerId) && generalIdSet.contains(qcInvalid.OwnerId)){
                    //hotline
                    notifyToId = hotlineTeam;
                }
                else{
                    //assign for owner
                    notifyToId = qcInvalid.OwnerId;
                }
                if(string.isBlank(qcInvalid.sales__c)){
                    error += 'Sale can not be null' + '\n\t';
                }
                if(string.isBlank(qcInvalid.Industry__c) && !string.isBlank(qcInvalid.Agency__c) && qcInvalid.Agency__c != 'Global Agency' ){
                        error += 'Industry can not be null' + '\n\t';
                }
                if(string.isBlank(qcInvalid.Agency__c) || qcInvalid.Agency__c == 'Other'){
                    error += 'Qc Account has not linked to Account Owner';
                }
                cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
                
                post.idList.add(notifyToId);
                post.recordId = qcInvalid.id;
                post.message =  error;
                if( notifyToId == hotlineTeam ){

                    post.isEmail = true;
                    post.title = 'Fix invalid qc account';
                    post.body = 'Dear Hotline Team <br/>';
                    post.toEmail = 'support_qc@coccoc.vn';
                    post.body += error.replace('\n\t', '<br/>');

                    sendEmailList.add(post);
                }else{
                    chatterPosts.add(post);
                }                
            }

        }


        System.debug('chatterPosts.size() =>' + chatterPosts.size());
        if(chatterPosts.size() > 0){
            List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
            for(cc_ChatterBatchWrapper item: chatterPosts){                            
                ConnectApi.FeedItemInput feedItemInput = cc_Util.genChatterwithMetion(item.idList[0], item.recordId, item.message);
                ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
                    
                batchInputs.add(batchInput);
            }

            system.debug('batchInputs.size=>' + batchInputs.size());
            if(batchInputs.size() > 0){
                ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchinputs);
            }        
        }

            //Send email
        if(sendEmailList.size() > 0){
            cc_QcAccountChatterBatch batch = new cc_QcAccountChatterBatch(sendEmailList);
            database.executeBatch(batch);
        }


    }
}