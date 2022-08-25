import { api, LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Balancesummary extends NavigationMixin(LightningElement) {
    @api summary


    handleOpenQCAccount(event){
        let qcid = event.currentTarget.dataset.qcid;

        this[NavigationMixin.GenerateUrl]({
            type: "standard__recordPage",
            attributes: {
                objectApiName: 'QC_Account__c',
                recordId: qcid,
                actionName: "view"
            }
        }).then((url) => {
            window.open(url, "_blank");
        });
    }
}