({
    createPicker: function(component, event, helper){
		var action = component.get("c.getAccessToken");	
        var currentRecordId = component.get("v.recordId");
        var currentObjectName = component.get("v.sObjectName");
        
        
        document.getElementById("recordIdCurrent").innerHTML = currentRecordId;
        document.getElementById("sObjectTypeCurrent").innerHTML = currentObjectName;
        
        
        console.log('###action: '+action);
		action.setCallback(this, function(response){
			var status = response.getState();
            console.log('###status: '+status);
            console.log('###RecordId:'+ component.get("v.recordId"));
            console.log('###sObjectName:'+ component.get("v.sObjectName"));
			if(status === "SUCCESS"){
                console.log('###return value: '+JSON.stringify(response.getReturnValue()));
				var accessToken = response.getReturnValue().accessToken;
				var folderId = response.getReturnValue().folderID;
                var prefixURL = response.getReturnValue().prefixURL;
                document.getElementById("prefixURL").innerHTML = prefixURL;
				console.log('###accessToken: '+accessToken);
                console.log('###folderId: '+folderId);
                console.log('###prefixURL: '+prefixURL);
                
				picker = new google.picker.PickerBuilder()
                    .addView( new google.picker.DocsUploadView().setParent( folderId ) )
                    //.addView( google.picker.ViewId.DOCS )
                    .setOAuthToken( accessToken )
                    .setCallback( this.pickerCallback )
                    .build();
                component.set("v.picker", picker);
			}
		});  
        $A.enqueueAction(action);
    },
    pickerCallback: function (data){
        console.log('###data: '+data);
		if( data[google.picker.Response.ACTION] === google.picker.Action.PICKED ) {
			var downloadUrl;
			
            //Document.NAME, Document.TYPE
            //
            //debugger;
            //var doc = data[google.picker.Response.DOCUMENTS];
			if( data.viewToken[0] === "upload" ) {
				downloadUrl = data[google.picker.Response.DOCUMENTS][0].downloadUrl;  
			}
			else {
				downloadUrl = data[google.picker.Response.DOCUMENTS][0].url;
			}
            //debugger;
            var documentId = data[google.picker.Response.DOCUMENTS][0].id;
            var doc = data[google.picker.Response.DOCUMENTS][0];
			var fileName = doc[google.picker.Document.NAME];
            console.log('###fileName: '+fileName);
            /*var fileName;
            fileName = data[google.picker.Response.DOCUMENTS][0].NAME;
            var addFile = component.get("c.addToDocuments");
            addFile.setParams({
                "recordId" : component.get("v.recordId"),
                "ojectType": component.get("v.sObjectType"),
                "fileName":fileName,
                "fileUrl":downloadUrl
            });
            addFile.setCallback(this, function(a) {
                component.set("v.addFileResult", a.getReturnValue());
            });
            $A.enqueueAction(addFile);
            */
            document.getElementById("fileName").innerHTML = fileName;
			var a = document.getElementById("resultUrl");
            var prefixURL = document.getElementById("prefixURL").innerHTML;
			
            a.innerHTML = prefixURL + documentId;
            //a.innerHTML = 'https://drive.google.com/file/d/' + documentId;
            //a.href= 'https://drive.google.com/file/d/' + documentId;
			a.click();
		}
	},
    
})