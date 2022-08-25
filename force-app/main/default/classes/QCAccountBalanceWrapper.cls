public class QCAccountBalanceWrapper {
	public String Customer_id {get;set;}
	public String Customer_email{get;set;}
	public String Customer_status{get;set;}
	public long Customer_balance{get;set;}
	public static List<QCAccountBalanceWrapper> parse(String json) {
		return (List<QCAccountBalanceWrapper>) System.JSON.deserialize(json, List<QCAccountBalanceWrapper>.class);
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
        public String Customer_id {get;set;}
        public String Customer_email{get;set;}
        public String Customer_status{get;set;}
        public long Customer_balance{get;set;}
        public String insertError;
        public String updateError;
    }
}