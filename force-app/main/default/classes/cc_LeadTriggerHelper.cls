public with sharing class cc_LeadTriggerHelper {    

    public class CombineWrapper{
        public String accountId;
        public String qc_account_Id;
    }

    public static void attemptCreateRelationShip(String params){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnCreateRelationship(params);
        }else {
            attemptSycnCreateRelationship(params);
        }    
    }   

    @future
    public static void attemptAsycnCreateRelationship(String params){
        attemptSycnCreateRelationship(params);
    }


    public static void attemptSycnCreateRelationship(String params){
        List<CombineWrapper> combines = (List<CombineWrapper>)JSON.deserialize(params, List<CombineWrapper>.class);
        Map<String, CombineWrapper> combineIds = new Map<String, CombineWrapper> ();
        List<Relationship__c> upsertList = new List<Relationship__c>();


        if(combines.size() > 0){

            for(CombineWrapper combine : combines){
                if(!String.isBlank(combine.accountId) && !String.isBlank(combine.qc_account_Id)){

                    Relationship__c relation = new Relationship__c();
                    relation.ID_combination__c =  combine.accountId + '' + combine.qc_account_Id;
                    relation.Account__c = combine.accountId;
                    relation.QC_Account__c = combine.qc_account_Id;
                    relation.Relationship_Type__c = 'Own';

                    upsertList.add(relation);
                }
                
            }
            
        }

        if(upsertList.size() > 0){
            Schema.SObjectField field = Relationship__c.field.ID_combination__c;
            Database.upsert(upsertList, field, false);
        }

    }

}