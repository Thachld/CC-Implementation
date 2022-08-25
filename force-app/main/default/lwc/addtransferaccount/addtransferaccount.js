import { api, LightningElement, track, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import getQCAccounts from '@salesforce/apex/TransferRequestController.getQCAccounts';
import addTransferAccounts from '@salesforce/apex/TransferRequestController.addTransferAccounts';
import getQCAccountByRequest from '@salesforce/apex/TransferRequestController.getQCAccountByRequest'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const DELAY = 150;

export default class Addtransferaccount extends LightningElement {
    @api recordId;
    gridData = [];
    gridAllData = [];
    error;
    data;
    @track selectedAccounts = [];
    searchKey;
    sortBy = 'Name';
    sortDirection = 'asc';
    searchTerm = '';
    selectedIds = [];
    limitRecord =  20;

    
    columns = [
        { label: 'Selection', fieldName: 'isSelected', type: 'checkboxButton', 
            typeAttributes: { 
                checked : {fieldName: 'isSelected'},
                buttonDisabled: { fieldName: 'isDisabled' }, 
                rowId: { fieldName: 'Id' }, 
                label: { fieldName: 'Name' }, 
            }
        },
        { label: 'QC Account', fieldName: 'Name', iconName: 'utility:priority' , sortable : true},
        { label: 'Id', fieldName: 'QC_Account_Id__c', sortable : true},
        { label: 'Industry', fieldName: 'Industry__c', iconName: 'utility:tile_card_list', sortable : true },
        { label: 'Sale', fieldName: 'Sale_Email__c', iconName: 'utility:user',type: 'email',sortable : true },
        { label: 'Ads Op', fieldName: 'Support_Email__c', iconName: 'utility:user',type: 'email',sortable : true },
    ];


    @wire(getQCAccountByRequest, {requestId: '$recordId'})
    wiredQCAccountByRequest({data, error}){
        if(data){
            if(data.length > 0){
                let prdata = JSON.stringify(data);
                console.table('prdata=>' + prdata);  
                this.procesResult(data);
                console.table('this.gridData=>' + JSON.stringify(this.gridData));
            }
        }else if(error){
            console.error('error=>' + JSON.stringify(error) );
        }
    }

    handleSelectedRec(event){
        var value = event.detail.value;
        console.log('value=>' + JSON.stringify(value));
        this.selectedAccounts = value;
        this.setSelectIds();

        console.log('this.selectedAccounts =>' + JSON.stringify(this.selectedAccounts));   
    }
    
    handleRemoveSelectedItem(event){ 
        const recordId = event.currentTarget.name;
        this.selectedAccounts = this.selectedAccounts.filter((item) => item.Id !== recordId);

        this.setSelectIds();
        
        for(let i=0; i< this.gridData.length ; i++){ 
            if(this.gridData[i].Id == recordId){                
                this.gridData[i].isSelected = false;
            }
        }

        const selectacccmp = this.template.querySelector('c-accountselection');
        selectacccmp.removeSelectedRec(recordId);
        console.log('handleRemoveSelectedItem - this.gridData');   
        console.table(this.gridData);   

    }   

    handleKeyChange(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
        this.searchTerm = event.target.value;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
            getQCAccounts({ requestId: this.recordId, searchTerm: this.searchTerm, exceptIds: this.selectedIds }).then((result) => {
                let data = JSON.parse(JSON.stringify(result));                
                this.procesResult(data);
            }).catch((error) => {
                console.log(error);
                this.gridData = undefined;
            });
        }, DELAY);
    }

    setSelectIds(){ 
        var _selectIds = [];
        for(let i = 0 ; i< this.selectedAccounts.length ; i++){ 
            _selectIds.push(this.selectedAccounts[i].Id);
        }

        this.selectedIds = _selectIds;
    }

    procesResult(data){ 
        var grdata = [];
        var grAlldata = [];
        for(let i = 0 ; i < data.length ; i ++){
            if(i < this.limitRecord){
                grdata.push({
                    'isSelected' : false,
                    'Id' : data[i].Id,
                    'Name' : data[i].Name,
                    'QC_Account_Id__c' : data[i].QC_Account_Id__c,
                    'Industry__c' : data[i].Industry__c,
                    'Sale_Email__c' : data[i].Sale_Email__c,
                    'Support_Email__c' : data[i].Support_Email__c
                    }                        
                );
            }

            grAlldata.push({
                'isSelected' : false,
                'Id' : data[i].Id,
                'Name' : data[i].Name,
                'QC_Account_Id__c' : data[i].QC_Account_Id__c,
                'Industry__c' : data[i].Industry__c,
                'Sale_Email__c' : data[i].Sale_Email__c,
                'Support_Email__c' : data[i].Support_Email__c
                }                        
            );
        }


        this.gridAllData = grAlldata;
        this.gridData = grdata;
    }

    handleAddAccount(event){        

        console.log('this.selectedIds=>' + this.selectedIds);

        if(this.selectedIds.length > 0 ){
            addTransferAccounts({requestId:this.recordId, qcAccounts: this.selectedIds})
            .then(result=>{
                const evt = new ShowToastEvent({
                    title: 'Add QC Account to Transfer Request!',
                    message: 'QC Accounts was added to transfer request sucessfully ',
                    variant: 'success',
                });

                this.dispatchEvent(evt);
            })
            .catch(error=>{
                this.error = error;
                const evt = new ShowToastEvent({
                    title: 'Add QC Account to Transfer Request!',
                    message: 'Failed to add QC Account to Transfer request!',
                    variant: 'error',
                });
                this.dispatchEvent(evt);
            })
        }

        this.dispatchEvent(new CloseActionScreenEvent());
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

        let parseData = JSON.parse(JSON.stringify(this.gridData));
       
        let keyValue = (a) => {
            return a[fieldName];
        };


       let isReverse = direction === 'asc' ? 1: -1;


        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });
        
        this.gridData = parseData;       
    }

    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}