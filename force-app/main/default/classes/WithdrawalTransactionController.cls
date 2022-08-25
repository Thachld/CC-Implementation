public with sharing class WithdrawalTransactionController {
    
    @AuraEnabled
    public static Boolean confirmPayment(String paymentId){
        Boolean isSuccess = false;
                
        List<BalanceServiceController.BalanceWrapper> results = new List<BalanceServiceController.BalanceWrapper>();
        Payment__c payment = [SELECT Id, QC_Account__r.QC_Account_Id__c, Withdrawal_TransId__c, Final_Amount__c, Amount__c, Stage__c FROM Payment__c WHERE Id = : paymentId LIMIT 1];
       
        if(payment != null){
            if(!String.isBlank(payment.Withdrawal_TransId__c)){
                Datetime balanceTodate = Datetime.now();
                results = BalanceServiceController.getBalancebyTransaction(payment.QC_Account__r.QC_Account_Id__c, payment.Withdrawal_TransId__c,balanceTodate);

            }else {                 
                AuraHandledException auraException = new AuraHandledException(Label.NotExistsWithdrawalTransd);
                auraException.setMessage(Label.NotExistsWithdrawalTransd);
                throw auraException;
            }
        }
        
        if(results != null){
            BalanceServiceController.BalanceWrapper result = results[0];

            List<BalanceServiceController.DetailWrapper> details = result.detail;
            if(details != null && details.size() > 0){
                BalanceServiceController.DetailWrapper detail = details[0];

                if(detail != null && detail.balance != null){
                    if(detail.balance > 0 ){
                        if(payment.Final_Amount__c != NULL){
                            if(payment.Final_Amount__c == 0){
                                AuraHandledException auraException = new AuraHandledException('Final Amount is equal zero. you cannot confirm this payment!');
                                auraException.setMessage('Final Amount is equal zero. you cannot confirm this payment!');
                                throw auraException;
                            }
                        }else {
                            payment.Final_Amount__c = payment.Amount__c;
                        }
                        
                        if(detail.balance >= payment.Final_Amount__c){
                            payment.Stage__c = PaymentConstant.STAGE_DONE;
                            update payment;
                            isSuccess = true;
                        }else {                            
                            AuraHandledException auraException = new AuraHandledException(Label.BalanceIsnotEnough);
                            auraException.setMessage(Label.BalanceIsnotEnough);
                            throw auraException;
                        }
                    }else if(detail.balance <= 0){
                        AuraHandledException auraException = new AuraHandledException(Label.BalanceIsZero);
                        auraException.setMessage(Label.BalanceIsZero);
                        throw auraException;
                    }
                }else {                    
                    AuraHandledException auraException = new AuraHandledException(Label.NoBalance);
                    auraException.setMessage(Label.NoBalance);
                    throw auraException;
                }
            }else {                
                AuraHandledException auraException = new AuraHandledException(Label.NoBalance);
                auraException.setMessage(Label.NoBalance);
                throw auraException;
            }
        }            
        
        return isSuccess;
    }

    @AuraEnabled
    public static List<Payment__c> createWithdrawalRequest(PaymentWrapper withrawalrequest, List<WithdrawalPaymentWrapper> wdPayments){
        Savepoint sp = Database.setSavepoint();
        try {

            Map<String,Payment__c> mapPyToInsert = new Map<String,Payment__c>();
            Map<String,TransferWrapper> mapTransferAccount = new Map<String,TransferWrapper>();
            List<Payment__c> transferPyToInsert = new List<Payment__c>();

            for(WithdrawalPaymentWrapper wdPayment: wdPayments){
                Payment__c newpy = new Payment__c();
                newpy.RecordTypeId = withrawalrequest.recordtypeid;
                newpy.QC_Account__c = withrawalrequest.qcaccountid;
                newpy.Assignee__c = withrawalrequest.assignee;
                newpy.Approver__c = withrawalrequest.approver;
                newpy.Allow_Create__c = withrawalrequest.allowcreate;
                newpy.Withdrawal_from_QC__c = withrawalrequest.withdrawalfromqc;
                
                

                if(wdPayment.type == PaymentConstant.TYPE_COUPON){
                    newpy.Type__c = PaymentConstant.TYPE_WITHDRAWAL_COUPON;
                }else if(wdPayment.type == PaymentConstant.TYPE_INCOME){
                    newpy.Type__c  = PaymentConstant.TYPE_WITHDRAWAL_INCOME;
                }   
                
                newpy.Refund_Type__c = wdPayment.refundtype;
                newpy.Name = wdPayment.name; 
                newpy.Note__c = wdPayment.note;
                newpy.Withdrawal_Current_Balance__c = wdPayment.balance;
                newpy.Amount__c = wdPayment.amount;
                if(!String.isBlank(wdPayment.pyid)){
                    newpy.Withdrawal_Payment__c = wdPayment.pyid;
                }
                newpy.Withdrawal_From_TransId__c = wdPayment.transid;
                newpy.Stage__c = PaymentConstant.STAGE_NEW;

                mapPyToInsert.put(wdPayment.transid, newpy);
                if(wdPayment.iscreatetransfer 
                    && !String.isBlank(wdPayment.transfertouserid)
                    && wdPayment.refundtype == PaymentConstant.REFUND_TYPE_REFUND_FOR_TRANSFER
                    ){
                    TransferWrapper tf = new TransferWrapper();
                    tf.transfername = wdPayment.transfername;
                    tf.transfertouserid = wdPayment.transfertouserid;
                    mapTransferAccount.put(wdPayment.transid, tf);
                }
            }

            Database.insert(mapPyToInsert.values(),true);
            Id transferRecordTypeId = Schema.SObjectType.Payment__c.getRecordTypeInfosByDeveloperName().get(PaymentConstant.RECORDTYPE_TRANSFER_PAYMENT).getRecordTypeId();   
            for(String transId : mapTransferAccount.keySet()){
                Payment__c withdrawal = mapPyToInsert.get(transId);
                TransferWrapper tf = mapTransferAccount.get(transId);

                if(withdrawal != null && tf != null){                    
                    Payment__c newpy = new Payment__c();

                    newpy.RecordTypeId = transferRecordTypeId;
                    newpy.Name = mapTransferAccount.get(transId).transfername;
                    newpy.QC_Account__c = mapTransferAccount.get(transId).transfertouserid;
                    newpy.Assignee__c = withrawalrequest.assignee;
                    newpy.Approver__c = withrawalrequest.approver;  
                    newpy.Parent_Payment__c = withdrawal.Id;
                    newpy.Type__c = PaymentConstant.TYPE_INCOME;                        
                    newpy.Note__c = 'Transfer from payment transaction :' + 'https://coccoc.lightning.force.com/' + withdrawal.Id  ;                
                    newpy.Amount__c = withdrawal.Amount__c;                
                    newpy.Stage__c = PaymentConstant.STAGE_NEW;

                    System.debug('newpy=>' + newpy);
                    transferPyToInsert.add(newpy);
                }
            }

            List<Database.SaveResult> results = Database.insert(transferPyToInsert,false);
            Boolean is_Success = true;

            if(results!= null){
                for(Database.SaveResult result : results){
                    if(!result.isSuccess()){
                        for(Database.Error err : result.getErrors()) {
                            System.debug('err.getMessage=>' + err.getMessage());
                        }     
                        is_Success = false;  
                    }
                }

                if(!is_Success){
                    Database.rollback(sp);
                    throw new AuraHandledException('Error when child record inserted!'); 
                }
            }

            return mapPyToInsert.values();
        } catch (Exception e) {
            Database.rollback(sp);
            // System.debug('e.getMessage()=>' + e.getMessage());
            // return null;
            throw new AuraHandledException(e.getMessage());
        }
    }


    public class TransferWrapper{
        @AuraEnabled
        public String transfertouserid {get;set;}

        @AuraEnabled
        public String transfername {get;set;}
    }


    public class WithdrawalPaymentWrapper{       
        @AuraEnabled
        public Integer no {get;set;}

        @AuraEnabled
        public String transid {get;set;}

        @AuraEnabled
        public String pyid {get;set;}

        @AuraEnabled
        public Decimal balance {get;set;}

        @AuraEnabled
        public Decimal amount {get;set;}

        @AuraEnabled
        public String name {get;set;}

        @AuraEnabled
        public String note {get;set;} 
        
        @AuraEnabled
        public String type {get;set;}

        @AuraEnabled
        public Boolean iscreatetransfer {get;set;}

        @AuraEnabled
        public String transfertouserid {get;set;}

        @AuraEnabled
        public String transfername {get;set;}

        @AuraEnabled
        public String refundtype {get;set;}    
    }

    public class PaymentWrapper{ 

        @AuraEnabled
        public String recordtypeid {get;set;}

        @AuraEnabled
        public String qcaccountid {get;set;}       
        
        @AuraEnabled
        public String assignee {get;set;}      

        @AuraEnabled
        public String approver {get;set;}  
       
        @AuraEnabled
        public String withdrawalfromqc {get;set;}   
        
        @AuraEnabled
        public Boolean allowcreate {get;set;}   
    }

}