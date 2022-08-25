@IsTest(SeeAllData=true)
public with sharing class cc_QC_AccountHandler_Test {
    @istest
    public static void testInsert(){

        List<User> salesUsers = [select id, QC_Email__c from user where isActive= true and profile.Name='Sales Profile' limit 2];
        List<User> userList = [select id, QC_Email__c from user where isActive= true and profile.Name='System Administrator' limit 10];
        List<user> userListSale = [select id, QC_Email__c from user where isActive= true and profile.Name !='System Administrator' limit 10 ];

        System.runas(userList.get(0)) {
            Test.startTest();
            Account acc = cc_initData.initAccount();
            insert acc;
            
            AccountTeamMember team = cc_initData.initTeamAccount(acc.Id, userList.get(1).Id , 'Ad Op Manager');
            insert team;

            QC_Account__c qcAccount = cc_initData.initQCAccount();
            qcAccount.OwnerId = salesUsers.get(0).id;
            qcAccount.AccountOwner__c = acc.Id;
            qcAccount.Sales__c = userList.get(0).id;
            qcAccount.Support__c  = userList.get(0).id;
            qcAccount.QC_Account_Id__c = '2244111111';
            qcAccount.Register_time__c = System.now() - 10;
            insert qcAccount;                     
            
            try {
                Test.stopTest();                
            } catch (Exception ex) {
                
            }

            Test.getEventBus().deliver();                
        }
    }

    @istest
    public static void testUpdate(){
        List<User> salesUsers = [select id, QC_Email__c from user where isActive= true and profile.Name='Sales Profile' limit 2];
        List<User> userList = [select id, QC_Email__c from user where isActive= true and profile.Name='System Administrator' limit 10];
        List<user> userListSale = [select id, QC_Email__c from user where isActive= true and profile.Name !='System Administrator' limit 10 ];

        System.runas(userList.get(0)) {
            Test.startTest();
                RecordType recordtype = [SELECT Id, Name FROM recordType WHERE Name = 'Agency'];
                Account acc1 = cc_initData.initAccount('Test Account 1');
                acc1.RecordTypeId = recordtype.Id;
                insert acc1;    

                recordtype = [SELECT Id, Name FROM recordType WHERE Name = 'Client'];
                Account acc2 = cc_initData.initAccount('Test Account 2');
                acc2.RecordTypeId = recordtype.Id;
                insert acc2;    
                
                AccountTeamMember team = cc_initData.initTeamAccount(acc1.Id, userList.get(0).Id , 'Ad Op Manager');
                insert team;

                QC_Account__c qcAccount = cc_initData.initQCAccount();
                    qcAccount.OwnerId = salesUsers.get(0).id;
                    qcAccount.Sales__c = userList.get(0).id;
                    qcAccount.AccountOwner__c = acc1.Id;
                    qcAccount.Support__c  = userList.get(0).id;
                    qcAccount.QC_Account_Id__c = '2244111111';
                    qcAccount.Register_time__c = System.now() - 10;
                    insert qcAccount;

                QC_Account__Share temp = new QC_Account__Share();
                    temp.AccessLevel = 'Edit';
                    temp.ParentId = qcAccount.Id ;
                    temp.RowCause = 'Manual';
                    temp.UserOrGroupId = userListSale.get(1).Id; //2
                    insert temp;
                
                //Update
                    qcAccount.AccountOwner__c = acc2.Id;
                    qcAccount.Sales__c = userList.get(1).Id;
                    qcAccount.Support__c  = userList.get(1).Id;                
                    qcAccount.OwnerId = salesUsers.get(1).Id;	
                    update qcAccount;

                    qcAccount.Support__c  = userListSale.get(2).Id;//2   
                    update qcAccount;
            
            try {
                Test.stopTest();                
            } catch (Exception ex) {
                
            }

            Test.getEventBus().deliver();    
        }
    }
}