({
    sendHelper: function (component,templateId, campaignId, recipientType, docIds) {
        
        // call the server side controller method 	
        var action = component.get("c.sendMailsMethod");       
        // set the 3 params to sendMailMethod method   
        action.setParams({
            'campIdId': campaignId,
            'templateId': templateId,
            'receipentType': recipientType,
            'listdocIds' : docIds
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();   
                
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Send Email Info',
                    message: 'Send Email process is processing',
                    duration:' 5000',                   
                    type: 'success',
                    mode: 'sticky'
                });
                toastEvent.fire(); 
                
                location.reload();
                
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }

                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Send Email Info',
                    message: 'Email failed to processing',
                    duration:' 5000',                   
                    type: 'error',
                    mode: 'sticky'
                });
                toastEvent.fire(); 
            }


        });
        $A.enqueueAction(action);
    },

    getEmailTemplateHelper: function (component, event) {
       
        var action = component.get("c.getEmailTempaltes");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS" && response.getReturnValue() != null) {
                component.set("v.emailfolderVSTemplateList", response.getReturnValue());
                component.set('v.loaded', !component.get('v.loaded'));

                var result = response.getReturnValue();
            }else if (state === "INCOMPLETE") {
                // do something
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                            errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);

    },

    getUploadedFiles : function(component, event){
       
        var action = component.get("c.getFilesDB");  

        action.setParams({  
            "recordId": component.get("v.recordId") 
        }); 

        action.setCallback(this,function(response){  
            var state = response.getState();  
            if(state === "SUCCESS"){  
                
                var result = response.getReturnValue();    
                for (var i =0; i< result.length; i++){
                    var row = result[i];

                    if (row.FileExtension == 'xls' || row.FileExtension == 'xlsx'){
                        row.FileExtension = "excel";
                    }else if (row.FileExtension == 'doc' || row.FileExtension == 'docx'){
                        row.FileExtension = "word";
                    }else if (row.FileExtension == 'pdf'){
                        row.FileExtension = "pdf";
                    }else if (row.FileExtension == 'csv'){
                        row.FileExtension = "csv";
                    }else if (row.FileExtension == 'zip'){
                        row.FileExtension = "zip";
                    }else{
                        row.FileExtension = "unknown"; 
                    }
                } 
                var js = JSON.stringify(result);      
                component.set("v.files",result);  
            }  
        });  
        $A.enqueueAction(action);  
    },

    //Delete file
    deleteUploadedFile : function(component, contentDocumentId) {   
           
        var action = component.get("c.deleteFileDB");
        action.setParams({
            "contentDocumentId":contentDocumentId
        });        

        action.setCallback(this, function(response){
           
			var state = response.getState();
            
			if (state === "SUCCESS"){			
                var files = component.get("v.files");
                
                for(var i=0; i< files.length ; i++){
                    if (files[i].Id == contentDocumentId){
                        files.splice(i, 1); 
                    }
                }

                component.set("v.files",files);                
				
			}else if (state === "INCOMPLETE"){

			}else if (state === "ERROR"){
                var errors = response.getError(); 
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    var message = errors[0].message;                   
                }   
                         
			}
		});

		$A.enqueueAction(action);                
        
    },
})