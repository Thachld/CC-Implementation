import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import apexSearch  from '@salesforce/apex/BalanceServiceController.searchQCAccount';

export default class Listwithdrawalfrompayment extends NavigationMixin(LightningElement) {    

    result = [];
    errors = [];
    isMultiEntry = false;    

    @api 
    get withdrawaldatas(){
        return this.result;
    }

    set withdrawaldatas(value){
        let datas =[];
        let incomeRefundTypeOptions = [
            { label: 'Refund to Client', value: 'Refund to Client' },
            { label: 'Refund for Transfer', value: 'Refund for Transfer' },
            { label: 'Internal refund', value: 'Internal refund' }
        ];

        let couponRefundTypeOptions = [                 
            { label: 'Internal refund', value: 'Internal refund' }
        ];


        for (let i=0 ; i< value.length; i++){    
            let notAllowTransfer = true;

            let refundTypeOptions = []
            if(value[i].type === 'INCOME'){                
                refundTypeOptions = incomeRefundTypeOptions;
            }else{
                refundTypeOptions = couponRefundTypeOptions;
            }

            datas.push({
                'no': i+1,
                'pyid': value[i].paymentId,
                'transid': value[i].transId,
                'qcid': value[i].qcId,
                'balance': value[i].balance,
                'type': value[i].type,
                'amount': 0,
                'note': '',
                'name': '',
                'notAllowTransfer' : notAllowTransfer,
                'iscreatetransfer': false,
                'transfertouserid': '',
                'transfername': 'Auto Transfer',
                'refundtype':'',
                'retundTypeOption' : refundTypeOptions,
                'errors': []                
            });
        }

        this.result = datas;
    }

    @api validateInput(){
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input');
        inputFields.forEach(inputField => {
            if(!inputField.checkValidity()) {
                inputField.reportValidity();
                isValid = false;
            }
        });

        let areaFields = this.template.querySelectorAll('lightning-textarea');
        areaFields.forEach(areaField => {
            if(!areaField.checkValidity()) {
                areaField.reportValidity();
                isValid = false;
            }
        });


        let comboboxFields = this.template.querySelectorAll('lightning-combobox');
        comboboxFields.forEach(comboboxField => {
            if(!comboboxField.checkValidity()) {
                comboboxField.reportValidity();
                isValid = false;
            }
        });        

        let validLookup = this.validateCustomLookupField();

        return isValid&&validLookup;                
    }

    validateCustomLookupField(){
        let isValid = true;
        
        let lookups = this.template.querySelectorAll('c-lookup');
        if(lookups.length != null && lookups.length != undefined && lookups.length != 0){
            let duplicateValid = true;
            for(let i = 0 ; i < this.result.length ; i ++){
                if(this.result[i].qcid === this.result[i].transfertouserid){
                    duplicateValid = false;
                }

                let uniqueid = this.result[i].transid;
                let lookupfield = lookups[i].getLookupField(uniqueid);
                let lookupMisingvalid = true;
                if(!lookupfield.checkValidity()) {
                    lookupfield.reportValidity();
                    lookupMisingvalid = false;
                }

                isValid = lookupMisingvalid && duplicateValid;
            }
        }
        

        return isValid;
    }

    
    @api
    getWithdrawalPaymentData(){        
        return this.result;
    }    

    handleOpenPayment(event){
        let pyid = event.target.dataset.pyid;
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: pyid,
                objectApiName: 'Payment__c', 
                actionName: 'view'
            }
        }).then(url => {
            window.open(url);
        });
    }


    handleWithdrawalAmountChange(event){
        let withdrawalAmount = event.target.value;
        let transid = event.currentTarget.dataset.transid;

        let record = this.result.find(item=> item.transid === transid);
        record.amount = withdrawalAmount;

        this.result = [...this.result];

        let totalWithdrawalAmount = this.calculateTotalAmount();
        this.dispatchTotalAmountEvt(totalWithdrawalAmount);
    }

    handlePaymentNameChange(event){
        let paymentname = event.target.value;
        let transid = event.currentTarget.dataset.transid;

        let record = this.result.find(item=> item.transid === transid);
        record.name = paymentname;

        this.result = [...this.result];
    }    

    handleNoteChange(event){
        let notevalue = event.target.value;
        let transid = event.currentTarget.dataset.transid;

        let record = this.result.find(item=> item.transid === transid);
        record.note = notevalue;

        this.result = [...this.result];
    }

    handleChangeRefundType(event){
        let refundtype = event.target.value;
        let transid = event.currentTarget.dataset.transid;

        let record = this.result.find(item=> item.transid === transid);
        record.refundtype = refundtype;

        if(refundtype === 'Refund for Transfer'){
            record.notAllowTransfer = false;
            record.iscreatetransfer = true;
        }else{
            record.notAllowTransfer = true;
            record.iscreatetransfer = false;
        }

        this.result = [...this.result];
    }

    calculateTotalAmount(){
        let totalWithdrawalAmount = 0;
        for(let i=0; i< this.result.length; i++){
            let amount = parseFloat(this.result[i].amount);
            totalWithdrawalAmount += amount;
        }

        return totalWithdrawalAmount;
    }

    dispatchTotalAmountEvt(totalamount){
        const createRequestEvt = new CustomEvent('calculattotalamount', {detail : {'TotalAmount': totalamount}} );
        this.dispatchEvent(createRequestEvt);
    }

    
    handleLookupSearch(event) {
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup
        apexSearch(event.detail)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    handleCheckedCreateTransferPayment(event){
        let transid = event.currentTarget.dataset.transid;
        let checked = event.target.checked;

        let record = this.result.find(item=> item.transid === transid);
        record.iscreatetransfer = checked;

        this.result = [...this.result];
    }

    handleLookupSelectionChange(event) {
        let detail = event.detail;
        let selection = detail.selection;
        let uniqueid = detail.uniqueid;
        let record = this.result.find(item=> item.transid === uniqueid);

        if(selection !=null && selection != undefined && selection.length != 0){            
            record.transfertouserid = selection[0].id;

            if(selection[0].id === record.qcid){
                let errors = record.errors;
                let existsDuplicateErr = false;
                if(errors.length != 0 && errors.length != undefined){
                    for(let i = 0; i < errors.length; i ++){
                        if(errors[i].id === 'duplicate'){
                            existsDuplicateErr = true
                        }
                    }
                }

                if(!existsDuplicateErr){
                    record.errors.push({
                        'id':'duplicate',
                        'message': 'You cannot transfer to same qc account'
                    })
                }                
            }else{                
                if(record.errors.length != 0 && record.errors.length != undefined){
                    for(let i = 0; i < record.errors.length; i ++){
                        if(record.errors[i].id === 'duplicate'){
                            record.errors.splice(i,1);
                        }
                    }
                }
            }

        }else{
            record.transfertouserid = '';            
            if(record.errors.length != 0 && record.errors.length != undefined){
                for(let i = 0; i < record.errors.length; i ++){
                    if(record.errors[i].id === 'duplicate'){
                        record.errors.splice(i,1);
                    }
                }
            }
        }

        this.result = [...this.result];
    }    
}