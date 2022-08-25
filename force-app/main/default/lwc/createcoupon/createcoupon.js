import { LightningElement, api, wire } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getCampaign from '@salesforce/apex/CreateCouponController.getCampaign';
import getQCAccount from '@salesforce/apex/CreateCouponController.getQCAccount';

const PROMOTION = 'PROMOTION';
const PROMOTION_WITH_CONDITION = 'PROMOTION_WITH_CONDITION';

export default class Createcoupon extends NavigationMixin(LightningElement) {
    @api recordId;  
    @api campaigndata;

    qcaccountdata;
    intervalSpendingDays;
    error;
    isSpinner = false;    
    conditionType;

    renderedCallback() {
        console.log('campaigndata' + JSON.stringify(this.campaigndata)) 
        this.assignFieldsValueByCampaign();
    }

    handleSubmit( event ) {
        event.preventDefault(); 
        this.isSpinner = true;
        let fields = event.detail.fields;        
        this.template.querySelector( 'lightning-record-edit-form' ).submit( fields );
    }

    handleSuccess(event){
        this.isSpinner = false;
        let couponid = event.detail.id;
        const evt = new ShowToastEvent({
            title: 'Coupon creation!',
            message: 'Coupon {0} was created sucessfully! See it here {1}! ',            
            messageData: [
                'Salesforce',
                {
                    url : 'https://coccoc.lightning.force.com/' + couponid,
                    label: 'here',
                },
            ],
            variant: 'success',
            mode:'sticky'
        });
        this.dispatchEvent(evt);
    	console.log('IN SUCCESS'); 
        
        this.closeQuickAction(couponid);  
    }
    handleError(event){
        
	    console.log('IN ERROR');
        console.log(JSON.stringify(event.detail));
        this.isSpinner = false;

        const evt = new ShowToastEvent({
            title: 'Coupon creation!',
            message: 'Coupon was failed to create!',
            variant: 'error',
        });
        this.dispatchEvent(evt);
        this.completedCreateRequest('error');
    }

    handleChangeCampaign(event){
        let campaignId = event.target.value;
        this.getCampaign(campaignId);
        this.assignFieldsValueByCampaign();
    }

    handleChangeQCAccount(event){
        let qcAccountId = event.target.value;
        this.getQCAccount(qcAccountId);    
        this.assignFieldsValueByCampaign();    
    }

    handleCancel(event){
        this.closeQuickAction(undefined);
    }


    getCampaign(campId){
        getCampaign({'campId' : campId})
        .then(result =>{
            if(result){
                this.campaigndata = result;
                this.error = undefined;               
            }
        })
        .catch(error=> {
            this.error = error;
            this.campaigndata = undefined;
        })
    }

    getQCAccount(qcAccountId){
        getQCAccount({'qcAccId' : qcAccountId})
        .then(result =>{
            if(result){
                this.qcaccountdata = result;
                this.error = undefined;
            }
        })
        .catch(error=> {
            this.error = error;
            this.qcaccountdata = undefined;
        })
    }


    assignFieldsValueByCampaign(){
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );

        if (inputFields && this.campaigndata !== null && this.campaigndata !== undefined) {            
            inputFields.forEach(field => {
                if(field.fieldName === 'SpendingExpirationDate__c'){
                    if(this.campaigndata.Interval_Spending_Days__c){
                        let currdate = new Date();
                        let dtvalue  =  new Date(currdate.getFullYear(), currdate.getMonth(),  currdate.getDate() + this.campaigndata.Interval_Spending_Days__c) ; 
                        field.value =  dtvalue.toISOString();
                    }                    
                }else if (field.fieldName === 'Interval_Spending_Days__c'){
                    field.value = this.campaigndata.Interval_Spending_Days__c;
                }else if (field.fieldName === 'ExpirationDate__c'){
                    if(this.campaigndata.CouponExpired__c){
                        let currdate = new Date();
                        let dtvalue = new Date(currdate.getFullYear(), currdate.getMonth(),  currdate.getDate() + this.campaigndata.CouponExpired__c) ; 
                        field.value =  dtvalue.toISOString();
                    }
                }
            });


            this.conditionType = this.campaigndata.Condition_Type__c;
        }
    }

    assignFieldValue(inputFields, fieldName, fieldValue){
        if (inputFields && (fieldName) && (fieldValue)) {
            inputFields.forEach(field => {
                if(field.fieldName === fieldName){
                    field.value = fieldValue;
                }
            });
        }
    }

    get isShowSpendingExpiredDate(){
        let isShow = false;
        
        if(this.campaigndata !== null  && this.campaigndata != undefined && this.qcaccountdata !== null && this.qcaccountdata != undefined){
            if(this.qcaccountdata.IsApplyTransactionType__c === false){
                isShow = true;                
            }
        }

        return isShow;
    }

    get isIntervalSpendingDays(){
        let isShow = false;
        
        if(this.campaigndata !== null  && this.campaigndata != undefined && this.qcaccountdata !== null && this.qcaccountdata != undefined){
            if(this.qcaccountdata.IsApplyTransactionType__c === true){
                if(this.campaigndata.Required_Interval_Spending_Days__c === true){
                    isShow = true;                
                }
            }
        }

        return isShow;
    }


    get isPromotionCondition(){
        let isShow = false;

        if(this.campaigndata !== null  && this.campaigndata != undefined && this.qcaccountdata !== null && this.qcaccountdata != undefined){
            if(this.qcaccountdata.IsApplyTransactionType__c === true){
                if(this.campaigndata.Internal_Type__c === PROMOTION_WITH_CONDITION){
                    isShow = true;
                }
            }
        }

        return isShow;
    }

    get isCreateFromCampaign(){
        if(this.recordId){
            return true;
        }else{
            return false;
        }        
    }

    closeQuickAction(newRecordId){
        const closeQA = new CustomEvent('close',{
                                            detail: {
                                                newrecordid: newRecordId
                                            }
                                        });
        this.dispatchEvent(closeQA);
    }
}