@istest
public with sharing class BalanceServiceController_Test {
    
    
    @istest
    public static void testsearchQCAccount(){
        
        List<Id> fixedResults = new List<Id>();

        List<QC_Account__c> listInsertQCAcc = new List<QC_Account__c>();
        Account acc = cc_initData.initAccount('Test Account');
        insert acc;
       

        for(Integer i = 0; i < 10 ; i++){
            QC_Account__c qcAccount = cc_initData.initQCAccount('testqcacc' + String.valueOf(i) + '@testcoccoc.com', acc.Id);        
            qcAccount.QC_Account_Id__c = '112233445' +  String.valueOf(i);

            listInsertQCAcc.add(qcAccount);
        }

        insert listInsertQCAcc;
        for(QC_Account__c qc : listInsertQCAcc){
            fixedResults.add(qc.id);
        }

        Test.setFixedSearchResults(fixedResults);
       
        List<QC_Account__c> testqc = [SELECT Id FROM QC_Account__c];
        System.assertEquals(10, testqc.size());

        List<String> selectedIds = new List<String>();
        List<LookupSearchResult> tesresult = BalanceServiceController.searchQCAccount('112', selectedIds);

        System.assertEquals(10, tesresult.size());
    }

    @istest
    public static void testGetBalancebyUserId(){
        
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where DeveloperName =:PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );   
            insert payment3;

            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                .setName('balancebervice_v2')
                                .setUri('https://api.qc.coccoc.com/salesforce/balance')
                                .setMethod('GET')
                                .setTimeout(10000)
                                .buildAndSave();


            List<String> qcIds = new List<String>();
            qcIds.add(qcAccount.QC_Account_Id__c);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());

                BalanceServiceController.getBalance(qcIds, System.now());


                BalanceServiceWrapper wrp = new BalanceServiceWrapper();
                BalanceServiceWrapper.DetailWrapper dt = new BalanceServiceWrapper.DetailWrapper();
                dt.BALANCE = 1;
                dt.ID = '12';
                dt.TIMESTAMP = '';
                dt.TYPE = '';

                BalanceServiceWrapper.SummaryWrapper sum = new BalanceServiceWrapper.SummaryWrapper();
                sum.COUPON_MONEY = 1;
                sum.REAL_MONEY = 1;
                sum.REFUND_MONEY =0;
                sum.TOTAL_MONEY = 2;

                BalanceServiceWrapper.BalanceWrapper wraper = new BalanceServiceWrapper.BalanceWrapper();
                wraper.detail =new List<BalanceServiceWrapper.DetailWrapper>{dt};
                wraper.summary = sum;
                wraper.user_id = '1122334455';

                BalanceServiceWrapper rs = new BalanceServiceWrapper();
                rs.balances = new List<BalanceServiceWrapper.BalanceWrapper>{wraper};
                
            Test.stopTest();
    }

    @istest
    public static void testGetBalancebyQCAccount(){
        
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                .setName('balancebervice_v2')
                                .setUri('https://api.qc.coccoc.com/salesforce/balance')
                                .setMethod('GET')
                                .setTimeout(10000)
                                .buildAndSave();

            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where DeveloperName =:PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );   
            insert payment3;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
                List<String> qcAccIds = new List<String>();
                qcAccIds.add(qcAccount.Id);

                BalanceServiceController.getBalanceByQcAccount(qcAccIds, System.now());


                BalanceServiceWrapper wrp = new BalanceServiceWrapper();
                BalanceServiceWrapper.DetailWrapper dt = new BalanceServiceWrapper.DetailWrapper();
                dt.BALANCE = 1;
                dt.ID = '12';
                dt.TIMESTAMP = '';
                dt.TYPE = '';

                BalanceServiceWrapper.SummaryWrapper sum = new BalanceServiceWrapper.SummaryWrapper();
                sum.COUPON_MONEY = 1;
                sum.REAL_MONEY = 1;
                sum.REFUND_MONEY =0;
                sum.TOTAL_MONEY = 2;

                BalanceServiceWrapper.BalanceWrapper wraper = new BalanceServiceWrapper.BalanceWrapper();
                wraper.detail =new List<BalanceServiceWrapper.DetailWrapper>{dt};
                wraper.summary = sum;
                wraper.user_id = '1122334455';

                BalanceServiceWrapper rs = new BalanceServiceWrapper();
                rs.balances = new List<BalanceServiceWrapper.BalanceWrapper>{wraper};
            Test.stopTest();
    }

    @istest
    public static void testGetBalancebyPayment(){
        
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                .setName('balancebervice_v2')
                                .setUri('https://api.qc.coccoc.com/salesforce/balance')
                                .setMethod('GET')
                                .setTimeout(10000)
                                .buildAndSave();

            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where DeveloperName =:PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );   
            insert payment3;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
                String paymentId = payment3.Id; 

                BalanceServiceController.getBalancebyPayment(paymentId, System.now());


                BalanceServiceWrapper wrp = new BalanceServiceWrapper();
                BalanceServiceWrapper.DetailWrapper dt = new BalanceServiceWrapper.DetailWrapper();
                dt.BALANCE = 1;
                dt.ID = '12';
                dt.TIMESTAMP = '';
                dt.TYPE = '';

                BalanceServiceWrapper.SummaryWrapper sum = new BalanceServiceWrapper.SummaryWrapper();
                sum.COUPON_MONEY = 1;
                sum.REAL_MONEY = 1;
                sum.REFUND_MONEY =0;
                sum.TOTAL_MONEY = 2;

                BalanceServiceWrapper.BalanceWrapper wraper = new BalanceServiceWrapper.BalanceWrapper();
                wraper.detail =new List<BalanceServiceWrapper.DetailWrapper>{dt};
                wraper.summary = sum;
                wraper.user_id = '1122334455';

                BalanceServiceWrapper rs = new BalanceServiceWrapper();
                rs.balances = new List<BalanceServiceWrapper.BalanceWrapper>{wraper};
            Test.stopTest();
    }

    @istest
    public static void testGetBalancebyTransaction(){
        
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                .setName('balancebervice_v2')
                                .setUri('https://api.qc.coccoc.com/salesforce/balance')
                                .setMethod('GET')
                                .setTimeout(10000)
                                .buildAndSave();

            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where DeveloperName =:PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );   
            insert payment3;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
                String paymentId = payment3.Id; 

                BalanceServiceController.getBalancebyTransaction('1122334455', '1258e', System.now());


                BalanceServiceWrapper wrp = new BalanceServiceWrapper();
                BalanceServiceWrapper.DetailWrapper dt = new BalanceServiceWrapper.DetailWrapper();
                dt.BALANCE = 1;
                dt.ID = '12';
                dt.TIMESTAMP = '';
                dt.TYPE = '';

                BalanceServiceWrapper.SummaryWrapper sum = new BalanceServiceWrapper.SummaryWrapper();
                sum.COUPON_MONEY = 1;
                sum.REAL_MONEY = 1;
                sum.REFUND_MONEY =0;
                sum.TOTAL_MONEY = 2;

                BalanceServiceWrapper.BalanceWrapper wraper = new BalanceServiceWrapper.BalanceWrapper();
                wraper.detail =new List<BalanceServiceWrapper.DetailWrapper>{dt};
                wraper.summary = sum;
                wraper.user_id = '1122334455';

                BalanceServiceWrapper rs = new BalanceServiceWrapper();
                rs.balances = new List<BalanceServiceWrapper.BalanceWrapper>{wraper};
            Test.stopTest();
    }

    @istest
    public static void testGetBalancebyWithdrawal(){
        
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.Auto_Confirm_Weekend__c = true;
            qcAccount.QC_Account_Id__c = '1122334455';
            qcAccount.Need_Approval__c = false;       
            qcAccount.Real_Money_Balance__c = null;
            insert qcAccount;
            
            coccoc.ManageQCCredential.insertOrgDefaultQCCredential('UhwDPOS4O9nXdpMUgFSty0YBP7BKPlrjexYnDFPu', System.now() +3 );
            CouponIntegration__c cpsetting = new CouponIntegrationTestDataBuilder()
                                .setName('balancebervice_v2')
                                .setUri('https://api.qc.coccoc.com/salesforce/balance')
                                .setMethod('GET')
                                .setTimeout(10000)
                                .buildAndSave();

            RecordType rcType ;
            rcType = [select Id, Name FROM recordType where DeveloperName =:PaymentConstant.RECORDTYPE_ADVANCE_PAYMENT];
            Payment__c payment3 =  cc_initData.initPayment(rcType.id,'1258f', qcAccount.id );   
            insert payment3;
            
            rcType = [select Id, Name FROM recordType where DeveloperName =:PaymentConstant.RECORDTYPE_REFUND_PAYMENT];
            Payment__c payment4 =  cc_initData.initPayment(rcType.id,'1258e', qcAccount.id );   
            payment4.Withdrawal_From_TransId__c = '1258f';
            insert payment4;

            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new cc_BalanceServiceHttpCalloutMock());
                String paymentId = payment4.Id; 

                BalanceServiceController.getBalancebyWithdrawal(paymentId, System.now(), true);


                BalanceServiceWrapper wrp = new BalanceServiceWrapper();
                BalanceServiceWrapper.DetailWrapper dt = new BalanceServiceWrapper.DetailWrapper();
                dt.BALANCE = 1;
                dt.ID = '12';
                dt.TIMESTAMP = '';
                dt.TYPE = '';

                BalanceServiceWrapper.SummaryWrapper sum = new BalanceServiceWrapper.SummaryWrapper();
                sum.COUPON_MONEY = 1;
                sum.REAL_MONEY = 1;
                sum.REFUND_MONEY =0;
                sum.TOTAL_MONEY = 2;

                BalanceServiceWrapper.BalanceWrapper wraper = new BalanceServiceWrapper.BalanceWrapper();
                wraper.detail =new List<BalanceServiceWrapper.DetailWrapper>{dt};
                wraper.summary = sum;
                wraper.user_id = '1122334455';

                BalanceServiceWrapper rs = new BalanceServiceWrapper();
                rs.balances = new List<BalanceServiceWrapper.BalanceWrapper>{wraper};
            Test.stopTest();
    }

    @istest
    public static void testGetTranstype(){

        Test.startTest();
            List<Transactions_Type__c> insertTrans = new List<Transactions_Type__c>();
            Transactions_Type__c transtype = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.COMPENSATION)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.COMPENSATION)
                                                .setAllowCoupon(true)
                                                .build();
            transtype.Allow_Withdraw__c = true;
            insertTrans.add(transtype);
            
            Transactions_Type__c transtype1 = new TransactionTypeTestDataBuilder()
                                                .setName(TransactionTypeConstant.ADVANCE)
                                                .setTransactionTypeId('1')
                                                .setInternalType(TransactionTypeConstant.ADVANCE)
                                                .setAllowCoupon(false)
                                                .build();
            transtype1.Allow_Withdraw__c = true;
            insertTrans.add(transtype1);

            insert insertTrans;

            List<BalanceServiceController.TransTypeWrapper> testtrans = BalanceServiceController.getTranstype();

            System.assertEquals(2, testtrans.size());

        Test.stopTest();

    }
}