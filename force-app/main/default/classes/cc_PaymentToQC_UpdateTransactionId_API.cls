@RestResource(urlMapping='/paymentuptransactionidqctosf')
global class cc_PaymentToQC_UpdateTransactionId_API {
 	@HttpPost
     global static string doPostAccountFromQCSystem(){
         PaymentToQCWrapper.Responds rp = new PaymentToQCWrapper.Responds();
         cc_setting__c setting = [select id, name, Qc_account_email__c,Hotline__c,is_write_api_log__c   from cc_setting__c];
         try{
             PaymentToQCWrapper incomePayment = PaymentToQCWrapper.parse(RestContext.request.requestBody.tostring());
             Payment__c payment = new Payment__c();
             
             List<Payment__c> paymentList = [select id, name, recordType.Name from Payment__c where id =:incomePayment.Salesforce_id];
             if( paymentList.size() > 0){
                 payment =  paymentList.get(0);
                 payment.Name = incomePayment.Transaction_id;
                 if( payment.RecordType.Name == cc_static_Message.Payment_RecordType_Transfer || 
                   payment.RecordType.Name == cc_static_Message.Payment_RecordType_Refund || 
                   payment.RecordType.Name == cc_static_Message.Payment_RecordType_Advance ||
                   payment.RecordType.Name == cc_static_Message.Payment_RecordType_Normal
                   || payment.RecordType.Name == cc_static_Message.Payment_RecordType_Standard)
                 {
                    payment.State_temp__c = cc_static_Message.Payment_Done; 
                 }
                	 
                 update payment;
             }
             else{
                 
                 rp.status = 'fail';
                 rp.message = 'Can not find payment';
                 if( setting.is_write_api_log__c){
                     cc_Util.writeLog('paymentuptransactionidqctosf',rp.message,RestContext.request.requestBody.tostring() );
                 }
                 return system.JSON.serialize(rp);
             }
			 
             rp.status = 'success';
             rp.message = '';
             return system.JSON.serialize(rp);
         }catch(Exception ex){
             rp.status = 'fail';
             rp.message = ex.getMessage();
             if( setting.is_write_api_log__c){
                     cc_Util.writeLog('paymentuptransactionidqctosf',rp.message, RestContext.request.requestBody.tostring());
             }
             return system.JSON.serialize(rp);
         }
     }
}