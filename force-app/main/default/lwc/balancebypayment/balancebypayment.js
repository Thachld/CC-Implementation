import { LightningElement,api, wire } from 'lwc';
import getBalancebyPayment  from '@salesforce/apex/BalanceServiceController.getBalancebyPayment';

export default class Balancebypayment extends LightningElement {
    @api recordId;
    balanceDatas = [];    
    isSpinner = false;    
    balanceDate;    
    showWithdraw = false;
    showSummary = false;

    handleOnchangeDate(event){
        let local = this.convertTZ(event.target.value, 'Asia/Jakarta');        
        this.balanceDate =  local;
    }

    handleGetBalanceService(event){
        this.isSpinner = true;      

        if(this.recordId){
            getBalancebyPayment({'paymentId': this.recordId, 'balanceTodate': this.balanceDate })
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