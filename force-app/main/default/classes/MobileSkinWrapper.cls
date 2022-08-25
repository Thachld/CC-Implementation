public with sharing class MobileSkinWrapper {
    
    public Item[] items;
	public class Item {
		public Detail details;
		public Stat stats;
	}
	public class Detail {		
		public String client_id;	//456		
		public String date_x;	//2022-03-10
	}
	public class Stat {
		public Double spending;	//50000000
		public Double ctr;	//0.2
		public Integer shows;	//500000
		public Integer clicks;	//100000
	}

	public static Map<String,MobileSkinWrapper.Item> parseToMap(String json){
		Map<String,MobileSkinWrapper.Item> mapresult = new Map<String,MobileSkinWrapper.Item>();

		json = json.replace('"date":', '"date_x":');
		MobileSkinWrapper result = (MobileSkinWrapper) System.JSON.deserialize(json, MobileSkinWrapper.class);

		for(MobileSkinWrapper.Item item :result.items){
            String key = item.details.client_id + '###' + item.details.date_x;
			mapresult.put(key, item);			
		}

		return mapresult;
	}
}