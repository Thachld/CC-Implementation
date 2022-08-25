public with sharing class PaymentPlatformEventHelper {

    /*************************************************************************
    * author: Thach LD
    * date: 14/10/2021 
    * Description: Publishing payment transaction to QC by Platform event
    *************************************************************************/

    public static void publishPaymentCreated(List<cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper> evntMsg){
        List<payment_created__e> evts = new List<payment_created__e>();
        for(cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper msg:  evntMsg){            
            payment_created__e evt = new payment_created__e();
            evt.SF_Id__c = msg.id;
            evt.Name__c = msg.name;           
            evt.Note__c = msg.note;
            evt.Final_Amount__c = msg.finalamount;
            evt.Payment_method__c = msg.paymentmethod;
            evt.QC_Email__c = msg.qcemail;
            evt.QC_Id__c = msg.qcid;
            evt.Stage__c = msg.stage;
            evt.Type__c = msg.type;
            evt.Type_Mapping_Id__c = msg.typemappingid;
            evt.Confirmed_By_Email__c = msg.confirmByEmail;

            Integer wdTransId;
            if( !String.isBlank(msg.withdrawaltransId)){
                if(msg.withdrawaltransId.isNumeric()){
                    wdTransId = Integer.valueOf(msg.withdrawaltransId);
                }else {
                    wdTransId = null;
                }                
            }else {
                wdTransId = null;
            }
            evt.Withdrawal_Transaction_Id__c = wdTransId ;

            evts.add(evt);
        }        

        if(evts.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(evts);            
        }

    }

    public static Map<String,PaymenToTransactionType__mdt> getTranstypeMapping(){
        Map<String,PaymenToTransactionType__mdt> mapResult = new Map<String,PaymenToTransactionType__mdt>();
        try {            
            for(PaymenToTransactionType__mdt maptrans : [SELECT DeveloperName, RecordTypeId__c, Internal_Type__c, Transaction_Type_Id__c,Payment_Record_Type__c, SF_TransId__c FROM PaymenToTransactionType__mdt ]){
                mapResult.put(maptrans.RecordTypeId__c, maptrans);
            }            
        } catch (Exception ex) {
            System.debug('getTranstypeMapping=>' + ex.getMessage());
        }

        return mapResult;
    }

    //Publish NormalPayment platform event
    public static void publishPaymentConfirmed(List<cc_PaymentStreaming_Wrapper.ConfirmedPayment> evntMsg){
        List<payment_confirmed__e> evts = new List<payment_confirmed__e>();
        for(cc_PaymentStreaming_Wrapper.ConfirmedPayment msg:  evntMsg){
            payment_confirmed__e evt = new payment_confirmed__e();
            evt.Id__c = msg.Id;
            evt.Name__c = msg.Name;           
            evt.Note__c = msg.Note;
            evt.Final_Amount__c = msg.Final_Amount;
            evt.Stage__c = msg.Stage;
            evts.add(evt);
        }        

        if(evts.size() > 0){
            List<Database.SaveResult> results = EventBus.publish(evts);  
        }

    }
}