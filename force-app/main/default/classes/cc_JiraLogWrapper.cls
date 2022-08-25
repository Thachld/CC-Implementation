public class cc_JiraLogWrapper {
    public string field;
    public string fromValue;
    public string fromString;
    public string toString;
    public string toValue;
    public Datetime created;
    public String author;
    public String logId;

    public class CommentWrapper{
        public string commentId;      
        public string jiraId;
        public String authorId;       
        public Datetime created;
        public Datetime updated;        
        public List<ContentWrapper> contents;  
    }

    public class ContentWrapper{
        public String type;      
        public List<SubContentWrapper> subcontents;       
    }

    public class SubContentWrapper{
        public BasicContentWrapper content;
        public List<ListContentWrapper> listcontents;
    }


    public class ListContentWrapper{
        public String type;      
        public List<BasicContentWrapper> contents;
    }


    public class BasicContentWrapper{
        public String type;   
        public String text; 
        public AttrsWrapper attrs;
        public List<MarkWrapper> marks;
        public List<ListContentWrapper> contents;
        public List<QuoteBasicWrapper> quotecontents;
    }    

    public class AttrsWrapper{
        public String url;      
        public String id;
        public String text;     
    }

    public class MarkWrapper{
        public String type;   
    }

    public class QuoteBasicWrapper{
        public String type;   
        public String text; 
        public AttrsWrapper attrs;   
    }
}