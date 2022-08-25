public class BalanceServiceWrapper{	
	public List<BalanceWrapper> balances;

	public class BalanceWrapper{
		public List<BalanceServiceWrapper.DetailWrapper> detail;
		public SummaryWrapper summary;
		public String user_id;
		public String date_time;
	}

	public  class DetailWrapper {
		public Decimal balance;	
		public String id;	
		public String timestamp;	
		public String type;	
		public String internal_type;	
	}
	public  class SummaryWrapper {
		@AuraEnabled
		public String qcId {get;set;}

		@AuraEnabled
		public String userEmail {get;set;}

		@AuraEnabled
		public String userId {get;set;}

		@AuraEnabled
		public Decimal coupon_money {get;set;}

        @AuraEnabled
		public Decimal real_money {get;set;}

        @AuraEnabled
		public Decimal refund_money {get;set;}

        @AuraEnabled
		public Decimal total_money {get;set;}

		@AuraEnabled
		public String date_time {get;set;}
	}
	public static List<BalanceWrapper> parse(String json){

		String jsbody = json.replace('DATETIME', 'date_time');
		System.debug('jsbody=>' + jsbody);

		BalanceServiceWrapper balancers = (BalanceServiceWrapper) System.JSON.deserialize(jsbody, BalanceServiceWrapper.class);
		List<BalanceWrapper> results = balancers.balances;

		for(BalanceWrapper result: results){
			System.debug('result.summary=>' + result.summary);

			if(result.detail != null){
				List<BalanceServiceWrapper.DetailWrapper> details = new List<BalanceServiceWrapper.DetailWrapper>();
				for(BalanceServiceWrapper.DetailWrapper dt : result.detail){
					dt.balance = Math.floor(dt.balance);				
					details.add(dt);
				}

				result.detail = details;
			}

			
			result.summary.total_money = Math.floor(result.summary.total_money);
			result.summary.real_money = Math.floor(result.summary.real_money);
			result.summary.coupon_money = Math.floor(result.summary.coupon_money);
			result.summary.refund_money = Math.floor(result.summary.refund_money);
			result.summary.date_time = result.date_time;			
		}

		return results;
	}
}