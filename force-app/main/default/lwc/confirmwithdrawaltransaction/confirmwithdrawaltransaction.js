import { api, LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CloseActionScreenEvent } from 'lightning/actions';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';

import confirmPayment from '@salesforce/apex/WithdrawalTransactionController.confirmPayment';


export default class Confirmwithdrawaltransaction extends LightningElement {
    @api recordId;

    isSpinner = false;
    isShowError = false;
    errorMessage;

    handleConfirm(event){
        this.isSpinner = true;

        confirmPayment({'paymentId': this.recordId })
        .then((results) => {                
            var isSuccess = results;
            console.log(JSON.stringify(results));
            this.isSpinner = false;

            if(isSuccess == true){
                const evt = new ShowToastEvent({
                    title: 'Withdrawal Confirm!',
                    message: 'Withdraw transaction was confirmed!',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.closeQuickAction();

                getRecordNotifyChange([{recordId: this.recordId}]);
            }else{
                const evt = new ShowToastEvent({
                    title: 'Withdrawal Confirm!',
                    message: 'Withdraw transaction was failed confirmed!',
                    variant: 'error',
                });
                this.dispatchEvent(evt);  
                this.isShowError = true;    
            }
        })
        .catch((error) => {                
            console.error('Lookup error', JSON.stringify(error));    
            this.isSpinner = false; 
            
            if ( error.body.message){
                this.errorMessage =error.body.message;                
            }

            const evt = new ShowToastEvent({
                title: 'Withdrawal Confirm!',
                message: 'Withdraw transaction was failed confirmed!',
                variant: 'error',
            });
            this.dispatchEvent(evt);              
            this.isShowError = true;
        });
    }

    handleCancel(event){
        this.closeQuickAction();
        // this.dispatchEvent(new CloseActionScreenEvent());
    }

    closeQuickAction(){
        const closeQA = new CustomEvent('close');
        this.dispatchEvent(closeQA);
    }

    

}