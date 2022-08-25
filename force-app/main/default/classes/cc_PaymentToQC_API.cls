/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 08-19-2022
 * @last modified by  : @Thach Le
**/
@RestResource(urlMapping='/paymentqctosf')
global class cc_PaymentToQC_API {
 @HttpPost
    global static string doPostPaymenttoSFSystem(){
        // List<Data_Sync_Monitor__e> monitorEvts = new List<Data_Sync_Monitor__e>();        
        PaymentToQCWrapper.Responds rp = new PaymentToQCWrapper.Responds();
        cc_setting__c setting = cc_setting__c.getInstance('cc setting');
        string userName = setting.payment_assignee__c; //'thuyntm@coccoc.com';
        system.debug('debug#' + RestContext.request.requestBody.tostring());
        try{
            PaymentToQCWrapper incomePayment = PaymentToQCWrapper.parse(RestContext.request.requestBody.tostring());
                
            Payment__c payment = new Payment__c();
            List<QC_Account__c> qcAccountList = [SELECT Id, Name FROM QC_Account__c WHERE QC_Account_Id__c =:incomePayment.Customer_id WITH SECURITY_ENFORCED ];
            List<Payment__c> paymentList = [SELECT Id, Name, RecordTypeId FROM Payment__c WHERE Name =:incomePayment.Transaction_id WITH SECURITY_ENFORCED];
            List<User> userList = [SELECT Id, Name FROM User WHERE UserName = :userName WITH SECURITY_ENFORCED];
            List<Coupon__c> coupons = new List<Coupon__c>();
            List<Campaign> camps = new List<Campaign>();
            List<Sync_QC_Coupon__e> evnts = new List<Sync_QC_Coupon__e>();

            RecordType rcType ;

            rcType = [SELECT Id, Name FROM recordType WHERE Name =:cc_static_Message.Payment_RecordType_Standard WITH SECURITY_ENFORCED];             
                                
            if(qcAccountList.size()>0 ){
                payment.QC_Account__c = qcAccountList.get(0).Id;                
            }

            if(paymentList.size() > 0){
                    payment.Id = paymentList.get(0).id;
                    payment.RecordTypeId = paymentList.get(0).RecordTypeId;
            }
            if(userList.size() >0){
                payment.Assignee__c = userList.get(0).Id;
            }
                
            payment.RecordTypeId = String.isBlank(payment.RecordTypeId)? rcType.Id : payment.RecordTypeId;
            payment.Name = incomePayment.Transaction_id;
            payment.Amount__c = incomePayment.Transaction_amount;
            payment.Final_Amount__c = incomePayment.Transaction_amount;
            payment.Payment_method__c = incomePayment.Payment_method;
                
            payment.Stage__c = incomePayment.Transaction_status;
            payment.State_temp__c = incomePayment.Transaction_status;
            payment.Type__c = incomePayment.Transaction_type;
            payment.Time__c = incomePayment.Timestamp == null? null: datetime.newInstance(incomePayment.Timestamp);
            payment.Time_for_collect_money__c = incomePayment.Time_collect_money;

            //Add more field https://coccoc.atlassian.net/browse/AM-7996
            payment.CouponId__c = incomePayment.coupon_id;            
            payment.CampaignId__c = incomePayment.coupon_campaign_id;  
            
            if(!String.isBlank(incomePayment.coupon_id)){
                coupons = [SELECT Id, Status__c,Payment__c FROM Coupon__c WHERE CouponId__c =: incomePayment.coupon_id AND Status__c = 'Active' LIMIT 1];                             
            }

            if(!String.isBlank(incomePayment.coupon_campaign_id)){
                camps = [SELECT Id FROM Campaign WHERE QCCampaignId__c =: incomePayment.coupon_campaign_id LIMIT 1];    
                
                if(camps != null && camps.size() > 0){
                    payment.Campaign__c = camps[0].Id;
                }
            }
                
            datetime dateTemp = incomePayment.Date_collect_money == null ? null : datetime.newInstance(incomePayment.Date_collect_money);
            system.debug('debug#' + incomePayment.Date_collect_money);
            system.debug('debug#' + dateTemp);
            payment.Date_for_collect_money__c = incomePayment.Date_collect_money == null ? null :  date.newinstance(dateTemp.year(), dateTemp.month(), dateTemp.day());
                
            payment.Address__c = incomePayment.Address;     

            
            upsert payment;    
            
            ///Publishing Data Sync Message Event
            // Data_Sync_Monitor__e mornitoEvt = new Data_Sync_Monitor__e();
            // mornitoEvt.SF_Id__c = payment.Id;
            // mornitoEvt.Event_Name__c = DataSyncMonitorConstant.PAYMENT_CREATED;
            // mornitoEvt.UniqueId__c = incomePayment.Transaction_id;
            // mornitoEvt.Broker_Time__c = incomePayment.broker_time == null? null: datetime.newInstance(incomePayment.broker_time);
            // monitorEvts.add(mornitoEvt);

            // if(monitorEvts.size() > 0){
            //     List<Database.SaveResult> results = EventBus.publish(monitorEvts);            
            // }
            
            if(coupons != null && coupons.size() > 0){
                cc_static_Message.isDoneCouponViaAPI = true;                

                coupons[0].Status__c = CouponConstant.STATUS_USED;
                coupons[0].Payment__c = payment.Id;
                coupons[0].TimeUsed__c = System.now();
                update coupons[0];

                
            }else {
                Sync_QC_Coupon__e evt = new Sync_QC_Coupon__e();
                evt.CouponId__c = incomePayment.coupon_id;   
                evt.Coupon_Campaign_Id__c = incomePayment.coupon_campaign_id;  
                evt.QC_Account__c = qcAccountList.get(0).id;
                evt.Payment__c = payment.id;
                evnts.add(evt);
            }


            if(evnts.size() > 0){
                Eventbus.publish(evnts);
            }
            
            rp.status = 'success';
            rp.message = '';
            string str = system.JSON.serialize(rp);
            system.debug('debug#' + str);

            
            return str;
        }catch(Exception ex){
            rp.status = 'fail';
            rp.message = ex.getMessage();
            if( setting.is_write_api_log__c){
                cc_Util.writeLog('paymentqctosf',rp.message, RestContext.request.requestBody.tostring());
            }
            string str = system.JSON.serialize(rp);
            system.debug('debug#' + str);
            return str;
        }
    }
}