public with sharing class cc_SendEmailWithTemplateController {
    @AuraEnabled 
    public static Id sendMailsMethod(String campIdId,String templateId, String receipentType, List<String> listdocIds){
        try {
            Id jobId;
            if(!String.isBlank(campIdId) && !String.isBlank(templateId) && !String.isBlank(receipentType)){
                Set<String> docIds = new Set<String>();
                docIds.addAll(listdocIds);
                cc_SendMassEmail_Batch mailbatch = new cc_SendMassEmail_Batch(templateId,receipentType, campIdId, docIds);
                jobId = Database.executeBatch(mailbatch, 50);                
            }     
            return jobId;       
        } catch (Exception ex) {
            throw new AuraException(ex.getMessage());
        }
        
        
    }   
    
    @AuraEnabled
    public static list<emailTemplateWrapper> getEmailTempaltes(){
        list<emailTemplateWrapper> emailTemplateWrapperlist = new list<emailTemplateWrapper>();
        
        map<String,emailTemplateWrapper> folderIdVsTemplateMap = new map<String,emailTemplateWrapper>();
        Set<String> fldIds = new Set<String>();
        
        for(Folder fl:  [SELECT Id,Name FROM Folder WHERE Type = 'Email']){
            fldIds.add(fl.Id);
        }

        
        for(sobject emailtemp : [ SELECT Id, FolderId, HtmlValue, FolderName, isActive, body,Name,subject FROM EmailTemplate WHERE isActive = true and FolderId IN :fldIds ]){ 
            if( folderIdVsTemplateMap.containskey( String.valueof(emailtemp.get('FolderId'))) ){
                
                EmailTemplates template = new EmailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                folderIdVsTemplateMap.get( String.valueof(emailtemp.get('FolderId')) ).emailtemplatelist.add( template );
                
            }else{
                emailTemplateWrapper tempWrap = new emailTemplateWrapper();
                tempWrap.folderId = String.valueOf(emailtemp.get('FolderId'));
                tempWrap.folderName = String.valueOf(emailtemp.get('FolderName'));
                
                emailTemplates template = new emailTemplates();
                template.emailTemplateId = String.valueOf(emailtemp.get('Id'));
                template.emailTemplatename = String.valueOf(emailtemp.get('Name'));
                template.emailbody = (emailtemp.get('HtmlValue') != null ? String.valueOf(emailtemp.get('HtmlValue')) : '' );
                template.emailSubject = String.valueOf(emailtemp.get('subject'));
                tempWrap.emailtemplatelist = new list<emailTemplates>{ template };
                folderIdVsTemplateMap.put( String.valueof(emailtemp.get('FolderId'))  , tempWrap );
            }   
        }
        
        if( !folderIdVsTemplateMap.isEmpty() ){
            emailTemplateWrapperlist.addAll( folderIdVsTemplateMap.values() );
            
            
            return emailTemplateWrapperlist;
        }
        return null;
    }

    @AuraEnabled  
    public static List<ContentDocument> getFilesDB(String recordId){ 
        Set<Id> recordIds = new Set<Id>{recordId};
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM 
                                                ContentDocumentLink WHERE LinkedEntityId IN :recordIds
                                            ];       

        Set<String> contentDocumentIds = new Set<String>();   
        
        for(ContentDocumentLink cdl:cdlList){ 
            if (!contentDocumentIds.contains(cdl.ContentDocumentId)){
                contentDocumentIds.add(cdl.ContentDocumentId);
            }               
        }  

        return [SELECT Id, Title, FileType ,FileExtension, ContentSize FROM ContentDocument WHERE Id IN :contentDocumentIds];   
        
    } 

    //Delete file 
    @AuraEnabled  
    public static void deleteFileDB(String contentDocumentId){ 
        try {
            delete [SELECT Id FROM ContentDocument WHERE Id = :contentDocumentId];    
        } catch (Exception e) {
            throw new AuraHandledException('Something is wrong :' + e.getMessage());
        }  
    }

    
    
    public class emailTemplateWrapper{
        
        @AuraEnabled 
        public String folderName{get;set;}
        
        @AuraEnabled 
        public String folderId{get;set;}
        
        @AuraEnabled
        public list<emailTemplates> emailtemplatelist{get;set;}
        
    }
    
    public class emailTemplates{
        
        @AuraEnabled 
        public String emailTemplateId{get;set;}
        
        @AuraEnabled 
        public String emailbody{get;set;}
        
        @AuraEnabled
        public String emailSubject {get;set;}
        
        @AuraEnabled 
        public String emailTemplatename{get;set;}
    }  

    public class Filewrapper{
        @AuraEnabled 
        public String Id{get;set;}
    }
    
    
}