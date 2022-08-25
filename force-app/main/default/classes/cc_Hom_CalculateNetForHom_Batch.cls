global class cc_Hom_CalculateNetForHom_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public datetime minDateTime {get;set;}
    public datetime maxDateTime {get;set;}
    //public string Master_Commitment = 'DC-000001'; //20% current
    //public string Master_NoCommitment = 'DC-000000'; //18% current 
    
    public List<Contract__c> contractList {get;set;}
    public set<id> qcAccountIdSet {get;set;}
    public List<HandOver_Minute__c> homList {get;set;}
    public Map<id,Set<Id>> contractToQcMap {get;set;}
    public Map<id,Set<Id>> accountToQcMap {get;set;}
    public Map<id,list<Discount__c>> contractToRateMap {get;set;}
    public List<Discount__c> normalRateList {get;set;}
    public string userAssign {get;set;}
    public List<id> homInputList {get;set;}
    public boolean isUpdateToPreviousCoupond {get;set;}
    public List<Payment__c> couponPaymentList {get;set;}
    public Map<id,List<QC_Account_Data__c>> qcToQCAccountData {get;set;}
    public cc_Hom_CalculateNetForHom_Batch(List<id> homInputListTemp,boolean isUpdateToPreviousCoupondTemp){
        qcToQCAccountData = new Map<id,List<QC_Account_Data__c>>();
        isUpdateToPreviousCoupond = isUpdateToPreviousCoupondTemp;
        homInputList = homInputListTemp;
        cc_setting__c settting = cc_Util.getCustomSetting();
        userAssign = settting.Hom_assign__c;// '0050o00000Xok43AAB';
        contractToQcMap = new Map<id,Set<id>>();
        accountToQcMap = new Map<id,Set<id>>();
        contractToRateMap = new Map<id,List<Discount__c>>();
        date dtToday = date.today();
        
        minDateTime = dtToday;
        maxDateTime = dtToday;       
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM QC_Account_Data__c LIMIT 1]);
        
    }
    global void execute(Database.BatchableContext bc, List<QC_Account_Data__c> scope){
        
    }
    global void finish(Database.BatchableContext bc){
        
    }
}