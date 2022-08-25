import { api, LightningElement, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createWithdrawalRequest from '@salesforce/apex/WithdrawalTransactionController.createWithdrawalRequest';

export default class Createwithdrawaltransactionmultiple extends NavigationMixin(LightningElement) {   
    @api withdraws;    
    
    wdrequest = {
        'recordtypeid' : '',       
        'qcaccountid' : '',         
        'assignee' : '',
        'approver' : '',       
        'withdrawalfromqc' : 'Yes',
        'allowcreate':true
        };
    
    withdrawalPaymentData = [];

    isShowError = false;
    errorMsg
    isShowbalanceisnotEnoughMsg = false;
    balanceisnotEnoughMsg
    isSpinner = false;
    totalWithdrawalAmount = 0;   

    renderedCallback() {        
        let withdraw = this.withdraws[0];
        console.log('withdraw' + JSON.stringify(withdraw));
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName === 'QC_Account__c'){
                    field.value = withdraw.qcId ; 
                }else if(field.fieldName === 'Withdrawal_from_QC__c'){
                    field.value = 'Yes'; 
                }else if(field.fieldName === 'Type__c'){                    
                    field.value  = 'WITHDRAWAL_INCOME';
                }                               
            });
        }       
    }
    
    handleSubmit( event ) {

        event.preventDefault(); 
        this.isSpinner = true;
        let fields = event.detail.fields;  
        
        let validateInput = false;
        
        validateInput = this.template.querySelector('c-listwithdrawalfrompayment').validateInput();       
        
        if(validateInput){            
            this.wdrequest.recordtypeid = '0120o000001jwryAAA';
            this.wdrequest.qcaccountid = fields.QC_Account__c; 
            this.wdrequest.assignee = fields.Assignee__c;  
            this.wdrequest.approver = fields.Approver__c;   

            this.withdrawalPaymentData = this.template.querySelector('c-listwithdrawalfrompayment').getWithdrawalPaymentData();

            if(this.withdrawalPaymentData != null && this.withdrawalPaymentData != undefined
                && this.wdrequest != null && this.wdrequest != undefined){
                    this.isShowError = false;
                    this.errorMsg = '';  
                    this.createWithdrawalRQ();

            }else{
                this.isShowError = true;
                this.errorMsg = 'Something wrong here!';  
            }
            // this.template.querySelector( 'lightning-record-edit-form' ).submit( fields );   
        }else{
            this.isSpinner = false;
        }  
                      
    }

    handleCalculateTotalAmount(event){
        let totalamount = event.detail.TotalAmount;
        console.log('totalamount=>' + JSON.stringify(totalamount));
        
        this.totalWithdrawalAmount = totalamount;
    }

    handleSuccess(event){
    	console.log('IN SUCCESS');       
    }    

    handleError(event){
        
	    console.log('IN ERROR');
        console.log(JSON.stringify(event.detail));

        const evt = new ShowToastEvent({
            title: 'Withdraw transaction creation!',
            message: 'Withdraw transaction was faled to create!',
            variant: 'error',
        });
        this.dispatchEvent(evt);

        this.completedCreateRequest('error');
    }

    closeModal(){
        this.doCloseModal();
    }

    handleCancel(){
        this.doCloseModal();
    }

    doCloseModal(){
        this.completedCreateRequest('success');
        const closeModalEvt = new CustomEvent('closewithdrawmodel');
        this.dispatchEvent(closeModalEvt);        
    }


    completedCreateRequest(state){
        const createRequestEvt = new CustomEvent('createdwithdrawal', {detail : {'state': state},bubbles : true, composed : true} );
        this.dispatchEvent(createRequestEvt);
    }

    createWithdrawalRQ(){
        createWithdrawalRequest({withrawalrequest : this.wdrequest,  wdPayments : this.withdrawalPaymentData})
        .then(result =>{
            if(result ){

                this.isSpinner = false;        
                this.doCloseModal();
                console.log('result=>' + JSON.stringify(result));
                const evt = new ShowToastEvent({
                    title: 'Withdraw transaction creation!',
                    message: 'Withdraw transaction {0} was created sucessfully! See it {1}! ',            
                    messageData: [
                        'Salesforce',
                        {
                            url : 'https://coccoc.lightning.force.com/lightning/o/Payment__c/list?filterName=Recent',
                            label: 'here',
                        },
                    ],
                    variant: 'success',
                    mode:'sticky'
                });
                this.dispatchEvent(evt);
            }
        })
        .catch(error=>{
            console.log('error=>' + JSON.stringify(error));

            this.isSpinner = false;        
            this.doCloseModal();
            const evt = new ShowToastEvent({
                title: 'Withdraw transaction creation!',
                message: 'Failed to Create Withdrawal Request',  
                variant: 'error',
            });
            this.dispatchEvent(evt);
        })
    }
}