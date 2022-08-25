public with sharing class cc_PaymentWrapper {
    public class Responds{
        public string status{get;set;}
        public string message{get;set;}
    }
    
    public class BalanceResult{       
        public List<BalanceDetail> DETAIL;
        public BalanceSummary SUMMARY;
        public String USER_ID;
    }

    public class BalanceDetail{
        public Decimal BALANCE;
        public String ID;
        public String TIMESTAMP;
        public String TYPE;
    }

    public class BalanceSummary{
        public Decimal COUPON_MONEY;
        public Decimal REAL_MONEY;
        public Decimal REFUND_MONEY;
        public Decimal TOTAL_MONEY;
    }
}