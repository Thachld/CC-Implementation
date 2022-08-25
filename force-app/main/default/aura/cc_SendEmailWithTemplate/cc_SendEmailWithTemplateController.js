({
    doInit: function (component, event, helper) {
        helper.getEmailTemplateHelper(component, event);
        helper.getUploadedFiles(component, event); 
    },

    sendMail: function (component, event, helper) {      
        var templateId = component.get("v.templateId");
        var campaignId = component.get("v.recordId");
        var recipientType = component.get("v.recipient"); 
        var files = component.get("v.files");
        
        var docIds = [];
        for(var i = 0 ; i< files.length ; i++){
            var file = files[i];
            docIds.push(file.Id);
        }

        debugger;
        if( templateId && campaignId && recipientType){
            helper.sendHelper(component, templateId, campaignId, recipientType, docIds);
        }else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Required Message',
                    message: 'Please select required field *',
                    duration:' 5000',                   
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire(); 
        }
        
        
        
    },
  
    closeMessage: function (component, event, helper) {
        component.set("v.templateId", false);
        component.set("v.files", null);
        component.set("v.subject", null);
        component.set("v.recipient", null);
        component.set("v.emailbody", null);
        //$A.get("e.force:closeQuickAction").fire()
    },

    onSelectEmailFolder: function (component, event, helper) {
        var folderId = event.target.value;
        component.set("v.folderId1", folderId);
        if (folderId != null && folderId != '' && folderId != 'undefined') {
            var emailfolderVSTemplateList = component.get("v.emailfolderVSTemplateList");
            emailfolderVSTemplateList.forEach(function (element) {
                if (element.folderId == folderId) {
                    component.set("v.emailTemplateList", element.emailtemplatelist);
                }
            });
        } else {
            var temp = [];
            component.set("v.emailTemplateList", temp);
        }
    },

    onSelectEmailTemplate: function (component, event, helper) {
        var emailTempId = event.target.value;
        var emailbody = '';
        var emailSubject = '';
        component.set("v.templateId", emailTempId);
        if (emailTempId != null && emailTempId != '' && emailTempId != 'undefined') {
            var emailTemplateList = component.get("v.emailTemplateList");
            emailTemplateList.forEach(function (element) {
                if (element.emailTemplateId == emailTempId && element.emailbody != null) {
                    emailbody = element.emailbody;
                    emailSubject = element.emailSubject;
                }
            });
        }
        component.set("v.emailbody", emailbody);
        component.set("v.subject", emailSubject);

    },

    onSelectRecipientTypes:function (component, event, helper) {
        var recipientType = event.target.value;
        component.set("v.recipient", recipientType);
    },

    closeModal: function (component, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    openmodal: function (component, event, helper) {
        var cmpTarget = component.find('Modalbox');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        $A.util.addClass(cmpBack, 'slds-backdrop--open');
    },
    

    handleUploadFinished : function (component, event, helper) {
        helper.getUploadedFiles(component, event); 
    },

    handleDeleteFile :function (component, event, helper) {
        var contentDocumentId = event.target.getAttribute('data-id');
        if(contentDocumentId){
            helper.deleteUploadedFile(component, contentDocumentId);
        }

    }


})