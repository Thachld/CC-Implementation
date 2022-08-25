public with sharing class SpendingBonusWrapper {
    public SuccessWrapper success;
    public FailedWrapper failed;

    public class SuccessWrapper{
        public Integer total;
        public List<CouponWrapper> items;
    }

    public class FailedWrapper{
        public Integer total;
        public List<ErrorWrapper> items;
    }

    public class CouponWrapper{
        public String id;
        public String code;
        public String ownerId;
        public Decimal amount;
        public String usedBy;
        public String timeUsed;
        public String couponCampaignId;
        public String expireDate;
        public String email;        
        public String spendingExpireDate;
        public String usedTransactionId;
        public String timeIssued;
        public String status;
        public String transactionTypeMappingId;
        public Integer intervalSpendingDays;  
        public String conditionContent;  
    }

    public class ErrorWrapper{
        public String email;
        public String errorMessage;
    }

    public static SpendingBonusWrapper parse(String json){
		return (SpendingBonusWrapper) System.JSON.deserialize(json, SpendingBonusWrapper.class);
	}
}