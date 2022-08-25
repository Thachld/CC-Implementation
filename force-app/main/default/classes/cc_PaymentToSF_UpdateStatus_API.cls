@RestResource(urlMapping='/paymentupdatestatussf')
global class cc_PaymentToSF_UpdateStatus_API {
	@HttpPost
     global static string doPostStatusToSF(){
         PaymentToQCWrapper.Responds rp = new PaymentToQCWrapper.Responds();
         cc_setting__c setting = [select id, name, Qc_account_email__c,Hotline__c,is_write_api_log__c   from cc_setting__c];
         try{
             PaymentToQCWrapper incomePayment = PaymentToQCWrapper.parse(RestContext.request.requestBody.tostring());
             Payment__c payment = new Payment__c();
             
             List<Payment__c> paymentList = [select id, name from Payment__c where name =:incomePayment.Transaction_id];
             if( paymentList.size() > 0){
                 payment =  paymentList.get(0);
                 payment.Stage__c = incomePayment.Transaction_status;
                 if( payment.Stage__c == cc_static_Message.Payment_Done || payment.Stage__c == cc_static_Message.Payment_Fail ){
                     payment.State_temp__c = payment.Stage__c;
                 }
                 payment.Note__c = incomePayment.Note;
                 payment.Amount__c = incomePayment.Transaction_amount;
             }
             else{
                 rp.status = 'fail';
                 rp.message = 'Can not find payment';
                 if( setting.is_write_api_log__c){
                     cc_Util.writeLog('paymentupdatestatussf',rp.message, RestContext.request.requestBody.tostring());
                 }
                 return system.JSON.serialize(rp);
             }
			 upsert payment;
             rp.status = 'success';
             rp.message = '';
             return system.JSON.serialize(rp);
         }catch(Exception ex){
             rp.status = 'fail';
             rp.message = ex.getMessage();
             if( setting.is_write_api_log__c){
                 cc_Util.writeLog('paymentupdatestatussf',rp.message, RestContext.request.requestBody.tostring());
             }
             return system.JSON.serialize(rp);
         }
     }
}