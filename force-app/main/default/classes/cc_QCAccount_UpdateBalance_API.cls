@RestResource(urlMapping='/paymentupdatebalancetosf')
global class cc_QCAccount_UpdateBalance_API {
	@HttpPost
    global static string updateAccountBalanceSystem(){
        QCAccountBalanceWrapper.Responds rp = new QCAccountBalanceWrapper.Responds();
       
        try{
            List<QCAccountBalanceWrapper> incomeQCAccountList = QCAccountBalanceWrapper.parse(RestContext.request.requestBody.tostring());
            Set<string> customerIdSet = new Set<string>();
            for( QCAccountBalanceWrapper item: incomeQCAccountList ){
                customerIdSet.add(item.Customer_id);
            }
             
             
             List<QC_Account__c> acAccountList = [select id, Status__c,Balance__c,QC_Account_Id__c  from QC_Account__c where QC_Account_Id__c =:customerIdSet];
             Map<string, QC_Account__c> existQCAccountMap = new Map<string, QC_Account__c>();
            for( integer i = 0; i< acAccountList.size();i++){
                if( !existQCAccountMap.containsKey(acAccountList.get(i).QC_Account_Id__c ) ){
                    existQCAccountMap.put(acAccountList.get(i).QC_Account_Id__c, acAccountList.get(i));
                }
            }
            Map<string,QC_Account__c> mapQCAccountUpdateTemp = new Map<string,QC_Account__c>(); 
            List<string> customerIdListTemp = new List<string>();
            for( integer i = 0; i< incomeQCAccountList.size();i++){
                if( existQCAccountMap.containsKey(incomeQCAccountList.get(i).Customer_id ) ){
                    QC_Account__c existQCAccount = existQCAccountMap.get(incomeQCAccountList.get(i).Customer_id);
                    existQCAccount.Status__c = incomeQCAccountList.get(i).Customer_status;
                    existQCAccount.Balance__c = incomeQCAccountList.get(i).Customer_balance;
                    mapQCAccountUpdateTemp.put(incomeQCAccountList.get(i).Customer_id, existQCAccount);
                    customerIdListTemp.add(incomeQCAccountList.get(i).Customer_id);
                }
                else{
                    QCAccountBalanceWrapper.QCAccountError error = new QCAccountBalanceWrapper.QCAccountError();
                    error.Customer_id = incomeQCAccountList.get(i).Customer_id;
                    error.Customer_balance = incomeQCAccountList.get(i).Customer_balance;
                    error.Customer_status =  incomeQCAccountList.get(i).Customer_status;
                    error.updateError = 'Can not find qc Account';
                    rp.qcAccountError.add(error);
                }  
            }
            Map<string,QC_Account__c> mapQCAccountUpdate = new Map<string,QC_Account__c>();
            if( mapQCAccountUpdateTemp.size() > 0){
                 customerIdListTemp.sort();
                 for(string item: customerIdListTemp){
                     mapQCAccountUpdate.put(item, mapQCAccountUpdateTemp.get(item));
                 }
                cc_static_Message.isUpdateBalance = true;
                 system.debug('debug#api' + cc_static_Message.isUpdateBalance);
                Database.UpsertResult[] qcAccountUpsertListResult = database.upsert(mapQCAccountUpdate.values(), false);
                for(integer i = 0; i < customerIdListTemp.size(); i++){
                    Database.UpsertResult sr = qcAccountUpsertListResult.get(i);
                    if(!sr.isSuccess()){
                        QC_Account__c qcAccountTemp = mapQCAccountUpdate.get(customerIdListTemp.get(i));
                        QCAccountBalanceWrapper.QCAccountError error = new QCAccountBalanceWrapper.QCAccountError();
                        error.Customer_id = qcAccountTemp.QC_Account_Id__c;
                        error.Customer_balance = (long) qcAccountTemp.Balance__c;
                        error.Customer_status =  qcAccountTemp.Status__c;
                        error.updateError += sr.getErrors();
                        rp.qcAccountError.add(error);
                    }
                }               
             }
            rp.totalqcAccount =incomeQCAccountList.size();
            rp.totalFail = rp.qcAccountError.size();
            rp.totalSuccess = rp.totalqcAccount - rp.totalFail;
            
            
         }catch(Exception ex){
             rp.error = ex.getMessage();
             return system.JSON.serialize(rp);
         }
		 
        return system.JSON.serialize(rp);
        
    }
}