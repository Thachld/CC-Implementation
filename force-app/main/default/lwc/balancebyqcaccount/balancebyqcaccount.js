import { LightningElement,api, wire } from 'lwc';
import getBalanceByQcAccount  from '@salesforce/apex/BalanceServiceController.getBalanceByQcAccount';

export default class Balancebyqcaccount extends LightningElement {
    @api recordId;
    balanceDatas = [];    
    isSpinner = false;    
    balanceDate;    
    showWithdraw = false;
    showSummary = true;

    handleOnchangeDate(event){
        let local = this.convertTZ(event.target.value, 'Asia/Jakarta');        
        this.balanceDate =  local;
    }

    handleGetBalanceService(event){
        this.isSpinner = true;
        let selectedQcIds = [];
        selectedQcIds.push(this.recordId);    

        if(selectedQcIds != null && selectedQcIds != undefined && selectedQcIds.length > 0){
            getBalanceByQcAccount({'qcIds': selectedQcIds, 'balanceTodate': this.balanceDate })
            .then((results) => {                
                this.balanceDatas = results;
                console.log(JSON.stringify(this.balanceDatas));
                this.isSpinner = false;
            })
            .catch((error) => {                
                console.error('Lookup error', JSON.stringify(error));    
                this.isSpinner = false;            
            });
        }        
    }    


    get defaultDattime(){
        var currdt = new Date(); 
        var balancedt = new Date(currdt.getFullYear(), currdt.getMonth() , currdt.getDate() , currdt.getHours() , currdt.getMinutes() , 0 , 0); 
        if(this.balanceDate !== null && this.balanceDate !== undefined){     
            balancedt = new Date(this.balanceDate);
            return balancedt.toISOString();
        }else{            
            this.balanceDate = balancedt;     
            return balancedt.toISOString();       
        }  
    }

    convertTZ(date, tzString) {
        return new Date((typeof date === "string" ? new Date(date) : date).toLocaleString("en-US", {timeZone: tzString}));   
    }
}