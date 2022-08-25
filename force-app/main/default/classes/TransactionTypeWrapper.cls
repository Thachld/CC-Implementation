public class TransactionTypeWrapper {
    
    public Boolean success;
    public Data data;

    public class Data{        
        public Integer total;
        public List<DataWrapper> items;
    }

    public class DataWrapper{
        public String id;
        public String internal_type;
        public Integer priority;
        public String label;
        public String comment;
        public String is_enabled;
        public String allow_coupon;
        public String created_time;
        public String updated_time;
        public String transaction_type;
        public String required_interval_spending_days;
        public Integer maximum_interval_spending_days;
    }


    public static TransactionTypeWrapper parse(String jsonString){
		return (TransactionTypeWrapper) System.JSON.deserialize(jsonString, TransactionTypeWrapper.class);
	}
}