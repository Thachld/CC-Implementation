@RestResource(urlMapping='/qcaccountrealcoupontosf')
global class cc_QCAccountRealCouponAPI {
	@HttpPost
    global static string updateRealCouponSystem(){
        QCAccountRealCouponWrapper.Responds rp = new QCAccountRealCouponWrapper.Responds();
        try{
        List<QCAccountRealCouponWrapper> incomeQCAccountList = QCAccountRealCouponWrapper.parse(RestContext.request.requestBody.tostring());
        Map<string,QCAccountRealCouponWrapper> qcAccountRealCouponIncomeMap = getIncomeWrapperMap(incomeQCAccountList);
        Set<string> customerIdSet = new Set<string>();
        Set<string> keyMappingSet = new Set<string>();
        
        for(QCAccountRealCouponWrapper item :incomeQCAccountList){
            customerIdSet.add(item.Customer_id);
            keyMappingSet.add(item.mappingKey);
        }

        List<QC_Account__c> acAccountList = [select id, Status__c,Balance__c,QC_Account_Id__c  from QC_Account__c where QC_Account_Id__c =:customerIdSet];
        Map<string, QC_Account__c> existQCAccountMap = new Map<string, QC_Account__c>();
        for( integer i = 0; i< acAccountList.size();i++){
            if( !existQCAccountMap.containsKey(acAccountList.get(i).QC_Account_Id__c ) ){
                existQCAccountMap.put(acAccountList.get(i).QC_Account_Id__c, acAccountList.get(i));
            }
        }
        Map<string, QCAccount_RealCoupon__c> qcAccountRealCouPonMap = getMapQCAccountRealCoupon(keyMappingSet);
        Map<string,QCAccount_RealCoupon__c> qcAccountUpdateTempMap = new Map<string,QCAccount_RealCoupon__c>(); 
        Map<string, QCAccount_RealCoupon__c> qcAccountUpdateMap = new Map<string,QCAccount_RealCoupon__c>();
        List<string> customerIdListTemp = new List<string>();
        for( integer i = 0; i< incomeQCAccountList.size();i++){
             if( existQCAccountMap.containsKey(incomeQCAccountList.get(i).Customer_id ) ){
                 QC_Account__c existQCAccount = existQCAccountMap.get(incomeQCAccountList.get(i).Customer_id);
                 QCAccount_RealCoupon__c temp = getQCAccountRealCoupon(incomeQCAccountList.get(i));
                 temp.QC_Account__c = existQCAccount.id;
                 if( qcAccountRealCouPonMap.containsKey(temp.mappingkey__c)){
                     temp.id = qcAccountRealCouPonMap.get(temp.mappingkey__c).id;
                 }
                 qcAccountUpdateTempMap.put(incomeQCAccountList.get(i).Customer_id, temp);
                 customerIdListTemp.add(incomeQCAccountList.get(i).Customer_id);
             }
            else{
                QCAccountRealCouponWrapper.QCAccountError error = new QCAccountRealCouponWrapper.QCAccountError();
                error.qcAccountError = incomeQCAccountList.get(i);
               
                error.insertError = 'Can not find qc Account';
                rp.qcAccountError.add(error);
            }
        }
        customerIdListTemp.sort();
        for(string item: customerIdListTemp){
            qcAccountUpdateMap.put(item, qcAccountUpdateTempMap.get(item));
        }
		 Database.UpsertResult[] qcAccountInsertListResult = database.upsert(qcAccountUpdateMap.values(), false);
            
            
        for(integer i = 0; i < customerIdListTemp.size(); i++){
            Database.UpsertResult sr = qcAccountInsertListResult.get(i);
            if(!sr.isSuccess()){
                //QCAccount_RealCoupon__c qcAccountTemp = qcAccountInsertMap.get(customerIdListTemp.get(i));
                QCAccountRealCouponWrapper.qcAccountError error = new QCAccountRealCouponWrapper.qcAccountError();
                error.qcAccountError = qcAccountRealCouponIncomeMap.get(customerIdListTemp.get(i));
                if( sr.isCreated())
                    error.insertError = '' + sr.getErrors();
                else{
                    error.updateError = '' + sr.getErrors();
                }
                
                rp.qcAccountError.add(error);				
            }
            }   
            rp.totalqcAccount =incomeQCAccountList.size();
            rp.totalFail = rp.qcAccountError.size();
            rp.totalSuccess = rp.totalqcAccount - rp.totalFail;  
            cc_setting__c setting = cc_Util.getCustomSetting();
            if(setting.is_write_api_log__c && rp.totalFail != null && rp.totalFail >0){
                cc_Util.writeLog('Real Coupon','Real Coupon error', system.JSON.serialize(rp));
            }
        }
        Catch(Exception ex){
             rp.error = ex.getMessage();
             return system.JSON.serialize(rp);
        }
        
        return system.JSON.serialize(rp);
    }
    public static  QCAccount_RealCoupon__c getQCAccountRealCoupon(QCAccountRealCouponWrapper item ){
        QCAccount_RealCoupon__c temp = new QCAccount_RealCoupon__c();
        temp.name = item.customer_id + ' ' + item.synDate;
        temp.mappingkey__c = item.customer_id + '_' + item.synDate;
        temp.Coupon_spending__c = item.coupon_spending;
        temp.Real_spending__c = item.real_spending;
        //temp.Real_balance__c = item.rel
        return temp;
    }
    public static Map<string, QCAccount_RealCoupon__c> getMapQCAccountRealCoupon(Set<string> keyMappingSet){
        List<QCAccount_RealCoupon__c> qcAccountRealCoupon = [select id,mappingkey__c from QCAccount_RealCoupon__c where mappingkey__c in:keyMappingSet  ];
        Map<string, QCAccount_RealCoupon__c> qcAccountRealCouPonMap = new Map<string, QCAccount_RealCoupon__c>();
        for(QCAccount_RealCoupon__c item: qcAccountRealCoupon){
            if( !qcAccountRealCouPonMap.containsKey(item.mappingkey__c)){
                qcAccountRealCouPonMap.put(item.mappingkey__c, item);
            }
        }
        return qcAccountRealCouPonMap;
    }
    public static Map<string,QCAccountRealCouponWrapper> getIncomeWrapperMap(List<QCAccountRealCouponWrapper> incomeQCAccountList){
        Map<string,QCAccountRealCouponWrapper> qcAccountRealCouponMap = new Map<string,QCAccountRealCouponWrapper>();
        for(QCAccountRealCouponWrapper item: incomeQCAccountList){
             if( !qcAccountRealCouponMap.containsKey(item.Customer_id)){
                     qcAccountRealCouponMap.put(item.Customer_id,item);
                 }
        }
        return qcAccountRealCouponMap;
    }
}