public class cc_ContractLinkHandler {     
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public static void bulkBefore() {  
        //isInsert
        Set<String> accIds = new Set<String>();
        Map<String, Set<String>> mapAccQC = new Map<String, Set<String>>();
        Set<String> qcAccIds= new Set<String>();
        for(Contract_link__c link : (List<Contract_link__c>)Trigger.new){
            accIds.add(link.Account__c);

            if(!String.isBlank(link.Agency_for_signing__c) ){
                accIds.add(link.Agency_for_signing__c);
            }
        }

        for(Relationship__c rl: [SELECT Account__c, QC_Account__c FROM Relationship__c WHERE Account__c IN : accIds]){
            if(mapAccQC.containsKey(rl.Account__c)){
                mapAccQC.get(rl.Account__c).add(rl.QC_Account__c);
            }else {
                mapAccQC.put(rl.Account__c, new Set<String>{rl.QC_Account__c});
            }
        }
        

        if(Trigger.isInsert){           
            for(Contract_link__c link :(List<Contract_link__c>)Trigger.new){
                if(!String.isBlank(link.Account__c)){
                    Set<String> qcIds = mapAccQC.get(link.Account__c);
                    // System.debug('qcIds =>' + qcIds);
                    // System.debug('mapAccQC =>' + mapAccQC);
                    // System.debug('link.Account__c =>' + link.Account__c);

                    if(qcIds != null){
                        if(!qcIds.contains(link.QC_Account__c)){
                            link.addError('QC Account ' + link.QC_Account_Name__c + ' has account owner not same as Account on Contract');
                        }
                    }else {
                        link.addError('QC Account ' + link.QC_Account_Name__c + ' has account owner not same as Account on Contract');
                    }

                }
            }
        }
    }    
}