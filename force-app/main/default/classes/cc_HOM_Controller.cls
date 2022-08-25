public with sharing class cc_HOM_Controller {
    
    public class HOMwraper {
        
        @AuraEnabled
        public String ContractId {get;set;}

        @AuraEnabled
        public String Contract {get;set;}

        @AuraEnabled
        public String AccountId {get;set;}

        @AuraEnabled
        public String AccountOwner {get;set;}

        @AuraEnabled
        public String HOMId {get;set;}

        @AuraEnabled
        public String HOMName {get;set;}

        @AuraEnabled
        public String BaseURL {get;set;}

        @AuraEnabled
        public Decimal PaidAmount {get;set;}

        @AuraEnabled
        public Decimal DebitAmount {get;set;}

        @AuraEnabled
        public Boolean Selected {get;set;}
      
    }


    @AuraEnabled
    public static List<HOMwraper> getHOMbyQcAccountDB(String paymentId){
        try {
            List<HOMwraper> result = new List<HOMwraper>();
            Payment__c currpy = [SELECT Id, QC_Account__c, HandOver_Minutes__c FROM Payment__c WHERE Id = :paymentId];
            QC_Account__c curracc = [SELECT Id, AccountOwner__c, AccountOwner__r.Agency__c FROM QC_Account__c WHERE Id = :currpy.QC_Account__c LIMIT 1];
            Set<String> accIds = new Set<String>();
            
            if(curracc !=null){
                if(!String.isBlank(curracc.AccountOwner__c)){
                    accIds.add(curracc.AccountOwner__c);

                    if(!String.isBlank(curracc.AccountOwner__r.Agency__c)){
                        accIds.add(curracc.AccountOwner__r.Agency__c);
                    }
                }
            }
            
            if(accIds.size() > 0){                

                for(HandOver_Minute__c hom : [SELECT Id, Name, Account__r.Name, Custom_Contract__r.Name, 
                                                Account__c, Custom_Contract__c, Total_Payment_Amount__c,
                                                Debit_Amount__c FROM HandOver_Minute__c 
                                                WHERE Account__c IN : accIds
                                                    AND Status__c IN ('Confirm', 'Sent', 'Received')
                                                ORDER BY Start_date__c DESC                                                
                                                ]){
                    HOMwraper homwp = new HOMwraper();
                    homwp.AccountId = hom.Account__c;
                    homwp.AccountOwner = hom.Account__r.Name;
                    homwp.ContractId = hom.Custom_Contract__c;
                    homwp.Contract = hom.Custom_Contract__r.Name;
                    homwp.HOMId = hom.Id;
                    homwp.HOMName = hom.Name;
                    homwp.PaidAmount = hom.Total_Payment_Amount__c;   
                    homwp.DebitAmount = hom.Debit_Amount__c;                    
                    homwp.BaseURL = URL.getSalesforceBaseUrl().toExternalForm();  
                    
                    if(hom.Id == currpy.HandOver_Minutes__c){
                        homwp.Selected = true;
                    }else {
                        homwp.Selected = false;
                    }
                    
                    result.add(homwp);
                }
            }
            
            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static void savePaymentDB(String recordId, String homId){
        try {
            Payment__c currpy = [SELECT Id, HandOver_Minutes__c  FROM Payment__c WHERE Id = :recordId];
            if(currpy != null){
                currpy.HandOver_Minutes__c = homId;

                update currpy;
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}