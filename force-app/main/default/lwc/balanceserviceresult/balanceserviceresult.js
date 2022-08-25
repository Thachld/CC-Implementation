import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

const COLUMS = [    
    {
        label: 'Transaction Id',
        type: "button",        
        fieldName: "transId",
        typeAttributes: { label: { fieldName: "transId" }, name: "gotoPayment", variant: "base" }
    },
    {   
        label: 'Topup date', 
        fieldName: 'timestamp',
        type: 'date',
        typeAttributes:{day:'2-digit',month:'2-digit',year:'numeric'},  
        cellAttributes: {class: {fieldName: 'format'}}, 
        hideDefaultActions: 'true'
    },
    {   
        label: 'Balance', 
        fieldName: 'balance',
        type: 'currency',
        cellAttributes: { alignment: 'left'}
    },
    {   
        label: 'Money Type', 
        fieldName: 'type',
        type: 'text'
    },
    {   
        label: 'Internal Type', 
        fieldName: 'internal_type',
        type: 'text'
    }   

]



export default class Balanceserviceresult extends NavigationMixin(LightningElement) {   
    @api showwithdraw;
    @api showsummary;
    @api maxrowselection = 1;   
    @api activesections; 

    sortBy = 'transId';
    sortDirection = 'desc';
    isModalOpen = false;
    isSingleTransaction = false;
    isMultipleTransaction = false;
    balanceColums = COLUMS;

    recordatas = [];
    withdrawaldata;
    withdrawaldatas;


    @api
    get balancedatas(){
        return this.recordatas;
    }
    
    set balancedatas(value){        

        this.recordatas = this.doSortData(this.sortBy, this.sortDirection, value);                
    }

    handleWithrawTransaction(event){   
        
        if(this.isSingleTransaction === true || this.isMultipleTransaction === true){
            this.isModalOpen = true;     
        }else{
            this.isModalOpen = false;     
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
        }
    }

    getSelectedRows(event){
        const rowselecteds = event.detail.selectedRows; 
        console.log('rowselected=>' + JSON.stringify(rowselecteds));

        if(rowselecteds != null && rowselecteds != undefined){
            if(rowselecteds.length === 1){
                this.withdrawaldata = rowselecteds[0];
                this.isSingleTransaction = true;
                this.isMultipleTransaction =false;
            }else{
                this.withdrawaldatas = rowselecteds;
                this.isSingleTransaction = false;
                this.isMultipleTransaction =true;
            }
        }  
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
        // serialize the data before calling sort function        
        let keyValue = (a) => {
            return a[fieldName];
        };
        let isReverse = direction === 'asc' ? 1: -1;

        
        var sortRecords = [];
        for(var i = 0; i < this.balancedatas.length ; i++){
           
            let summary = this.balancedatas[i].summary;
            let qcId = this.balancedatas[i].qcId;
            let userId = this.balancedatas[i].userId;
            let todt = this.balancedatas[i].todt;
            let userEmail = this.balancedatas[i].userEmail;

            let parseData;
            if(this.balancedatas[i].detail != null && this.balancedatas[i].detail != undefined && this.balancedatas[i].detail.length > 0){

                parseData = JSON.parse(JSON.stringify(this.balancedatas[i].detail));
                parseData.sort((x, y) => {
                    x = keyValue(x) ? keyValue(x) : ''; 
                    y = keyValue(y) ? keyValue(y) : '';
            
                    return isReverse * ((x > y) - (y > x));
                });

            }

            sortRecords.push({
                'detail': parseData,
                'summary': summary,
                'qcId': qcId,
                'userEmail': userEmail,
                'userId': userId,
                'todt': todt
            });
        }

        this.balancedatas = sortRecords;
    }

    doSortData(fieldName, direction, datas){

        let keyValue = (a) => {
            return a[fieldName];
        };

        let isReverse = direction === 'asc' ? 1: -1;
        
        var sortRecords = [];
        for(var i = 0; i < datas.length ; i++){
            
            let summary = datas[i].summary;
            let qcId = datas[i].qcId;
            let userid = datas[i].userid;
            let todt = datas[i].todt;
            let userEmail = datas[i].userEmail;

            let parseData;
            if(datas[i].detail != undefined && datas[i].detail != null && datas[i].detail.length > 0){   
                parseData = JSON.parse(JSON.stringify(datas[i].detail));

                parseData.sort((x, y) => {
                    x = keyValue(x) ? keyValue(x) : ''; 
                    y = keyValue(y) ? keyValue(y) : '';
               
                    return isReverse * ((x > y) - (y > x));
                });    
            }            
            
            sortRecords.push({
                'detail': parseData,
                'summary': summary,
                'qcId': qcId,
                'userEmail': userEmail,
                'userid': userid,
                'todt': todt
            });
        }

        
        return sortRecords;       
    }

    handleCloseModal(event){
        this.isModalOpen = false;
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

}