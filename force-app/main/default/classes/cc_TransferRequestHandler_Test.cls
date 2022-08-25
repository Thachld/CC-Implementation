@istest
public class cc_TransferRequestHandler_Test {
    @TestSetup
    static void testSetup(){        

        Profile prof = [SELECT Id FROM profile WHERE Name='System Administrator' LIMIT 1]; 
        UserRole role = [SELECT Id FROM UserRole WHERE Name ='C-Suite' LIMIT 1];         
        User owner = cc_initData.initUser(prof.Id, 'Le', 'thachld', role.Id);
        insert owner;

        User owner1 = cc_initData.initUser(prof.Id, 'nguyen', 'toannc', role.Id);
        insert owner1;
        
    }
    public testMethod static void testUpdate(){

        Test.startTest();

            User owner = [SELECT ID FROM User WHERE lastName = 'thachld']; 
            User newUser = [SELECT ID FROM User WHERE lastName = 'toannc']; 

            Date today = System.today();
            List<QC_Account_Data__c> listQCAccountData = new List<QC_Account_Data__c>();
            String mdRecTypeId = Schema.SObjectType.Make_Design__c.getRecordTypeInfosByDeveloperName().get('Simple_design').getRecordTypeId();
        
            System.runAs(owner){
                cc_setting__c ccSetting = cc_initData.initCustomeSetting();
                insert ccSetting;   
                
                cc_Trigger_Control__c trg = cc_initData.initTrigger('TRANSFER_TRIGGER',true);
                insert trg;

                String accname = 'Batch Account test';
                Account acc = cc_initData.initAccount(accname);  
                insert acc;

                String qcname = 'qcAccount123@qcCococ.com';
                QC_Account__c qcacc = cc_initData.initQCAccount(qcname, acc.Id);  
                qcacc.sales__c = owner.Id;          
                insert qcacc;

                Date startDate = today.toStartOfMonth();        
                Date endDate = startDate.addMonths(5);        
                String type = 'Master - Commitment';
                Contract__c con = cc_initData.initContract(acc.Id, startDate, endDate, type);
                insert con;    
                
            for(Integer d = 0; d < 5; d++){
                    Date dt = today.addDays(d);                
                    Datetime dtime = Datetime.newInstance(dt.year(), dt.month(), dt.day(), 0,0,0);       
                    if(d < 3){    
                            Integer qty = 10 * d;
                            Decimal val = 1000 * d;                
                            QC_Account_Data__c datanormal = cc_initData.initQCAccountData(qcacc.Id,qcacc.AccountOwner__c, dtime, val, qty , 'Normal');
                            datanormal.Sale__c = owner.Id;
                            listQCAccountData.add(datanormal);
                        }else{
                            Integer qty = 20 * d;
                            Decimal val = 1500 * d;        

                            QC_Account_Data__c dataPromo = cc_initData.initQCAccountData(qcacc.Id,qcacc.AccountOwner__c, dtime, val, qty ,'Promo');
                            dataPromo.Sale__c = owner.Id;
                            listQCAccountData.add(dataPromo);
                        }
                    }
                insert listQCAccountData;  

                Lead ld = cc_initData.initLead();
                insert ld;

                Opportunity  opp = cc_initData.initOpportunity(acc.Id); 
                insert opp;   

                Media_Plan__c mp = cc_initData.initMediaPlan(acc.Id, opp.Id);
                insert mp;

                Make_design__c md = cc_initData.initDesign(mp.Id, mdRecTypeId);
                insert md;

                Ads_Campaign__c ads = cc_initData.initAdsCampaign(acc.Id, opp.Id, qcacc.Id);
                insert ads;

                Transfer_Request__c rq = cc_initData.initTransferRequest(owner.Id, newUser.Id, 'Sale User', 'Sale;Account;Contract;QC Account;Lead;Media Plan;Make Design/Content;Ads Campaign');
                rq.Status__c = 'New';
                rq.Approval_Status__c = 'New';
                
                insert rq;
            }

            
            Transfer_Request__c newRq = [SELECT Id FROM Transfer_Request__c WHERE Name = 'Test Transfer Request' LIMIT 1];
            newRq.Approval_Status__c = 'Approved';
            newRq.Is_Immediately__c = true;

            update newRq;
            delete newRq;
            undelete newRq;
            update newRq;

            cc_TriggerException exp = new cc_TriggerException();
        try {
            Test.stopTest();
            Transfer_Request__c result = [SELECT Id,Status__c FROM Transfer_Request__c WHERE Name = 'Test Transfer Request' LIMIT 1];

            System.assertEquals('Completed', result.Status__c);
            
        } catch (Exception ex) {
            
        }
        
        Test.getEventBus().deliver();    
    }

}