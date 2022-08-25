({
    //Note: Import Static Resource for google api
    //Use API Version 39, that not enable Locker service yet: https://success.salesforce.com/answers?id=9063A000000E6juQAC
    onApiLoad: function(component, event, helper) {
        gapi.load( "picker", { "callback" : helper.createPicker(component, helper) } );
    },    	
	uploadFiles: function(component,event, helper){
        console.log('###Here ');
        helper.createPicker(component, helper);
        var picker = component.get("v.picker");
        console.log('###Here picker: '+ picker);
		picker.setVisible( true );
        component.set("v.addFileResult", null);
	},
    saveDocument:function(component, event){
        var downloadUrl = document.getElementById( "resultUrl" ).innerHTML;
        var fileName = document.getElementById( "fileName" ).innerHTML;
        var recordIdCurrent = document.getElementById("recordIdCurrent").innerHTML;
        var sObjectTypeCurrent = document.getElementById("sObjectTypeCurrent").innerHTML;
        console.log('###Here current Id, Object Type ');
        console.log('###recordIdCurrent: '+recordIdCurrent);
        console.log('###sObjectTypeCurrent: '+sObjectTypeCurrent);
        var addFile = component.get("c.addToDocuments");
        addFile.setParams({
            "recordId" : recordIdCurrent,
            "ojectType": sObjectTypeCurrent,
            "fileName":fileName,
            "fileUrl":downloadUrl
        });
        addFile.setCallback(this, function(response) {
            
            component.set("v.addFileResult", response.getReturnValue());
            var toastEvent = $A.get("e.force:showToast");
            var state = response.getState();
            if(state === "SUCCESS"){
               toastEvent.setParams({
                    "title": "Success!",
                   	"type":"success",
                    "message": "File has been added successfully."
                }); 
                $A.get('e.force:refreshView').fire();
                //location.reload();
            }else{
                toastEvent.setParams({
                    "title": "Error!",
                    "type":"error",
                    "message": response.getReturnValue()
                }); 
            }
            
            toastEvent.fire();
            
        });
        $A.enqueueAction(addFile);
		//$A.get('e.force:refreshView').fire();
        //alert(resultMessage);
            
    },
    createFolderJS: function(component, event, helper){
        var createFolderAction = component.get("c.createFolder");
            createFolderAction.setParams({
                "recordId" : component.get("v.recordId")
            });
            createFolderAction.setCallback(this, function(a) {
                console.log('###Folder response'+ a.getReturnValue());
                component.set("v.addFileResult", a.getReturnValue());
            });
            $A.enqueueAction(createFolderAction);
    }
})