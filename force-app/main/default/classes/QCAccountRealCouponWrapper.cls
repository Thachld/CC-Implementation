public class QCAccountRealCouponWrapper {
	public string Customer_id {get;set;}
	public Double coupon_spending{get;set;}
    public Double real_spending{get;set;}
    public string synDate{get;set;}
    private string mappingKeyTemp;
    public string mappingKey{
        get{
            if( mappingKeyTemp == null){
                mappingKeyTemp = Customer_id + '_' + synDate;
            }
            return mappingKeyTemp;
        }
    }
    public static List<QCAccountRealCouponWrapper> parse(String json) {
		return (List<QCAccountRealCouponWrapper>) System.JSON.deserialize(json, List<QCAccountRealCouponWrapper>.class);
	}
    public class Responds{
        public Responds(){
            qcAccountError = new List<QCAccountError>();
            qcAccountSuccess = new List<QCAccountSuscess>();
        }
        public List<QCAccountError> qcAccountError;
        public Integer totalqcAccount {get;set;}
        public Integer totalSuccess {get;set;}
        public Integer totalFail{get;set;}
        public String error{get;set;}
        public List<QCAccountSuscess> qcAccountSuccess;
    }
    public class QCAccountSuscess{
        public String Customer_id;
    }
    
    public class QCAccountError {
        public QCAccountRealCouponWrapper qcAccountError {get;set;}
        public String insertError;
        public String updateError;
    }
}