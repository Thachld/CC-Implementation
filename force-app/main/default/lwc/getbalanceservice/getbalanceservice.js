import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import FORM_FACTOR from '@salesforce/client/formFactor';
/** Apex methods from SampleLookupController */
import apexSearch  from '@salesforce/apex/BalanceServiceController.searchQCAccount';
import getBalancesv  from '@salesforce/apex/BalanceServiceController.getBalance';
import getRecentlyViewed  from '@salesforce/apex/BalanceServiceController.getRecentlyViewed';
import getTranstype from '@salesforce/apex/BalanceServiceController.getTranstype';

const REFUND_TYPE = 'REFUND';

export default class Getbalanceservice extends LightningElement {   
    @api notifyViaAlerts = false;
    
    isMultiEntry = false;
    maxSelectionSize = 10;
    initialSelection = [
        {
            id: 'na',
            sObjectType: 'na',
            icon: 'standard:lightning_component',
            title: 'Inital selection',
            subtitle: 'Not a valid record',
            stringfield1: '123'
        }
    ];
    errors = [];
    recentlyViewed = [];
    newRecordOptions = [];    
    balanceDatas = [];
    balanceresults;
    balanceDatasOriginal = [];
    transTypeOptions = [];
    selectedTransType = [];
    selectedRecords = [];
    activesections = [];

    isNotSelectUserId = false;
    isSpinner = false;
    
    balanceDate;
    showWithdraw = true;
    showSummary = true;

    /**
     * Loads recently viewed records and set them as default lookpup search results (optional)
     */
    @wire(getTranstype)
    getTranstype({ data }) {
        if (data) {
            console.log('transtypeotions=>' + JSON.stringify(data));
            this.transTypeOptions = data;
        }
    }

    @wire(getRecentlyViewed)
    getRecentlyViewed({ data }) {
        if (data) {
            console.log('recentlyViewed=>' + JSON.stringify(data));
            this.recentlyViewed = data;
            
            this.initLookupDefaultResults();
        }
    }
 
    connectedCallback() {
        this.initLookupDefaultResults();
    }

    /**
     * Initializes the lookup default results with a list of recently viewed records (optional)
     */
    initLookupDefaultResults() {
        // Make sure that the lookup is present and if so, set its default results
        const lookup = this.template.querySelector('c-lookup');
        if (lookup) {
            lookup.setDefaultResults(this.recentlyViewed);
        }
    }
    
    /**
     * Handles the lookup search event.
     * Calls the server to perform the search and returns the resuls to the lookup.
     * @param {event} event `search` event emmitted by the lookup
     */
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

    /**
     * Handles the lookup selection change
     * @param {event} event `selectionchange` event emmitted by the lookup.
     * The event contains the list of selected ids.
     */
    // eslint-disable-next-line no-unused-vars
    handleLookupSelectionChange(event) {
        this.checkForErrors();
    }

    // All functions below are part of the sample app form (not required by the lookup).

    handleLookupTypeChange(event) {
        this.initialSelection = [];
        this.errors = [];
        this.isMultiEntry = event.target.checked;
    }

    handleMaxSelectionSizeChange(event) {
        this.maxSelectionSize = event.target.value;
    }

    handleSubmit() {
        this.checkForErrors();
        if (this.errors.length === 0) {
            this.notifyUser('Success', 'The form was submitted.', 'success');
        }
    }

    handleClear() {
        this.initialSelection = [];
        this.errors = [];
    }

    checkForErrors() {
        this.errors = [];
        const selection = this.template.querySelector('c-lookup').getSelection();
        // Custom validation rule
        if (this.isMultiEntry && selection.length > this.maxSelectionSize) {
            this.errors.push({ message: `You may only select up to ${this.maxSelectionSize} items.` });
        }
        // Enforcing required field
        if (selection.length === 0) {
            this.errors.push({ message: 'Please make a selection.' });
            this.balanceDatas = [];
            this.balanceDatasOriginal = [];
        }

        this.selectedRecords = selection;
        this.isNotSelectUserId = false;
    }

    notifyUser(title, message, variant) {
        if (this.notifyViaAlerts) {
            // Notify via alert
            // eslint-disable-next-line no-alert
            alert(`${title}\n${message}`);
        } else {
            // Notify via toast (only works in LEX)
            const toastEvent = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(toastEvent);
        }
    }

    handleCheckedTransType(event){
        this.selectedTransType = event.detail.value;
        console.log('selectedTransType=>' + this.selectedTransType);
        // if(this.selectedTransType.length > 0){
        //     let datas = this.balanceDatasOriginal;
        //     var datafiler = [];
        //     for(let i = 0; i< datas.length ; i++){
        //         if(this.selectedTransType.includes(datas[i].type)){
        //             datafiler.push(datas[i]);
        //         }
        //     }
        //     this.balanceDatas = datafiler;
        // }else{
        //     this.balanceDatas = this.balanceDatasOriginal;
        // }

        let origindata = this.balanceDatasOriginal;
        if(this.selectedTransType.length > 0){
            var filterRecords = [];
            for(var i = 0; i < origindata.length ; i++){
                var detail = origindata[i].detail;              
                
                let datafiler = [];
                if(detail != undefined && detail != null && detail.length > 0){                    
                    for(let j = 0; j < detail.length; j++){
                        if(this.selectedTransType.includes(detail[j].type)){
                            datafiler.push(detail[j]);
                        }                    
                    }
                }

                let summary = origindata[i].summary;
                let qcId = origindata[i].qcId;
                let userId = origindata[i].userId;
                let todt = origindata[i].todt;
                let userEmail = origindata[i].userEmail;

                filterRecords.push({
                    'detail': datafiler,
                    'summary': summary,
                    'qcId': qcId,
                    'userEmail': userEmail,
                    'userId': userId,
                    'todt': todt
                });
                
                
            }

            this.balanceresults = filterRecords;
        }else{
            this.balanceresults = origindata;
        }
    }

    handleOnchangeDate(event){
        let local = this.convertTZ(event.target.value, 'Asia/Jakarta');        
        this.balanceDate =  local;

    }

    handleCreatedWithdrawal(event){
        this.isSpinner = true;
        let selectedUserIds = [];

        for(let i = 0 ; i < this.selectedRecords.length ; i++){
            if(this.selectedRecords[i].stringfield1 != undefined){
                selectedUserIds.push(this.selectedRecords[i].stringfield1);
            }
        }

        this.balanceDate = new Date();
        if(selectedUserIds != null && selectedUserIds != undefined && selectedUserIds.length > 0){
            this.getBalance(selectedUserIds, this.balanceDate);            
        }
    }

    handleGetBalanceService(event){
        this.isSpinner = true;
        let selectedUserIds = [];

        for(let i = 0 ; i < this.selectedRecords.length ; i++){
            if(this.selectedRecords[i].stringfield1 != undefined){
                selectedUserIds.push(this.selectedRecords[i].stringfield1);
            }
        }

        if(selectedUserIds != null && selectedUserIds != undefined && selectedUserIds.length > 0){
            this.getBalance(selectedUserIds, this.balanceDate);            
        }else{
            this.isNotSelectUserId = true;
            this.isSpinner = false;   
        }
    } 

    getBalance(selectedUserIds, balanceDate){
        getBalancesv({'userIds': selectedUserIds, 'balanceTodate': balanceDate })
        .then((results) => {     
            console.log('Lookup results', JSON.stringify(results)); 
            var records = [];    
            var activeRecs = [];        
            for(var i = 0; i < results.length ; i++){
                var detail = results[i].detail;              
                if(detail != undefined && detail != null && detail.length > 0){   
                    for(let j = 0; j < detail.length; j++){
                        records.push(detail[j]);
                    }
                }

                activeRecs.push(results[i].qcId);
            }

            this.activesections = activeRecs;
            this.balanceresults = results;
            this.balanceDatas = records;
            this.balanceDatasOriginal = results;            
            console.log('this.balanceresults=>' + JSON.stringify(this.balanceresults));
            this.isSpinner = false;
        })
        .catch((error) => {                
            console.error('Lookup error', JSON.stringify(error));    
            this.isSpinner = false;            
        });
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


    get marginAround() {
        if(FORM_FACTOR === 'Large' || FORM_FACTOR === 'Medium'){
            return 'slds-m-around_medium'
        }else{
            return ''
        }
    }


    convertTZ(date, tzString) {
        return new Date((typeof date === "string" ? new Date(date) : date).toLocaleString("en-US", {timeZone: tzString}));   
    }
}