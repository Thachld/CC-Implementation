@IsTest(SeeAllData=true)
public class cc_QCAccountTrigger_Test {
    @isTest
    public static void testQCAccount(){
        
        List<User> salesUsers = [select id, QC_Email__c from user where isActive= true and profile.Name='Sales Profile' limit 2];
        List<User> userList = [select id, QC_Email__c from user where isActive= true and profile.Name='System Administrator' limit 10];
        List<user> userListSale = [select id, QC_Email__c from user where isActive= true and profile.Name !='System Administrator' limit 10 ];
        // cc_setting__c settting = cc_initData.initCustomeSetting();
        // insert settting;

        // cc_Profile__c profile = cc_initData.initProfileSetting('Sales Profile', '00e0o000003Ewa5');
        // insert profile;

        System.runas(userList.get(0)) {
            Test.startTest();
            Account acc = cc_initData.initAccount();
            insert acc;
            
            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.OwnerId = salesUsers.get(0).id;
            qcAccount.Sales__c = userList.get(0).id;
            qcAccount.Support__c  = userList.get(0).id;
            qcAccount.QC_Account_Id__c = '2244111111';
            insert qcAccount;
            QC_Account__Share temp = new QC_Account__Share();
            temp.AccessLevel = 'Edit';
            temp.ParentId = qcAccount.id ;
            temp.RowCause = 'Manual';
            temp.UserOrGroupId = userListSale.get(2).id; //2
            insert temp;
            
            
            qcAccount.AccountOwner__c = acc.id;
            qcAccount.Sales__c = userList.get(1).id;
            qcAccount.Support__c  = userList.get(1).id;
            system.debug('debug#' + userList.get(1).id);
            qcAccount.OwnerId = salesUsers.get(1).id;		
            
            update qcAccount;
            qcAccount.Support__c  = userListSale.get(2).id;//2   
            update qcAccount;
            
            Test.stopTest();
        }
    }
}