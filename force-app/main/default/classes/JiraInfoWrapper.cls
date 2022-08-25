public class JiraInfoWrapper{
	public String id;	//45954
	public String key;	//FS-1
	public fields fields;
	public class fields {
		public issuetype issuetype;
		public project project;
		public priority priority;
		public String[] labels;
		public assignee assignee;
		public String updated;
		public status status;
		public String summary;	
		public String duedate;	
		public customfield_10049 customfield_10049;	
	}
	public class issuetype {
		public String name;	
	}
	public class project {
		public String key;	
		public String name;	
	}
	public class priority {
		public String name;	
	}
	
	public class assignee {
		public String accountId;	
	}
	public class status {
		public String name;	
	}

	public class customfield_10049 {
		public String value;	
	}

	public static JiraInfoWrapper parse(String json){
		return (JiraInfoWrapper) System.JSON.deserialize(json, JiraInfoWrapper.class);
	}
}