public with sharing class cc_KPI_CaculateSupportController {
    public KPI__c MKPI {get;set;}
    public String kpiId {get;set;}
    public List<Daily_KPI__c> dailyKPIs {get;set;}
    public Map<String, List<cc_kpimetrics_wraper>> mapMetrics{get;set;}
    public boolean refreshPage {get;set;}
    private cc_KPI_Setting__c kpisetting {get;set;}

    public cc_KPI_CaculateSupportController(ApexPages.StandardController stdController) {
        this.kpiId = (String)stdController.getId();
        getKPI();
        this.dailyKPIs = new List<Daily_KPI__c>();
        this.mapMetrics = new Map<String, List<cc_kpimetrics_wraper>>();
        this.refreshPage = false;
        this.kpisetting = cc_Util.getKPISetting('ccKPISetting');
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
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Sale/Support field cannot be blank'));
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
                            KPI_Category__c                            
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
        cc_KPI_GendetailFile_Support_batch generatefile = new cc_KPI_GendetailFile_Support_batch(this.MKPI.Period__c, pkpiIds, this.kpisetting.IncludePayment__c);
        Database.executeBatch(generatefile, 1);      
    }

    public void deleteDailyKPIs(){
        delete [SELECT Id FROM Daily_KPI__c WHERE KPI__c =:this.MKPI.Id];
    }

    public void calculationAmount(){
        List<Sale_Spending_Payment__c> sps = new List<Sale_Spending_Payment__c>();
        List<cc_QCData_wraper> spendings = new List<cc_QCData_wraper>();
        List<cc_QCData_wraper> payments = new List<cc_QCData_wraper>();
        Datetime minDateTime = Datetime.newInstance(this.MKPI.From_Date__c.year(), this.MKPI.From_Date__c.month(), this.MKPI.From_Date__c.day(), 0,0,0);       
        Datetime maxDateTime = Datetime.newInstance(this.MKPI.To_Date__c.year(), this.MKPI.To_Date__c.month(), this.MKPI.To_Date__c.day(), 23,59,59); 
        User supporturs = [SELECT Id, Sale_Team__c FROM User WHERE Id = :this.MKPI.Sales__c LIMIT 1];

        System.debug('minDateTime =>' + minDateTime);
        System.debug('maxDateTime =>' + maxDateTime);

        sps = [SELECT Id, KPI__c, KPI__r.KPIAutoNumber__c, KPI_Number__c, 
                    Payment_Amount__c, Spending_Amount__c, KPI_Category__c
                    FROM Sale_Spending_Payment__c 
                    WHERE KPI__c = :this.MKPI.Id ];

        if(sps != null){

            for(AggregateResult arr  :  [SELECT Industry__c Industry__c,                 
                                                Agency__c Agency__c,                                   
                                            SUM(Total_Spending__c) Total_Spending__c
                                            FROM QC_Account_Data__c 
                                            WHERE syn_date__c >=: minDateTime 
                                                AND syn_date__c <=:  maxDateTime 
                                                AND QC_Account__r.Type__c != 'Internal' 
                                                AND QC_Account__r.Type__c != 'External'              
                                                AND Support__c = :this.MKPI.Sales__c                                         
                                            GROUP BY Industry__c, Agency__c]){

                cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                cc_KPI_Calculation_Helper.SpendingWrapper spendingdata = new cc_KPI_Calculation_Helper.SpendingWrapper();

                Decimal amount = (Decimal)arr.get('Total_Spending__c');                   
                String industry = (String)arr.get('Industry__c');            
                String agency = (String)arr.get('Agency__c');    
    
                spendingdata.agency = agency; 
                spendingdata.industry = industry;   
                spendingdata.saleId = this.MKPI.Sales__c   ;   
                spendingdata.Amount =  amount;                
    
                qc=cc_KPI_Calculation_Helper.getSupportSpendingKPICategory(supporturs, spendingdata);
                qc.exists = false;

                spendings.add(qc);

            }

            System.debug('spendings =>' + spendings);


            //payment
            if(this.kpisetting.IncludePayment__c){
                String acceptedrecordtype = this.kpisetting.PaymentRecordType__c;
                String [] acceptedReccordtypes;
                if(!String.isBlank(acceptedrecordtype)){
                    acceptedReccordtypes = acceptedrecordtype.split(',');
                }

                String acceptedpaymentMethod = this.kpisetting.Paymentmethod__c;
                String [] acceptedpaymentmethods;
                if(!String.isBlank(acceptedpaymentMethod)){
                    acceptedpaymentmethods = acceptedpaymentMethod.split(',');
                }
                for(AggregateResult arr  :  [SELECT Industry__c Industry__c,                    
                                                    Agency__c Agency__c,                       
                                                SUM(Final_Amount__c) Final_Amount__c
                                                FROM Payment__c 
                                                WHERE Effective_date__c >=: minDateTime 
                                                    AND Effective_date__c <=:  maxDateTime 
                                                    AND Stage__c = 'Done'
                                                    AND QC_Account__r.Type__c != 'Internal'              
                                                    AND QC_Account__r.Type__c != 'External'              
                                                    AND Payment_method__c IN :acceptedpaymentmethods
                                                    AND RecordType.DeveloperName IN :acceptedReccordtypes
                                                    AND Support__c = :this.MKPI.Sales__c                                            
                                                GROUP BY Industry__c, Agency__c]){

                    cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                    cc_KPI_Calculation_Helper.PaymentWrapper paymentdata = new cc_KPI_Calculation_Helper.PaymentWrapper();                                
                    String industry = (String)arr.get('Industry__c');                      
                    String agency = (String)arr.get('Agency__c');                     
                    Decimal amount = (Decimal) arr.get('Final_Amount__c');               

                    paymentdata.agency = agency; 
                    paymentdata.industry = industry;   
                    paymentdata.saleId = this.MKPI.Sales__c ;   
                    paymentdata.Amount =  amount;     

                    qc = cc_KPI_Calculation_Helper.getSupportPaymentKPICategory(supporturs, paymentdata);            
                    qc.exists = false;                 
                    payments.add(qc);           
                }
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