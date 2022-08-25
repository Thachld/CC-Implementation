public with sharing class AccountSpendingReport_Batch implements Database.Batchable<SObject>{
    private Datetime startDt;
    private Datetime endDt;

    public AccountSpendingReport_Batch(Date pfromdate, Date ptodate) {
        this.startDt = Datetime.newInstance(pfromdate.year(), pfromdate.month(), pfromdate.day(), 0,0,0);       
        this.endDt = Datetime.newInstance(ptodate.year(), ptodate.month(), ptodate.day(), 23,59,59);       
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id FROM Account]);
    }

    public void execute(Database.BatchableContext bc, List<Account> scope){
        Set<String> accIds = new Set<String>();
        List<Account_Spending__c> listUpsert = new List<Account_Spending__c>();

        for(Account acc: scope){
            accIds.add(acc.Id);
        }


        //query spending data
        for (AggregateResult arr : [SELECT Accounts__c Account__c,
                                    CALENDAR_YEAR(convertTimezone(syn_date__c)) YEAR,
                                    CALENDAR_QUARTER(convertTimezone(syn_date__c)) QUARTER,
                                    CALENDAR_MONTH(convertTimezone(syn_date__c)) MONTH,
                                    SUM(Total_spending__c) Total_spending__c
                                    FROM QC_Account_data__c
                                    WHERE syn_date__c >= :this.startDt
                                    AND syn_date__c <= : this.endDt
                                    AND Accounts__c IN : accIds
                                    AND Total_spending__c > 0
                                    GROUP BY Accounts__c , CALENDAR_YEAR(convertTimezone(syn_date__c)), CALENDAR_QUARTER(convertTimezone(syn_date__c)), CALENDAR_MONTH(convertTimezone(syn_date__c)) ]){

            String account = (String)arr.get('Account__c');     
            
            if(!String.isBlank(account)){
                Integer year = (Integer)arr.get('YEAR');     
                Integer month = (Integer)arr.get('MONTH');
                Integer quarter = (Integer)arr.get('QUARTER');                
                Decimal spendingAmount = (Decimal)arr.get('Total_spending__c');
                
                String upsertId = account + String.valueOf(year) + String.valueOf(quarter) + String.valueOf(month);

                Account_Spending__c accSpending = new Account_Spending__c();
                accSpending.Account__c = account;
                accSpending.Spending_Amount__c = spendingAmount;
                accSpending.Year__c =  String.valueOf(year);
                accSpending.Month__c =  String.valueOf(month);
                accSpending.Quarter__c =  String.valueOf(quarter);
                accSpending.UpsertId__c = upsertId;

                listUpsert.add(accSpending);
            }
        }

        System.debug('listUpsert' + listUpsert.size());
        if(listUpsert.size() > 0){
            Schema.SObjectField f = Account_Spending__c.Fields.UpsertId__c;
            Database.upsert(listUpsert, f, false);
        }

    }

    public void finish(Database.BatchableContext bc){
        
    }
}