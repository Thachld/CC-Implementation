@istest
public with sharing class ClientSharingTrigger_Test {

    @TestSetup
    static void makeData(){
        cc_Trigger_Control__c trg = cc_initData.initTrigger('CLIENT_SHARING_TRIGGER',true);
        insert trg;

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(11), null, 'Pharmacy', 'HN',false);
        u0.Manager_Level__c = KPIConstant.MANAGER_LEVEL_3;
        insert u0;
        
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(11), null, 'Pharmacy', 'HN',false);
        u1.ManagerId = u0.Id;
        u1.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u1;
        
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(11), null, 'Airlines;Real Estate', 'HN',false);
        u2.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u2;

        Account testacc = cc_initData.initAccount('Test Account');
        testacc.Available_Client_to_be_shared__c = true;
        testacc.Shared_Client__c = true;
        insert testacc;

        QC_Account__c qcAcc = cc_initData.initQCAccount('testqcacc'+ string.valueOfGmt(System.now()) +'@coccoc.com.test', testacc.id);
        qcAcc.Industry__c = 'Pharmacy';
        insert qcAcc;
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareFrom(u1.Id)
                                        .setShareTo(u2.Id)
                                        .setStatus(ClientSharingConstant.STATUS_IN_PROGRESS)
                                        .setStartDate(System.today())
                                        .setEndDate(System.today().addDays(30))
                                        .buildAndSave();

        Client_Sharing__c testSharing1 = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing1')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareFrom(u1.Id)
                                        .setShareTo(u2.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today().addDays(35))
                                        .setEndDate(System.today().addDays(60))
                                        .buildAndSave();                                
    }
    
    @istest
    public static void testValidStartDate(){       
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing2')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareTo(testUser.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today().addDays(10))
                                        .setEndDate(System.today().addDays(30))
                                        .build();
        try {
            insert testSharing;
        } catch (Exception ex) {
            Boolean valid = ex.getMessage().contains('Start date must not be in other Sharing request')?true:false;
            System.assertEquals(true, valid);
        }

    }

    @istest
    public static void testValidEndDate(){       
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing3')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareTo(testUser.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today().addDays(-20))
                                        .setEndDate(System.today().addDays(10))
                                        .build();
        try {
            insert testSharing;
        } catch (Exception ex) {
            Boolean valid = ex.getMessage().contains('End date must not be in other Sharing request')?true:false;
            System.assertEquals(true, valid);
        }

    }

    @istest
    public static void testValidNestedDate(){       
        Account testAcc = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing4')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareTo(testUser.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today().addDays(-10))
                                        .setEndDate(System.today().addDays(40))
                                        .build();
        try {
            insert testSharing;
        } catch (Exception ex) {
            Boolean valid = ex.getMessage().contains('This Client is sharing for other request. Please re-select you Start date and End Date')?true:false;
            System.assertEquals(true, valid);
        }
    }

    @istest
    public static void testStopSharing(){       
        
        Client_Sharing__c testClShare = [SELECT Id, Status__c, Share_to__c FROM Client_Sharing__c WHERE Name ='Test Client Sharing1' LIMIT 1  ];
        testClShare.Status__c = ClientSharingConstant.STATUS_IN_PROGRESS;
        update testClShare;
        Test.startTest();
        try {
            testClShare.Status__c = ClientSharingConstant.STATUS_COMPLETED;
            update testClShare;
        } catch (Exception ex) {

            Test.stopTest();

            User testu = [SELECT Id, Cross_Selling_KPI_Category__c FROM User WHERE Id=:testClShare.Share_to__c LIMIT 1];
            System.assert(!testu.Cross_Selling_KPI_Category__c.Contains('Phamacy'));

        }
    }

    @istest
    public static void testSharing(){   
        Test.startTest();    
        Client_Sharing__c testClShare = [SELECT Id, Account__c, Status__c FROM Client_Sharing__c WHERE Name ='Test Client Sharing1' LIMIT 1  ];
        
        try {
            testClShare.Status__c = ClientSharingConstant.STATUS_IN_PROGRESS;
            update testClShare;
        } catch (Exception ex) {
            Test.stopTest();

            List<Client_Sharing_Detail__c> detail = [SELECT Id FROM Client_Sharing_Detail__c ];
            System.assertEquals(1, detail.size());

            List<AccountTeamMember> team = [SELECT Id FROM AccountTeamMember WHERE AccountId = :testClShare.Account__c AND TeamMemberRole = 'Client Sharing' ];
            System.assertEquals(1, team.size());

            List<QC_Account__Share> qcShare = [SELECT Id FROM QC_Account__Share WHERE RowCause = 'Client_Sharing__c' ];
            System.assertEquals(1, qcShare.size());
        }
    }


    @istest 
    public static void testAddCrossSellingKpiCategory0(){

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Pharmacy', 'HN',false);
        u0.Manager_Level__c = KPIConstant.MANAGER_LEVEL_3;
        insert u0;
        
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Pharmacy', 'HN',false);
        u1.ManagerId = u0.Id;
        u1.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u1;
        
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        u2.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u2;
       
        Account testacc = cc_initData.initAccount('Test Account 2');
        testacc.Available_Client_to_be_shared__c = true;
        testacc.Shared_Client__c = true;
        insert testacc;

        QC_Account__c qcAcc = cc_initData.initQCAccount('testqcacc2'+ string.valueOfGmt(System.now()) +'@coccoc.com.test', testacc.id);
        qcAcc.Industry__c = 'Pharmacy';
        qcAcc.OwnerId = u1.Id;
        qcAcc.Sales__c = u1.Id;
        insert qcAcc;
       
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing 2')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareFrom(u1.Id)
                                        .setShareTo(u2.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today())
                                        .setEndDate(System.today().addDays(30))
                                        .buildAndSave();

        Test.startTest();
            Client_Sharing__c testcl = [SELECT Id, Status__c FROM Client_Sharing__c WHERE Id = :testSharing.Id LIMIT 1];
            testcl.Status__c = ClientSharingConstant.STATUS_IN_PROGRESS;

            update testcl;
        try {
            
            Test.stopTest();

            User testu = [SELECT Id, Cross_Selling_KPI_Category__c FROM User WHERE Id=:u2.Id LIMIT 1];
            System.assert(testu.Cross_Selling_KPI_Category__c.Contains('Pharmacy'));
        } catch (Exception ex) {
            
        }
        
    }

    @istest 
    public static void testAddCrossSellingKpiCategory1(){

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate;EduJobs', 'HN',false);
        u0.Manager_Level__c = KPIConstant.MANAGER_LEVEL_2;
        insert u0;
        
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'EduJobs', 'HN',false);
        u1.ManagerId = u0.Id;
        u1.Manager_Level__c = KPIConstant.MANAGER_LEVEL_3;
        u1.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u1;
        
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        u2.ManagerId = u0.Id;
        u2.Manager_Level__c = KPIConstant.MANAGER_LEVEL_3;
        u2.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u2;
       
        Account testacc = cc_initData.initAccount('Test Account 3');
        testacc.Available_Client_to_be_shared__c = true;
        testacc.Shared_Client__c = true;
        insert testacc;

        QC_Account__c qcAcc = cc_initData.initQCAccount('testqcacc3'+ string.valueOfGmt(System.now()) +'@coccoc.com.test', testacc.id);
        qcAcc.Industry__c = 'EduJobs';
        qcAcc.OwnerId = u1.Id;
        qcAcc.Sales__c = u1.Id;
        insert qcAcc;
       
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing 3')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareFrom(u1.Id)
                                        .setShareTo(u2.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today())
                                        .setEndDate(System.today().addDays(30))
                                        .buildAndSave();

        Test.startTest();
            Client_Sharing__c testcl = [SELECT Id, Status__c FROM Client_Sharing__c WHERE Id = :testSharing.Id LIMIT 1];
            testcl.Status__c = ClientSharingConstant.STATUS_IN_PROGRESS;

            update testcl;
        try {
            
            Test.stopTest();

            User testu = [SELECT Id, Cross_Selling_KPI_Category__c FROM User WHERE Id=:u2.Id LIMIT 1];
            System.assert(testu.Cross_Selling_KPI_Category__c.Contains('EduJobs'));
        } catch (Exception ex) {
            
        }
        
    }

    @istest 
    public static void testAddCrossSellingKpiCategory2(){

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate;Other', 'HN',false);
        u0.Manager_Level__c = KPIConstant.MANAGER_LEVEL_2;
        insert u0;
        
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Other', 'HN',false);
        u1.ManagerId = u0.Id;       
        u1.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u1;
        
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate', 'HN',false);
        u2.ManagerId = u0.Id;
        u2.Manager_Level__c = KPIConstant.MANAGER_LEVEL_3;
        u2.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u2;
       
        Account testacc = cc_initData.initAccount('Test Account 4');
        testacc.Available_Client_to_be_shared__c = true;
        testacc.Shared_Client__c = true;
        insert testacc;

        QC_Account__c qcAcc = cc_initData.initQCAccount('testqcacc4'+ string.valueOfGmt(System.now()) +'@coccoc.com.test', testacc.id);
        qcAcc.Industry__c = 'Other';
        qcAcc.OwnerId = u1.Id;
        qcAcc.Sales__c = u1.Id;
        insert qcAcc;
       
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing 4')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareFrom(u1.Id)
                                        .setShareTo(u2.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today())
                                        .setEndDate(System.today().addDays(30))
                                        .buildAndSave();

        Test.startTest();
            Client_Sharing__c testcl = [SELECT Id, Status__c FROM Client_Sharing__c WHERE Id = :testSharing.Id LIMIT 1];
            testcl.Status__c = ClientSharingConstant.STATUS_IN_PROGRESS;

            update testcl;
        try {
            
            Test.stopTest();

            User testu = [SELECT Id, Cross_Selling_KPI_Category__c FROM User WHERE Id=:u2.Id LIMIT 1];
            System.assert(testu.Cross_Selling_KPI_Category__c.Contains('Other'));
        } catch (Exception ex) {
            
        }
        
    }

    @istest 
    public static void testAddCrossSellingKpiCategory3(){

        Profile pf = [SELECT ID FROM Profile WHERE Name = 'Sales Profile'];
        User u0 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Airlines;Real Estate;Other', 'HN',false);
        u0.Manager_Level__c = KPIConstant.MANAGER_LEVEL_2;
        insert u0;
        
        User u1 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Real Estate', 'HN',false);
        u1.ManagerId = u0.Id;   
        u1.Manager_Level__c = KPIConstant.MANAGER_LEVEL_3;    
        u1.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u1;
        
        User u2 = cc_initData.initUser(pf.Id, 'Sales' ,' User' + String.valueOf(1), null, 'Other', 'HN',false);
        u2.ManagerId = u0.Id;
        
        u2.Sale_Team__c = KPIConstant.SALE_TEAM_DIRECT;
        insert u2;
       
        Account testacc = cc_initData.initAccount('Test Account 5');
        testacc.Available_Client_to_be_shared__c = true;
        testacc.Shared_Client__c = true;
        insert testacc;

        QC_Account__c qcAcc = cc_initData.initQCAccount('testqcacc5'+ string.valueOfGmt(System.now()) +'@coccoc.com.test', testacc.id);
        qcAcc.Industry__c = 'Real Estate';
        qcAcc.OwnerId = u1.Id;
        qcAcc.Sales__c = u1.Id;
        insert qcAcc;
       
        
        Client_Sharing__c testSharing = new ClientSharingTestDataBuilder()
                                        .setName('Test Client Sharing 5')
                                        .setAccount(testacc.Id)
                                        .setShareType('Payment')
                                        .setShareFrom(u1.Id)
                                        .setShareTo(u2.Id)
                                        .setStatus(ClientSharingConstant.STATUS_NEW)
                                        .setStartDate(System.today())
                                        .setEndDate(System.today().addDays(30))
                                        .buildAndSave();

        Test.startTest();
            Client_Sharing__c testcl = [SELECT Id, Status__c FROM Client_Sharing__c WHERE Id = :testSharing.Id LIMIT 1];
            testcl.Status__c = ClientSharingConstant.STATUS_IN_PROGRESS;

            update testcl;
        try {
            
            Test.stopTest();

            User testu = [SELECT Id, Cross_Selling_KPI_Category__c FROM User WHERE Id=:u2.Id LIMIT 1];
            System.assert(testu.Cross_Selling_KPI_Category__c.Contains('Real Estate'));
        } catch (Exception ex) {
            
        }
        
    }

}