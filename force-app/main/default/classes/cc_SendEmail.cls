public class cc_SendEmail {
    public static void sendEmail(string emailTo,string subject, string htmlBody, string key){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { emailTo };
        message.subject =subject;
        message.setHtmlBody(htmlBody);  
        message.setCharset('UTF-8');
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if (!results[0].success) {
            cc_Util.writeLog('email', results.get(0).getErrors()[0].getMessage() , '');
        }
    }
}