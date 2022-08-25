global class cc_KPI_Calculation_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public String kpiPeriod {get;set;}
    public Datetime minDateTime {get;set;}
    public Datetime maxDateTime {get;set;}
    public Date minDate {get;set;}
    public Date maxDate {get;set;}    
    public List<Sale_Spending_Payment__c> listUpSertSP;   
    public List<KPI__c> KPIs {get;set;}
    public List<Sale_Spending_Payment__c> listDeleteSP; 
    public Set<String> kpiIds {get;set;}   
    public List<cc_DMLResult_wrapper> lserrors  {get;set;} 
    public cc_KPI_Setting__c kpisetting {get;set;}

    public cc_KPI_Calculation_Batch(String period) {
        this.kpiIds = new Set<String>();        
        this.lserrors = new  List<cc_DMLResult_wrapper>();
        this.KPIs = new List<KPI__c>();
        this.listUpSertSP = new List<Sale_Spending_Payment__c>();
        this.listDeleteSP = new List<Sale_Spending_Payment__c>();
        this.kpiPeriod = period;
        this.kpisetting = cc_Util.getKPISetting('ccKPISetting');
        
        date dtToday = date.today();
        Date rundate;
        //Get First day of month and last day Of Month in runing period        
        if(!string.isBlank(period)){    
            string[] M = period.split('-');
            dtToday = date.NewInstance(integer.valueOf(M[1]), integer.valueOf(M[0]), 1 );
            rundate = dtToday;
        }else{           
            rundate = dttoday.addMonths(-1);                
        }

        this.minDate = rundate.toStartOfMonth();        
        this.maxDate = minDate.addDays(Date.daysInMonth(minDate.year(), minDate.month()) - 1);        
        this.minDateTime = Datetime.newInstance(minDate.year(), minDate.month(), minDate.day(), 0,0,0);       
        this.maxDateTime = Datetime.newInstance(maxDate.year(), maxDate.month(), maxDate.day(), 23,59,59); 
    }


    global Database.QueryLocator start(Database.BatchableContext bc) {
      
        return Database.getQueryLocator([SELECT Id, Name, Sales__c, Sales__r.LastName, Sales__r.Email,
                                                SalesManager__c, From_Date__c, To_Date__c, Period__c,
                                                KPI_Category__c, TotalRefundAmount__c                                                
                                        FROM KPI__c WHERE Period__c =: kpiPeriod
                                            AND RecordType.DeveloperName = 'Sale_KPI'
                                            AND Status__c != 'Confirmed']);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        
        Map<String,String> mapSale = new  Map<String,String>();
        Set<String> kpiIds = new Set<String>();
        Map<String, List<Sale_Spending_Payment__c>> mapSP= new Map<String, List<Sale_Spending_Payment__c>>();
        Map<String, List<cc_QCData_wraper>> mapSpending = new Map<String, List<cc_QCData_wraper>>();
        Map<String, List<cc_QCData_wraper>> mapPayment = new Map<String, List<cc_QCData_wraper>>();
        Map<String, cc_QCData_wraper> mapRefund = new Map<String, cc_QCData_wraper>();
        Map<String, User> mapUser ;

        for(KPI__c kpi: scope){
            kpiIds.add(kpi.Id);
            if(!String.isBlank(kpi.Sales__c) ){
                mapSale.put(kpi.Sales__c, kpi.Id);
                this.KPIs.add(kpi);
            }
        }


        for(Sale_Spending_Payment__c sp : [SELECT Id, KPI__c, KPI__r.KPIAutoNumber__c, KPI_Number__c, 
                                            Payment_Amount__c, Spending_Amount__c, KPI_Category__c
                                             FROM Sale_Spending_Payment__c 
                                            WHERE KPI__c IN :kpiIds]){
            if(mapSP.containsKey(sp.KPI__c)){
                mapSP.get(sp.KPI__c).add(sp);
            }else{
                mapSP.put(sp.KPI__c, new List<Sale_Spending_Payment__c>{sp});
            }                                 
        }

        mapUser = new map<String, User>([SELECT Id, Sale_Team__c FROM User WHERE Id IN :mapSale.keySet()]);

        //Spending 
        for(AggregateResult arr  :  [SELECT Sale__c Sale__c, 
                                            Xaxis__c Xaxis__c, 
                                            Special_client__c Special_client__c, 
                                            Industry__c Industry__c, 
                                            Agency__c Agency__c, 
                                            Is_HN_Region__c Is_HN_Region__c,
                                            Xaxis_Owner__c Xaxis_Owner__c, 
                                            Strategic_Client__c Strategic_Client__c,                                 
                                        SUM(Total_Spending__c) Total_Spending__c
                                        FROM QC_Account_Data__c 
                                        WHERE syn_date__c >=: this.minDateTime 
                                            AND syn_date__c <=:  this.maxDateTime 
                                            AND Sale__c IN  :mapSale.keySet()    
                                            AND QC_Account__r.Type__c != 'Internal'                                       
                                        GROUP BY Sale__c, Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c ,Xaxis_Owner__c, Strategic_Client__c]){

            
            Decimal amount = (Decimal)arr.get('Total_Spending__c');                   
            String industry = (String)arr.get('Industry__c');  
            Boolean isXaxis = (Boolean)arr.get('Xaxis__c');     
            Boolean isSpecialclient = (Boolean)arr.get('Special_client__c');     
            String agency = (String)arr.get('Agency__c');      
            Boolean isHNRegion = (Boolean)arr.get('Is_HN_Region__c');      
            Boolean isXaxisOwner = (Boolean)arr.get('Xaxis_Owner__c');
            Boolean isStrategicClient = (Boolean)arr.get('Strategic_Client__c');
            String sale = (String) arr.get('Sale__c');

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
            cc_KPI_Calculation_Helper.SpendingWrapper spendingdata = new cc_KPI_Calculation_Helper.SpendingWrapper();
            spendingdata.agency = agency; 
            spendingdata.industry = industry;               
            spendingdata.Amount =  amount; 
            spendingdata.isHNRegion = isHNRegion;
            spendingdata.isSpecialclient = isSpecialclient;
            spendingdata.isStrategicClient = isStrategicClient;
            spendingdata.isXaxis = isXaxis;
            spendingdata.isXaxisOwner = isXaxisOwner;
            spendingdata.saleId = sale;
            
            User saleurs = mapUser.get(sale);

            qc = cc_KPI_Calculation_Helper.getSaleSpendingKPICategory(saleurs, spendingdata);
            qc.exists = false;              
            if(mapSpending.containsKey(sale) ){
                mapSpending.get(sale).add(qc);
            }else{
                mapSpending.put(sale, new List<cc_QCData_wraper> {qc}); 
            }            
        }


        //Payment
        String accepted_recordtype = this.kpisetting.PaymentRecordType__c;
        String [] acceptedReccordtypes;
        if(!String.isBlank(accepted_recordtype)){
            acceptedReccordtypes = accepted_recordtype.split(',');
        }

        String accepted_paymentMethod = this.kpisetting.Paymentmethod__c;
        String [] acceptedpaymentmethods;
        if(!String.isBlank(accepted_paymentMethod)){
            acceptedpaymentmethods = accepted_paymentMethod.split(',');
        }

        if(acceptedReccordtypes != null && acceptedpaymentmethods !=null){

            for(AggregateResult arr  :  [SELECT Sale__c Sale__c, 
                                                Xaxis__c Xaxis__c, 
                                                Special_client__c Special_client__c, 
                                                Industry__c Industry__c, 
                                                Agency__c Agency__c,   
                                                Is_HN_Region__c Is_HN_Region__c, 
                                                Xaxis_Owner__c Xaxis_Owner__c,      
                                                Strategic_Client__c Strategic_Client__c,                               
                                            SUM(Final_Amount__c) Final_Amount__c
                                            FROM Payment__c 
                                            WHERE EffectiveDate__c >=: this.minDate 
                                                AND EffectiveDate__c <=: this.maxDate 
                                                AND Stage__c = 'Done'
                                                AND QC_Account__r.Type__c != 'Internal' 
                                                AND Payment_method__c IN :acceptedpaymentmethods
                                                AND RecordType.DeveloperName IN :acceptedReccordtypes
                                                AND Sale__c IN  :mapSale.keySet()                                                    
                                            GROUP BY Sale__c, Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c, Xaxis_Owner__c,Strategic_Client__c]){
               
                Decimal amount = (Decimal)arr.get('Final_Amount__c');                   
                String industry = (String)arr.get('Industry__c');  
                Boolean isXaxis = (Boolean)arr.get('Xaxis__c');     
                Boolean isSpecialclient = (Boolean)arr.get('Special_client__c');     
                String agency = (String)arr.get('Agency__c');      
                Boolean isHNRegion = (Boolean)arr.get('Is_HN_Region__c');      
                Boolean isXaxisOwner = (Boolean)arr.get('Xaxis_Owner__c');
                Boolean isStrategicClient = (Boolean)arr.get('Strategic_Client__c');
                String sale = (String) arr.get('Sale__c');
                

                cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                cc_KPI_Calculation_Helper.PaymentWrapper paymentdata = new cc_KPI_Calculation_Helper.PaymentWrapper();
                paymentdata.agency = agency; 
                paymentdata.industry = industry;               
                paymentdata.Amount =  amount; 
                paymentdata.isHNRegion = isHNRegion;
                paymentdata.isSpecialclient = isSpecialclient;
                paymentdata.isStrategicClient = isStrategicClient;
                paymentdata.isXaxis = isXaxis;
                paymentdata.isXaxisOwner = isXaxisOwner;
                paymentdata.saleId = sale;
                
                User saleurs = mapUser.get(sale);

                qc = cc_KPI_Calculation_Helper.getSalePaymentKPICategory(saleurs, paymentdata);
                qc.exists = false;              
                
                if(mapPayment.containsKey(sale) ){
                    mapPayment.get(sale).add(qc);
                }else{
                    mapPayment.put(sale, new List<cc_QCData_wraper> {qc}); 
                }            
            }
        }   
        
        
        //Refund Payment
        for(AggregateResult arr  :  [SELECT Sale__c Sale__c,                             
                                        SUM(Final_Amount__c) Final_Amount__c
                                        FROM Payment__c 
                                        WHERE EffectiveDate__c >=: this.minDate 
                                            AND EffectiveDate__c <=: this.maxDate 
                                            AND Stage__c = 'Done'
                                            AND QC_Account__r.Type__c != 'Internal' 
                                            AND Payment_method__c IN :acceptedpaymentmethods
                                            AND RecordType.DeveloperName = 'Refund_payment'
                                            AND Refund_Type__c = 'Refund to Client' 
                                            AND Sale__c IN  :mapSale.keySet()                                                    
                                        GROUP BY Sale__c]){

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
            qc.Amount = (Decimal)arr.get('Final_Amount__c');                   
            String sale = (String) arr.get('Sale__c');            

            if(!String.isBlank(sale)){
                mapRefund.put(sale, qc);
            }                                

        }


        for(KPI__c kpi : scope){

            List<cc_QCData_wraper> alls = new List<cc_QCData_wraper>();
            List<Sale_Spending_Payment__c> sps = mapSP.get(kpi.Id);

            if(sps != null){
                
                List<cc_QCData_wraper> spendings = new List<cc_QCData_wraper>(); 
                Map<String, List<cc_QCData_wraper>> mapAlls = new Map<String, List<cc_QCData_wraper>>();
                List<cc_QCData_wraper> payments = new List<cc_QCData_wraper>();
                spendings = mapSpending.get(kpi.Sales__c);
                payments = mapPayment.get(kpi.Sales__c);

                for(Sale_Spending_Payment__c  sp: sps){
                    sp.Spending_Amount__c = 0;
                    sp.Payment_Amount__c = 0;

                    if(spendings != null){
                        for(cc_QCData_wraper spending: spendings){

                            if(sp.KPI_Category__c == spending.KPICategory){
                                Decimal amount = spending.Amount==null?0: spending.Amount;
                                sp.Spending_Amount__c = sp.Spending_Amount__c ==null?0 : sp.Spending_Amount__c + amount;
                                spending.exists = true;                                
                            }
                        }
                    }


                    if(payments != null){
                        for(cc_QCData_wraper payment: payments){
                            if(sp.KPI_Category__c == payment.KPICategory){    
                                Decimal amount = payment.Amount==null?0: payment.Amount;                        
                                sp.Payment_Amount__c = sp.Payment_Amount__c ==null?0 : sp.Payment_Amount__c + amount;
                                payment.exists = true;                                
                            }
                        }
                    }
                    
                    this.listUpSertSP.add(sp);   
                                
                }              
            }


            if(mapRefund != null){
                cc_QCData_wraper rf = mapRefund.get(kpi.Sales__c);
                if(rf != null && rf.Amount !=null){
                    kpi.TotalRefundAmount__c = (rf.Amount == null?0 : rf.Amount);
                }
            }

            this.kpiIds.add(kpi.Id);            

            //Process for case KPI: Actual KPI data is not assign
            
        }
    }

    global void finish(Database.BatchableContext bc){        

        if(this.listUpSertSP.size() > 0){
            Schema.SObjectField field = Sale_Spending_Payment__c.Fields.KPI_Number__c;
            Database.UpsertResult[] results = Database.upsert(this.listUpSertSP, field,false);

            for(Database.UpsertResult rs: results){
                if (!rs.isSuccess()){
                    cc_DMLResult_wrapper err = new cc_DMLResult_wrapper();
                    err.Errors  = JSON.serialize(rs.getErrors()) ;  
                    this.lserrors.add(err);                 
                }
            }

            if(this.kpiIds.size() >0){
                Boolean isGeneratefile = true;
                cc_KPI_CalculationActivities_Batch activitiesbatch = new cc_KPI_CalculationActivities_Batch(this.kpiPeriod , isGeneratefile);
                Database.executeBatch(activitiesbatch, 40);               
            }

            if(this.lserrors.size() > 0){

                AsyncApexJob asyn = [SELECT id, ApexClassId, ApexClass.name,
                                        JobItemsProcessed, TotalJobItems,
                                        NumberOfErrors, CreatedBy.Email
                                    FROM AsyncApexJob
                                    WHERE Id = :bc.getJobId()];
    
                Integer successed = 0;
                BatchJobLog__c batchlog = new BatchJobLog__c();
                batchlog.BatchClassName__c = asyn.ApexClass.name;
                batchlog.JobId__c = bc.getJobId();
                batchlog.Period__c = this.kpiPeriod;
                batchlog.RunningUser__c = UserInfo.getUserId();
                insert batchlog;
    
                List<BatchJobLogDetail__c> errsLog = new List<BatchJobLogDetail__c>();
                for(cc_DMLResult_wrapper err: this.lserrors){
                    
                    BatchJobLogDetail__c log = new BatchJobLogDetail__c();
                    log.IsCreated__c = true;                
                    log.ErrorLog__c = err.Errors;
                    log.BatchJobLog__c = batchlog.Id;
    
                    errsLog.add(log);    
                } 
                
                if (errsLog.size() > 0){   
                    insert errsLog;
                }
            }
        }            
    }    
}