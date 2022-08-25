public class JiraCommentAPIWrapper {
    public String commentId;
    public String authorId;
    public String jiraId;

    public static JiraCommentAPIWrapper parseCommentAPI(String json){
		return (JiraCommentAPIWrapper) System.JSON.deserialize(json, JiraCommentAPIWrapper.class);
	}
}