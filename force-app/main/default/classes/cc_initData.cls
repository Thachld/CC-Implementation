@istest
public class cc_initData {
    public static User initUser(Id profID, String fName, String lName, String roldId){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,                                
                                email = uniqueName + '@cococ' + orgId + '.com',
                                Username = uniqueName + '@cococ' + orgId + '.com',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = lName,
                                TimeZoneSidKey = 'Asia/Ho_Chi_Minh',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                UserPermissionsSupportUser  = true,
                                Sale_Team__c = 'Direct',
                                ProfileId = profID,
                                UserRoleId = roldId );                             
        return tuser;
    }

    public static User initUser(Id profID, String fName, String lName, String roldId, String kpicate, String region, Boolean xaxisOwner){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,                                
                                email = uniqueName + '@cococ' + orgId + '.com',
                                Username = uniqueName + '@cococ' + orgId + '.com',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = lName,
                                Trac_Name__c = lName,
                                TimeZoneSidKey = 'Asia/Ho_Chi_Minh',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                UserPermissionsSupportUser  = true,
                                KPI_Category__c = kpicate,
                                Region__c = region,
                                Owner_Xaxis__c = xaxisOwner,
                                Sale_Team__c = 'Direct',
                                ProfileId = profID,                                
                                UserRoleId = roldId );                             
        return tuser;
    }

    public static User initUser(Id profID, String fName, String lName, String roldId, String kpicate, String region, Boolean xaxisOwner, String team){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        
        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(  firstname = fName,
                                lastName = lName,                                
                                email = uniqueName + '@cococ' + orgId + '.com',
                                Username = uniqueName + '@cococ' + orgId + '.com',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = lName,
                                Trac_Name__c = lName,
                                TimeZoneSidKey = 'Asia/Ho_Chi_Minh',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                UserPermissionsSupportUser  = true,
                                KPI_Category__c = kpicate,
                                Region__c = region,
                                Owner_Xaxis__c = xaxisOwner,
                                Sale_Team__c = team,
                                ProfileId = profID,
                                UserRoleId = roldId );                             
        return tuser;
    }

    public static HandOver_Minute__c initHandOverMinute(){
        HandOver_Minute__c hom = new HandOver_Minute__c();
        hom.name = 'test';
        hom.status__c = 'new';
        return hom;
    }

    public static HandOver_Minute__c initHandOverMinute(String accId, String conId, Date beginDT, Date endDT){
        HandOver_Minute__c hom = new HandOver_Minute__c();
        hom.name = 'HOM Test ';
        hom.status__c = 'New';
        hom.Custom_Contract__c = conId;
        hom.Account__c = accId;       
        hom.Start_Date__c = beginDT;
        hom.End_Date__c =  endDT;

        return hom;
    }
    public static Contract_link__c initContractLink(id contractId, id qcAccountId){
        Contract_link__c cl = new Contract_link__c();
        cl.Contract__c = contractId;
        cl.QC_Account__c = qcAccountId;
        return cl;
    }
    
    public static Contract__c initContract(id accId, date startDate, date endDate)
    {
        Contract__c ctr = new Contract__c();
        ctr.name = 'test';
        ctr.Account__c = accId;
        ctr.Contract_Start_Date__c = startDate;
        ctr.Contract_End_Date__c = endDate;
        ctr.DiscountBonus_as_Policy__c = false;
        ctr.Special_discount__c = 20;
        ctr.Discount_By__c = 'Special Discount/Bonus';
        ctr.Type__c = 'Master - Commitment';
        
        ctr.Commitment_Value__c = 100;
        ctr.Ads_type__c = 'Icons';
        return ctr;
    }

    public static Contract__c initContract(Id accId, date startDate, date endDate, String type)
    {
        Contract__c ctr = new Contract__c();
        ctr.name = 'test';
        ctr.Account__c = accId;
        ctr.Contract_Start_Date__c = startDate;        
        ctr.DiscountBonus_as_Policy__c = false;
        ctr.Discount_By__c = 'Special Discount';
        ctr.Discount_By__c = 'Special Discount/Bonus';
        ctr.Special_discount__c = 20;
        ctr.Type__c = type;
        ctr.Active__c = true;
        ctr.No_expire_date__c = true;
        ctr.Commitment_Value__c = 100;
        if(!type.startsWith('Master')){           
            ctr.Contract_value_Incl_VAT__c = 20;
        }
        
        ctr.Ads_type__c = 'Icons';
        ctr.Payment_method__c = 'Prepaid';
        ctr.Status__c = 'Done';
        return ctr;
    }
   
    public static Lead initLead(){
        Lead l = new Lead();
        l.Industry_c__c = 'Ecommerce';
        l.LastName = 'test';
        l.QC_Account_Id__c = '1234';
        l.Website = 'www.google.com.vn';
        return l;
    }

    public static Lead initLead(String name, String email, String website){
        Lead l = new Lead();
        l.Industry_c__c = 'Ecommerce';
        l.LastName = name;        
        l.Website = website;
        l.Email = email;
        return l;
    }


    public static Lead initLead(String ownerId, String website){
        Lead l = new Lead();
        l.Industry_c__c = 'Ecommerce';
        l.LastName = 'test';
        l.QC_Account_Id__c = '1234';
        l.Website = website;
        l.OwnerId = ownerId;
        return l;
    }

    public static cc_setting__c initCustomeSetting(){
        cc_setting__c ccSetting = new cc_setting__c();
        ccSetting.Name = 'cc setting';
        ccSetting.Hotline__c = 'Hotline';
        ccSetting.payment_assignee__c = 'test1@coccoc.com.qa';
        ccSetting.push_topic__c = 'CreateNormalPaymentStr';
        ccSetting.Qc_account_email__c = 'thuyntm@coccoc.com';
        ccSetting.is_write_api_log__c = true;
        ccSetting.Fixing_Payment_and_Spending__c = '0050o00000XnIz3AAF';
        ccSetting.Ads_Local__c = 'Ads Local';
        ccSetting.Consultant_to_Agency_Business__c = 'Consultant to Agency Business';
        ccSetting.Deputy_Head_of_Agency__c = 'Deputy Head of Agency';
        ccSetting.Global_Ads_Leader__c = 'Ads Operation Team leader';
        ccSetting.Xaxis_Name__c = 'Xaxis Inc';
        ccSetting.Hom_assign__c = '0050o00000Xok43AAB';
        ccSetting.CouponDefaultAssignee__c = '0050o00000XojprAAB';
        return ccSetting;
    }
   
    public static QC_Account__c initQCAccount(){
        QC_Account__c   qcAccount = new QC_Account__c();
        qcAccount.name = 'toannguye114@gmail.com';
        qcAccount.Industry__c = 'Retails';
        qcAccount.Status__c = 'New Account';
        return qcAccount;
    }

    public static QC_Account__c initQCAccount(String name, Id accId){
        QC_Account__c   qcAccount = new QC_Account__c();
        qcAccount.AccountOwner__c = accId;
        if(String.isBlank(name)){
            qcAccount.name = 'dinhthach.it@coccoc.com.test';
        }else{
            qcAccount.name = name;
        }        
        
        qcAccount.Industry__c = 'Airlines';
        qcAccount.Status__c = 'New Account';
        return qcAccount;
    }

    public static QC_Account__c initQCAccount(String name, Id accId, String industry, Boolean xaxis, Boolean special_client, Boolean Strategic_client, String saleId){
        QC_Account__c   qcAccount = new QC_Account__c();
        qcAccount.AccountOwner__c = accId;
        if(String.isBlank(name)){
            qcAccount.name = 'dinhthach.it@coccoc.com.test';
        }else{
            qcAccount.name = name;
        }        
        
        qcAccount.Industry__c = industry;        
        qcAccount.Xaxis__c = xaxis;
        qcAccount.Special_Client__c = special_client;
        qcAccount.Strategic_Client__c = Strategic_client;
        qcAccount.Sales__c = saleId;
        qcAccount.Status__c = 'New Account';
        return qcAccount;
    }


    public static Payment__c initPayment(string recordType, string transactionId, string qcAccountId)
    {
        Payment__c payment = new Payment__c();
        payment.RecordTypeId = recordType;
        payment.Name = transactionId;
        payment.Amount__c = 100000;
        payment.Effective_date__c = datetime.newInstance(2020,1,2,0,0,0);
        payment.Final_Amount__c = 100000;
        payment.Payment_method__c = 'Cash';
        payment.QC_Account__c = qcAccountId;
        payment.Stage__c = 'Done';
        payment.State_temp__c = 'Done';
        payment.Type__c = 'INCOME';
        return payment;
    }

    public static Payment__c initPayment(string recordType, string transactionId, string qcAccountId, Date effdt, String saleId, String industry, String agency)
    {
        Payment__c payment = new Payment__c();
        payment.RecordTypeId = recordType;
        payment.Name = transactionId;
        payment.Amount__c = 100000;
        payment.Effective_date__c = effdt;
        payment.Final_Amount__c = 100000;
        payment.Payment_method__c = 'Cash';
        payment.QC_Account__c = qcAccountId;
        payment.Stage__c = 'Done';
        payment.State_temp__c = 'Done';
        payment.Type__c = 'INCOME';
        payment.Sale__c = saleId;
        payment.Industry__c = industry;
        payment.Agency__c = agency;
        return payment;
    }

    public static Account initAccount(){
        Account acc = new Account();
        acc.name = 'test';
        acc.Industry__c = 'Airlines';
        return acc;
    }

    public static Account initAccount(String name){
        Account acc = new Account();
        acc.name = name;
        acc.Industry__c = 'Airlines';
        return acc;
    }

    public static Account initAccount(String name, String recordType, String area,String industry){
        Account acc = new Account();
        acc.RecordTypeId = recordType;
        acc.name = name;
        acc.Area__c = area;
        acc.Industry__c = industry;
        return acc;
    }


    public static Relationship__c initRelationship(id qcId, id accId)
    {
        Relationship__c relationship = new Relationship__c();
        relationship.Account__c = accId;
        relationship.QC_Account__c = qcId;
        relationship.Relationship_Type__c = 'Own';
        return relationship;
    }
    public static FeedItem initFeedItem(string userId, string recordId){
        FeedItem post = new FeedItem();
        post.ParentId = userId;
        post.RelatedRecordId = recordId;
        post.Body = 'test';
        post.Title = 'QC Account Permission';
        return post;
    }

    public static FeedItem initFeedItem(string caseId, String title, String body){
        FeedItem post = new FeedItem();
        post.ParentId = caseId;       
        post.Body = body;
        post.Title = title;        
        return post;
    }

    public static FeedComment initFeedComment(string feedId, String body){
        FeedComment comm = new FeedComment();        
        comm.CommentBody  = body;
        comm.CommentType  = 'TextComment';   
        comm.FeedItemId = feedId;     
        return comm;
    }

    public static Opportunity initOpportunity(id accId){
        Opportunity opp = new Opportunity();
        opp.StageName = 'New';
        opp.CloseDate = date.today();
        opp.name = 'test';
		opp.AccountId = accId; 
        return opp;
    }

    public static Opportunity initOpportunity(id accId, String OwnerId, String stage, Date closedt){
        Opportunity opp = new Opportunity();
        opp.StageName = stage;
        opp.CloseDate = closedt;
        opp.name = 'test';
        opp.AccountId = accId; 
        opp.OwnerId = OwnerId;        
        return opp;
    }

    public static Media_Plan__c initMediaPlan(id accId, id oppId){
        Media_Plan__c m = new Media_Plan__c();
        m.Name = 'test';
        m.Account__c = accId;
        m.Opportunity__c = oppId;
        m.Budget__c = 100;
        return m;
    }
    public static Make_design__c initDesign(id mediaplan, id rctyid){
        Make_design__c design = new Make_design__c();
        design.name = 'Test';
        design.Media_plan__c = mediaplan;
        design.RecordTypeId = rctyid;
        return design;
    }

    public static Ads_Campaign__c initAdsCampaign(String accId, String oppId, String qcId){
        Ads_Campaign__c ads = new Ads_Campaign__c();
        ads.Account__c = accId;
        ads.Opportunity__c = oppId;
        ads.QC_Account__c = qcId;
        ads.Due_date__c = System.today() + 90;
        ads.Stage__c = 'New';
        ads.Type__c = 'Banners newtab';

        return ads;
    }

    public static Campaign initCampaign(String name,  Date startDate){
        Campaign camp = new Campaign();
      
        camp.Name = name;        
        camp.Status = 'In Progress';
        camp.IsActive = true;        
        camp.Type = 'Email';
        camp.StartDate = startDate;

        return camp;
    }

    public static CampaignMember initCampaignMember(String campId, String conId){
        CampaignMember member = new CampaignMember();
        
        member.CampaignId = campId;
        member.ContactId = conId;
        member.Status = 'Sent';  

        return member;
    }

    public static CampaignMember initCampaignMember(String campId, String leadid, String status){
        CampaignMember member = new CampaignMember();
        
        member.CampaignId = campId;
        member.LeadId = leadid;
        member.Status = 'Sent';  

        return member;
    }

    public static Contact initContact(String name, String accountId){
        Contact con = new Contact();
        
        con.LastName  = name;       
        con.AccountId = accountId;        

        return con;
    }


    public static Transfer_Request__c initTransferRequest(String fromUser, String toUser, String type, String category){
        Transfer_Request__c rq = new Transfer_Request__c();
        rq.name = 'Test Transfer Request';
        rq.From_User__c = fromUser;
        rq.To_User__c = toUser;
        rq.Transfer_Type__c = type;
        rq.Transfer_Category__c = category;
        rq.Transfer_Date__c = System.today()-1;
        return rq;
    }

    public static cc_Trigger_Control__c initTrigger(String name, Boolean val){        
        cc_Trigger_Control__c tg = new cc_Trigger_Control__c();

        tg.name = name;
        tg.allow_run__c = val;

        return tg;
    }

    public static cc_Profile__c initProfileSetting(String name, String prfId){        
        cc_Profile__c prf = new cc_Profile__c();

        prf.name = name;
        prf.ProfileId__c = prfId;

        return prf;
    }

    public static AccountTeamMember initTeamAccount(string accountId, string userId, string role){
        AccountTeamMember team = new AccountTeamMember();
        team.AccountAccessLevel = 'Read';
        team.ContactAccessLevel = 'None';
        team.OpportunityAccessLevel = 'None';
        team.CaseAccessLevel = 'None';
        
        team.AccountId = accountId;
        if(!String.isBlank(role)){
            team.TeamMemberRole = role;
        }else{
            team.TeamMemberRole = 'Ad Op Manager';
        }       
        
        team.UserId = userId;
        return team;
    }

    public static cc_Batch_Parameter__c initbatchParamSetting(String name, Date fromDt, Date toDT, String clause1,String clause2, 
                                                                String fieltotal, String fieldAccum, String fieldAccumAlias, String objectAccum,
                                                                String arrField, String arrFunc, Integer batchSize){        
        cc_Batch_Parameter__c prf = new cc_Batch_Parameter__c();

        prf.name = name;
        prf.From_Date__c = fromDt;
        prf.To_Date__c = toDT;

        prf.Field_Total__c = fieltotal;
        prf.FieldAccum__c = fieldAccum;
        prf.FieldAccumAlias__c = fieldAccumAlias;
        prf.ObjectAccum__c = objectAccum;
        prf.AgregateField__c = arrField;
        prf.AggregateFunc__c = arrFunc;
        prf.BatchSize__c = batchSize;

        prf.Where_Clause1__c = clause1;
        prf.Where_Clause2__c = clause2;

        return prf;
    }

    public static QC_Integration__c initQcIntegrationSetting(String name){
        QC_Integration__c integration = new QC_Integration__c();
        integration.Name = name;        
        integration.EncryptToken__c = 'WHE0uGENWfuckWOBzM1ZziQ6rZ8WHvCqypoAaopl1om3rS2LYNZcYUsw3h24LlCuEUkVIQs5FboBQnmd+jvNRA==	';
        integration.Key__c = 'v/T8rWxPKi/2Wnoz4tTYMeAly1L6gOIZu/p+6117pdE=';        

        return integration;
    }

    public static cc_KPI_Setting__c initKPISetting(String name){
        cc_KPI_Setting__c kpi = new cc_KPI_Setting__c();
        kpi.Name = name;
        kpi.SendEmailToManager__c = true;
        kpi.SendEmailToSale__c = true;   
        kpi.Sales_Director__c = '0050o00000Xn1UNAAZ';
        kpi.Sales_Director_PA__c = '0050o00000Xn3cmAAB';    
        kpi.PaymentRecordType__c = 'Normal_payment,Real_Payment,Standard_payment';    
        kpi.Paymentmethod__c = 'Cash,Bank Transfer,Payment Gateway';  
        kpi.IncludePayment__c = true;       
        kpi.SaleEmailtemplate__c = 'Sale_KPI_Template';       
        kpi.SupportEmailTemplate__c = 'Support_KPI_Template';    
        kpi.Day_to_Re_run_last_kpi_period__c = 2;       

        return kpi;
    }

    public static cc_Jira_Integration__c initJiraIntegrationSetting(String name, String dfjiraId){
        cc_Jira_Integration__c jira = new cc_Jira_Integration__c();
        jira.Name = name;       
        jira.defaultUser__c = dfjiraId;   
        jira.Defaut_Project__c = 'FS';
        jira.FieldLogChange__c = 'summary,status,assignee,project,priority,description,customfield_10049,reporter,issuetype,duedate	';          
        jira.restpath__c = 'rest/api/3/issue'; 
        jira.Chatter_Profile_Id__c = '00e0o000002QpEqAAK';      

        return jira;
    }

    public static Jira_Setting__c initJiraSetting(){
        Jira_Setting__c jira = new Jira_Setting__c();
        jira.Default_FrontLine_User__c = '005A7000000HwTgIAK';       
        jira.Default_Jira_CC__c = '0050o00000Xn1URAAZ';   
        jira.Default_Jira_Project__c = 'FS';
        jira.Default_Jira_Status__c = 'Backlog';          
        jira.FrontLine_Teams__c = '005A7000000HwTgIAK;0055h000001qtQqAAI;005A7000000I3xlIAC	'; 
        jira.SF_Admin__c = '0050o00000XLyrMAAT';      

        return jira;
    }

    public static cc_Payment_Setting__c initPaymentSetting(String name){
        cc_Payment_Setting__c py = new cc_Payment_Setting__c();

        py.Name = name;
        py.HOM_Calculation__c = 'Real_Payment';
        py.Paid_Amount_Calculation__c = 'Real_Payment;Refund_payment';
        py.Transferred_Payment__c = 'Transfer_payment';
        py.Weekend__c = 'Saturday;Sunday;';

        return py;
    }

    public static KPI__c initKPI(String name, String saleId, String period, Date startdt, Date enddt, String KPIcat){
        KPI__c kpi = new KPI__c();
        kpi.Name =name;
        kpi.Sales__c =saleId;
        kpi.Period__c = period;
        kpi.From_Date__c = startdt;
        kpi.To_Date__c = enddt;
        kpi.KPI_Category__c = KPIcat;
        kpi.Status__c = 'New';

        return kpi;
    }

    public static KPI__c initKPI(String name, String saleId, String period, Date startdt, Date enddt, String KPIcat, String managerId, String recordtypeId){
        KPI__c kpi = new KPI__c();
        kpi.Name =name;
        kpi.RecordTypeId = recordtypeId;
        kpi.Sales__c =saleId;
        kpi.SalesManager__c =managerId;
        kpi.Period__c = period;
        kpi.From_Date__c = startdt;
        kpi.To_Date__c = enddt;
        kpi.KPI_Category__c = KPIcat;
        kpi.Status__c = 'New';

        return kpi;
    }

    public static Sale_Spending_Payment__c initSaleSpendingPayment(String name, String kpiId, String cat){
        Sale_Spending_Payment__c saleKPI = new Sale_Spending_Payment__c();                           
        saleKPI.KPI__c = kpiId;
        saleKPI.KPI_Category__c = cat;
        saleKPI.Name = name;              
        
        return saleKPI;
    }

    public static Task initTask(String subj , String subtasktype,String OwnerId){
        Task tk = new Task();
        tk.Subject = subj;
        tk.TaskSubtype = subtasktype;
        tk.OwnerId = OwnerId;

        return tk;
    }

    public static Event initEvent(String subj , String type, String OwnerId){
        Event evt = new Event();
        evt.Subject = subj;
        evt.type = type;
        evt.OwnerId = OwnerId;
        evt.ActivityDateTime = System.now();
        evt.DurationInMinutes = 1000;
        return evt;
    }

    public static KPI_Target__c initKPITarget(String name, String saleId, String recordtypeId, String quater){
        KPI_Target__c target = new KPI_Target__c();

        target.Name = name;
        target.recordtypeId = recordtypeId;
        target.Sale_Manager__c = saleId;
        target.Status__c = 'New';
        target.Approval_status__c = 'Approved';
        target.Quarter__c = quater;

        return target;
    }

    public static KPI_Target_Detail__c initKPITargetdetail(String name, String saleId, String targetId, String quater, String period,String category){
        KPI_Target_Detail__c detail = new KPI_Target_Detail__c();

        detail.Name = name;
        detail.KPI_Target__c = targetId;
        detail.Sale__c = saleId;
        detail.Period__c = period;
        detail.KPI_Category__c = category;       
        detail.Quarter__c = quater;
        detail.PaymentKPI__c = 2000000;
        detail.SpendingKPI__c = 6000000;

        return detail;
    }

    public static TransferSpendingCash__c initTransferSpendingCash (String name, String saleId , String tosaleId, Date from_dt, Date to_dt, String purpose, String type,String obj ){
        TransferSpendingCash__c rq = new TransferSpendingCash__c();
        rq.Name = name;
        rq.From_Sale__c = saleId;
        rq.To_Sale__c = tosaleId;
        rq.From_date__c = from_dt;
        rq.To_date__c = to_dt;   
        rq.Transfer_Purpose__c = purpose;     
        rq.Transfer_Type__c = type;
        rq.Transferobject__c = obj;
        rq.Status__c = 'New';
        rq.Approval_Status__c = 'Approved';

        return rq;
    }

    public static EmailTemplate  initEmailTemplate(String name, String devname, String sub, String BodyVar){
        EmailTemplate emailTemplate = new EmailTemplate();
        emailTemplate.isActive = true;
        emailTemplate.Name = name;
        emailTemplate.Subject = sub;
        emailTemplate.DeveloperName = devname;
        emailTemplate.Body = BodyVar;      
        emailTemplate.TemplateType = 'text';
        emailTemplate.FolderId = UserInfo.getUserId();

        return emailTemplate;
    }  

    public static ContentVersion  initContentVersion(String title, String body,String recordId){
        ContentVersion content = new ContentVersion(); 
        content.Title  =  title; 
        content.PathOnClient= title ;        
        content.VersionData = Blob.valueOf(body); 
        content.FirstPublishLocationId  = recordId;

        return content;
    }


    public static ContentDocumentLink initContentDocumentLink (String contentId, String linkedEntityId){
        ContentDocumentLink contentlink = new ContentDocumentLink();
        contentlink.LinkedEntityId  = linkedEntityId;
        contentlink.contentdocumentid= [SELECT contentdocumentid FROM contentversion where id =: contentId].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 

        return contentlink;
    }

    public static Case initJiraCase(String sbj, String descr, String ccUserId ){
        Case cs = new Case();
        cs.Subject = sbj;
        cs.Description = descr;
        cs.Status = 'New';
        cs.Origin = 'Web';
        cs.CreateJiraTicket__c = true;
        cs.Priority = 'Medium';        
        cs.DueDate__c = System.today() + 10;
        cs.IssueType__c = 'Task';
        cs.JiraCC__c = ccUserId;
        cs.JiraProject__c = 'FS';
        cs.Severity__c = 'Critical';

        return cs;
    }

    public static Attachment initAttachment(String name, String body, String parentId){
        Attachment att = new Attachment();
        att.Name = name;
        att.ParentId = parentId;
        att.Body = Blob.valueOf(body);

        return att;
    }
  

    public static QC_Account_Data__c initQCAccountData(String qcId, String accId, Datetime syndate, Decimal val,Integer qty,String type){
        QC_Account_Data__c data = new QC_Account_Data__c();

        data.QC_Account__c = qcId;
        data.Accounts__c = accId;
        data.syn_date__c = syndate;

        if(type == 'Normal'){
            data.real_spending__c = 13 * val;
            data.TotalQCSpending__C = 13 * val;
        }else{
            data.real_spending__c = 10 * val;
            data.TotalQCSpending__C = 10 * val;
        }
        
        data.overspending__c = 0;         
        data.Coupon_spending__c = 0;
        data.serp_desktop_spending__c = 1 * val; 
        data.serp_mobile_spending__c = 1 * val;
        data.serp_banners_spending__c = 1 * val; 
        data.serp_market_spending__c = 1 * val;
        data.maps_spending__c = 1 * val; 
        data.icons_newtab_spending__c = 1 * val;
        data.new_tab_spending__c = 0; 
        data.new_tab_js_code_spending__c = 0;
        data.skins_spending__c = 1 * val; 
        data.skintool_masthead_spending__c = 0;
        data.masthead_spending__c = 0; 
        data.video_spending__c = 1 * val;
        data.mb_general_spending__c = 0; 
        data.single_zen_cards_spending__c = 1 * val;
        data.double_zen_cards_spending__c = 0; 
        data.video_masthead_spending__c = 0;
        data.masthead_jscode_spending__c = 1 * val; 
        // data.vast_skin_spending__c = 0;
        data.skintool_skin_spending__c = 1 * val; 
        data.skintool_video_skin_spending__c = 0;
        data.skintool_masthead_video_spending__c = 1 * val; 
        data.skintool_iconsidebar_spending__c = 0;
        data.skintool_video_banner_spending__c = 1 * val;
        data.serp_desktop_show__c = 1* qty; 
        data.serp_mobile_show__c = 1* qty;
        data.serp_banners_show__c = 1* qty; 
        data.serp_market_show__c = 1* qty;
        data.maps_show__c = 1* qty; 
        data.icons_newtab_show__c = 1* qty;
        data.new_tab_show__c = 0; 
        data.new_tab_js_code_show__c = 0;
        data.skins_show__c = 1* qty; 
        data.skintool_masthead_view__c = 0;
        data.masthead_show__c = 0; 
        data.video_show__c = 0;
        data.mb_general_show__c = 0; 
        data.single_zen_cards_show__c = 1* qty;
        data.double_zen_cards_show__c = 0; 
        data.video_masthead_show__c = 0;
        data.masthead_jscode_show__c = 1* qty; 
        // data.vast_skin_show__c = 0;
        data.skintool_skin_view__c = 1* qty; 
        data.skintool_video_skin_view__c = 0;
        data.skintool_masthead_video_view__c = 0; 
        data.skintool_iconsidebar_view__c = 0;
        data.skintool_video_banner_view__c = 1* qty;
        data.serp_desktop_click__c = 0; 
        data.serp_mobile_click__c = 0;
        data.serp_banners_click__c = 1* qty; 
        data.serp_market_click__c = 1* qty;
        data.maps_click__c = 0; 
        data.icons_newtab_click__c = 0;
        data.new_tab_click__c = 0; 
        data.new_tab_js_code_click__c  = 0;
        data.skins_click__c = 0; 
        data.skintool_masthead_click__c = 0;
        data.masthead_click__c = 0; 
        data.video_click__c = 0;
        data.mb_general_click__c = 0; 
        data.single_zen_cards_click__c = 0;
        data.double_zen_cards_click__c = 0; 
        data.video_masthead_click__c = 1* qty;
        data.masthead_jscode_click__c = 0; 
        // data.vast_skin_click__c = 0;
        data.skintool_skin_click__c = 0; 
        data.skintool_video_skin_click__c = 0;
        data.skintool_masthead_video_click__c = 0; 
        data.skintool_iconsidebar_click__c = 0;
        data.skintool_video_banner_click__c = 0;  
        
        return data;
    }

    public static QC_Account_Data__c initQCAccountData(String qcId, String accId, Datetime syndate, Decimal val,Integer qty, String industry, String agency, String type, String saleId){
        QC_Account_Data__c data = new QC_Account_Data__c();

        data.QC_Account__c = qcId;
        data.Accounts__c = accId;
        data.syn_date__c = syndate;
        data.Industry__c = industry;
        data.Agency__c = agency;
        data.sale__c = saleId;

        if(type == 'Normal'){
            data.real_spending__c = 13 * val;
            data.TotalQCSpending__C = 13 * val;
        }else{
            data.real_spending__c = 10 * val;
            data.TotalQCSpending__C = 10 * val;
        }
        
        data.overspending__c = 0;         
        data.Coupon_spending__c = 0;
        data.serp_desktop_spending__c = 1 * val; 
        data.serp_mobile_spending__c = 1 * val;
        data.serp_banners_spending__c = 1 * val; 
        data.serp_market_spending__c = 1 * val;
        data.maps_spending__c = 1 * val; 
        data.icons_newtab_spending__c = 1 * val;
        data.new_tab_spending__c = 0; 
        data.new_tab_js_code_spending__c = 0;
        data.skins_spending__c = 1 * val; 
        data.skintool_masthead_spending__c = 0;
        data.masthead_spending__c = 0; 
        data.video_spending__c = 1 * val;
        data.mb_general_spending__c = 0; 
        data.single_zen_cards_spending__c = 1 * val;
        data.double_zen_cards_spending__c = 0; 
        data.video_masthead_spending__c = 0;
        data.masthead_jscode_spending__c = 1 * val; 
        // data.vast_skin_spending__c = 0;
        data.skintool_skin_spending__c = 1 * val; 
        data.skintool_video_skin_spending__c = 0;
        data.skintool_masthead_video_spending__c = 1 * val; 
        data.skintool_iconsidebar_spending__c = 0;
        data.skintool_video_banner_spending__c = 1 * val;
        data.serp_desktop_show__c = 1* qty; 
        data.serp_mobile_show__c = 1* qty;
        data.serp_banners_show__c = 1* qty; 
        data.serp_market_show__c = 1* qty;
        data.maps_show__c = 1* qty; 
        data.icons_newtab_show__c = 1* qty;
        data.new_tab_show__c = 0; 
        data.new_tab_js_code_show__c = 0;
        data.skins_show__c = 1* qty; 
        data.skintool_masthead_view__c = 0;
        data.masthead_show__c = 0; 
        data.video_show__c = 0;
        data.mb_general_show__c = 0; 
        data.single_zen_cards_show__c = 1* qty;
        data.double_zen_cards_show__c = 0; 
        data.video_masthead_show__c = 0;
        data.masthead_jscode_show__c = 1* qty; 
        // data.vast_skin_show__c = 0;
        data.skintool_skin_view__c = 1* qty; 
        data.skintool_video_skin_view__c = 0;
        data.skintool_masthead_video_view__c = 0; 
        data.skintool_iconsidebar_view__c = 0;
        data.skintool_video_banner_view__c = 1* qty;
        data.serp_desktop_click__c = 0; 
        data.serp_mobile_click__c = 0;
        data.serp_banners_click__c = 1* qty; 
        data.serp_market_click__c = 1* qty;
        data.maps_click__c = 0; 
        data.icons_newtab_click__c = 0;
        data.new_tab_click__c = 0; 
        data.new_tab_js_code_click__c  = 0;
        data.skins_click__c = 0; 
        data.skintool_masthead_click__c = 0;
        data.masthead_click__c = 0; 
        data.video_click__c = 0;
        data.mb_general_click__c = 0; 
        data.single_zen_cards_click__c = 0;
        data.double_zen_cards_click__c = 0; 
        data.video_masthead_click__c = 1* qty;
        data.masthead_jscode_click__c = 0; 
        // data.vast_skin_click__c = 0;
        data.skintool_skin_click__c = 0; 
        data.skintool_video_skin_click__c = 0;
        data.skintool_masthead_video_click__c = 0; 
        data.skintool_iconsidebar_click__c = 0;
        data.skintool_video_banner_click__c = 0;  
        
        return data;
    }


    public static List<QC_Account_Data__c> initQCAccountData(string qc1, string qc2, string qc3, string qc4,string qc5, string qc6 ,
                                                             string qc1sfid, string qc2sfid,string qc3sfid,  string qc4sfid, string qc5sfid, string qc6sfid){
        datetime dtnow = datetime.now().addMonths(-1);
        datetime dt1 = DateTime.newInstance(dtnow.year(),dtnow.month(),2,10,0,0);
        datetime dt2 = DateTime.newInstance(dtnow.year(),dtnow.month(),7,10,0,0);
        datetime dt3 = DateTime.newInstance(dtnow.year(),dtnow.month(),11,10,0,0);
        datetime dt4 = DateTime.newInstance(dtnow.year(),dtnow.month(),17,10,0,0);
        datetime dt5 = DateTime.newInstance(dtnow.year(),dtnow.month(),23,10,0,0);
        datetime dt6 = DateTime.newInstance(dtnow.year(),dtnow.month(),27,10,0,0);
        string strQCAccountData = getQCAccountData(dt1, dt2, dt3, dt4, dt5, dt6,qc1, qc2, qc3, qc4, qc5, qc6);
        
        List<QCAccountDataWrapper> incomeQCAccountList = QCAccountDataWrapper.parse(strQCAccountData);
        List<QC_Account_Data__c> resultList = new List<QC_Account_Data__c>();
        List<id> tempList = new List<id>();
        tempList.add(qc1sfid);
        tempList.add(qc2sfid);
        tempList.add(qc3sfid);
        tempList.add(qc4sfid);
        tempList.add(qc5sfid);
        tempList.add(qc6sfid);
        for(integer i = 0; i< incomeQCAccountList.size();i ++){
            QC_Account_Data__c temp = initQCAccountDataWrapper(incomeQCAccountList.get(i));
            temp.name = 'test@abc.com' +  temp.syn_date__c.format('dd/MM/yyyy');
            temp.QC_Account__c = tempList.get(i);
            resultList.add(temp);
        }
        return resultList;
        
      // QC_Account_Data__c doPostAccountFromQCSystem.initQCAccountData(QCAccountDataWrapper inComeQCAccountData)
    }



    public static string getQCAccountData(datetime dt1, datetime dt2,datetime dt3, datetime dt4, datetime dt5, datetime dt6,
                                        string qc1, string qc2, string qc3, string qc4, string qc5, string qc6
                                         ){
         long dt1long =  dt1.getTime(); 
                                             long dt2long =  dt2.getTime(); 
                                             long dt3long =  dt3.getTime(); 
                                             long dt4long =  dt4.getTime(); 
                                             long dt5long =  dt5.getTime(); 
                                             long dt6long =  dt6.getTime(); 
         return '[{"customer_id":' + qc1 +  ',"syn_date":' +dt1long + ',"real_spending": 10,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1},' +
                 '{"customer_id":' + qc2 +',"syn_date":' + dt2long+ ',"real_spending": 10,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1},' + 
             '{"customer_id":'  + qc3 + ',"syn_date":' +dt3long + ',"real_spending": 10,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1},' +
             '{"customer_id":' + qc4 + ',"syn_date":' +dt4long + ',"real_spending": 10,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1},' +
             '{"customer_id": ' + qc5+ ' ,"syn_date":' + dt5long+ ',"real_spending": 10,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1},' +
             '{"customer_id":' + qc6 + ',"syn_date":' + dt6long+ ',"real_spending": 10,"serp_desktop_click":0,"serp_desktop_show":3,"serp_desktop_spending":0,"serp_banners_click":0,"serp_banners_show":0,"serp_banners_spending":0,"serp_market_click":0,"serp_market_show":0,"serp_market_spending":0,"serp_mobile_click":0,"serp_mobile_show":0,"serp_mobile_spending":0,"maps_click":2,"maps_show":100,"maps_spending":0,"icons_newtab_click":0,"icons_newtab_show":0,"icons_newtab_spending":0,"new_tab_click":500,"new_tab_show":0,"new_tab_spending":39476500,"new_tab_js_code_click":100,"new_tab_js_code_show":0,"new_tab_js_code_spending":9177300,"skins_click":0,"skins_show":100,"skins_spending":0,"masthead_click":0,"masthead_show":0,"masthead_spending":0,"video_masthead_click":0,"video_masthead_show":0,"video_masthead_spending":0,"video_click":0,"video_show":0,"video_spending":0,"mb_general_click":0,"mb_general_show":500,"mb_general_spending":0,"single_zen_cards_click":500,"single_zen_cards_show":500,"single_zen_cards_spending":11952000,"double_zen_cards_click":0,"double_zen_cards_show":0,"double_zen_cards_spending":0,"overspending":0,"skintool_skin_view":0,"skintool_skin_click":1,"skintool_skin_price":1.5,"skintool_skin_spending":2,"skintool_video_skin_view":3,"skintool_video_skin_click":5,"skintool_video_skin_price":5.5,"skintool_video_skin_spending":6,"skintool_masthead_view":6,"skintool_masthead_click":7,"skintool_masthead_price":7.5,"skintool_masthead_spending":1,"skintool_masthead_video_view":1,"skintool_masthead video_click":1,"skintool_masthead_video_price":1,"skintool_masthead_video_spending":1,"skintool_iconsidebar_view":1,"skintool_iconsidebar_click":1,"skintool_iconsidebar_price":1,"skintool_iconsidebar_spending":1}' +
             ']';
     }     

    public static QC_Account_Data__c initQCAccountDataWrapper(QCAccountDataWrapper inComeQCAccountData){
        QC_Account_Data__c qcAccData = new QC_Account_Data__c();
        qcAccData.syn_date__c = inComeQCAccountData.synDate;
        if(inComeQCAccountData.serp_desktop_click != null )
            qcAccData.serp_desktop_click__c = inComeQCAccountData.serp_desktop_click;
        if(inComeQCAccountData.serp_desktop_show != null )
            qcAccData.serp_desktop_show__c = inComeQCAccountData.serp_desktop_show;
        if(inComeQCAccountData.serp_desktop_spending != null )
            qcAccData.serp_desktop_spending__c = inComeQCAccountData.serp_desktop_spending;
        
        if(inComeQCAccountData.serp_banners_click != null )
            qcAccData.serp_banners_click__c = inComeQCAccountData.serp_banners_click;
        if(inComeQCAccountData.serp_banners_show != null )
            qcAccData.serp_banners_show__c = inComeQCAccountData.serp_banners_show;
        if(inComeQCAccountData.serp_banners_spending != null )
            qcAccData.serp_banners_spending__c = inComeQCAccountData.serp_banners_spending;
        
        if(inComeQCAccountData.serp_market_click != null )
            qcAccData.serp_market_click__c = inComeQCAccountData.serp_market_click;
        if(inComeQCAccountData.serp_market_show != null )
            qcAccData.serp_market_show__c = inComeQCAccountData.serp_market_show;
        if(inComeQCAccountData.serp_market_spending != null )
            qcAccData.serp_market_spending__c = inComeQCAccountData.serp_market_spending;
        
        if(inComeQCAccountData.serp_mobile_click != null )
            qcAccData.serp_mobile_click__c = inComeQCAccountData.serp_mobile_click;
        if(inComeQCAccountData.serp_mobile_show != null )
            qcAccData.serp_mobile_show__c = inComeQCAccountData.serp_mobile_show;
        if(inComeQCAccountData.serp_mobile_spending != null )
            qcAccData.serp_mobile_spending__c = inComeQCAccountData.serp_mobile_spending;
        
        if(inComeQCAccountData.maps_click != null )
            qcAccData.maps_click__c = inComeQCAccountData.maps_click;
        if(inComeQCAccountData.maps_show != null )
            qcAccData.maps_show__c = inComeQCAccountData.maps_show;
        if(inComeQCAccountData.maps_spending != null )
            qcAccData.maps_spending__c = inComeQCAccountData.maps_spending;
        
        if(inComeQCAccountData.icons_newtab_click != null )
            qcAccData.icons_newtab_click__c = inComeQCAccountData.icons_newtab_click;
        if(inComeQCAccountData.icons_newtab_show != null )
            qcAccData.icons_newtab_show__c = inComeQCAccountData.icons_newtab_show;
        if(inComeQCAccountData.icons_newtab_spending != null )
            qcAccData.icons_newtab_spending__c = inComeQCAccountData.icons_newtab_spending;
        
        if(inComeQCAccountData.new_tab_click != null )
            qcAccData.new_tab_click__c = inComeQCAccountData.new_tab_click;
        if(inComeQCAccountData.new_tab_show != null )
            qcAccData.new_tab_show__c = inComeQCAccountData.new_tab_show;
        if(inComeQCAccountData.new_tab_spending != null )
            qcAccData.new_tab_spending__c = inComeQCAccountData.new_tab_spending;
        
        if(inComeQCAccountData.new_tab_js_code_click != null )
            qcAccData.new_tab_js_code_click__c = inComeQCAccountData.new_tab_js_code_click;
        if(inComeQCAccountData.new_tab_js_code_show != null )
            qcAccData.new_tab_js_code_show__c = inComeQCAccountData.new_tab_js_code_show;
        if(inComeQCAccountData.new_tab_js_code_spending != null )
            qcAccData.new_tab_js_code_spending__c = inComeQCAccountData.new_tab_js_code_spending;
        
        if(inComeQCAccountData.skins_click != null )
            qcAccData.skins_click__c = inComeQCAccountData.skins_click;
        if(inComeQCAccountData.skins_show != null )
            qcAccData.skins_show__c = inComeQCAccountData.skins_show;
        if(inComeQCAccountData.skins_spending != null )
            qcAccData.skins_spending__c = inComeQCAccountData.skins_spending;
        
        if(inComeQCAccountData.masthead_click != null )
            qcAccData.masthead_click__c = inComeQCAccountData.masthead_click;
        if(inComeQCAccountData.masthead_show != null )
            qcAccData.masthead_show__c = inComeQCAccountData.masthead_show;
        if(inComeQCAccountData.masthead_spending != null )
            qcAccData.masthead_spending__c = inComeQCAccountData.masthead_spending;
        
        if(inComeQCAccountData.masthead_jscode_show != null )
            qcAccData.masthead_jscode_show__c = inComeQCAccountData.masthead_jscode_show;
        if(inComeQCAccountData.masthead_jscode_click != null )
            qcAccData.masthead_jscode_click__c = inComeQCAccountData.masthead_jscode_click;
        if(inComeQCAccountData.masthead_jscode_spending != null )
            qcAccData.masthead_jscode_spending__c = inComeQCAccountData.masthead_jscode_spending;
        
        if(inComeQCAccountData.video_click != null )
            qcAccData.video_click__c = inComeQCAccountData.video_click;
        if(inComeQCAccountData.video_show != null )
            qcAccData.video_show__c = inComeQCAccountData.video_show;
        if(inComeQCAccountData.video_spending != null )
            qcAccData.video_spending__c = inComeQCAccountData.video_spending;
        
        if(inComeQCAccountData.video_masthead_click != null )
            qcAccData.video_masthead_click__c = inComeQCAccountData.video_masthead_click;
        if(inComeQCAccountData.video_masthead_show != null )
            qcAccData.video_masthead_show__c = inComeQCAccountData.video_masthead_show;
        if(inComeQCAccountData.video_masthead_spending != null )
            qcAccData.video_masthead_spending__c = inComeQCAccountData.video_masthead_spending;
        
        if(inComeQCAccountData.mb_general_click != null )
            qcAccData.mb_general_click__c = inComeQCAccountData.mb_general_click;
        if(inComeQCAccountData.mb_general_show != null )
            qcAccData.mb_general_show__c = inComeQCAccountData.mb_general_show;
        if(inComeQCAccountData.mb_general_spending != null )
            qcAccData.mb_general_spending__c = inComeQCAccountData.mb_general_spending;
        
        if(inComeQCAccountData.single_zen_cards_click != null )
            qcAccData.single_zen_cards_click__c = inComeQCAccountData.single_zen_cards_click;
        if(inComeQCAccountData.single_zen_cards_show != null )
            qcAccData.single_zen_cards_show__c = inComeQCAccountData.single_zen_cards_show;
        if(inComeQCAccountData.single_zen_cards_spending != null )
            qcAccData.single_zen_cards_spending__c = inComeQCAccountData.single_zen_cards_spending;
        
        if(inComeQCAccountData.double_zen_cards_click != null )
            qcAccData.double_zen_cards_click__c = inComeQCAccountData.double_zen_cards_click;
        if(inComeQCAccountData.double_zen_cards_show != null )
            qcAccData.double_zen_cards_show__c = inComeQCAccountData.double_zen_cards_show;
        if(inComeQCAccountData.double_zen_cards_spending != null )
            qcAccData.double_zen_cards_spending__c = inComeQCAccountData.double_zen_cards_spending;
        
        if(inComeQCAccountData.other_show != null )
            qcAccData.other_show__c = inComeQCAccountData.other_show;
        if(inComeQCAccountData.other_click != null )
            qcAccData.other_click__c = inComeQCAccountData.other_click;
        if(inComeQCAccountData.other_spending != null )
            qcAccData.other_spending__c = inComeQCAccountData.other_spending;
        
        if(inComeQCAccountData.overspending != null )
            qcAccData.overspending__c = inComeQCAccountData.overspending;
        if(inComeQCAccountData.coupon_spending != null )
            qcAccData.coupon_spending__c = inComeQCAccountData.coupon_spending;
        if(inComeQCAccountData.real_spending != null )
            qcAccData.real_spending__c = inComeQCAccountData.real_spending;
       
        return qcAccData;
    }
    public static List<Sale_target_v1__c> initSalesTargetForSpending(string str){
        List<Sale_target_v1__c> result = (List<Sale_target_v1__c>) system.JSON.deserialize(str, List<Sale_target_v1__c>.class);
        return result;
    }
    public static List<Account> initAccountForSpending(string str){
        List<Account> result = (List<Account>) system.JSON.deserialize(str, List<Account>.class);
        return result;
    }
    public static List<QC_Account__c> initQCAccountForSpending(string str){
        List<QC_Account__c> result = (List<QC_Account__c>) system.JSON.deserialize(str, List<QC_Account__c>.class);
        return result;
    }
  	 public static List<QC_Account_Data__c> initQCAccountDataForSpending(string str){
        List<QC_Account_Data__c> result = (List<QC_Account_Data__c>) system.JSON.deserialize(str, List<QC_Account_Data__c>.class);
        return result;
    }


    public static void insertCSVtoAttachfile(String filename, String parrentId, String fileHeader, List<String> fileBody){
        
        String csvFile = fileHeader + String.join(fileBody, '\n');
        filename = filename + '.csv';    

        ContentVersion contentVersion = new ContentVersion(
            Title = filename,
            PathOnClient = filename,
            VersionData = Blob.valueOf(csvFile),
            IsMajorVersion = true
        );
        insert contentVersion;    

        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = parrentId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
    } 
  
}