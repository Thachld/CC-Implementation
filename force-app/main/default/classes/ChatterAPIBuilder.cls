public with sharing class ChatterAPIBuilder {   

    public static ConnectApi.FeedItemInput initFeedItem(JiraCommentWrapper.CommentWrapper comment, String caseId, Map<String,User> mapUser, Boolean isCreated){


        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();        
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        ConnectApi.TextSegmentInput textSegment;
        ConnectApi.MentionSegmentInput mentionSegmentInput;
        ConnectApi.LinkSegmentInput  urlSegment;
        ConnectApi.MarkupBeginSegmentInput beginMarkup;
        ConnectApi.MarkupEndSegmentInput endMarkup;
        
        List<JiraCommentWrapper.BasicContentWrapper> contents = comment.body.content;

        if(contents != null ){
            Boolean isPost = false;

                ConnectApi.MarkupBeginSegmentInput beginItalicMarkup = new ConnectApi.MarkupBeginSegmentInput();
                beginItalicMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                messageBodyInput.messageSegments.add(beginItalicMarkup);

                textSegment = new ConnectApi.TextSegmentInput();
                textSegment.text = 'Jira CommentId[' + comment.id.trim()  + '] from jira by ';
                messageBodyInput.messageSegments.add(textSegment);
                

                if(mapUser.containsKey(comment.author.accountId) &&  !String.isBlank(comment.author.accountId)){                    
                    User usr = mapUser.get(comment.author.accountId);
                    if(usr != null){
                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                        mentionSegmentInput.Id = usr.Id;
                        messageBodyInput.messageSegments.add(mentionSegmentInput);   
                    }else {
                        System.debug('Jira User Mention Missing =>' + comment.author.accountId);
                    }                 
                }

                ConnectApi.MarkupEndSegmentInput endItalicMarkup = new ConnectApi.MarkupEndSegmentInput();
                endItalicMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                messageBodyInput.messageSegments.add(endItalicMarkup);

            
            for(JiraCommentWrapper.BasicContentWrapper cont: contents){  
                
                if(cont.type == 'paragraph'){
                    if(cont.content !=null){
                        //begin paragraph
                        beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                        beginMarkup.markupType = ConnectApi.MarkupType.PARAGRAPH;
                        messageBodyInput.messageSegments.add(beginMarkup);

                        for(JiraCommentWrapper.BasicContentWrapper basic: cont.content){ 
                            if(basic != null){
                                if(basic.type == 'text' && !String.isBlank(basic.text)){
                                    List<JiraCommentWrapper.MarkWrapper> marks = basic.marks;
                                    if(marks != null){
                                        for(JiraCommentWrapper.MarkWrapper mark: marks){
                                            if(mark.type == 'Code'){
                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                beginMarkup.markupType = ConnectApi.MarkupType.CODE;
                                                messageBodyInput.messageSegments.add(beginMarkup);
                                                
                                                textSegment = new ConnectApi.TextSegmentInput();
                                                textSegment.text = basic.text;
                                                messageBodyInput.messageSegments.add(textSegment);

                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                endMarkup.markupType = ConnectApi.MarkupType.CODE;
                                                messageBodyInput.messageSegments.add(endMarkup);

                                            }else if(mark.type == 'underline'){
                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                beginMarkup.markupType = ConnectApi.MarkupType.UNDERLINE;
                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                textSegment = new ConnectApi.TextSegmentInput();
                                                textSegment.text = basic.text;
                                                messageBodyInput.messageSegments.add(textSegment);

                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                endMarkup.markupType = ConnectApi.MarkupType.UNDERLINE;
                                                messageBodyInput.messageSegments.add(endMarkup);
                                            }else if(mark.type == 'strike'){
                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                beginMarkup.markupType = ConnectApi.MarkupType.STRIKETHROUGH;
                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                textSegment = new ConnectApi.TextSegmentInput();
                                                textSegment.text = basic.text;
                                                messageBodyInput.messageSegments.add(textSegment);

                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                endMarkup.markupType = ConnectApi.MarkupType.STRIKETHROUGH;
                                                messageBodyInput.messageSegments.add(endMarkup);
                                            }else if(mark.type == 'strong'){
                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                beginMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                textSegment = new ConnectApi.TextSegmentInput();
                                                textSegment.text = basic.text;
                                                messageBodyInput.messageSegments.add(textSegment);

                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                endMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                messageBodyInput.messageSegments.add(endMarkup);
                                            }else if(mark.type == 'em'){
                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                beginMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                textSegment = new ConnectApi.TextSegmentInput();
                                                textSegment.text = basic.text;
                                                messageBodyInput.messageSegments.add(textSegment);

                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                endMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                messageBodyInput.messageSegments.add(endMarkup);
                                            }else {
                                                textSegment = new ConnectApi.TextSegmentInput();
                                                textSegment.text = basic.text;
                                                messageBodyInput.messageSegments.add(textSegment);
                                            }
                                        }
                                    }else {
                                        textSegment = new ConnectApi.TextSegmentInput();
                                        textSegment.text = basic.text;
                                        messageBodyInput.messageSegments.add(textSegment);
                                    }
                                }else if(basic.type == 'mention' && !String.isBlank(basic.attrs.id)){
                                    User usr = mapUser.get(basic.attrs.id);
                                    if(usr != null){
                                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                                        mentionSegmentInput.Id = usr.Id;
                                        messageBodyInput.messageSegments.add(mentionSegmentInput);   
                                    }else {
                                        System.debug('Jira User Mention Missing =>' + basic.attrs.id);
                                    }  
                                }else if(basic.type == 'inlineCard' && !String.isBlank(basic.attrs.url)){
                                    urlSegment = new ConnectApi.LinkSegmentInput ();
                                    urlSegment.url = basic.attrs.url;
                                    messageBodyInput.messageSegments.add(urlSegment);
                                }else if(basic.type == 'hardBreak'){
                                    textSegment = new ConnectApi.TextSegmentInput();
                                    textSegment.text = '&nbsp;';
                                    messageBodyInput.messageSegments.add(textSegment);    
                                }
                            }
                        }

                        endMarkup = new ConnectApi.MarkupEndSegmentInput();
                        endMarkup.markupType = ConnectApi.MarkupType.PARAGRAPH;
                        messageBodyInput.messageSegments.add(endMarkup);    
                        //End paragraph
                    }
                }else if(cont.type == 'bulletList'){
                    if(cont.content !=null){
                        for(JiraCommentWrapper.BasicContentWrapper subcont: cont.content){
                            List<JiraCommentWrapper.BasicContentWrapper> listcontents = subcont.content;
                            if(listcontents != null){
                                //Begin List Item
                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                beginMarkup.markupType = ConnectApi.MarkupType.LISTITEM;
                                messageBodyInput.messageSegments.add(beginMarkup);
                                
                                for(JiraCommentWrapper.BasicContentWrapper listcontent : listcontents){
                                    if(listcontent.type == 'paragraph'){
                                        List<JiraCommentWrapper.BasicContentWrapper> listbasiccontents = listcontent.content;

                                        if(listbasiccontents != null){
                                            for(JiraCommentWrapper.BasicContentWrapper basic: listbasiccontents){
                                                if(basic.type == 'text' && !String.isBlank(basic.text)){
                                                    List<JiraCommentWrapper.MarkWrapper> marks = basic.marks;
                                                    if(marks != null){
                                                        for(JiraCommentWrapper.MarkWrapper mark: marks){
                                                            if(mark.type == 'Code'){

                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(endMarkup);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(endMarkup);

                                                            }else if(mark.type == 'underline'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.UNDERLINE;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.UNDERLINE;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else if(mark.type == 'strike'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.STRIKETHROUGH;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.STRIKETHROUGH;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else if(mark.type == 'strong'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(beginMarkup);
                
                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);
                
                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else if(mark.type == 'em'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(beginMarkup);
                
                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);
                
                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else {
                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);
                                                            }
                                                        }
                                                    }else {
                                                        textSegment = new ConnectApi.TextSegmentInput();
                                                        textSegment.text = basic.text;
                                                        messageBodyInput.messageSegments.add(textSegment);
                                                    }                                                    
                                                }else if(basic.type == 'mention' && !String.isBlank(basic.attrs.id)){
                                                    User usr = mapUser.get(basic.attrs.id);
                                                    if(usr != null){
                                                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                                                        mentionSegmentInput.Id = usr.Id;
                                                        messageBodyInput.messageSegments.add(mentionSegmentInput);   
                                                    }else {
                                                        System.debug('Jira User Mention Missing =>' + basic.attrs.id);
                                                    }   
                                                }else if(basic.type == 'inlineCard' &&!String.isBlank(basic.attrs.url)){
                                                    urlSegment = new ConnectApi.LinkSegmentInput ();
                                                    urlSegment.url = basic.attrs.url;
                                                    messageBodyInput.messageSegments.add(urlSegment);
                                                }else if(basic.type == 'hardBreak'){
                                                    textSegment = new ConnectApi.TextSegmentInput();
                                                    textSegment.text = '&nbsp;';
                                                    messageBodyInput.messageSegments.add(textSegment);    
                                                }  
                                            }
                                        }
                                    }
                                }


                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                endMarkup.markupType = ConnectApi.MarkupType.LISTITEM;
                                messageBodyInput.messageSegments.add(endMarkup);      
                                //End List item

                            }

                        }
                    }
                }else if(cont.type == 'orderedList'){
                    if(cont.content !=null){
                        for(JiraCommentWrapper.BasicContentWrapper subcont: cont.content){
                            List<JiraCommentWrapper.BasicContentWrapper> listcontents = subcont.content;                            
                            if(listcontents != null){
                                //Begin ORDEREDLIST
                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                beginMarkup.markupType = ConnectApi.MarkupType.ORDEREDLIST;
                                messageBodyInput.messageSegments.add(beginMarkup);
                                
                                for(JiraCommentWrapper.BasicContentWrapper listcontent : listcontents){                                    
                                    if(listcontent.type == 'paragraph'){
                                        List<JiraCommentWrapper.BasicContentWrapper> listbasiccontents = listcontent.content;

                                        if(listbasiccontents != null){
                                            beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                            beginMarkup.markupType = ConnectApi.MarkupType.LISTITEM;
                                            messageBodyInput.messageSegments.add(beginMarkup);

                                            for(JiraCommentWrapper.BasicContentWrapper basic: listbasiccontents){                                                

                                                if(basic.type == 'text' && !String.isBlank(basic.text)){
                                                    List<JiraCommentWrapper.MarkWrapper> marks = basic.marks;
                                                    if(marks != null){
                                                        for(JiraCommentWrapper.MarkWrapper mark: marks){
                                                            if(mark.type == 'Code'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(endMarkup);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(endMarkup);


                                                            }else if(mark.type == 'underline'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.UNDERLINE;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.UNDERLINE;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else if(mark.type == 'strike'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.STRIKETHROUGH;
                                                                messageBodyInput.messageSegments.add(beginMarkup);

                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);

                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.STRIKETHROUGH;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else if(mark.type == 'strong'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(beginMarkup);
                
                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);
                
                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.BOLD;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else if(mark.type == 'em'){
                                                                beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                                                beginMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(beginMarkup);
                
                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);
                
                                                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                                                endMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                                                messageBodyInput.messageSegments.add(endMarkup);
                                                            }else {
                                                                textSegment = new ConnectApi.TextSegmentInput();
                                                                textSegment.text = basic.text;
                                                                messageBodyInput.messageSegments.add(textSegment);
                                                            }
                                                        }
                                                    }else {
                                                        textSegment = new ConnectApi.TextSegmentInput();
                                                        textSegment.text = basic.text;
                                                        messageBodyInput.messageSegments.add(textSegment);
                                                    }
                                                }else if(basic.type == 'mention' && !String.isBlank(basic.attrs.id)){
                                                    User usr = mapUser.get(basic.attrs.id);
                                                    if(usr != null){
                                                        mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                                                        mentionSegmentInput.Id = usr.Id;
                                                        messageBodyInput.messageSegments.add(mentionSegmentInput);   
                                                    }else {
                                                        System.debug('Jira User Mention Missing =>' + basic.attrs.id);
                                                    }      
                                                }else if(basic.type == 'inlineCard' &&!String.isBlank(basic.attrs.url)){
                                                    urlSegment = new ConnectApi.LinkSegmentInput ();
                                                    urlSegment.url = basic.attrs.url;
                                                    messageBodyInput.messageSegments.add(urlSegment);
                                                }else if(basic.type == 'hardBreak'){
                                                    textSegment = new ConnectApi.TextSegmentInput();
                                                    textSegment.text = '&nbsp;';
                                                    messageBodyInput.messageSegments.add(textSegment);    
                                                }      
                                            }

                                            endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                            endMarkup.markupType = ConnectApi.MarkupType.LISTITEM;
                                            messageBodyInput.messageSegments.add(endMarkup);    
                                        }
                                    }
                                }

                                endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                endMarkup.markupType = ConnectApi.MarkupType.ORDEREDLIST;
                                messageBodyInput.messageSegments.add(endMarkup);      
                                //End ORDEREDLIST

                            }

                        }
                    }
                }else if(cont.type == 'blockquote'){                    
                    if(cont.content !=null){
                      
                        beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                        beginMarkup.markupType = ConnectApi.MarkupType.CODE;
                        messageBodyInput.messageSegments.add(beginMarkup);

                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = '';
                        messageBodyInput.messageSegments.add(textSegment);   

                        endMarkup = new ConnectApi.MarkupEndSegmentInput();
                        endMarkup.markupType = ConnectApi.MarkupType.CODE;
                        messageBodyInput.messageSegments.add(endMarkup);                        

                        for(JiraCommentWrapper.BasicContentWrapper quotecont: cont.content){                                                   
                            if(quotecont !=null){
                                List<JiraCommentWrapper.BasicContentWrapper> quotecontents = quotecont.content;
                                if(quotecontents != null){
                                    beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                    beginMarkup.markupType = ConnectApi.MarkupType.PARAGRAPH;
                                    messageBodyInput.messageSegments.add(beginMarkup);

                                    beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                                    beginMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                    messageBodyInput.messageSegments.add(beginMarkup);

                                    
                                    for(JiraCommentWrapper.BasicContentWrapper quote: quotecontents){                                        
                                        if(quote.type == 'text' && !String.isBlank(quote.text)){                                    
                                            textSegment = new ConnectApi.TextSegmentInput();
                                            textSegment.text = quote.text;
                                            messageBodyInput.messageSegments.add(textSegment);                                    
                                        }else if(quote.type == 'mention' && !String.isBlank(quote.attrs.id)){
                                            User usr = mapUser.get(quote.attrs.id);
                                            if(usr != null){
                                                mentionSegmentInput = new ConnectApi.MentionSegmentInput();
                                                mentionSegmentInput.Id = usr.Id;
                                                messageBodyInput.messageSegments.add(mentionSegmentInput);   
                                            }else {
                                                System.debug('Jira User Mention Missing =>' + quote.attrs.id);
                                            }       
                                        }else if(quote.type == 'inlineCard' && !String.isBlank(quote.attrs.url)){
                                            urlSegment = new ConnectApi.LinkSegmentInput ();
                                            urlSegment.url = quote.attrs.url;
                                            messageBodyInput.messageSegments.add(urlSegment);
                                        }else if(quote.type == 'hardBreak'){
                                            textSegment = new ConnectApi.TextSegmentInput();
                                            textSegment.text = '&nbsp;';
                                            messageBodyInput.messageSegments.add(textSegment);    
                                        } 
                                    }

                                    endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                    endMarkup.markupType = ConnectApi.MarkupType.ITALIC;
                                    messageBodyInput.messageSegments.add(endMarkup);

                                    endMarkup = new ConnectApi.MarkupEndSegmentInput();
                                    endMarkup.markupType = ConnectApi.MarkupType.PARAGRAPH;
                                    messageBodyInput.messageSegments.add(endMarkup);   
                                }                                
                            }
                        }

                        beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                        beginMarkup.markupType = ConnectApi.MarkupType.CODE;
                        messageBodyInput.messageSegments.add(beginMarkup);
                        
                        textSegment = new ConnectApi.TextSegmentInput();
                        textSegment.text = '';
                        messageBodyInput.messageSegments.add(textSegment);   

                        endMarkup = new ConnectApi.MarkupEndSegmentInput();
                        endMarkup.markupType = ConnectApi.MarkupType.CODE;
                        messageBodyInput.messageSegments.add(endMarkup);                      
                       
                    }
                }else if(cont.type == 'codeBlock'){
                    if(cont.content !=null){
                      
                        beginMarkup = new ConnectApi.MarkupBeginSegmentInput();
                        beginMarkup.markupType = ConnectApi.MarkupType.CODE;
                        messageBodyInput.messageSegments.add(beginMarkup);                                       

                        for(JiraCommentWrapper.BasicContentWrapper basic: cont.content){                                                     
                            if(basic !=null){
                                if(basic.type == 'text' && !String.isBlank(basic.text)){
                                    textSegment = new ConnectApi.TextSegmentInput();
                                    textSegment.text = basic.text;
                                    messageBodyInput.messageSegments.add(textSegment); 
                                }
                            }
                        }

                        endMarkup = new ConnectApi.MarkupEndSegmentInput();
                        endMarkup.markupType = ConnectApi.MarkupType.CODE;
                        messageBodyInput.messageSegments.add(endMarkup);       
                    }
                }  
            }      
            
            feedItemInput.body = messageBodyInput;        
            

            if(isCreated){
                feedItemInput.feedElementType = ConnectApi.FeedElementType.FEEDITEM;
                feedItemInput.subjectId = caseId;
            }
            
        }

        return feedItemInput;
    }

}