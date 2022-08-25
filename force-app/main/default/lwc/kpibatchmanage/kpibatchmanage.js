import { LightningElement,track,wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';  
import  runBatchJob  from '@salesforce/apex/KPIBatchController.runBatchJob';
import  getJobs  from '@salesforce/apex/KPIBatchController.getJobs';
import getKPISetting from '@salesforce/apex/KPIBatchController.getKPISetting';
import updateKPISetting from '@salesforce/apex/KPIBatchController.updateKPISetting';

import PERIOD_FIELD from '@salesforce/schema/KPI__c.Period__c'; 
import QUARTER_FIELD from '@salesforce/schema/KPI_Target__c.Quarter__c'; 

const BATCHCOLUMS = [
    {
        label: 'Batch Name',
        type: "text",
        sortable:"false",
        fieldName: "batchName"        
    },
    {
        label: 'Status',
        type: "text",
        sortable:"false",
        fieldName: "status"        
    },
    { label: 'Submit Date', 
            fieldName: 'submittedDate',
            type: 'date',
            typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true},
            cellAttributes: {class: {fieldName: 'format'}}, 
            hideDefaultActions: 'true'
    },
    { label: 'Submit By', 
            fieldName: 'submittedBy',
            type: 'text'            
    },
    { label: 'Completed Date', 
            fieldName: 'completionDate',
            type: 'date',
            typeAttributes:{day:'numeric',month:'short',year:'numeric',hour:'2-digit',minute:'2-digit',second:'2-digit',hour12:true},
            cellAttributes: {class: {fieldName: 'format'}}, 
            hideDefaultActions: 'true'
    }, {
        label: 'Refresh',
        type: "button",
        fieldName: "jobId",
        initialWidth: 100,
        typeAttributes: { label: 'Refresh', name: "refreshBatch", variant: "Neutral" }
    },
]

const kpiSettingName = 'ccKPISetting';

export default class Kpibatchmanage extends LightningElement {    
    batchDatas=[];    
    kpiSetting={};  
    isAllowSentEmailtoSale;
    isAllowSentEmailtoMng;
    isDisable = true;
    periodClass = 'slds-show';
    quarterClass = 'slds-hide';
    selectedBatch;
    selectedBatchLabel;
    selectedPeriod;
    selectedPeriodLabel;   

    selectedQuarter;
    selectedQuarterLabel;  

    selectedParam;

    isSpinner = false;
    displayMsg;
    batchColums = BATCHCOLUMS; 
    periodOptions = [];
    quarterOptions = [];
    batchOptions = [
        {
            value: 'runKPICalculation',
            label: 'Batch Calculation Sale/Suport KPI'
        },
        {
            value: 'runKPIMngCalculation',
            label: 'Batch Calculation Manager KPI'
        },
        {
            value: 'runApplySaleTarget',
            label: 'Batch for Apply sale/Support Target'
        },
        {
            value: 'runRollOverSaleTarget',
            label: 'Batch for Roll-Over sale/Support and Manager Target'
        }
    ];

    @wire(getPicklistValues, { recordTypeId: '0120o000001JdorAAC', fieldApiName: PERIOD_FIELD })
    wiredPeriodPickListValue({ data, error }){
        if(data){
            console.log(' Picklist values are ', data.values);
            this.periodOptions = data.values;           
        }
        if(error){
            console.log(' Error while fetching Picklist values  ${error}');            
            this.pickListvalues = undefined;
        }
    }

    @wire(getPicklistValues, { recordTypeId: '0120o000001JdmvAAC', fieldApiName: QUARTER_FIELD })
    wiredQuarterPickListValue({ data, error }){
        if(data){
            console.log(' Picklist values are ', data.values);
            this.quarterOptions = data.values;           
        }
        if(error){
            console.log(' Error while fetching Picklist values  ${error}');            
            this.quarterOptions = undefined;
        }
    }

    @wire(getKPISetting, {setingName: kpiSettingName})
    wiredSettingData({ data, error }){
        if(data){
            console.log(' Custom Setting ', data);
            this.kpiSetting = data;       
            this.isAllowSentEmailtoSale =  this.kpiSetting.SendEmailToSale__c; 
            this.isAllowSentEmailtoMng =  this.kpiSetting.SendEmailToManager__c; 
        }
        if(error){
            console.log(' Custom Setting eror ' + JSON.stringify(error));            
            this.kpiSetting = undefined;
        }
    }
    


    handleOnchangeBatchtype(event){
        this.selectedBatch = event.detail.value;
        if(this.selectedBatch === 'runRollOverSaleTarget'){
            this.periodClass = 'slds-hide';
            this.quarterClass = 'slds-show';
        }else{
            this.periodClass = 'slds-show';
            this.quarterClass = 'slds-hide';
        }
        this.selectedBatchLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    handleOnchangePeriod(event){
        this.selectedPeriod = event.detail.value;
        this.selectedPeriodLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        this.selectedParam = event.detail.value;
    }

    handleOnchangeQuarter(event){
        this.selectedQuarter = event.detail.value;
        this.selectedParam = event.detail.value;
        this.selectedQuarterLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
    }

    handleRunBatchJob(event){
        this.isSpinner = true;
        console.log('this.selectedBatch' + this.selectedBatch + ' this.selectedParam ' + this.selectedParam);
        if(this.selectedParam && this.selectedBatch){
            runBatchJob({jobName : this.selectedBatch, periodorQuater: this.selectedParam})
            .then(result=>{
                if(result){
                    this.isSpinner = false;
                    console.log('result' + result);
                    this.batchDatas = result;

                    this.dispatchEvent(  
                        new ShowToastEvent({  
                            title: 'Success',  
                            variant: 'success',  
                            message: 'You have run ' + this.selectedBatchLabel + ' for period ' + this.selectedPeriodLabel + ' Successfully!',  
                            mode: 'sticky'
                        }),  
                    );

                }
            })
            .catch(error=>{    
                this.isSpinner = false;          
                console.log('error=>' + error);      
                this.dispatchEvent(  
                    new ShowToastEvent({  
                        title: 'Error',  
                        variant: 'error',  
                        message: 'You have failed to run ' + this.selectedBatchLabel + ' for period ' + this.selectedPeriodLabel,  
                        mode: 'sticky'
                    }),  
                );       
            });
        }
    }

    handleRowAction(event){
        // console.log('name=>' + event.detail.action.name);
        if(event.detail.action.name === 'refreshBatch'){
            var listjobid = [];
            for(var i= 0 ;i < this.batchDatas.length ; i++){                
                listjobid.push(this.batchDatas[i].jobId);
            }
            console.log(listjobid);
            if(listjobid.length > 0){
                this.isSpinner = true;
                getJobs({ jobIds : listjobid})
                .then(result => {
                    if(result){
                        this.isSpinner = false;
                        // console.log('result' + result);
                        this.batchDatas = result;
                    }
                })
                .catch(error=>{    
                    this.isSpinner = false;          
                    console.log('error=>' + error);
                })
            }            
        }
    }


    handleOnchangeSendEmailtoSale(event){      
        this.isAllowSentEmailtoSale = event.target.checked;
        this.isDisable = false;
        console.log( 'isAllowSentEmailtoSale =>' + this.isAllowSentEmailtoSale);
    }

    handleOnchangeSendEmailtoMng(event){
        this.isAllowSentEmailtoMng = event.target.checked;
        this.isDisable = false;
        console.log( 'this.isAllowSentEmailtoMng =>' + this.isAllowSentEmailtoMng);
    }   

    handleUpdateSetting(event){
        this.isSpinner = true;        
        updateKPISetting({setingName : kpiSettingName, isAllowEmailToSale: this.isAllowSentEmailtoSale, isAllowEmailToMng:this.isAllowSentEmailtoMng})
        .then(result=>{
            if(result){
                this.isSpinner = false;
                console.log('result' + result);
                this.kpiSetting = result;
                
                this.dispatchEvent(  
                    new ShowToastEvent({  
                        title: 'Success',  
                        variant: 'success',  
                        message: 'Updated KPI Custom Setting Successfully!',                          
                    }),  
                );
            }
        })
        .catch(error=>{    
            this.isSpinner = false;          
            console.log('error=>' + JSON.stringify(error));      
            this.dispatchEvent(  
                new ShowToastEvent({  
                    title: 'Error',  
                    variant: 'error',  
                    message: 'Failed to Update KPI Custom Setting',  
                    mode: 'sticky'
                }),  
            );       
        }) 
    }
}