import { LightningElement, track,wire } from 'lwc';  
import { NavigationMixin } from 'lightning/navigation';
import saveRecord from '@salesforce/apex/WebToCaseController.saveCase';  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
const MAX_FILE_SIZE = 3000000;

import NAME_LABEL from '@salesforce/label/c.Name';
import EMAIL_LABEL from '@salesforce/label/c.Email';
import PHONE_LABEL from '@salesforce/label/c.Phone';
import SUBJECT_LABEL from '@salesforce/label/c.Case_Subject';
import DESCIPTION_LABEL from '@salesforce/label/c.Desciption';
import SUCCESS_LABEL from '@salesforce/label/c.Success_Create_Case_Msg';
import FAIL_LABEL from '@salesforce/label/c.Failed_Create_Case_Msg';
import FILESIZEEXCEE_LABEL from '@salesforce/label/c.File_Size_Exceed';
import SAVE_CASE_LABEL from '@salesforce/label/c.Save_Case';
import FILE_UPLOAD_LABEL from '@salesforce/label/c.File_Upload';
import BACK_TO_HOME_LABEL from '@salesforce/label/c.Back_to_Home';
import PHONE_PATTERN_LABEL from '@salesforce/label/c.Phone_Pattern';
import REQUIRED_CAPTCHA_LABEL from '@salesforce/label/c.Required_Captcha';
import REQUIRED_FIELD_MESSAGE_LABEL from '@salesforce/label/c.Required_field_Message';
import SUCCESS_CONTENT_LABEL from '@salesforce/label/c.Success_Content';
import TITLE_LABEL from '@salesforce/label/c.contact_form_title';

export default class Webtocaseform extends NavigationMixin(LightningElement) {
    
    name;
    phone;
    email;
    subject;
    description;
    uploadedFiles = []; 
    file; 
    fileContents; 
    fileReader; 
    content; 
    fileName;

    LABEL_NAME = NAME_LABEL;
    LABEL_PHONE = PHONE_LABEL;
    LABEL_EMAIL = EMAIL_LABEL;
    LABEL_SUBJECT = SUBJECT_LABEL;
    LABEL_DESCRIPTION = DESCIPTION_LABEL;    
    LABEL_SAVECASE = SAVE_CASE_LABEL;
    LABEL_FILE = FILE_UPLOAD_LABEL;   
    LABEL_SUCCESS = SUCCESS_LABEL;
    LABEL_BACK_TO_HOME = BACK_TO_HOME_LABEL;
    LABEL_PHONE_PATTERN = PHONE_PATTERN_LABEL;
    LABEL_REQUIRED_CAPTCHA = REQUIRED_CAPTCHA_LABEL;
    LABEL_REQUIRED_FIELD_MESSAGE = REQUIRED_FIELD_MESSAGE_LABEL;
    LABEL_SUCCESS_CONTENT = SUCCESS_CONTENT_LABEL;
    LABEL_TITLE = TITLE_LABEL;

    isUploadfile = false;
    verifiedBool = true;
    isValidField = true;
    isCreated = false;
    isSpinner = false;
    notvalidCaptcha;
    captchaResponse
    
    handleUpdate( event ) {       
        this.verifiedBool = event.detail.value;
        if ( event.detail.response ) {            
            this.captchaResponse = event.detail.response;
        }
    }
    
    onNameChange(event) {  
        this.name = event.detail.value;  
    }  
    onPhoneChange(event) {  
        this.phone = event.detail.value;  
    }  
    onEmailChange(event) {  
        this.email = event.detail.value;  
    }  
    onDescriptionChange(event) {  
        this.description = event.detail.value;  
    }  
    onSubjectChange(event) {  
        this.subject = event.detail.value;  
    }  

    onFileUpload(event) {  
        if (event.target.files.length > 0) {  
            this.uploadedFiles = event.target.files;  
            this.fileName = event.target.files[0].name; 
            this.isUploadfile = true; 
            this.file = this.uploadedFiles[0];  
            if (this.file.size > this.MAX_FILE_SIZE) {
                this.isUploadfile = false;   
                this.dispatchEvent(  
                    new ShowToastEvent({  
                        title: 'Error',  
                        variant: 'error',  
                        message: FILESIZEEXCEE_LABEL + ' ' + MAX_FILE_SIZE,  
                    }),  
                );
            }  
        }  
    }  

    // handleDeletefile(event){
    //     this.fileName = null;
    //     this.uploadedFiles = null;  
    //     this.file = null;  
    //     this.isUploadfile = false;
    // }

    validateAction(){
        let fieldErrorMsg = REQUIRED_FIELD_MESSAGE_LABEL;    
        this.template.querySelectorAll("lightning-input").forEach(item => {
            let fieldValue=item.value;
            let fieldLabel=item.label;   
            let fieldType=item.type;  
            if(!fieldValue && fieldType != 'file'){
                item.setCustomValidity(fieldErrorMsg+' '+fieldLabel);                
                this.isValidField = false;
            }else{                
                item.setCustomValidity("");
            }
            item.reportValidity();
		});
    }

    saveCase() {     
        this.validateAction();
        console.log('this.isValidField' + this.isValidField);
        console.log('this.verifiedBool' + this.verifiedBool);
        console.log('this.isUploadfile' + this.isUploadfile);
        if(this.isValidField){
            if(this.verifiedBool){
                this.notvalidCaptcha = true;
            }else{
                this.notvalidCaptcha = false;
                this.isSpinner = true;
                this.saveRecord();
                // if(this.isUploadfile){
                //     this.fileReader = new FileReader();  
                //     this.fileReader.onloadend = (() => {  
                //         this.fileContents = this.fileReader.result;  
                //         let base64 = 'base64,';  
                //         this.content = this.fileContents.indexOf(base64) + base64.length;  
                //         this.fileContents = this.fileContents.substring(this.content);   
                //         this.saveRecord();  
                //     });

                //     if(this.isUploadfile){
                //         this.fileReader.readAsDataURL(this.file);  
                //     } 
                // }else{
                //     this.saveRecord();  
                // }
            }
        }
          
               
      }  

    saveRecord() {  
        console.log('saveRecord');
        var newCase = {  
            'sobjectType': 'Case',  
            'SuppliedName': this.name,  
            'Full_Name__c': this.name,  
            'SuppliedEmail': this.email,  
            'SuppliedPhone': this.phone,  
            'Mobile__c': this.phone,  
            'Origin':'Web',
            'Status':'New',
            'Subject':this.subject,
            'Description': this.description  
        }  
        
        saveRecord({  
            newCs: newCase,  
            file: encodeURIComponent(this.fileContents),  
            fileName: this.fileName  
        })  
        .then(caseId => {  
            if (caseId) {  
                this.isCreated = true;
                this.isSpinner = false;
                console.log(caseId);
            }  
        }).catch(error => {  
            this.isSpinner = false;
            console.log(error);
            this.dispatchEvent(  
                new ShowToastEvent({  
                title: 'Error',  
                variant: 'error',  
                message: FAIL_LABEL,  
                }),  
            );  
        });  
    }   

    handleBackToHome(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'home'
            },
        });
    }
    
}