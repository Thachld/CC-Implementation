/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 07-04-2022
 * @last modified by  : @Thach Le
**/

public class MassUpdateQCAccount_Batch implements Database.Batchable<SObject>{
    public MassUpdateQCAccount_Batch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id,IsApplyTransactionType__c FROM QC_Account__c WHERE Source__c = : QCAccountConstant.SOURCE_QC AND IsApplyTransactionType__c= false]);
    }

    public void execute(Database.BatchableContext bc, List<QC_Account__c> scope){

        for(QC_Account__c qc :  scope){
            qc.IsApplyTransactionType__c =  true;
        }

        update scope;
    }

    public void finish(Database.BatchableContext bc){
        
    }

}