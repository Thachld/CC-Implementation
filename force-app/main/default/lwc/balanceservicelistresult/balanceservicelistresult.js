import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

const COLUMS = [    
    {
        label: 'User Id',
        type: "button",        
        fieldName: "userId",
        typeAttributes: { label: { fieldName: "userId" }, name: "gotoQCAccount", variant: "base" },
        sortable: true
    },    
    {
        label: 'Transaction Id',
        type: "button",        
        fieldName: "transId",
        typeAttributes: { label: { fieldName: "transId" }, name: "gotoPayment", variant: "base" },
        sortable: true
    },
    {   
        label: 'Topup date', 
        fieldName: 'timestamp',
        type: 'date',
        typeAttributes:{day:'2-digit',month:'2-digit',year:'numeric'},
        cellAttributes: {class: {fieldName: 'format'}}, 
        hideDefaultActions: 'true',
        sortable: true
    },
    {   
        label: 'Balance', 
        fieldName: 'balance',
        type: 'currency',
        cellAttributes: { alignment: 'left'},
        sortable: true
    },
    {   
        label: 'Money Type', 
        fieldName: 'type',
        type: 'text',
        sortable: true
    }    
]



export default class Balanceservicelistresult extends NavigationMixin(LightningElement) {
    @api balancedatas;
    @api showwithdraw;
    @api showsummary;
    @api maxrowselection = 10;

    sortBy = 'userId';
    sortDirection = 'asc';
    isSingleModalOpen = false;
    isMultipleModalOpen = false;
    balanceColums = COLUMS;
    withdrawaldata;
    withdrawaldatas;
    isSingleWithdrawal;

    isShowBlankFromTrans = false;
    blankFromTransMsg;

    handleWithrawTransaction(event){ 

        if(this.isSingleWithdrawal){
            console.log('this.withdrawaldata=>' + JSON.stringify(this.withdrawaldata) );
            if(this.withdrawaldata.transId){
                this.isSingleModalOpen = true;
                this.isShowBlankFromTrans = false;
                this.blankFromTransMsg = '';
            }
        }else{
            if(this.withdrawaldatas != null && this.withdrawaldatas != undefined){ 
                this.isMultipleModalOpen = true;
                this.isShowBlankFromTrans = false;
                this.blankFromTransMsg = '';                
            }else{
                this.isShowBlankFromTrans = true;
                this.blankFromTransMsg = 'Please select transaction for withdrawal request!';
            }
        }
        
    }

    handleRedirectoQC(event){
        var qcId = event.currentTarget.dataset.id;
        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: 'QC_Account__c',
                recordId: qcId,
                actionName: "view"
            }
        }).then((url) => {
            window.open(url, "_blank");
        });
    }

    handleRowAction(event) {

        console.log('event.detail.action.name=>' + event.detail.action.name);
        console.log('event.detail.row.transId=>' + event.detail.row.transId);
        console.log(event.detail.row.paymentId);
        if(event.detail.action.name === 'gotoPayment'){
            this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    objectApiName: 'Payment__c',
                    recordId: event.detail.row.paymentId,
                    actionName: "view"
                }
            }).then((url) => {
                window.open(url, "_blank");
            });
        }else if(event.detail.action.name === 'gotoQCAccount'){
            this[NavigationMixin.GenerateUrl]({
                type: "standard__recordPage",
                attributes: {
                    objectApiName: 'QC_Account__c',
                    recordId: event.detail.row.qcId,
                    actionName: "view"
                }
            }).then((url) => {
                window.open(url, "_blank");
            });
        }
    }

    getSelectedRows(event){
        const rowselecteds = event.detail.selectedRows;

        console.log('rowselected=>' + JSON.stringify(rowselecteds));
        if(rowselecteds != null && rowselecteds != undefined){
            if(rowselecteds.length === 1){
                this.isSingleWithdrawal = true;
                this.withdrawaldata = rowselecteds[0];
            }else{
                this.withdrawaldatas = rowselecteds;
                this.isSingleWithdrawal = false;
            }
        }
        
        
        var selectedPaymentIds = [];
        for(let i = 0; i < rowselecteds.length; i ++){
            var row = rowselecteds[i];
            selectedPaymentIds.push(row.transId, row.paymentId);
        }
        console.log('selectedPaymentIds=>' + JSON.stringify(selectedPaymentIds));
    }

    handleCloseModal(event){
        this.isModalOpen = false;
    }

    handleSortdata(event) {
        // field name
        this.sortBy = event.detail.fieldName;

        // sort direction
        this.sortDirection = event.detail.sortDirection;

        // calling sortdata function to sort the data based on direction and selected field
        this.sortData(event.detail.fieldName, event.detail.sortDirection);
    }

    sortData(fieldName, direction) {

        let parseData = JSON.parse(JSON.stringify(this.balancedatas));
       
        let keyValue = (a) => {
            return a[fieldName];
        };


       let isReverse = direction === 'asc' ? 1: -1;

           parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.balancedatas = parseData;       
    }



    get isShowWithDraw(){        
        if(this.showwithdraw === true){            
            return true;
        }else{            
            return false;
        }

    }

    get isShowSummary(){
        if(this.showsummary === false){    
            return false;
        }else{                 
            return true;            
        }
    }

    get marginAroundSmall() {
        if(FORM_FACTOR === 'Large' || FORM_FACTOR === 'Medium'){
            return 'slds-m-around_small'
        }else{
            return ''
        }
    }

}