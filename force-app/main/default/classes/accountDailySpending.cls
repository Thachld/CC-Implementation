global class accountDailySpending implements Schedulable {
	global void execute(SchedulableContext sc){
        calculate();
    }
    public accountDailySpending(){
        calculate();
    }
    public void calculate(){    
        //check QC account datas have null Account and update it to prevent differences
        List<QC_account_data__c> updateqcdatas = [SELECT id,Accounts__c,QC_account__r.AccountOwner__c from QC_account_data__c where Accounts__c = null and QC_account__r.AccountOwner__c <> null and syn_date__c >= last_n_days:2];
        for (QC_account_data__c item : updateqcdatas) {
            item.Accounts__c = item.QC_account__r.AccountOwner__c;
        }
        update updateqcdatas;
        //1. Update yesterday data
        //a.define new lists of Accounts to update yesterday
        List<Account> accts1 = new list<Account>();
        //summary data
        AggregateResult[] groupedResults1 = [select Accounts__c acctid, sum(total_spending__c) total, sum(Search_total_spending__c) searchtotal,sum(Zen_feed_total_spending__c) zentotal,sum(Newtab_total_spending__c) newtab,
                                             sum(Premium_Spending__c) premium, sum(icons_newtab_spending__c) icon, sum(Magnetic_Masthead_total_spending__c) masthead,sum(skintool_iconsidebar_spending__c) iconsidebar
                                             from QC_account_data__c 
                                             where syn_date__c = yesterday and Accounts__c <> null and total_spending__c > 0 group by Accounts__c];
        for (AggregateResult record:groupedResults1) {
            Account acct = new Account();
            acct.id = String.valueof(record.get('acctid'));
            acct.Spending_yesterday__c = Decimal.valueof(String.valueof(record.get('total')));
            acct.Yesterday_search_spending__c = Decimal.valueof(String.valueof(record.get('searchtotal')));
            acct.Yesterday_zen_spending__c = Decimal.valueof(String.valueof(record.get('zentotal')));
            acct.Yesterday_newtab_spending__c = Decimal.valueof(String.valueof(record.get('newtab')));
            acct.Yesterday_premium_spending__c = Decimal.valueof(String.valueof(record.get('premium')));
            acct.Yesterday_Icon_spending__c = Decimal.valueof(String.valueof(record.get('icon')));
            acct.Yesterday_masthead_Spending__c = Decimal.valueof(String.valueof(record.get('masthead')));
            acct.Yesterday_Iconsidebar_Spending__c = Decimal.valueof(String.valueof(record.get('iconsidebar')));
            accts1.add(acct);
        }
        update accts1;
        //b.define new lists of Accounts to update data 2 days ago
        List<Account> accts2 = new list<Account>();
        //summary data of 2 days ago  
        AggregateResult[] groupedResults2 = [select Accounts__c acctid, sum(total_spending__c) total, sum(Search_total_spending__c) searchtotal,sum(Zen_feed_total_spending__c) zentotal,sum(Newtab_total_spending__c) newtab,
                                             sum(Premium_Spending__c) premium, sum(icons_newtab_spending__c) icon, sum(Magnetic_Masthead_total_spending__c) masthead, sum(skintool_iconsidebar_spending__c) iconsidebar
                                             from QC_account_data__c 
                                             where syn_date__c >= last_n_days:2 and syn_date__c< yesterday and Accounts__c <> null and total_spending__c > 0 group by Accounts__c];
        for (AggregateResult record:groupedResults2) {
            Account acct = new Account();
            acct.id = String.valueof(record.get('acctid'));
            acct.Spending_2_days_ago__c = Decimal.valueof(String.valueof(record.get('total')));
            acct.X2_days_ago_search_spending__c = Decimal.valueof(String.valueof(record.get('searchtotal')));
            acct.X2_days_ago_zen_spending__c = Decimal.valueof(String.valueof(record.get('zentotal')));
            acct.X2_days_ago_newtab_spending__c = Decimal.valueof(String.valueof(record.get('newtab')));
            acct.X2_days_ago_premium_spending__c = Decimal.valueof(String.valueof(record.get('premium')));
            acct.X2_days_ago_Icon_spending__c = Decimal.valueof(String.valueof(record.get('icon')));
            acct.X2_days_ago_masthead_Spending__c = Decimal.valueof(String.valueof(record.get('masthead')));
            acct.X2_days_ago_Iconsidebar_Spending__c = Decimal.valueof(String.valueof(record.get('iconsidebar')));
            accts2.add(acct);
        }
        update accts2; 
    }

}