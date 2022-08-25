import { api,wire, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Accountselection extends NavigationMixin(LightningElement) {
    
    @api iconSoft;
    @api result = [];
    @api allresult = [];
    @api recordId;
   
    isSort = true;
    sortBy = '';
    sortDirection = '';
    selectecQcAccount = [];

    //title
    qcAccounTitle = 'QC Account';
    idTitle = 'Id';
    industryTitle = 'Industry';
    saleTitle = 'Sale';
    adsOpTitle = 'Ads Op';    

    @api removeSelectedRec(qcId){ 
        let queryItem = '[data-qcid="' + qcId + '"]';
        let checkboxe = this.template.querySelector(queryItem)
        checkboxe.checked = false;

        this.selectecQcAccount = this.selectecQcAccount.filter((item) => item.Id !== qcId);
    }

    handleSelectAll(event){
        
        var selected = event.target.checked;

        var selectacc = [];
        for(let i = 0 ; i< this.result.length ; i ++){ 
            selectacc.push({ 
                'Id': this.result[i].Id,
                'label': this.result[i].Name
            });
        }

        let checkboxes = this.template.querySelectorAll('[data-checkbox-button="checkbox-button"]')
        for(let i=0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }

        if(selected){
            this.selectecQcAccount = selectacc;
        }else{
            this.selectecQcAccount = [];
        }

        const custevent = CustomEvent('selectedrecs', {   
            detail: {
                value: this.selectecQcAccount 
            },
        });

        this.dispatchEvent(custevent);

        console.log('this.result=>' + JSON.stringify(this.result));

    }

    handleSelected(event){        
        var isSelected = event.target.checked;
        var qcId = event.currentTarget.dataset.qcid;
        var name = event.currentTarget.dataset.name;

        console.log('qcId=>' + qcId);
        console.log('name=>' + name);

        if(isSelected){ 
            this.selectecQcAccount.push({ 
                'Id': qcId,
                'label': name
            });
        }else{
            this.selectecQcAccount = this.selectecQcAccount.filter((item) => item.Id !== qcId);
        }    

        const custevent = CustomEvent('selectedrecs', {
            detail: {
                value : this.selectecQcAccount 
            },
        });

        this.dispatchEvent(custevent);

        console.log('this.result=>' + JSON.stringify(this.result));
    }

    handleOpenQCAccount(event){ 
        var qcId = event.currentTarget.dataset.qcid;
       
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: qcId,
                objectApiName: 'QC_Account__c', 
                actionName: 'view'
            }
        }).then(url => {
            window.open(url);
        });
        
    }

    handleSortbyQCAccount(event){
        this.sortData('Name');
    }
    handleSortbyId(event){
        this.sortData('QC_Account_Id__c');
    }
    handleSortbyIndustry(event){
        this.sortData('Industry__c');
    }
    handleSortbySale(event){
        this.sortData('Sale_Email__c');
    }
    handleSortbyAdsOp(event){
        this.sortData('Support_Email__c');
    }

    handleScroll(event) {
        let area = this.template.querySelector('.scrollArea');
        let threshold = 2 * event.target.clientHeight;
        let areaHeight = area.clientHeight;
        let scrollTop = event.target.scrollTop;        
        if(areaHeight - threshold < scrollTop) {             
            let sliceFurther = this.result.length + 20;
            if (sliceFurther > this.allresult.length) {
                sliceFurther = this.allresult.length;
            }
            let records = this.allresult.slice(0, sliceFurther);            
            this.result = records;
        }
    }


    sortData(fieldName) {              
        let parseData = JSON.parse(JSON.stringify(this.result));
       
        let keyValue = (a) => {
            return a[fieldName];
        };

       let isReverse = this.sortDirection === 'asc' ? 1: -1;


        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
           
            return isReverse * ((x > y) - (y > x));
        });


        if(isReverse === -1){
            this.iconSoft = "utility:arrowup";            
            this.sortDirection = 'asc';
        }else{
            this.iconSoft = "utility:arrowdown";            
            this.sortDirection = 'desc';
        }   
        
        this.sortBy = fieldName;
        this.result = parseData;       
    }
    

    get sortbyQCAccount(){
        if(this.sortBy === 'Name'){ 
            return true;
        }else{
            return false;
        }
    }
    get sortbyId(){
        if(this.sortBy === 'QC_Account_Id__c'){ 
            return true;
        }else{
            return false;
        }
    }
    get sortbyIndustry(){
        if(this.sortBy === 'Industry__c'){ 
            return true;
        }else{
            return false;
        }
    }
    get sortbySale(){
        if(this.sortBy === 'Sale_Email__c'){ 
            return true;
        }else{
            return false;
        }
    }
    get sortbyAdsOp(){
        if(this.sortBy === 'Support_Email__c'){ 
            return true;
        }else{
            return false;
        }
    }


    get checkall(){ 

        let selectall = false;
        if(this.selectecQcAccount.length < this.result.length){ 
            selectall = false;
        }else{
            selectall =true;
        }

        return selectall;
    }
}