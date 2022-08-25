global class cc_KPI_Calculation_Support_Batch implements Database.Batchable<sObject>, Database.Stateful{
    private String kpiPeriod {get;set;}
    private Datetime minDateTime {get;set;}
    private Datetime maxDateTime {get;set;}
    private Date minDate {get;set;}
    private Date maxDate {get;set;}    
    private List<Sale_Spending_Payment__c> listUpSertSP;   
    private List<KPI__c> KPIs {get;set;}
    private List<Sale_Spending_Payment__c> listDeleteSP; 
    private Set<String> kpiIds {get;set;}   
    private List<cc_DMLResult_wrapper> lserrors  {get;set;} 
    private cc_KPI_Setting__c kpisetting {get;set;}
    private Boolean includePayment {get;set;}

    public cc_KPI_Calculation_Support_Batch(String period, Boolean pincludePayment) {
        this.kpiIds = new Set<String>();        
        this.lserrors = new  List<cc_DMLResult_wrapper>();
        this.KPIs = new List<KPI__c>();
        this.listUpSertSP = new List<Sale_Spending_Payment__c>();
        this.listDeleteSP = new List<Sale_Spending_Payment__c>();
        this.kpiPeriod = period;
        this.kpisetting = cc_Util.getKPISetting('ccKPISetting');
        this.includePayment = pincludePayment ==null?this.kpisetting.IncludePayment__c : pincludePayment;
        
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
                                                KPI_Category__c                                                
                                        FROM KPI__c WHERE Period__c =: kpiPeriod
                                            AND RecordType.DeveloperName = 'Support_KPI'
                                            AND Status__c != 'Confirmed']);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        
        Map<String,String> mapSale = new  Map<String,String>();
        Map<String, User> mapUser ;
        Set<String> kpiIds = new Set<String>();
        Map<String, List<Sale_Spending_Payment__c>> mapSP= new Map<String, List<Sale_Spending_Payment__c>>();
        Map<String, List<cc_QCData_wraper>> mapSpending = new Map<String, List<cc_QCData_wraper>>();
        Map<String, List<cc_QCData_wraper>> mapPayment = new Map<String, List<cc_QCData_wraper>>();

        for(KPI__c kpi: scope){
            kpiIds.add(kpi.Id);
            if(!String.isBlank(kpi.Sales__c) ){
                mapSale.put(kpi.Sales__c, kpi.Id);
                this.KPIs.add(kpi);
            }
        }

        mapUser = new map<String, User>([SELECT Id, Sale_Team__c FROM User WHERE Id IN :mapSale.keySet()]);

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

        for(AggregateResult arr  :  [SELECT Support__c Sale__c,                                             
                                            Industry__c Industry__c, 
                                            Agency__c Agency__c,                                                                           
                                        SUM(Total_Spending__c) Total_Spending__c
                                        FROM QC_Account_Data__c 
                                        WHERE syn_date__c >=: this.minDateTime 
                                            AND syn_date__c <=:  this.maxDateTime 
                                            AND Support__c IN  :mapSale.keySet()    
                                            AND QC_Account__r.Type__c != 'Internal' 
                                            AND QC_Account__r.Type__c != 'External'                                        
                                        GROUP BY Support__c, Industry__c, Agency__c]){

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
            cc_KPI_Calculation_Helper.SpendingWrapper spendingdata = new cc_KPI_Calculation_Helper.SpendingWrapper();

            Decimal amount = (Decimal)arr.get('Total_Spending__c');                   
            String industry = (String)arr.get('Industry__c');            
            String agency = (String)arr.get('Agency__c');      
            String sale = (String) arr.get('Sale__c');

            spendingdata.agency = agency; 
            spendingdata.industry = industry;   
            spendingdata.saleId = sale;   
            spendingdata.Amount =  amount; 
            User supporturs = mapUser.get(sale);

            qc=cc_KPI_Calculation_Helper.getSupportSpendingKPICategory(supporturs, spendingdata);
            qc.exists = false;
            
            if(mapSpending.containsKey(sale) ){
                mapSpending.get(sale).add(qc);
            }else{
                mapSpending.put(sale, new List<cc_QCData_wraper> {qc}); 
            }            
        }


        if(this.includePayment){
            //Payment
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

            if(acceptedReccordtypes != null && acceptedpaymentmethods !=null){

                for(AggregateResult arr  :  [SELECT Support__c Sale__c,                                                    
                                                    Industry__c Industry__c, 
                                                    Agency__c Agency__c,         
                                                SUM(Final_Amount__c) Final_Amount__c
                                                FROM Payment__c 
                                                WHERE EffectiveDate__c >=: this.minDate 
                                                    AND EffectiveDate__c <=: this.maxDate 
                                                    AND Stage__c = 'Done'
                                                    AND QC_Account__r.Type__c != 'Internal' 
                                                    AND QC_Account__r.Type__c != 'External' 
                                                    AND Payment_method__c IN :acceptedpaymentmethods
                                                    AND RecordType.DeveloperName IN :acceptedReccordtypes
                                                    AND Support__c IN  :mapSale.keySet()                                                    
                                                GROUP BY Support__c, Industry__c, Agency__c]){

                    cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                    cc_KPI_Calculation_Helper.PaymentWrapper paymentdata = new cc_KPI_Calculation_Helper.PaymentWrapper();                                
                    String industry = (String)arr.get('Industry__c');                      
                    String agency = (String)arr.get('Agency__c'); 
                    String sale = (String) arr.get('Sale__c');  
                    Decimal amount = (Decimal) arr.get('Final_Amount__c');               

                    paymentdata.agency = agency; 
                    paymentdata.industry = industry;   
                    paymentdata.saleId = sale;   
                    paymentdata.Amount =  amount;                        
                    User supporturs = mapUser.get(sale);

                    qc = cc_KPI_Calculation_Helper.getSupportPaymentKPICategory(supporturs, paymentdata);            
                    qc.exists = false; 
                    
                    if(mapPayment.containsKey(sale) ){
                        mapPayment.get(sale).add(qc);
                    }else{
                        mapPayment.put(sale, new List<cc_QCData_wraper> {qc}); 
                    }            
                }
            }    
        }
        
        
        //Calculation
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
                Set<String> kpis = new Set<String>();
                cc_KPI_GendetailFile_Support_batch generatefile = new cc_KPI_GendetailFile_Support_batch(this.kpiPeriod,kpis,this.includePayment);
                Database.executeBatch(generatefile, 20);               
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