global class cc_Daily_Cash_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        cc_DailyCash_AutoCalculate();
    }
    public cc_Daily_Cash_Schedule(){
        cc_DailyCash_AutoCalculate();
    }
    public void cc_DailyCash_AutoCalculate()
    {
        string realPaymentRecordTypeId = '0120o0000017b2pAAA'; //	Real Payment
        string standardPayment = '0120o000001jwrzAAA'; //Standard payment
        string refundPayment = '0120o000001jwryAAA'; //refund
        List<AggregateResult> realPaymentList = [select sum(final_amount__c) amount from Payment__c
                                                 where effective_date__c = yesterday and stage__c = 'Done' and recordtypeid =:realPaymentRecordTypeId];
        
        List<AggregateResult> cashGateWayList = [select sum(final_amount__c) amount
                                                 from Payment__c 
                                                 where effective_date__c = yesterday and stage__c = 'Done' and recordtypeid =:standardPayment and payment_method__c = 'Payment Gateway'];
        
        List<AggregateResult> cashToQCList = [select sum(final_amount__c) amount
                                              from Payment__c 
                                              where effective_date__c = yesterday and stage__c = 'Done' and recordtypeid =:standardPayment and payment_method__c != 'Payment Gateway'];
        
        
        List<AggregateResult> refundList = [select sum(final_amount__c)amount from Payment__c 
                                            where effective_date__c = yesterday and stage__c = 'Done' and recordtypeid =:refundPayment];
        date yesterday = date.today().addDays(-1);
        Daily_Cash__c dailyCash =  new Daily_Cash__c();
        dailyCash.Date__c = yesterday;
        dailyCash.Name = formatDate(yesterday);
        if(realPaymentList.size() >0){
            dailyCash.Real_money__c = (decimal)realPaymentList.get(0).get('amount');
        }
         if(cashGateWayList.size() >0){
            dailyCash.Cash_via_Gateway__c = (decimal)cashGateWayList.get(0).get('amount');
        }
         if(cashToQCList.size() >0){
            dailyCash.Cash_to_QC__c = (decimal)cashToQCList.get(0).get('amount');
        }
         if(refundList.size() >0){
            dailyCash.Refund__c = (decimal)refundList.get(0).get('amount');
        }
        insert dailyCash;
        
        
    }
    public String formatDate(Date d) {
        //return d.year() + '-' + d.month() + '-' + d.day();
        return getfullStr(d.day()) + '/' + getfullStr(d.month()) + '/' + d.year();
    }
    public string getfullStr(integer n){
        if( n<10)
            return '0' + n;
        return string.valueOf(n);
    }
    
}