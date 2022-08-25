public with sharing class cc_KPI_CaculateController {
    public KPI__c MKPI {get;set;}
    public String kpiId {get;set;}
    public List<Daily_KPI__c> dailyKPIs {get;set;}
    public Map<String, List<cc_kpimetrics_wraper>> mapMetrics{get;set;}
    public boolean refreshPage {get;set;}

    public cc_KPI_CaculateController(ApexPages.StandardController stdController) {
        this.kpiId = (String)stdController.getId();
        getKPI();
        this.dailyKPIs = new List<Daily_KPI__c>();
        this.mapMetrics = new Map<String, List<cc_kpimetrics_wraper>>();
        this.refreshPage = false;
    }

    public Pagereference calculateKPI(){
        if(this.MKPI.Status__c == 'Confirmed'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Can not calculate for Confirmed KPI'));
            return null;
        }

        if(this.MKPI.To_Date__c == null || this.MKPI.From_Date__c == null){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'From date and To date cannot be blank'));
            return null;
        }

        if(String.isBlank(this.MKPI.Sales__c)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sales field cannot be blank'));
            return null;
        }

        try{ 
            processCalculation();
            PageReference tempPage = ApexPages.currentPage();           
            tempPage.setRedirect(true);
            this.refreshPage = true;
            return null; 
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }
    public void getKPI(){
        this.MKPI = [SELECT Id, Name,
                            KPI_Number__c,
                            Status__c,
                            Sales__c, 
                            SalesManager__c,  
                            Period__c,
                            From_Date__c, 
                            To_Date__c, 
                            KPI_Category__c, 
                            TotalRefundAmount__c                     
                    FROM KPI__c WHERE Id =:this.kpiId LIMIT 1];
    }

    public void processCalculation(){
        //Delete old daily KPI
        deleteDailyKPIs();

        calculationActivities();
        calculationAmount();        

        System.debug('this.dailyKPIs.size() =>' + this.dailyKPIs.size());
        if( this.dailyKPIs.size() > 0 ){
            insert this.dailyKPIs;

            update this.MKPI;
        }

        Set<String> pkpiIds = new Set<String>();
        pkpiIds.add(this.kpiId);   
        if(Test.isRunningTest()){
            cc_KPI_GeneratedetailFile_batch generatefile = new cc_KPI_GeneratedetailFile_batch(this.MKPI.Period__c, pkpiIds);
            Database.executeBatch(generatefile);      
        }else{
            cc_KPI_GeneratedetailFile_batch generatefile = new cc_KPI_GeneratedetailFile_batch(this.MKPI.Period__c, pkpiIds);
            Database.executeBatch(generatefile, 20);      
        }     
        
    }

    public void deleteDailyKPIs(){
        delete [SELECT Id FROM Daily_KPI__c WHERE KPI__c =:this.MKPI.Id];
    }

    public void calculationAmount(){
        List<Sale_Spending_Payment__c> sps = new List<Sale_Spending_Payment__c>();
        List<cc_QCData_wraper> spendings = new List<cc_QCData_wraper>();
        List<cc_QCData_wraper> payments = new List<cc_QCData_wraper>();
        cc_QCData_wraper refund = new cc_QCData_wraper();
        Datetime minDateTime = Datetime.newInstance(this.MKPI.From_Date__c.year(), this.MKPI.From_Date__c.month(), this.MKPI.From_Date__c.day(), 0,0,0);       
        Datetime maxDateTime = Datetime.newInstance(this.MKPI.To_Date__c.year(), this.MKPI.To_Date__c.month(), this.MKPI.To_Date__c.day(), 23,59,59); 
        cc_KPI_Setting__c kpisetting = cc_Util.getKPISetting('ccKPISetting');

        String accepted_recordtype = kpisetting.PaymentRecordType__c;
        String [] acceptedReccordtypes;
        if(!String.isBlank(accepted_recordtype)){
            acceptedReccordtypes = accepted_recordtype.split(',');
        }

        String accepted_paymentMethod = kpisetting.Paymentmethod__c;
        String [] acceptedpaymentmethods;
        if(!String.isBlank(accepted_paymentMethod)){
            acceptedpaymentmethods = accepted_paymentMethod.split(',');
        }


        System.debug('minDateTime =>' + minDateTime);
        System.debug('maxDateTime =>' + maxDateTime);

        sps = [SELECT Id, KPI__c, KPI__r.KPIAutoNumber__c, KPI_Number__c, 
                    Payment_Amount__c, Spending_Amount__c, KPI_Category__c
                    FROM Sale_Spending_Payment__c 
                    WHERE KPI__c = :this.MKPI.Id ];

        if(sps != null){

            for(AggregateResult arr  :  [SELECT Industry__c Industry__c,
                                                Xaxis__c Xaxis__c, 
                                                Special_client__c Special_client__c,                                                 
                                                Agency__c Agency__c, 
                                                Is_HN_Region__c Is_HN_Region__c,
                                                Xaxis_Owner__c Xaxis_Owner__c,   
                                                Strategic_Client__c Strategic_Client__c,                                        
                                            SUM(Total_Spending__c) Total_Spending__c
                                            FROM QC_Account_Data__c 
                                            WHERE syn_date__c >=: minDateTime 
                                                AND syn_date__c <=:  maxDateTime 
                                                AND QC_Account__r.Type__c != 'Internal'              
                                                AND Sale__c = :this.MKPI.Sales__c                                         
                                            GROUP BY Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c ,Xaxis_Owner__c, Strategic_Client__c]){

                cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                qc.Amount = (Decimal)arr.get('Total_Spending__c');                   
                String Industry = (String)arr.get('Industry__c');  
                Boolean xaxis = (Boolean)arr.get('Xaxis__c');     
                Boolean Specialclient = (Boolean)arr.get('Special_client__c');     
                String Agency = (String)arr.get('Agency__c');      
                Boolean Is_HN_Region = (Boolean)arr.get('Is_HN_Region__c');      
                Boolean Xaxis_Owner = (Boolean)arr.get('Xaxis_Owner__c');
                Boolean Strategic_Client = (Boolean)arr.get('Strategic_Client__c');
                String KPICat;

                if(Strategic_Client){
                    KPICat = 'Strategic Team';
                }else if(Agency.trim() == 'Global Agency' || Agency.trim() == 'Local Agency'){   
                    if(Agency.trim() == 'Local Agency'){
                        if(Is_HN_Region){
                            KPICat = Agency.trim() + ' HN';
                        }else{
                            KPICat = Agency.trim() + ' HCM';
                        }                    

                        if(Specialclient){
                            KPICat = KPICat + '-Special Client';
                        }
                    }else{
                        if(xaxis){
                            if(Xaxis_Owner){
                                KPICat = Agency.trim() + '-Xaxis';
                            }else {
                                KPICat = Agency.trim();
                            }
                        }else{
                            if(Xaxis_Owner){
                                KPICat = Agency.trim() + '-Non Xaxis';
                            }else {
                                KPICat = Agency.trim();
                            }
                        }

                    }                
                }else if(!String.isBlank(Industry)){
                    if(Specialclient){
                        KPICat = Industry.trim() + '-Special';
                    }else {
                        KPICat = Industry.trim();
                    }
                }else {
                    KPICat = 'Unknown';
                }            

                qc.Industry =  Industry;
                qc.KPICategory = KPICat;
                qc.SpecialClient = Specialclient;
                qc.Xaxis = xaxis;
                qc.Agency = Agency;
                qc.exists = false;

                spendings.add(qc);

            }

            System.debug('spendings =>' + spendings);

            //Payment
            for(AggregateResult arr  :  [SELECT Industry__c Industry__c,
                                                Xaxis__c Xaxis__c, 
                                                Special_client__c Special_client__c,                                                 
                                                Agency__c Agency__c, 
                                                Is_HN_Region__c Is_HN_Region__c,
                                                Xaxis_Owner__c Xaxis_Owner__c, 
                                                Strategic_Client__c Strategic_Client__c,                                                    
                                            SUM(Final_Amount__c) Final_Amount__c
                                            FROM Payment__c 
                                            WHERE Effective_date__c >=: minDateTime 
                                                AND Effective_date__c <=:  maxDateTime 
                                                AND Stage__c = 'Done'
                                                AND QC_Account__r.Type__c != 'Internal'              
                                                AND Payment_method__c IN :acceptedpaymentmethods
                                                AND RecordType.DeveloperName IN :acceptedReccordtypes
                                                AND Sale__c = :this.MKPI.Sales__c                                            
                                            GROUP BY Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c ,Xaxis_Owner__c, Strategic_Client__c]){

                cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                qc.Amount = (Decimal)arr.get('Final_Amount__c');                   
                String Industry = (String)arr.get('Industry__c');  
                Boolean xaxis = (Boolean)arr.get('Xaxis__c');     
                Boolean Specialclient = (Boolean)arr.get('Special_client__c');     
                String Agency = (String)arr.get('Agency__c');
                Boolean Is_HN_Region = (Boolean)arr.get('Is_HN_Region__c');            
                Boolean Xaxis_Owner = (Boolean)arr.get('Xaxis_Owner__c');
                Boolean Strategic_Client = (Boolean)arr.get('Strategic_Client__c');

                String KPICat;
                if(Strategic_Client){
                    KPICat = 'Strategic Team';
                }else if(Agency.trim() == 'Global Agency' || Agency.trim() == 'Local Agency'){   
                    if(Agency.trim() == 'Local Agency'){
                        
                        if(Is_HN_Region){
                            KPICat = Agency.trim() + ' HN';
                        }else{
                            KPICat = Agency.trim() + ' HCM';
                        }

                        if(Specialclient){
                            KPICat = KPICat + '-Special Client';
                        }
                    }else{
                        if(xaxis){
                            if(Xaxis_Owner){
                                KPICat = Agency.trim() + '-Xaxis';
                            }else {
                                KPICat = Agency.trim();
                            }
                        }else{
                            if(Xaxis_Owner){
                                KPICat = Agency.trim() + '-Non Xaxis';
                            }else {
                                KPICat = Agency.trim();
                            }
                        }
                    }                
                }else if(!String.isBlank(Industry)){
                    if(Specialclient){
                        KPICat = Industry.trim() + '-Special';
                    }else {
                        if(Industry == 'Retails' || Industry == 'FMCG'){
                            KPICat = 'FMCG-Retails';
                        }else{
                            KPICat = Industry.trim();
                        }
                        
                    }
                }else {
                    KPICat = 'Unknown';
                }             

                qc.Industry =  Industry;
                qc.KPICategory = KPICat;
                qc.SpecialClient = Specialclient;
                qc.Xaxis = xaxis;   
                qc.Agency = Agency;
                qc.exists = false;
            
                payments.add(qc);           
            }

            System.debug('payments =>' + payments);

            for(Sale_Spending_Payment__c  sp: sps){
                sp.Spending_Amount__c = 0;
                sp.Payment_Amount__c = 0;
               
                if(spendings != null){
                    for(cc_QCData_wraper spending: spendings){

                        if(sp.KPI_Category__c == spending.KPICategory){
                            sp.Spending_Amount__c += spending.Amount==null?0: spending.Amount;
                            spending.exists = true;                            
                        }
                    }
                }


                if(payments != null){
                    for(cc_QCData_wraper payment: payments){
                        if(sp.KPI_Category__c == payment.KPICategory){                            
                            sp.Payment_Amount__c += payment.Amount==null?0: payment.Amount;
                            payment.exists = true;                           
                        }
                    }
                }                                   
            }
            
            update sps;
        }   
        
        //Refund Payment
        for(AggregateResult arr  :  [SELECT Sale__c Sale__c,                             
                                        SUM(Final_Amount__c) Final_Amount__c
                                        FROM Payment__c 
                                        WHERE Effective_Date__c >=: minDateTime
                                            AND Effective_Date__c <=: maxDateTime
                                            AND Stage__c = 'Done'
                                            AND QC_Account__r.Type__c != 'Internal' 
                                            AND Payment_method__c IN :acceptedpaymentmethods
                                            AND RecordType.DeveloperName = 'Refund_payment'
                                            AND Refund_Type__c = 'Refund to Client' 
                                            AND Sale__c = : this.MKPI.Sales__c                                                    
                                        GROUP BY Sale__c]){

            
            Decimal Amount = (Decimal)arr.get('Final_Amount__c');                   
            String sale = (String) arr.get('Sale__c');            

            if(!String.isBlank(sale)){
                this.MKPI.TotalRefundAmount__c = Amount;
            }
        }
        
    }

    public void calculationActivities(){
        // New Lead
        for(AggregateResult arr :[SELECT Count(Id) value, CreatedDate__c CreatedDate  
                                    FROM Lead 
                                    WHERE OwnerId = :this.MKPI.Sales__c 
                                        AND CreatedDate__c >= :this.MKPI.From_Date__c 
                                        AND CreatedDate__c <= :this.MKPI.To_Date__c 
                                    GROUP BY CreatedDate__c ] ){
            
            Date createDate = (Date)arr.get('CreatedDate');                        
            String datekey = String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            Decimal value = (Decimal)arr.get('value');

            cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();

            kpi.kpidate = createDate;
            kpi.kpivalue = value;
            kpi.kpimetrics = 'NewLead';

            if(this.mapMetrics.containsKey(datekey)){   
                this.mapMetrics.get(datekey).add(kpi);
            }else{
                this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
            }                            
        }

        // New Oppoturnity
        for(AggregateResult arr :[SELECT Count(Id) value, CreatedDate__c CreatedDate  
                                    FROM Opportunity 
                                    WHERE OwnerId = :this.MKPI.Sales__c 
                                        AND CreatedDate__c >= :this.MKPI.From_Date__c 
                                        AND CreatedDate__c <= :this.MKPI.To_Date__c 
                                    GROUP BY CreatedDate__c]){

            Date createDate = (Date)arr.get('CreatedDate');                        
            String datekey = String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            Decimal value = (Decimal)arr.get('value');

            cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();
            kpi.kpidate = createDate;
            kpi.kpivalue = value;
            kpi.kpimetrics = 'NewOpp';

            if(this.mapMetrics.containsKey(datekey)){
                this.mapMetrics.get(datekey).add(kpi);
            }else{
                this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
            }
            
        }

        // Opps Closed
        for(AggregateResult arr :[SELECT Count(Id) value, StageName Stage, CloseDate CloseDate  
                                    FROM Opportunity 
                                    WHERE OwnerId = :this.MKPI.Sales__c 
                                        AND IsClosed = true 
                                        AND CloseDate >= :this.MKPI.From_Date__c 
                                        AND CloseDate <= :this.MKPI.To_Date__c 
                                    GROUP BY StageName, CloseDate ]){

            Date CloseDate = (Date)arr.get('CloseDate');  
            String stage = (String)arr.get('Stage');                      
            String datekey = String.valueOf(CloseDate.year()) + String.valueOf(CloseDate.month()) + String.valueOf(CloseDate.day());
            if(stage == 'Closed Won'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();    
                kpi.kpidate = CloseDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Closed Won';

                if(this.mapMetrics.containsKey(datekey)){
                    this.mapMetrics.get(datekey).add(kpi);
                }else{
                    this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }else if(stage == 'Closed Lost'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();
    
                kpi.kpidate = CloseDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Closed Lost';

                if(this.mapMetrics.containsKey(datekey)){  
                    this.mapMetrics.get(datekey).add(kpi);
                }else{
                    this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }
            
        }

        // Task Activity
        for(AggregateResult arr :[SELECT Count(Id) value, TaskSubtype Type, CreatedDate__c CreatedDate  
                                    FROM Task 
                                    WHERE OwnerId = :this.MKPI.Sales__c 
                                        AND TaskSubtype IN ('Call','Meeting','Email')
                                        AND CreatedDate__c >= :this.MKPI.From_Date__c 
                                        AND CreatedDate__c <= :this.MKPI.To_Date__c 
                                    GROUP BY TaskSubtype, CreatedDate__c]){

            Date createDate = (Date)arr.get('CreatedDate');   
            String type = (String)arr.get('Type');                            
            String datekey = String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            if(type == 'Call'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();
    
                kpi.kpidate = createDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Call';

                if(this.mapMetrics.containsKey(datekey)){
                    this.mapMetrics.get(datekey).add(kpi);
                }else{
                    this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
                }            
            }else if(type == 'Email'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();

                kpi.kpidate = createDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Email';

                if(this.mapMetrics.containsKey(datekey)){                   
                    this.mapMetrics.get(datekey).add(kpi);
                }else{
                    this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }
            
        }
        
        for(AggregateResult arr :[SELECT Count(Id) value, CreatedDate__c CreatedDate  
                                    FROM Event 
                                    WHERE OwnerId = :this.MKPI.Sales__c 
                                        AND Type IN ('Meeting')
                                        AND CreatedDate__c >= :this.MKPI.From_Date__c 
                                        AND CreatedDate__c <= :this.MKPI.To_Date__c 
                                    GROUP BY CreatedDate__c, Type]){

            Date createDate = (Date)arr.get('CreatedDate');                                      
            String datekey = String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            Decimal value = (Decimal)arr.get('value');
    
            cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();

            kpi.kpidate = createDate;
            kpi.kpivalue = value;
            kpi.kpimetrics = 'Meeting';

            if(this.mapMetrics.containsKey(datekey)){                   
                this.mapMetrics.get(datekey).add(kpi);
            }else{
                this.mapMetrics.put(datekey, new List<cc_kpimetrics_wraper>{kpi});
            }                                
        }

        if(this.mapMetrics.size() > 0){
            for(String datekey: this.mapMetrics.keySet()){
                List<cc_kpimetrics_wraper> kpis = this.mapMetrics.get(datekey);
    
                if(kpis != null){
                    Daily_KPI__c dailykpi = new Daily_KPI__c();
                    String day = kpis[0].kpidate.day() < 10?'0' + String.valueOf(kpis[0].kpidate.day()) : String.valueOf(kpis[0].kpidate.day());
                    String month = kpis[0].kpidate.month() < 10?'0' + String.valueOf(kpis[0].kpidate.month()) : String.valueOf(kpis[0].kpidate.month());
    
                    dailykpi.Name =  day + '/' + month + '/' + String.valueOf(kpis[0].kpidate.year());
                    dailykpi.KPI__c = this.MKPI.Id;
                    dailykpi.Date__c = kpis[0].kpidate;
    
                    System.debug('kpis =>' + kpis.size());
                    for(cc_kpimetrics_wraper kpi : kpis){ 
                        if( kpi.kpimetrics == 'NewLead' ){  
                            dailykpi.NumberOfNewLeads__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }else if( kpi.kpimetrics == 'NewOpp' ){
                            dailykpi.NumberOfNewOpps__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }else if( kpi.kpimetrics == 'Closed Won' ){
                            dailykpi.CloseLostOpps__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }else if( kpi.kpimetrics == 'Closed Lost' ){
                            dailykpi.CloseWonOpps__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }else if( kpi.kpimetrics == 'Call' ){
                            dailykpi.NumberOfCalls__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }else if( kpi.kpimetrics == 'Meeting' ){
                            dailykpi.NumberOfMeeting__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }else if( kpi.kpimetrics == 'Email' ){
                            dailykpi.NumberOfEmail__c = kpi.kpivalue == null?0: kpi.kpivalue;
                        }       
                    }
    
                    this.dailyKPIs.add(dailykpi);
                }
            }
        }
    } 

}