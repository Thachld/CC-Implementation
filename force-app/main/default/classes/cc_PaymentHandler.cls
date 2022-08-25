public with sharing class cc_PaymentHandler implements cc_ITrigger{
    Set<String> homIds = new Set<String>();
    Set<String> parentPYIds = new Set<String>();
    Set<String> remainingPYIds = new Set<String>();
    Set<String> qcIds = new Set<String>();
    Set<String> dfqcIds = new Set<String>();
    Set<String> pyBalanceService = new Set<String>();
    Set<String> qcRealBalanceIds = new Set<String>();
    List<cc_PaymentStreaming_Wrapper.ConfirmedPayment> confirmedPyEvts = new List<cc_PaymentStreaming_Wrapper.ConfirmedPayment>();    
    List<cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper> createdPyEvts= new List<cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper>();
    Map<string,qc_Account__c> qcAccountValIdInvalIdMap = new Map<string,qc_Account__c>();
    List<qc_Account__c> invalidQcAccount = new List<qc_Account__c>();
    List<cc_ChatterBatchWrapper> chatterPosts = new List<cc_ChatterBatchWrapper>();
    Map<String, QC_Account__c> mapqcAccountUpdate = new Map<String,QC_Account__c>();  
   
    Map<String,PaymenToTransactionType__mdt> mapTrans = PaymentPlatformEventHelper.getTranstypeMapping();
    cc_setting__c setting = cc_Util.getCustomSetting();
    cc_Payment_Setting__c pySetting = cc_Util.getPaymentSetting('ccpaymentsetting');
    AdsOpManager__mdt defaultSetting = [SELECT FinalAmount__c, Industry__c, ManagerId__c, IsDefault__c FROM AdsOpManager__mdt WHERE Active__c = true AND IsDefault__c = true LIMIT 1];   
    String standardRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_STANDARD_PAYMENT).getRecordTypeId();    
    String avdRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT).getRecordTypeId();    
    String realRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_REAL_PAYMENT).getRecordTypeId();    
    String normalRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_NORMAL_PAYMENT).getRecordTypeId();    
    String rfRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_REFUND_PAYMENT).getRecordTypeId();    
    String tfRecordtypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_TRANSFER_PAYMENT).getRecordTypeId();  
    cc_PaymentTriggerHelper helper = new cc_PaymentTriggerHelper();   
    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public voId bulkBefore() {         
        //isInsert     
        
        if(Trigger.isInsert){        
            
            Map<String,RecordType> pamentRecordTypeMap = new Map<string, RecordType>([SELECT Id, Name FROM RecordType]);           
            Map<Id, QC_Account__c> qcAccountMap = new Map<Id, QC_Account__c>();

            for(Payment__c payment: (List<Payment__c>)Trigger.new){
                payment.Is_Standard_for_Stream__c = payment.Is_Standard__c;
                payment.Original_RecordType__c = pamentRecordTypeMap.get(payment.RecordTypeId).Name;                

                //Determine Transaction Type  
                if(mapTrans.containsKey(payment.RecordTypeId)){
                    if(payment.Type__c != PaymentConstant.TYPE_COUPON && payment.Type__c != PaymentConstant.TYPE_WITHDRAWAL_COUPON){
                        if(!String.isBlank(mapTrans.get(payment.RecordTypeId).SF_TransId__c)){
                            payment.Transactions_Type__c =  mapTrans.get(payment.RecordTypeId).SF_TransId__c;
                        } 

                        if(!String.isBlank(mapTrans.get(payment.RecordTypeId).Transaction_Type_Id__c)){
                            payment.Transaction_Type_Id__c =  mapTrans.get(payment.RecordTypeId).Transaction_Type_Id__c;                        
                        }
                    }
                }

                if( payment.Stage__c == PaymentConstant.STAGE_DONE 
                    || payment.Stage__c == PaymentConstant.STAGE_FAILURE){
                    payment.Done_time__c = datetime.now();

                    if(payment.RecordTypeId == normalRecordtypeId ){
                        payment.RecordTypeId = standardRecordtypeId;
                    }
                    if(payment.RecordTypeId == realRecordtypeId ){
                        if(payment.Effective_date__c == null ){
                            payment.Effective_date__c = datetime.now();
                        }
                    }else{
                        payment.Effective_date__c = datetime.now();
                    }
                }else{                    
                    //Auto confirm payment Ticket SAL408   
                    if(payment.RecordTypeId == avdRecordtypeId){
                        Datetime dt = System.now();
                        String Day_Created = dt.format('EEEE');  
                        String weekend = pySetting.Weekend__c;
                        String [] dayweekend;
                        if(!String.isBlank(weekend)){
                            dayweekend = weekend.split(';');
                        }                                  
                        if( payment.Auto_Confirm_Weekend__c == true 
                            && payment.Need_Approval__c  == false                            
                            && (dayweekend.contains(Day_Created))){
                                if(payment.Limit_Payment_Amount__c == null || payment.Limit_Payment_Amount__c == 0 || payment.Amount__c <= payment.Limit_Payment_Amount__c ){
                                    payment.Stage__c = PaymentConstant.STAGE_DONE;
                                    payment.Effective_date__c = datetime.now();
                                    payment.Done_time__c = datetime.now();             
                                }else if(payment.Limit_Payment_Amount__c < payment.Amount__c && payment.Limit_Payment_Amount__c != null  && payment.Limit_Payment_Amount__c != 0 ){
                                    payment.addError('You only can create payment for this qc Account with amount less or equal than (<=) ' + payment.Limit_Payment_Amount__c + ' on the weekend');
                                }                                                   
                            }
                    }
                }

            }
            
            qcAccountMap = cc_PaymentTriggerHelper.SetRelatedQCAccountOnInsert((List<Payment__c>)Trigger.new);

            for(Payment__c payment: (List<Payment__c>)Trigger.new){
                if( payment.Stage__c == PaymentConstant.STAGE_DONE ){   
                    //QC Account missing data
                    if( setting.Notify_missing_in_QC_Account__c == true  
                        && ( payment.RecordTypeId == realRecordtypeId 
                                || payment.RecordTypeId == standardRecordtypeId 
                                || payment.RecordTypeId == normalRecordtypeId ) 
                        && payment.Type__c == PaymentConstant.TYPE_INCOME ){

                            if(string.isBlank(payment.industry__c) 
                                || string.isBlank(payment.Agency__c) 
                                || string.isBlank(payment.Sale__c)){
                                
                                QC_Account__c qcTemp = qcAccountMap.get(payment.QC_Account__c);
                                if(!qcAccountValIdInvalIdMap.containsKey(qcTemp.Id)){
                                    qcAccountValIdInvalIdMap.put(qcTemp.Id, qcTemp);                                    
                                }
                            }                        
                    }
                    
                }
            }           
        }else if(Trigger.isUpdate) {               
            
            string userName = setting.payment_assignee__c;
            List<User> userList = [SELECT Id, name FROM user WHERE UserName=:userName];       
            Map<Id, QC_Account__c> qcAccountMap = new Map<Id, QC_Account__c>();

            for(Payment__c payment: (List<Payment__c>)Trigger.new){
                Payment__c oldPayment = (Payment__c)Trigger.oldMap.get(payment.Id);
                if ((payment.Stage__c == PaymentConstant.STAGE_DONE 
                        || payment.Stage__c == PaymentConstant.STAGE_FAILURE ) 
                        && payment.Stage__c != oldPayment.Stage__c ){

                        if(payment.RecordTypeId == normalRecordtypeId){
                            payment.RecordTypeId =  standardRecordtypeId;
                        }
                            
                        if(payment.RecordTypeId == realRecordtypeId ){
                            if(payment.Effective_date__c == null ){
                                payment.Effective_date__c = datetime.now();
                            }
                        }else{
                            payment.Effective_date__c = datetime.now();
                        }
                    }                
            } 

            qcAccountMap = cc_PaymentTriggerHelper.SetRelatedQCAccountOnUpdate((List<Payment__c>)Trigger.new, (Map<Id, Payment__c>)Trigger.oldMap);
            Map<string,qc_Account__c> qcAccountUpdateMap = new Map<string, qc_Account__c>();

            for(Payment__c payment: (List<Payment__c>)Trigger.new){
                payment.Is_Standard_for_Stream__c = payment.Is_Standard__c;                
                Payment__c oldPayment = (Payment__c)Trigger.oldMap.get(payment.Id);
                
                //Payment QC Account info
                if( (payment.Stage__c == PaymentConstant.STAGE_DONE 
                        || payment.Stage__c == PaymentConstant.STAGE_FAILURE ) 
                    && payment.Stage__c != oldPayment.Stage__c )
                {
                    //QC Account missing value
                    if( setting.Notify_missing_in_QC_Account__c == true  
                    && (payment.RecordTypeId == realRecordtypeId
                        || payment.RecordTypeId == standardRecordtypeId
                        || payment.RecordTypeId == normalRecordtypeId) 
                    && payment.Type__c == PaymentConstant.TYPE_INCOME 
                    && payment.Stage__c == PaymentConstant.STAGE_DONE){
                    
                        if(string.isBlank(payment.industry__c) 
                            || string.isBlank(payment.Agency__c) 
                            || string.isBlank(payment.Sale__c)){
                            
                            QC_Account__c qcTemp = qcAccountMap.get(payment.QC_Account__c);
                            if(!qcAccountValidInvalidMap.containsKey(qcTemp.Id)){
                                qcAccountValIdInvalIdMap.put(qcTemp.Id, qcTemp);                                
                            }
                        } 
                    }    
                }
                
                //Payment Approval notification to Assignee
                if(payment.isApproval__c != oldPayment.isApproval__c && (payment.isApproval__c == 1 || payment.isApproval__c == -1) )
                {
                    cc_ChatterBatchWrapper post = new cc_ChatterBatchWrapper();
                    
                    if( test.isRunningTest()){
                        post.IdList.add(UserInfo.getUserId());
                    }else{
                        post.IdList.add(userList.get(0).Id); 
                        post.IdList.add(qcAccountMap.get(payment.QC_Account__c).ownerId); 
                    }
                    post.recordId  = payment.Id;
                    
                    if(payment.isApproval__c == 1){
                        post.message = 'Payment ' + payment.Name + ' has just been approved';                        
                    }else{
                        post.message = 'Payment ' + payment.Name + ' has just been rejected';                        
                    }
                    
                    chatterPosts.add(post);
                }


                //Determine Transaction Type 
                if( payment.RecordTypeId != oldPayment.RecordTypeId
                    && mapTrans.containsKey(payment.RecordTypeId)){
                        if(payment.Type__c != PaymentConstant.TYPE_COUPON && payment.Type__c != PaymentConstant.TYPE_WITHDRAWAL_COUPON){
                            if(!String.isBlank(mapTrans.get(payment.RecordTypeId).SF_TransId__c)){
                                payment.Transactions_Type__c =  mapTrans.get(payment.RecordTypeId).SF_TransId__c;                        
                            } 
                            
                            if(!String.isBlank(mapTrans.get(payment.RecordTypeId).Transaction_Type_Id__c)){
                                payment.Transaction_Type_Id__c =  mapTrans.get(payment.RecordTypeId).Transaction_Type_Id__c;                        
                            }   
                        }
                }
            }            
        }
    
    }
    
    /**
    * bulkAfter
    *
    * This method is called prior to execution of an AFTER trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public voId bulkAfter() {	 
        Set<String> pyHomIds = new Set<String>();
        Set<String> pyPaidAmountIds = new Set<String>();
        Set<String> pyRefuncIds = new Set<String>();    
     
        if(pySetting != null){
            String shomcal = pySetting.HOM_Calculation__c ==null?'' : pySetting.HOM_Calculation__c;
            String spaidAmounntcal = pySetting.Paid_Amount_Calculation__c ==null?'' : pySetting.Paid_Amount_Calculation__c;
            String sremaindAmounntcal = pySetting.Transferred_Payment__c ==null?'' : pySetting.Transferred_Payment__c;
            String[] sHOMName = shomcal.split(';');
            String[] sPaidName = spaidAmounntcal.split(';');
            String[] sRemainName = sremaindAmounntcal.split(';');

           
            for(RecordType rcid : [SELECT Id, DeveloperName FROM RecordType WHERE IsActive = true AND SobjectType = 'Payment__c'] ){
                if(sHOMName.contains(rcid.DeveloperName)){
                    pyHomIds.add(rcid.Id);
                }                
                
                if(sPaidName.contains(rcid.DeveloperName)){
                    pyPaidAmountIds.add(rcid.Id);
                }

                if(sRemainName.contains(rcid.DeveloperName)){
                    pyRefuncIds.add(rcid.Id);
                }
            }   
        }

          
        if(Trigger.isInsert){
            Map<Id,Payment__c> newMap = (Map<Id,Payment__c>)Trigger.newMap;
            for(Payment__c py: newMap.values() ){
                
                if(py.Stage__c == PaymentConstant.STAGE_DONE){
                    //HOM
                    if (!String.isBlank(py.HandOver_Minutes__c)){
                        if(pyHomIds.contains(py.RecordTypeId)){
                            homIds.add(py.HandOver_Minutes__c);
                        }                       
                    }

                    //Paid amount Parent Payment, Remaining amount Parent Payment
                    if(!String.isBlank(py.Parent_Payment__c)){
                        if(pyPaidAmountIds.contains(py.RecordTypeId)){
                            parentPYIds.add(py.Parent_Payment__c);
                        }
                        
                        if(pyRefuncIds.contains(py.RecordTypeId)){
                            remainingPYIds.add(py.Parent_Payment__c);
                        }
                    } 

                    //QC Real Balance
                    if( py.RecordTypeId == realRecordtypeId 
                        && py.Is_Standard__c
                        && (py.Real_Money_Type__c == PaymentConstant.REAL_MONEY_TYPE_INCOME
                            || py.Real_Money_Type__c == PaymentConstant.REAL_MONEY_TYPE_PAY_DEPT)){                            
                            
                            this.qcRealBalanceIds.add(py.QC_Account__c);
                        
                    }else if( py.RecordTypeId == tfRecordtypeId 
                        && py.Is_Standard__c){                        
                            this.qcRealBalanceIds.add(py.QC_Account__c);
                    }

                    //QC Support is blank 
                    //https://coccoc.atlassian.net/browse/SAL-670
                    if ((py.RecordTypeId == standardRecordtypeId || py.RecordTypeId == avdRecordtypeId) 
                        && String.isBlank(py.support__c)  
                        && ( py.Agency__c == QCAccountConstant.AGENCY_CLIENT
                                || py.Agency__c == QCAccountConstant.AGENCY_PERSON_ACCOUNT
                                || py.Agency__c == QCAccountConstant.AGENCY_OTHER)
                        && py.Type__c == PaymentConstant.TYPE_INCOME){
                            Decimal defaultAmount = defaultSetting.FinalAmount__c == null?0 : defaultSetting.FinalAmount__c;

                            if(py.Final_Amount__c > defaultAmount && !String.isBlank(py.Industry__c)){
                                this.qcIds.add(py.QC_Account__c);
                            }else{
                                this.dfqcIds.add(py.QC_Account__c);
                            }
                    }
                }    
                //Get Blance Amount
                //https://coccoc.atlassian.net/browse/SAL-796
                if ( py.Withdrawal_from_QC__c == PaymentConstant.WITHDRAWAL_FROM_QC_YES
                        && py.RecordTypeId == rfRecordtypeId){
                        pyBalanceService.add(py.Id);
                } 

                //Publish Create Payment Platform Event
                if(    py.Stage__c == PaymentConstant.STAGE_DONE
                    && (py.Source__c != QCAccountConstant.SOURCE_SKINTOOL 
                        && py.Source__c != QCAccountConstant.SOURCE_SALESFORCE
                        && py.Source__c != QCAccountConstant.SOURCE_GAMESTORE) 
                    && (py.QC_Type__c != QCAccountConstant.TYPE_MCC 
                        && py.QC_Type__c != QCAccountConstant.TYPE_AGENCY)                 
                    && (!String.isBlank(py.Transaction_Type_Id__c))
                    && (    py.RecordTypeId == avdRecordtypeId 
                            || ( py.RecordTypeId == standardRecordtypeId && (py.Original_RecordType__c == 'Normal payment') )                                                     
                            || py.RecordTypeId == tfRecordtypeId
                        )
                    ){

                        cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper createdpy = new cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper();        
                        createdpy.id = py.Id;
                        createdpy.name = py.Name;
                        createdpy.note = py.Note__c;
                        createdpy.finalamount = py.Final_Amount__c;
                        createdpy.paymentmethod = py.Payment_method__c;
                        createdpy.qcemail = py.QC_Email__c;
                        createdpy.qcid = py.QC_Id__c;
                        createdpy.stage = py.Stage__c;
                        createdpy.type = py.Type__c;
                        createdpy.typemappingid = py.Transaction_Type_Id__c;
                        createdpy.confirmByEmail = py.Confirmed_By_Email__c;

                        createdPyEvts.add(createdpy);
                }

                ////Publish withdrawal transaction Platform Event
                if(   py.Stage__c == PaymentConstant.STAGE_DONE
                    && ( py.Source__c != QCAccountConstant.SOURCE_SKINTOOL 
                            && py.Source__c != QCAccountConstant.SOURCE_SALESFORCE
                            && py.Source__c != QCAccountConstant.SOURCE_GAMESTORE )                  
                    && ( py.Type__c == PaymentConstant.TYPE_WITHDRAWAL_INCOME 
                        || py.Type__c == PaymentConstant.TYPE_WITHDRAWAL_COUPON)
                    && ( py.QC_Type__c != QCAccountConstant.TYPE_MCC 
                        && py.QC_Type__c != QCAccountConstant.TYPE_AGENCY )                      
                    && (py.RecordTypeId == rfRecordtypeId 
                        && py.Withdrawal_from_QC__c == PaymentConstant.WITHDRAWAL_FROM_QC_YES)){

                        cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper createdpy = new cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper();        
                        createdpy.id = py.Id;
                        createdpy.name = py.Name;
                        createdpy.note = py.Note__c;
                        createdpy.finalamount = py.Final_Amount__c;
                        createdpy.paymentmethod = py.Payment_method__c;
                        createdpy.qcemail = py.QC_Email__c;
                        createdpy.qcid = py.QC_Id__c;
                        createdpy.stage = py.Stage__c;                        
                        if(!String.isBlank(py.Withdrawal_TransId__c)){
                            createdpy.type = PaymentConstant.TYPE_WITHDRAWAL;
                        }else {
                            createdpy.type = py.Type__c;
                        }
                        
                        createdpy.withdrawaltransId = py.Withdrawal_TransId__c;
                        createdpy.confirmByEmail = py.Confirmed_By_Email__c;

                        createdPyEvts.add(createdpy);
                }
            }
        }else if(Trigger.isUpdate) {
            Map<Id,Payment__c> newMap = (Map<Id,Payment__c>)Trigger.newMap;
            Map<Id,Payment__c> oldMap = (Map<Id,Payment__c>)Trigger.oldMap;
            for(String pyid: newMap.keySet() ){
                Payment__c newpy = newMap.get(pyid);
                Payment__c oldpy = oldMap.get(pyid);
                
                /* Hand-over minute */
                //change Status to Done
                if(newpy.Stage__c == PaymentConstant.STAGE_DONE && !String.isBlank(newpy.HandOver_Minutes__c) && oldpy.Stage__c != newpy.Stage__c){
                    if(pyHomIds.contains(newpy.RecordTypeId)){
                        homIds.add(newpy.HandOver_Minutes__c);
                    }                                    
                
                //Change HOM on Payment
                }else if( newpy.Stage__c == PaymentConstant.STAGE_DONE && oldpy.HandOver_Minutes__c != newpy.HandOver_Minutes__c){
                    
                    //Change HOM by change HOM to Payment
                    if( !String.isBlank(oldpy.HandOver_Minutes__c) && !String.isBlank(newpy.HandOver_Minutes__c) ){                        

                        if(pyHomIds.contains(newpy.RecordTypeId)){
                            homIds.add(newpy.HandOver_Minutes__c);
                            homIds.add(oldpy.HandOver_Minutes__c);
                        }
                    
                    //Change HOM by add HOM to Payment
                    }else if(String.isBlank(oldpy.HandOver_Minutes__c) && !String.isBlank(newpy.HandOver_Minutes__c)){                        
                        if(pyHomIds.contains(newpy.RecordTypeId)){
                            homIds.add(newpy.HandOver_Minutes__c);
                        } 
                    
                     //Change HOM by remove HOM from Payment
                    }else if(!String.isBlank(oldpy.HandOver_Minutes__c) && String.isBlank(newpy.HandOver_Minutes__c)){                        

                        if(pyHomIds.contains(oldpy.RecordTypeId)){
                            homIds.add(oldpy.HandOver_Minutes__c);
                        } 
                    }
                    
                }else if(newpy.Stage__c != PaymentConstant.STAGE_DONE && oldpy.Stage__c ==PaymentConstant.STAGE_DONE && oldpy.Stage__c != newpy.Stage__c){
                    if(pyHomIds.contains(oldpy.RecordTypeId)){
                        homIds.add(oldpy.HandOver_Minutes__c);
                    }
                }


                /* Parent Payment */
                //Change parent Payment or change Status to Done
                if( newpy.Stage__c == PaymentConstant.STAGE_DONE && !String.isBlank(newpy.Parent_Payment__c) && oldpy.Stage__c != newpy.Stage__c ){
                                        
                    if(pyPaidAmountIds.contains(newpy.RecordTypeId)){
                        parentPYIds.add(newpy.Parent_Payment__c);      
                    }
                    
                    if(pyRefuncIds.contains(newpy.RecordTypeId)){
                        remainingPYIds.add(newpy.Parent_Payment__c);
                    }
                
                //Change Parent Payment on Payment
                }else if( newpy.Stage__c == PaymentConstant.STAGE_DONE && oldpy.Parent_Payment__c != newpy.Parent_Payment__c){
                    
                    //Change Parent Payment by change Parent Payment to Parent Payment
                    if( !String.isBlank(oldpy.Parent_Payment__c) && !String.isBlank(newpy.Parent_Payment__c) ){                        

                        if(pyPaidAmountIds.contains(newpy.RecordTypeId)){
                            parentPYIds.add(newpy.Parent_Payment__c);
                            parentPYIds.add(oldpy.Parent_Payment__c);    
                        }
                        
                        if(pyRefuncIds.contains(newpy.RecordTypeId)){
                            remainingPYIds.add(newpy.Parent_Payment__c);
                            remainingPYIds.add(oldpy.Parent_Payment__c);
                        }
                    
                    //Change Parent Payment by add Parent Payment to Payment
                    }else if(String.isBlank(oldpy.Parent_Payment__c) && !String.isBlank(newpy.Parent_Payment__c)){                        

                        if(pyPaidAmountIds.contains(newpy.RecordTypeId)){
                            parentPYIds.add(newpy.Parent_Payment__c);      
                        }
                        
                        if(pyRefuncIds.contains(newpy.RecordTypeId)){
                            remainingPYIds.add(newpy.Parent_Payment__c);
                        }
                    
                    //Change Parent Payment by remove Parent Payment from Payment
                    }else if(!String.isBlank(oldpy.Parent_Payment__c) && String.isBlank(newpy.Parent_Payment__c)){                        

                        if(pyPaidAmountIds.contains(oldpy.RecordTypeId)){
                            parentPYIds.add(oldpy.Parent_Payment__c);      
                        }
                        
                        if(pyRefuncIds.contains(oldpy.RecordTypeId)){
                            remainingPYIds.add(oldpy.Parent_Payment__c);
                        }
                    }                
                }


                //publish Confirmed Standard Payment transaction Platform Event 
                if (    (newpy.Stage__c != oldpy.Stage__c)
                        && (newpy.Stage__c == PaymentConstant.STAGE_DONE || newpy.Stage__c == PaymentConstant.STAGE_FAILURE)                        
                        && (newpy.Source__c != QCAccountConstant.SOURCE_SKINTOOL 
                            && newpy.Source__c != QCAccountConstant.SOURCE_SALESFORCE
                            && newpy.Source__c != QCAccountConstant.SOURCE_GAMESTORE) 
                        && (newpy.State_temp__c != PaymentConstant.STAGE_DONE && newpy.State_temp__c != PaymentConstant.STAGE_FAILURE)   
                        && (newpy.Original_RecordType__c != 'Normal payment')    
                        && (newpy.RecordTypeId == standardRecordtypeId )     
                    ){
                        cc_PaymentStreaming_Wrapper.ConfirmedPayment confirmEvt = new cc_PaymentStreaming_Wrapper.ConfirmedPayment();        
                        confirmEvt.Id = newpy.Id;
                        confirmEvt.Name = newpy.Name;
                        confirmEvt.Note = newpy.Note__c;
                        confirmEvt.Final_Amount = newpy.Final_Amount__c;
                        confirmEvt.Stage = newpy.Stage__c;
                        confirmedPyEvts.add(confirmEvt);
                }

                //Publish Advance Payment transaction Platform Event 
                //https://coccoc.atlassian.net/browse/SAL-910   
                if(    newpy.Stage__c != oldpy.Stage__c
                        && newpy.Stage__c == PaymentConstant.STAGE_DONE
                        && ( newpy.Source__c != QCAccountConstant.SOURCE_SKINTOOL 
                                && newpy.Source__c != QCAccountConstant.SOURCE_SALESFORCE
                                && newpy.Source__c != QCAccountConstant.SOURCE_GAMESTORE )                 
                        && ( !String.isBlank(newpy.Transaction_Type_Id__c))
                        && ( newpy.QC_Type__c != QCAccountConstant.TYPE_MCC 
                                && newpy.QC_Type__c != QCAccountConstant.TYPE_AGENCY )
                        && ( newpy.RecordTypeId == avdRecordtypeId )
                    ){

                        cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper createdpy = new cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper();        
                        createdpy.id = newpy.Id;
                        createdpy.name = newpy.Name;
                        createdpy.note = newpy.Note__c;
                        createdpy.finalamount = newpy.Final_Amount__c;
                        createdpy.paymentmethod = newpy.Payment_method__c;
                        createdpy.qcemail = newpy.QC_Email__c;
                        createdpy.qcid = newpy.QC_Id__c;
                        createdpy.stage = newpy.Stage__c;
                        createdpy.type = newpy.Type__c;
                        createdpy.typemappingid = newpy.Transaction_Type_Id__c;
                        createdpy.confirmByEmail = newpy.Confirmed_By_Email__c;

                        createdPyEvts.add(createdpy);
                }

                //Publish Transfer, Normal Payment transaction Platform Event 
                if(    newpy.Stage__c != oldpy.Stage__c
                    && newpy.Stage__c == PaymentConstant.STAGE_DONE
                    && ( newpy.Source__c != QCAccountConstant.SOURCE_SKINTOOL 
                            && newpy.Source__c != QCAccountConstant.SOURCE_SALESFORCE
                            && newpy.Source__c != QCAccountConstant.SOURCE_GAMESTORE )       
                    && ( newpy.QC_Type__c != QCAccountConstant.TYPE_MCC 
                            && newpy.QC_Type__c != QCAccountConstant.TYPE_AGENCY )
                    && (!String.isBlank(newpy.Transaction_Type_Id__c))
                    && (    ( newpy.RecordTypeId == standardRecordtypeId && (newpy.Original_RecordType__c == 'Normal payment') )                                                     
                            || newpy.RecordTypeId == tfRecordtypeId)
                    ){

                        cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper createdpy = new cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper();        
                        createdpy.id = newpy.Id;
                        createdpy.name = newpy.Name;
                        createdpy.note = newpy.Note__c;
                        createdpy.finalamount = newpy.Final_Amount__c;
                        createdpy.paymentmethod = newpy.Payment_method__c;
                        createdpy.qcemail = newpy.QC_Email__c;
                        createdpy.qcid = newpy.QC_Id__c;
                        createdpy.stage = newpy.Stage__c;
                        createdpy.type = newpy.Type__c;
                        createdpy.typemappingid = newpy.Transaction_Type_Id__c;
                        createdpy.confirmByEmail = newpy.Confirmed_By_Email__c;
                        createdPyEvts.add(createdpy);
                }

                //Publish withdrawal transaction Platform Event
                if(    newpy.Stage__c != oldpy.Stage__c
                    && newpy.Stage__c == PaymentConstant.STAGE_DONE
                    && ( newpy.Source__c != QCAccountConstant.SOURCE_SKINTOOL 
                            && newpy.Source__c != QCAccountConstant.SOURCE_SALESFORCE
                            && newpy.Source__c != QCAccountConstant.SOURCE_GAMESTORE )                  
                    && ( newpy.Type__c == PaymentConstant.TYPE_WITHDRAWAL_INCOME 
                        || newpy.Type__c == PaymentConstant.TYPE_WITHDRAWAL_COUPON)
                    && ( newpy.QC_Type__c != QCAccountConstant.TYPE_MCC 
                        && newpy.QC_Type__c != QCAccountConstant.TYPE_AGENCY )                      
                    && (newpy.RecordTypeId == rfRecordtypeId 
                        && newpy.Withdrawal_from_QC__c == PaymentConstant.WITHDRAWAL_FROM_QC_YES)){

                        cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper createdpy = new cc_PaymentStreaming_Wrapper.CreatedPaymentWrapper();        
                        createdpy.id = newpy.Id;
                        createdpy.name = newpy.Name;
                        createdpy.note = newpy.Note__c;
                        createdpy.finalamount = newpy.Final_Amount__c;
                        createdpy.paymentmethod = newpy.Payment_method__c;
                        createdpy.qcemail = newpy.QC_Email__c;
                        createdpy.qcid = newpy.QC_Id__c;
                        createdpy.stage = newpy.Stage__c;
                        if(!String.isBlank(newpy.Withdrawal_TransId__c)){
                            createdpy.type = PaymentConstant.TYPE_WITHDRAWAL;
                        }else {
                            createdpy.type = newpy.Type__c;
                        }
                        
                        createdpy.withdrawaltransId = newpy.Withdrawal_TransId__c;
                        createdpy.confirmByEmail = newpy.Confirmed_By_Email__c;
                    
                        createdPyEvts.add(createdpy);
                }

                //QC Real Balance
                if( newpy.Stage__c == PaymentConstant.STAGE_DONE
                    && (newpy.Stage__c != oldpy.Stage__c
                        || newpy.Real_Money_Type__c != oldpy.Real_Money_Type__c
                        || newpy.Is_Standard__c != oldpy.Is_Standard__c) ){

                    if( newpy.RecordTypeId == realRecordtypeId 
                    && newpy.Is_Standard__c
                    && (newpy.Real_Money_Type__c == PaymentConstant.REAL_MONEY_TYPE_INCOME
                        || newpy.Real_Money_Type__c == PaymentConstant.REAL_MONEY_TYPE_PAY_DEPT)){                            
                        this.qcRealBalanceIds.add(newpy.QC_Account__c);    
                
                    }else if( newpy.RecordTypeId == tfRecordtypeId && newpy.Is_Standard__c){                        
                        this.qcRealBalanceIds.add(newpy.QC_Account__c);
                    }
                }

                //QC Support is blank 
                //https://coccoc.atlassian.net/browse/SAL-670
                if(newpy.Stage__c == PaymentConstant.STAGE_DONE
                    && newpy.Stage__c != oldpy.Stage__c){
                    if ((newpy.RecordTypeId == standardRecordtypeId || newpy.RecordTypeId == avdRecordtypeId) 
                        && String.isBlank(newpy.support__c)  
                        && ( newpy.Agency__c == QCAccountConstant.AGENCY_CLIENT
                                || newpy.Agency__c == QCAccountConstant.AGENCY_PERSON_ACCOUNT
                                || newpy.Agency__c == QCAccountConstant.AGENCY_OTHER)
                        && newpy.Type__c == PaymentConstant.TYPE_INCOME){

                            Decimal defaultAmount = defaultSetting.FinalAmount__c == null?0 : defaultSetting.FinalAmount__c;
                            if(newpy.Final_Amount__c > defaultAmount && !String.isBlank(newpy.Industry__c)){
                                this.qcIds.add(newpy.QC_Account__c);
                            }else{
                                this.dfqcIds.add(newpy.QC_Account__c);
                            }
                    }
                }       

                //Get Blance
                //https://coccoc.atlassian.net/browse/SAL-796                
                if (    newpy.Withdrawal_from_QC__c == PaymentConstant.WITHDRAWAL_FROM_QC_YES
                        && (newpy.Withdrawal_from_QC__c != oldpy.Withdrawal_from_QC__c)
                        && newpy.RecordTypeId == rfRecordtypeId  
                    ){                        
                        pyBalanceService.add(newpy.Id);
                }
                
            }
        }else if(Trigger.isDelete) {
            Map<Id,Payment__c> oldMap = (Map<Id,Payment__c>)Trigger.oldMap;
            for(Payment__c py: oldMap.values() ){
                
                //HOM 
                if(py.Stage__c == PaymentConstant.STAGE_DONE && !String.isBlank(py.HandOver_Minutes__c)){
                    if(pyHomIds.contains(py.RecordTypeId)){
                        homIds.add(py.HandOver_Minutes__c);
                    }
                }

                //Parent Payment
                if(py.Stage__c == PaymentConstant.STAGE_DONE && !String.isBlank(py.Parent_Payment__c)){                    

                    if(pyPaidAmountIds.contains(py.RecordTypeId)){
                        parentPYIds.add(py.Parent_Payment__c);
                    }
                    
                    if(pyRefuncIds.contains(py.RecordTypeId)){
                        remainingPYIds.add(py.Parent_Payment__c);
                    }
                }
            }
        }else if(Trigger.isUndelete){
            Map<Id,Payment__c> newMap = (Map<Id,Payment__c>)Trigger.newMap;
            for(Payment__c py: newMap.values() ){

                //HOM
                if(py.Stage__c == PaymentConstant.STAGE_DONE && !String.isBlank(py.HandOver_Minutes__c)){
                    if(pyHomIds.contains(py.RecordTypeId)){
                        homIds.add(py.HandOver_Minutes__c);
                    }
                }

                //Parent Payment
                if(py.Stage__c == PaymentConstant.STAGE_DONE && !String.isBlank(py.Parent_Payment__c)){                  

                    if(pyPaidAmountIds.contains(py.RecordTypeId)){
                        parentPYIds.add(py.Parent_Payment__c);
                    }
                    
                    if(pyRefuncIds.contains(py.RecordTypeId)){
                        remainingPYIds.add(py.Parent_Payment__c);
                    }
                }
            }
        }
    }
    
    /**
    * beforeInsert
    *
    * This method is called iteratively for each record to be inserted during a BEFORE
    * trigger. Never execute any SOQL/SOSL etc in this and other iterative methods.
    */
    public voId beforeInsert(SObject so) {}
    
    /**
    * beforeUpdate
    *
    * This method is called iteratively for each record to be updated during a BEFORE
    * trigger.
    */
    public voId beforeUpdate(SObject oldSo, SObject so) {}

    /**
    * beforeDelete
    *
    * This method is called iteratively for each record to be deleted during a BEFORE
    * trigger.
    */
    public voId beforeDelete(SObject so) {}
       

    /**
    * afterInsert
    *
    * This method is called iteratively for each record inserted during an AFTER
    * trigger. Always put field valIdation in the 'After' methods in case another trigger
    * has modified any values. The record is 'read only' by this point.
    */
    public voId afterInsert(SObject so) {}

    /**
    * afterUpdate
    *
    * This method is called iteratively for each record updated during an AFTER
    * trigger.
    */
    public voId afterUpdate(SObject oldSo, SObject so) {}

    /**
    * afterDelete
    *
    * This method is called iteratively for each record deleted during an AFTER
    * trigger.
    */
    public voId afterDelete(SObject so) {}
    
    /**
    * afterUnDelete
    *
    * This method is called iteratively for each record Undeleted during an AFTER
    * trigger.
    */
    public voId afterUnDelete(SObject so) {}

    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public voId andFinally() {     
        
        //Update QC Account
        System.debug('mapqcAccountUpdate.size() =>' + mapqcAccountUpdate.size());
        if(mapqcAccountUpdate.size() > 0){
            update mapqcAccountUpdate.values();
        }

        /* Calculation Payment Amount on HOM */
        System.debug('homIds.size() =>' + homIds.size());
        if(homIds.size() > 0){
            cc_PaymentTriggerHelper.attemptRollupPaymentForHOM(homIds);
        }

        /* Recalculation Parent Paid Amount ON Parent Payment */
        if(parentPYIds.size() > 0){
            cc_PaymentTriggerHelper.attemptCalculateParrentPaidAmount(parentPYIds);
        }

        //Calculation transfer amount for parrent payment
        if(remainingPYIds.size() > 0){
            cc_PaymentTriggerHelper.attemptCalculateTransferredAmount(remainingPYIds);
        }

        //publish confirm payment platform event
        System.debug('confirmedPyEvts.size() =>' + confirmedPyEvts.size());
        if(confirmedPyEvts.size() > 0){
            PaymentPlatformEventHelper.publishPaymentConfirmed(confirmedPyEvts);
        }        

        //publish created Payment platform event
        System.debug('createdPyEvts.size() =>' + createdPyEvts.size());
        if(createdPyEvts.size() > 0){
            PaymentPlatformEventHelper.publishPaymentCreated(createdPyEvts);
        }

        //Get Balance Information FROM QC
        System.debug('this.pyBalanceService=>' + this.pyBalanceService.size());
        if(pyBalanceService.size() > 0){
            BalanceServiceHelper.attemptgetBalanceService(pyBalanceService);
        }                  

        //Update Blank support to default team
        System.debug('this.qcIds=>' + this.qcIds.size());
        if(this.qcIds.size() > 0){
            cc_PaymentTriggerHelper.attemptUpdateBlankSupport(this.qcIds);
        }

        //Update Blank support to default team by industry
        System.debug('this.dfqcIds=>' + this.dfqcIds.size());
        if(this.dfqcIds.size() > 0){
            cc_PaymentTriggerHelper.attemptUpdateDefaultSupport(this.dfqcIds);
        }

        //Update Calculation Real Amount Balance ON QC Account
        System.debug('this.qcRealBalanceIds=>' + this.qcRealBalanceIds.size());
        if(this.qcRealBalanceIds.size() > 0){
            cc_PaymentTriggerHelper.attemptCalculateBalaneOnQCAccount(this.qcRealBalanceIds);
        }

        /* Push Notification, post chatter, send email */
        System.debug('qcAccountValidInvalidMap.size() =>' + qcAccountValidInvalidMap.size());
        if(qcAccountValidInvalidMap.size() > 0 || chatterPosts.size() > 0){
            PaymentChatterHelper.postChatter(qcAccountValidInvalidMap, chatterPosts, setting);
        }  
             
    }   
}