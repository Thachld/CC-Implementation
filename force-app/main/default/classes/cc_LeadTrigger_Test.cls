@IsTest(SeeAllData=true)
public class cc_LeadTrigger_Test { 
    public static testMethod void test(){
        //mock call out
        Test.setMock(HttpCalloutMock.class, new cc_QcAccountChatterBatch_mock_Test());
        //Get admin user
        User us = [select id from user where profile.name = 'System Administrator' and isactive = true limit 1];
        //get sales user 
        User sales = [select id from user where profile.name = 'Sales Profile' and isactive = true limit 1];
        //get support user
        User support = [select id from user where profile.name = 'Support Profile' and isactive = true limit 1];
        //get hotline ownerid
        Owner__mdt ownerhotline = [SELECT ID__c FROM Owner__mdt where Label = 'Hotline' limit 1];
        Owner__mdt Pharmacyowner = [SELECT ID__c FROM Owner__mdt where Label = 'Pharmacy' limit 1];
        system.runAs(us){
            //create new QC account and insert
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.QC_Account_Id__c = '1';
            qcAccount.Support__c = support.id;
            insert qcAccount;
            
            //create new lead and insert
            Lead newlead = cc_initData.initLead();
            newlead.QC_Account_Id__c = '1';
            newlead.OwnerId = ownerhotline.ID__c;
            newlead.Industry_c__c = 'Airlines';
            newlead.LeadSource = 'DMP';
            system.debug(newlead);
            insert newlead;
                        
            //update Lead's industry
            //
            
            newlead.Industry_c__c = 'Pharmacy';
            update newlead;
            system.debug(newlead);
                       
            Lead updatelead  = [SELECT Id, OwnerId, Industry_c__c FROM Lead WHERE Id = :newlead.Id LIMIT 1];          
            system.assertEquals(Pharmacyowner.ID__c, updatelead.OwnerId);
            
            //update lead owner
            newlead.ownerid = sales.id;
            system.debug(newlead);
            update newlead;
            //check if lead owner become qc account owner
            QC_account__c qcAfterUpdate  = [select id,ownerid,industry__c from QC_account__c where QC_Account_Id__c = '1'];
            system.assertEquals(sales.id, qcAfterUpdate.ownerid);
            //convert lead
            Database.LeadConvert lc = new database.LeadConvert();
            lc.setLeadId(newlead.id);
            lc.setDoNotCreateOpportunity(true);
            lc.setConvertedStatus('Converted');
            Database.LeadConvertResult lcr = Database.convertLead(lc);
            
            
        }        
    }
}