import { LightningElement, wire, api } from 'lwc';
import { refreshApex} from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getKPItargetDetails from '@salesforce/apex/cc_ManualSyncKPITargetController.getKPItargetDetails';
import syncKpiTarget from '@salesforce/apex/cc_ManualSyncKPITargetController.syncKpiTarget';

const COLS = [
    {label: 'Trac Name', fieldName:'SaleName__c',type: 'text'},
    {label: 'KPI Category', fieldName:'KPI_Category__c',type: 'text'},
    {label: 'Period', fieldName:'Period__c',type: 'text'},
    {label: 'Last Sync Date', fieldName:'LastSyncDateTime__c',type: 'date', typeAttributes: {  
                                                                                            day: 'numeric',  
                                                                                            month: 'short',  
                                                                                            year: 'numeric',  
                                                                                            hour: '2-digit',  
                                                                                            minute: '2-digit',  
                                                                                            second: '2-digit',  
                                                                                            hour12: true
                                                                                    } },
    {label: 'Spending', fieldName:'SpendingKPI__c',type: 'currency'},
    {label: 'Payment', fieldName:'PaymentKPI__c',type: 'currency'}
]


export default class Cc_KPItargetSelectedLWC extends LightningElement {
    @api recordId;
    kpitargets;
    isModalOpen = false;
    isSpinnerLoad = false;
    cols = COLS;
    

    @wire(getKPItargetDetails, {kpitargetId:'$recordId' }) kpitargets;

    handleSyncKPITargets(){
        
        var selectedSyncRecords = this.template.querySelector('lightning-datatable').getSelectedRows();         

        if(selectedSyncRecords.length > 0){
            this.isModalOpen = true;            
        }else{
            this.showNotification('warning', 'No records has been selected!', 'Warning Message!');
        }
        
    }

    showNotification(variant, message, title){
        const evt = new ShowToastEvent({     
            title : title,       
            message: message,
            variant: variant,
            mode: 'sticky'
        });
        this.dispatchEvent(evt);
    }

    handleConfirm(){
        this.isModalOpen = false;        
        var selectedSyncRecords = this.template.querySelector('lightning-datatable').getSelectedRows();
        
        syncKpiTarget({syncRecords:selectedSyncRecords, recordId: this.recordId})
        .then(result=> {
            if(result){
                this.showNotification('success', 'Syncing KPI target Successfully!', 'Success Message!');
                this.template.querySelector('lightning-datatable').selectedRows=[];
                return refreshApex(this.kpitargets);                    
            }
                    
        })
        .catch(error=>{
            this.showNotification('error', 'Failed to Sync KPI target!', 'Failed Message!');
            alert('Syncing error occurs : ' + JSON.stringify(error));
           
        })   
        
    }

    closeModal(){
        this.isModalOpen = false;
    }
}