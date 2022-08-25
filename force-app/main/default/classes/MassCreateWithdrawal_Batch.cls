public with sharing class MassCreateWithdrawal_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    private Set<String> qcIds {get;set;}
    private cc_setting__c setting {get;set;}   
    private List<LogFileWrapper.FileWrapper> logs {get;set;}
    private String refundRecordTypeId  {get;set;}
    private Mass_Withdrawal_Request__c request {get;set;}

    public MassCreateWithdrawal_Batch(Set<String> pqcIds, Mass_Withdrawal_Request__c prequest) {
        this.qcIds = pqcIds;
        this.setting = cc_setting__c.getInstance('cc setting');
        this.request = prequest;
        this.logs = new List<LogFileWrapper.FileWrapper>();
        this.refundRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_REFUND_PAYMENT).getRecordTypeId(); 
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, QC_Account_Id__c , Name, Type__c
                                        FROM QC_Account__c 
                                        WHERE QC_Account_Id__c IN : this.qcIds]);
    }

    public void execute(Database.BatchableContext bc, List<QC_Account__c> scope){
        Map<String,QC_Account__c> mapQCAcc = new Map<String,QC_Account__c>();
        Map<String, String> mapQCId = new Map<String, String>();
        Set<String> processQCIds = new Set<String>();
        Map<String,String> mapPayment = New Map<String,String>();

        Set<String> setIds = this.qcIds;

        for(QC_Account__c qc : scope){
            setIds.remove(qc.QC_Account_Id__c);
            if(qc.Type__c != QCAccountConstant.TYPE_AGENCY 
                && qc.Type__c != QCAccountConstant.TYPE_MCC){
                processQCIds.add(qc.QC_Account_Id__c);
                mapQCAcc.put(qc.QC_Account_Id__c, qc);    
                mapQCId.put(qc.Id, qc.QC_Account_Id__c);
            }else{
                LogFileWrapper.FileWrapper log = new LogFileWrapper.FileWrapper();
                log.Id = qc.QC_Account_Id__c;
                log.message = 'QC Account has type is Agency or MCC';
                this.logs.add(log);
            }
        }

        //QC Accounts don't exists
        if(setIds.size() > 0){
            for(String qcId : setIds){
                LogFileWrapper.FileWrapper log = new LogFileWrapper.FileWrapper();
                log.Id = qcId;
                log.message = 'QC Accounts do not exists in SF';
                this.logs.add(log);
            }
        }

        if(processQCIds.size() > 0){
            mapPayment = getPayments(mapQCId.keySet());
            List<Payment__c> pysToInsert = getBalance(processQCIds, mapQCAcc,mapPayment);
            if(pysToInsert != null){
                List<Database.SaveResult> results = Database.insert(pysToInsert,false);
                
                for(Integer i = 0 ; i < pysToInsert.size() ; i++){
                    Database.SaveResult rs = results[i];
                    Payment__c pyInsert = pysToInsert[i];
                    String errorMsg;
                    if(!rs.isSuccess()){ 
                        errorMsg += 'Failed to Insert Payment ' + pyInsert.Name;
                        for(Database.Error err : rs.getErrors()) { 
                            errorMsg +=  ' | Fields => ' +  err.getFields() + ' | Error message => ' + err.getMessage() ;                            
                        }
                        System.debug('errorMsg=>' + errorMsg);

                        LogFileWrapper.FileWrapper log = new LogFileWrapper.FileWrapper();
                        log.Id = mapQCId.get(pyInsert.QC_Account__c);
                        log.message = errorMsg;
                        this.logs.add(log);
                    }                    
                }          
            }
        }
    }

    public void finish(Database.BatchableContext bc){
        MassCreateWithdrawalLog_Batch generatefile = new MassCreateWithdrawalLog_Batch(this.request.Id, this.logs);
        Database.executeBatch(generatefile);   
    }

    public List<Payment__c> getBalance(Set<String> qcIds, Map<String,QC_Account__c> mapQCAcc, Map<String, String> mapPayment){
        List<BalanceServiceWrapper.BalanceWrapper> blresult = new List<BalanceServiceWrapper.BalanceWrapper>();
        List<Payment__c> pysToInsert = new List<Payment__c>();

        if(qcIds.size() >0){        
            Datetime balanceTodate = Datetime.now();    
            blresult = BalanceServiceController.getBalanceService(qcIds, balanceTodate);            
            
            System.debug('blresult=>' + blresult);
            if(blresult != null){                   
                List<Payment__c> newPy = initialWithdrawalPayment(blresult, mapQCAcc, mapPayment);

                System.debug('newPy=>' + newPy);
                pysToInsert.addAll(newPy);
            }        
        }  
        
        return pysToInsert;
    } 


    public List<Payment__c> initialWithdrawalPayment(List<BalanceServiceWrapper.BalanceWrapper> results, Map<String,QC_Account__c> mapQCAcc, Map<String, String> mapPayment){
        List<Payment__c> initPayments = new List<Payment__c>();       

        if(results != null && results.size() > 0){

            for(BalanceServiceWrapper.Balancewrapper result: results){
                List<BalanceServiceWrapper.DetailWrapper> details = result.detail;
                QC_Account__c qcAcc = mapQCAcc.get(result.user_id);

                System.debug('qcAcc=>' + qcAcc);
                System.debug('details=>' + details);
                if(details != null && details.size() > 0 && qcAcc != null){
                    for(BalanceServiceWrapper.DetailWrapper dt : details){
                        String fromPayment = mapPayment.get(dt.id);

                        if(dt.balance > 0){
                            if(dt.type == PaymentConstant.TYPE_INCOME){
                                Payment__c withDrawlINCOME = new Payment__c();
                                withDrawlINCOME.Name = 'Withdraw INCOME ' + qcAcc.Name;
                                withDrawlINCOME.Note__c = (this.request.Default_Note__c != null? this.request.Default_Note__c :'Mass Withdrawal INCOME ' + qcAcc.Name );
                                withDrawlINCOME.QC_Account__c = qcAcc.Id;
                                withDrawlINCOME.Stage__c = this.request.Is_Auto_Confirm__c == true? PaymentConstant.STAGE_DONE : PaymentConstant.STAGE_NEW;
                                withDrawlINCOME.Type__c = PaymentConstant.TYPE_WITHDRAWAL_INCOME;
                                withDrawlINCOME.Refund_Type__c = this.request.Refund_Type__c;
                                withDrawlINCOME.Withdrawal_from_QC__c = PaymentConstant.WITHDRAWAL_FROM_QC_YES;
                                withDrawlINCOME.Effective_date__c = (this.request.Effective_Date__c != null? this.request.Effective_Date__c :Datetime.now() ); 
                                withDrawlINCOME.Amount__c = dt.balance;
                                withDrawlINCOME.Final_Amount__c = dt.balance;
                                withDrawlINCOME.Assignee__c = (this.request.Assignee__c != null? this.request.Assignee__c : setting.CouponDefaultAssignee__c );  
                                withDrawlINCOME.RecordTypeId = this.refundRecordTypeId;
                                withDrawlINCOME.Mass_Withdrawal_Request__c = this.request.Id;
                                withDrawlINCOME.Withdrawal_Payment__c = fromPayment;
                                withDrawlINCOME.Withdrawal_From_TransId__c = dt.id;
                                withDrawlINCOME.Allow_Create__c  = true;

                                initPayments.add(withDrawlINCOME);
                            }else if(dt.type == PaymentConstant.TYPE_COUPON){
                                Payment__c withDrawlCOUPON = new Payment__c();
                                withDrawlCOUPON.Name = 'Withdraw COUPON ' + qcAcc.Name;
                                withDrawlCOUPON.Note__c = (this.request.Default_Note__c != null? this.request.Default_Note__c :'Mass Withdrawal COUPON ' + qcAcc.Name );
                                withDrawlCOUPON.QC_Account__c = qcAcc.Id;
                                withDrawlCOUPON.Stage__c = this.request.Is_Auto_Confirm__c == true? PaymentConstant.STAGE_DONE : PaymentConstant.STAGE_NEW;
                                withDrawlCOUPON.Type__c = PaymentConstant.TYPE_WITHDRAWAL_COUPON;
                                withDrawlCOUPON.Refund_Type__c = this.request.Refund_Type__c;
                                withDrawlCOUPON.Withdrawal_from_QC__c = PaymentConstant.WITHDRAWAL_FROM_QC_YES;
                                withDrawlCOUPON.Effective_date__c = (this.request.Effective_Date__c != null? this.request.Effective_Date__c :Datetime.now() ); 
                                withDrawlCOUPON.Amount__c = dt.balance;
                                withDrawlCOUPON.Final_Amount__c = dt.balance;
                                withDrawlCOUPON.Assignee__c = (this.request.Assignee__c != null? this.request.Assignee__c : setting.CouponDefaultAssignee__c ); 
                                withDrawlCOUPON.RecordTypeId = this.refundRecordTypeId;
                                withDrawlCOUPON.Mass_Withdrawal_Request__c = this.request.Id;
                                withDrawlCOUPON.Withdrawal_Payment__c = fromPayment;
                                withDrawlCOUPON.Withdrawal_From_TransId__c = dt.id;
                                withDrawlCOUPON.Allow_Create__c  = true;

                                initPayments.add(withDrawlCOUPON);

                            }
                        }
                    }
                }
            }
        }
        
        return initPayments;
    }



    public static Map<String,String> getPayments(Set<String> qcIds){
        Map<String, String> mapPayment = new Map<String, String>();

        for(Payment__c py : [SELECT Name, Id FROM Payment__c 
                            WHERE QC_Account__c IN :qcIds 
                            AND Stage__c = :PaymentConstant.STAGE_DONE
                            AND (
                                    RecordType.DeveloperName = :PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT
                                    OR RecordType.DeveloperName = :PaymentConstant.RECORDTYPE_NORMAL_PAYMENT
                                    OR RecordType.DeveloperName = :PaymentConstant.RECORDTYPE_TRANSFER_PAYMENT
                                    OR RecordType.DeveloperName = :PaymentConstant.RECORDTYPE_STANDARD_PAYMENT
                                )                            
                            ]){

            mapPayment.put(py.Name, py.Id);

        }


        return mapPayment;
    }
}