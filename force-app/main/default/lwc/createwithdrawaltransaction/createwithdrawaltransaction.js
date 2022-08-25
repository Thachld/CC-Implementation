import { api, LightningElement, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import createWithdrawalRequest from '@salesforce/apex/WithdrawalTransactionController.createWithdrawalRequest';

export default class Createwithdrawaltransaction extends NavigationMixin(LightningElement) {
    @api recordId;
    @api withdraw;    

    isShowbalanceisnotEnoughMsg = false;
    balanceisnotEnoughMsg

    isShowTransferSameClientMsg = false;
    transferSameClientMsg;

    isSpinner = false;
    iscreatetransfer = true;
    allowCreateTransfer = false;
    
    withdrawalPaymentData = {        
        'pyid': '',
        'transid': '',
        'balance': '',
        'type': '',
        'amount': 0,
        'note': '',
        'name': '',
        'notAllowTransfer' : false,
        'iscreatetransfer': false,
        'transfertouserid': '',
        'transfername': 'Auto Transfer',
        'refundtype' : ''
    };

    wdrequest = {
        'recordtypeid' : '',       
        'qcaccountid' : '',          
        'assignee' : '',
        'approver' : '',       
        'withdrawalfromqc' : 'Yes',
        'allowcreate':true
        };

    renderedCallback() {
        console.log('withdraw' + JSON.stringify(this.withdraw))

        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.fieldName === 'QC_Account__c'){
                    field.value =  this.withdraw.qcId ; //this.withdraw.qcId;
                }else if(field.fieldName === 'Withdrawal_From_TransId__c'){
                    field.value = this.withdraw.transId;
                }else if(field.fieldName === 'Type__c'){
                    if(this.withdraw.type === 'COUPON'){
                        field.value = 'WITHDRAWAL_COUPON';
                    }else if(this.withdraw.type === 'INCOME'){
                        field.value  = 'WITHDRAWAL_INCOME';
                    }                    
                }else if(field.fieldName === 'Withdrawal_Current_Balance__c'){
                    field.value = this.withdraw.balance;
                }else if(field.fieldName === 'Allow_Create__c'){
                    field.value = true;
                }else if(field.fieldName === 'Withdrawal_from_QC__c'){
                    field.value = 'Yes';    
                }      
            });
        }

        this.withdrawalPaymentData.pyid = this.withdraw.paymentId;
        this.withdrawalPaymentData.transid = this.withdraw.transId;
        this.withdrawalPaymentData.balance = this.withdraw.balance;
        this.withdrawalPaymentData.type = this.withdraw.type;        
    }
    
    handleSubmit( event ) {

        event.preventDefault();        
        let valid = true;
        this.isSpinner = true;
        let fields = event.detail.fields;        
        fields.Allow_Create__c = true;        
        fields.Withdrawal_Payment__c = this.withdraw.paymentId;
        
        var isValid = this.formValidate();
        if(isValid){
            this.wdrequest.recordtypeid = '0120o000001jwryAAA';
            this.wdrequest.qcaccountid = fields.QC_Account__c;     
            
            this.wdrequest.assignee = fields.Assignee__c;  
            this.wdrequest.approver = fields.Approver__c;  
            this.allowcreate = fields.Allow_Create__c;
                     
            this.withdrawalPaymentData.refundtype = fields.Refund_Type__c;
            this.withdrawalPaymentData.amount = fields.Amount__c;   
            this.withdrawalPaymentData.name = fields.Name;   
            this.withdrawalPaymentData.note = fields.Note__c;   
            this.withdrawalPaymentData.note = fields.Note__c;   
            this.withdrawalPaymentData.transfertouserid = fields.Transfer_to__c;
            this.withdrawalPaymentData.iscreatetransfer = this.iscreatetransfer;

            let withdrawalPaymentDatas = new Array();
            withdrawalPaymentDatas.push(this.withdrawalPaymentData);

            if(withdrawalPaymentDatas != null && withdrawalPaymentDatas != undefined
                && this.wdrequest != null && this.wdrequest != undefined){
                    this.isShowError = false;
                    this.errorMsg = '';  
                    this.createWithdrawalRQ(this.wdrequest, withdrawalPaymentDatas);
            }else{
                this.isShowError = true;
                this.errorMsg = 'Something wrong here!';  
            }
            // this.template.querySelector( 'lightning-record-edit-form' ).submit( fields );
        }else{
            this.isSpinner = false;
        }        
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

    handleChangeRefundType(event){
        let refundType = event.target.value;        
        if(refundType === 'Refund for Transfer'){
            this.allowCreateTransfer = true;    
            this.iscreatetransfer = true;    
        }else{
            this.allowCreateTransfer = false;
            this.iscreatetransfer = false;            
        }
    }

    handleCheckedCreateTransferPayment(event){
        let checked = event.target.checked;
        this.iscreatetransfer = checked;        
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

    formValidate(){
        let isValid = true;

        this.template.querySelectorAll('lightning-input-field').forEach(element => {            
          
            var inpVal;
            switch (element.fieldName) {  
                case 'Amount__c':
                    inpVal = element.value <= this.withdraw.balance ? true : false;
                    if (!inpVal) { 
                        this.isShowbalanceisnotEnoughMsg = true;
                        this.balanceisnotEnoughMsg = 'Request withdrawal amount should be less than current balance';  

                        element.classList.add("slds-has-error");
                    }else{
                        this.isShowbalanceisnotEnoughMsg = false;
                        this.balanceisnotEnoughMsg = '';  
                        element.classList.remove("slds-has-error");
                    }
                    break;

                case 'Transfer_to__c':
                    inpVal = element.value === this.withdraw.qcId ? false : true;
                    if (!inpVal) { 
                        this.isShowTransferSameClientMsg = true;
                        this.transferSameClientMsg = 'You cannot transfer to same qc account';  

                        element.classList.add("slds-has-error");
                    }else{
                        this.isShowTransferSameClientMsg = false;
                        this.transferSameClientMsg = '';  
                        element.classList.remove("slds-has-error");
                    }
                    
                    break;
                default:
                    inpVal = true;
                    break;
            }
            
            if(!inpVal){
                isValid = false;
            }

        });

        return isValid;
    }

    createWithdrawalRQ(wdrequest, withdrawalPaymentDatas){
        createWithdrawalRequest({withrawalrequest : wdrequest,  wdPayments : withdrawalPaymentDatas})
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
                            url : 'https://coccoc.lightning.force.com/' + result[0].Id,
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


    get showTransferto(){
        if(this.iscreatetransfer === true && this.allowCreateTransfer === true){
            return false;
        }else{
            return true;
        }
    }
}