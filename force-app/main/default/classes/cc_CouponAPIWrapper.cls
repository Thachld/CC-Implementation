public class cc_CouponAPIWrapper {

    public class ParamWrapper{
        public String coupon_id;
        public String coupon_campaign_id;
        public String qc_account;
        public String payment;
    }

    public class SuccessCampaignWraper{
        public String id;
        public String name;
        public String multiple_usage;
    }

    public class InvalidFieldWrapper{
        public String field;
        public String code;
        public String message;
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
        public String poi_id;
        public String spendingExpireDate;
        public String usedTransactionId;
        public String timeIssued;
        public String status;
        public String transactionTypeMappingId;
        public Integer intervalSpendingDays;  
        public String promotionConditionContent;  
    }

    public class FalseResultWraper{
        public String code;
        public String message;
        public List<InvalidFieldWrapper> invalid_fields;
    }

    public class CampaigntResultWrapper{
        public Decimal total;  
        public List<SuccessCampaignWraper> items;
    }

    public class ListCampaigntWrapper{
        public Boolean success;
        public CampaigntResultWrapper data;
        public FalseResultWraper error;
    }



    public class CampaignAPIResultWrapper{
        public Boolean success;
        public SuccessCampaignWraper data;
        public FalseResultWraper error;
    }

    public class CouponDataWrapper{
        public Boolean success;
        public CouponWrapper data;
        public FalseResultWraper error;
    }

    public class CouponDatasWrapper{
        public Boolean success;
        public List<CouponWrapper> data;
        public FalseResultWraper error;
    }

    public class Responds{
        public string status{get;set;}
        public string message{get;set;}
    }


    public class CreateCouponWrapper{
        public String id;
        public String qcemail;
        public String ownerId;
        public String campaign;
        public String couponCampaignId;
        public String transactionType;
        public String transactionTypeMappingId;
        public String expireDate;
        public String spendingExpiredDate;
        public Decimal value;
        public Integer quantity;  
        public Integer intervalSpendingDays;  
        public String promotionConditionContent;  
        public Set<String> emails;      
        public Boolean requiredIntervalSpendingDays;
    }

    public class EditCouponWrapper{
        public String ownerId;        
        public String expireDate;  
        public String spendingExpiredDate;      
        public Decimal value;        
        public String email;     
        public Integer intervalSpendingDays;  
        public String promotionConditionContent;   
        public String transactionTypeMappingId;
        public String couponCampaignId;
    }


    public class SpendingBonusCouponWrapper{
        public String qcid;        
        public Decimal amount;     
    }

    public class ActivateCouponWrapper{
        public String couponid;        
        public String userid;
        public String userRequestId;
        public String sfrecordId;
    }

    

}