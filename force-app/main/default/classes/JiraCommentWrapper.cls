public class JiraCommentWrapper {  
    public class JiraComment{
        public Integer total;
        public List<CommentWrapper> comments;
    }

    public class CommentWrapper{
        public String id; 
        public AuthorWrapper author; 
        public ContentWrapper body;
        public Datetime created;
        public Datetime updated;
    }

    public class ContentWrapper{
        public String type;
        public List<BasicContentWrapper> content;
    }

    public class BasicContentWrapper{
        public String type;   
        public String text; 
        public AttrsWrapper attrs;
        public List<MarkWrapper> marks;
        public List<BasicContentWrapper> content;        
    }

    public class AttrsWrapper{
        public String url;      
        public String id;
        public String text;     
    }

    public class MarkWrapper{
        public String type;   
    }

    public class AuthorWrapper{
        public String accountId;
        public String emailAddress;
        public String displayName;
        public Boolean active;
    }

    public static JiraComment parse(String json){
		return (JiraComment) System.JSON.deserialize(json, JiraComment.class);
	}
}