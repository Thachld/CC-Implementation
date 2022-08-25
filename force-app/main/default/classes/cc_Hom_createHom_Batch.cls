global class cc_Hom_createHom_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public date minDate {get;set;}
    public date maxDate {get;set;}
    public date previouMonth {get;set;}
    public string userAssign {get;set;}
    public List<HandOver_Minute__c> homListInsert = new List<HandOver_Minute__c>();
    public string inputDate {get;set;}
    public boolean isUpdateToPreviousCoupond {get;set;}
    public Map<id,id> accIdMap {get;set;}
    public cc_Hom_createHom_Batch(string strDate, boolean isUpdateToPreviousCoupondTemp, Map<id,id> accIdMapTemp){
        
        isUpdateToPreviousCoupond = isUpdateToPreviousCoupondTemp;
        accIdMap = accIdMapTemp;
        
        cc_setting__c settting = cc_Util.getCustomSetting();
        userAssign = settting.Hom_assign__c; 
        date dtToday = date.today();
        inputDate = '';
        if( !string.isBlank(strDate)){
            inputDate = strDate;
            string[] M = strDate.split('/');
            dtToday = date.NewInstance(integer.valueOf(M[2]), integer.valueOf(M[1]),integer.valueOf(M[0]));
            previouMonth = dtToday;
        }
        else{
            previouMonth = dttoday.addMonths(-1);
        }
        
        minDate = date.newInstance(previouMonth.year(), previouMonth.month(), 1);
        integer noOfDays = Date.daysInMonth(previouMonth.year(), previouMonth.month());
        maxDate = date.newInstance(previouMonth.year(), previouMonth.month(), noOfDays);
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([select id, name,Contract_Start_Date__c,Contract_End_Date__c,Account__c, Account__r.OwnerId, No_expire_date__c   
                                          from Contract__c where Is_Monthly__c = true
                                          and Active__c = true 
                                          and ((((Contract_Start_Date__c <=: minDate and Contract_End_Date__c >=: minDate)
                                                 or (Contract_Start_Date__c >=: minDate and Contract_Start_Date__c<=: maxDate)
                                                ) and No_expire_date__c != true) or 
                                               (No_expire_date__c =  true and ( Contract_Start_Date__c <=: minDate or Contract_Start_Date__c <=: maxDate))
                                              )]);
    }
    global void execute(Database.BatchableContext bc, List<Contract__c> scope){
        set<string> keySet = new set<string>();
        for(Contract__c item: scope){
            string key = item.id + '_' + previouMonth.month() + '_' + previouMonth.year();
            keySet.add(key);
        }
        List<HandOver_Minute__c> homList = [select id, monthly_key__c from HandOver_Minute__c where monthly_key__c in: keySet];
        Map<string,HandOver_Minute__c> homMap = new Map<string,HandOver_Minute__c>();
        for(HandOver_Minute__c item: homList){
            if(!homMap.containsKey(item.monthly_key__c)){
                homMap.put(item.monthly_key__c, item);
            }
        }
        set<id> contractAccountIdSet = new set<id>();
        for(Contract__c item: scope){
            string key = item.id + '_' + previouMonth.month() + '_' + previouMonth.year();
            HandOver_Minute__c temp = new HandOver_Minute__c();
            if( homMap.containsKey(key))
            {
                temp.id = homMap.get(key).id;
            }
            if(!string.isBlank(item.Account__c) && accIdMap.containsKey(item.Account__c))
                accIdMap.remove(item.Account__c);
            temp.name = 'Hom for '  + item.Name + ' ' +  previouMonth.month() + '_' + previouMonth.year();
            temp.Account__c = item.Account__c;
            temp.Status__c = 'New';
            temp.Assign_to__c = userAssign;
            temp.Start_date__c = mindate;
            temp.End_date__c = maxdate;
            if(item.Contract_Start_Date__c != null && temp.Start_date__c < item.Contract_Start_Date__c)
                temp.Start_date__c = item.Contract_Start_Date__c;
            
            if(item.No_expire_date__c != true && item.Contract_End_Date__c != null && temp.End_date__c > item.Contract_End_Date__c )
                temp.End_date__c = item.Contract_End_Date__c;
            //temp.OwnerId = item.Account__r.ownerId;
            temp.monthly_key__c = key;
            temp.Custom_Contract__c = item.id;
            homListInsert.add(temp);
        }
        
        
        
    }
    global void finish(Database.BatchableContext bc){
        if( accIdMap.size() >0){
            List<Account> accList = [select id, name , ownerId from Account where id in: accIdMap.keySet()];
            set<string> keySet = new set<string>();
            for(Account item: accList){
                string key = item.id + '_' + previouMonth.month() + '_' + previouMonth.year();
                keySet.add(key);
            }
            List<HandOver_Minute__c> homList = [select id, monthly_key__c from HandOver_Minute__c where monthly_key__c in: keySet];
            Map<string,HandOver_Minute__c> homMap = new Map<string,HandOver_Minute__c>();
            for(HandOver_Minute__c item: homList){
                if(!homMap.containsKey(item.monthly_key__c)){
                    homMap.put(item.monthly_key__c, item);
                }
            }
            for(Account item: accList){
                string key = item.id + '_' + previouMonth.month() + '_' + previouMonth.year();
                HandOver_Minute__c temp = new HandOver_Minute__c();
                if( homMap.containsKey(key))
                {
                    temp.id = homMap.get(key).id;
                }
                temp.name = 'Hom for '  + item.Name + ' ' + previouMonth.month() + '_' + previouMonth.year();
                if( temp.name.length() >80){
                    temp.name = temp.name.substring(0, 80);
                }
                temp.Account__c = item.id;
                temp.Status__c = 'New';
                temp.Assign_to__c = userAssign;
                temp.Start_date__c = mindate;
                temp.End_date__c = maxdate;
                //temp.OwnerId = item.ownerId;
                temp.monthly_key__c = key;
                homListInsert.add(temp);
            }
        }
        upsert homListInsert;
        List<Id> homIdList = new List<Id>();
        integer i = 0;
        for(HandOver_Minute__c item: homListInsert){
            homIdList.add(item.id);
            i++;
            if( i == 50){
                cc_Hom_CalculateNetForHom_Batch temp = new cc_Hom_CalculateNetForHom_Batch(homIdList, isUpdateToPreviousCoupond);
        		database.executeBatch(temp,50);
                i = 0;
                homIdList = new List<Id>(); 
            }
        }
        if( homIdList.size() >0)
        {
            cc_Hom_CalculateNetForHom_Batch temp = new cc_Hom_CalculateNetForHom_Batch(homIdList, isUpdateToPreviousCoupond);
        	database.executeBatch(temp,50);
        }
       
        
    }
}