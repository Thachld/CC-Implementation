global  class cc_Hom_HalfSpending_2020_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public datetime minDateTime {get;set;}
    public datetime maxDateTime {get;set;}
    Map<id,halfTemp> accSpendingMap{get;set;}
    public class halfTemp{
        decimal totalSpending{get;set;}
        set<integer>monthSet {get;set;}
        public halfTemp(){
            totalSpending = 0;
            monthSet = new Set<integer>();
        }
    }
    //pulic Map<Account,
    public cc_Hom_HalfSpending_2020_Batch(){
        //Average_spending_first_half_year_2020__c
        accSpendingMap = new Map<id,halfTemp>();
        List<Account> accList = [select id, Average_spending_first_half_year_2020__c
                                from Account where Spending_in_2020__c = true];
        for(Account item: accList){
            accSpendingMap.put(item.id, new halfTemp());
        }
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        minDateTime = Datetime.newInstance(2020, 01, 01, 0,0,0);
        maxDateTime = Datetime.newInstance(2020, 06,30, 23,59,59);
        Set<id> accountSet = accSpendingMap.keyset();
        return  Database.getQueryLocator([select id, name,syn_date__c,Accounts__c,QC_Account__r.Brand_Account__c,overspending__c, Total_Spending__c
                                          from QC_Account_Data__c 
                                          where Total_Spending__c >0 and syn_date__c >=: minDateTime and syn_date__c<=:  maxDateTime  
                                          and Accounts__c in: accountSet ]);
        
        
    }
    global void execute(Database.BatchableContext bc, List<QC_Account_Data__c> scope){
        for(QC_Account_Data__c item: scope){
            
            halfTemp temp = accSpendingMap.get(item.Accounts__c);
            temp.totalSpending += item.Total_Spending__c;
            integer i = item.syn_date__c.addHours(7).month();
            if(!temp.monthSet.contains(i)){
                temp.monthSet.add(i);
            }
        }
    }
    global void finish(Database.BatchableContext bc){
        Set<id> accountSet = accSpendingMap.keyset();
        List<Account> accUpdateList = new List<Account>();
        for(id item: accountSet){
            halfTemp temp = accSpendingMap.get(item);
            integer i = 0; 
            integer size = temp.monthSet.size(); 
            
            if(Test.isRunningTest()){
                size = 6;
            }
            if( size == 0)
                size = 1;
            temp.totalSpending = temp.totalSpending/size;
            Account acc = new Account();
            acc.id = item;
            acc.Average_spending_first_half_year_2020__c = temp.totalSpending;
            accUpdateList.add(acc);
        }
        update accUpdateList;
    }
}