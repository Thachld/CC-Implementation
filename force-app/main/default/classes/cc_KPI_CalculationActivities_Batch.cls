global class cc_KPI_CalculationActivities_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public String kpiPeriod {get;set;}    
    public Date minDate {get;set;}
    public Date maxDate {get;set;}   
    public Set<String> kpiIds {get;set;}
    List<Daily_KPI__c> updateKPIDetails {get;set;}    
    List<cc_DMLResult_wrapper> lserrors  {get;set;} 
    public Map<String, List<cc_kpimetrics_wraper>> mapMetrics{get;set;}
    public Boolean isrunNextJob {get;set;}

    public cc_KPI_CalculationActivities_Batch(String period, Boolean pisrunNextJob) {
        this.kpiPeriod = period;        
        this.lserrors = new List<cc_DMLResult_wrapper>();
        this.updateKPIDetails = new List<Daily_KPI__c>();
        this.mapMetrics = new Map<String, List<cc_kpimetrics_wraper>>();
        this.isrunNextJob = pisrunNextJob;

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
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Sales__c                                               
                                        FROM KPI__c 
                                        WHERE Period__c =: this.kpiPeriod
                                            AND RecordType.DeveloperName = 'Sale_KPI'
                                            AND Status__c != 'Confirmed'
                                            ]); 
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        Set<String> processKPIIds = new Set<String>();
        Map<String,String> mapSale = new Map<String,String>();        
        List<Daily_KPI__c> dailyKPIs = new List<Daily_KPI__c>();

        for (KPI__c kpi : scope){
            processKPIIds.add(kpi.Id);
            mapSale.put(kpi.Sales__c, kpi.Id);            
        }


        //Delete current KPI
        List<Daily_KPI__c> deletedailyKPI = [SELECT Id FROM Daily_KPI__c WHERE KPI__c IN :processKPIIds ];
        Database.delete(deletedailyKPI, false);

        //New Lead
        for(AggregateResult arr :[SELECT Count(Id) value, CreatedDate__c CreatedDate, OwnerId OwnerId  
                                    FROM Lead 
                                    WHERE OwnerId IN :mapSale.keySet()
                                        AND CreatedDate__c >= :this.minDate
                                        AND CreatedDate__c <= :this.maxDate
                                    GROUP BY CreatedDate__c,OwnerId  ] ){
            
            Date createDate = (Date)arr.get('CreatedDate');   
            String ownerId = (String)arr.get('OwnerId');                         
            String datakey = ownerId + '_' +  String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            Decimal value = (Decimal)arr.get('value');

            cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();

            kpi.kpidate = createDate;
            kpi.kpivalue = value;
            kpi.kpimetrics = 'NewLead';

            if(this.mapMetrics.containsKey(datakey)){   
                this.mapMetrics.get(datakey).add(kpi);
            }else{
                this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
            }                            
        }

        // New Oppoturnity
        for(AggregateResult arr :[SELECT Count(Id) value, CreatedDate__c CreatedDate, OwnerId OwnerId    
                                    FROM Opportunity 
                                    WHERE OwnerId IN :mapSale.keySet()
                                        AND CreatedDate__c >= :this.minDate
                                        AND CreatedDate__c <= :this.maxDate
                                    GROUP BY CreatedDate__c, OwnerId]){

            Date createDate = (Date)arr.get('CreatedDate');   
            String ownerId = (String)arr.get('OwnerId');                                 
            String datakey = ownerId + '_' +  String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            Decimal value = (Decimal)arr.get('value');

            cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();
            kpi.kpidate = createDate;
            kpi.kpivalue = value;
            kpi.kpimetrics = 'NewOpp';

            if(this.mapMetrics.containsKey(datakey)){
                this.mapMetrics.get(datakey).add(kpi);
            }else{
                this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
            }
            
        }

        // Opps Closed
        for(AggregateResult arr :[SELECT Count(Id) value, StageName Stage, CloseDate CloseDate, OwnerId OwnerId  
                                    FROM Opportunity 
                                    WHERE OwnerId IN :mapSale.keySet()
                                        AND IsClosed = true 
                                        AND CloseDate >= :this.minDate
                                        AND CloseDate <= :this.maxDate
                                    GROUP BY StageName, CloseDate, OwnerId ]){

            Date CloseDate = (Date)arr.get('CloseDate');  
            String stage = (String)arr.get('Stage');   
            String ownerId = (String)arr.get('OwnerId');                       
            String datakey = ownerId + '_' + String.valueOf(CloseDate.year()) + String.valueOf(CloseDate.month()) + String.valueOf(CloseDate.day());
            if(stage == 'Closed Won'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();    
                kpi.kpidate = CloseDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Closed Won';

                if(this.mapMetrics.containsKey(datakey)){
                    this.mapMetrics.get(datakey).add(kpi);
                }else{
                    this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }else if(stage == 'Closed Lost'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();
    
                kpi.kpidate = CloseDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Closed Lost';

                if(this.mapMetrics.containsKey(datakey)){  
                    this.mapMetrics.get(datakey).add(kpi);
                }else{
                    this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }
            
        }

        // Task Activity
        for(AggregateResult arr :[SELECT Count(Id) value, TaskSubtype Type, CreatedDate__c CreatedDate, OwnerId OwnerId  
                                    FROM Task 
                                    WHERE OwnerId IN :mapSale.keySet()
                                        AND TaskSubtype IN ('Call','Meeting','Email')
                                        AND CreatedDate__c >= :this.minDate
                                        AND CreatedDate__c <= :this.maxDate
                                    GROUP BY TaskSubtype, CreatedDate__c, OwnerId]){

            Date createDate = (Date)arr.get('CreatedDate');   
            String type = (String)arr.get('Type');           
            String ownerId = (String)arr.get('OwnerId');       

            String datakey = ownerId + '_' + String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            if(type == 'Call'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();
    
                kpi.kpidate = createDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Call';

                if(this.mapMetrics.containsKey(datakey)){
                    this.mapMetrics.get(datakey).add(kpi);
                }else{
                    this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }else if(type == 'Email'){
                Decimal value = (Decimal)arr.get('value');
    
                cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();

                kpi.kpidate = createDate;
                kpi.kpivalue = value;
                kpi.kpimetrics = 'Email';

                if(this.mapMetrics.containsKey(datakey)){                   
                    this.mapMetrics.get(datakey).add(kpi);
                }else{
                    this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
                }
            }            
        }

        for(AggregateResult arr :[SELECT Count(Id) value, CreatedDate__c CreatedDate , OwnerId OwnerId   
                                    FROM Event 
                                    WHERE OwnerId IN :mapSale.keySet()
                                        AND Type IN ('Meeting')
                                        AND CreatedDate__c >= :this.minDate
                                        AND CreatedDate__c <= :this.maxDate
                                    GROUP BY CreatedDate__c, OwnerId]){

            Date createDate = (Date)arr.get('CreatedDate');  
            String ownerId = (String)arr.get('OwnerId');
            String datakey = ownerId + '_' + String.valueOf(createDate.year()) + String.valueOf(createDate.month()) + String.valueOf(createDate.day());
            Decimal value = (Decimal)arr.get('value');
    
            cc_kpimetrics_wraper kpi = new cc_kpimetrics_wraper();

            kpi.kpidate = createDate;
            kpi.kpivalue = value;
            kpi.kpimetrics = 'Meeting';

            if(this.mapMetrics.containsKey(datakey)){                   
                this.mapMetrics.get(datakey).add(kpi);
            }else{
                this.mapMetrics.put(datakey, new List<cc_kpimetrics_wraper>{kpi});
            }                                
        }


        for(String datakey: this.mapMetrics.keySet()){   
            Integer intIndex = datakey.indexOf('_');
            String sales = datakey.substring(0, intIndex);

            List<cc_kpimetrics_wraper> kpis = this.mapMetrics.get(datakey);

            if(kpis != null){
                Daily_KPI__c dailykpi = new Daily_KPI__c();
                String day = kpis[0].kpidate.day() < 10?'0' + String.valueOf(kpis[0].kpidate.day()) : String.valueOf(kpis[0].kpidate.day());
                String month = kpis[0].kpidate.month() < 10?'0' + String.valueOf(kpis[0].kpidate.month()) : String.valueOf(kpis[0].kpidate.month());
                dailykpi.Name =  day + '/' + month + '/' + String.valueOf(kpis[0].kpidate.year());
                dailykpi.KPI__c = mapSale.get(sales);
                dailykpi.Date__c = kpis[0].kpidate;

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

                dailyKPIs.add(dailykpi);

            }
        }


        if(dailyKPIs.size() > 0){
            Database.SaveResult[] results = Database.insert(dailyKPIs,false);

            for(Database.SaveResult rs: results){
                if (!rs.isSuccess()){
                    cc_DMLResult_wrapper err = new cc_DMLResult_wrapper();
                    err.Errors  = JSON.serialize(rs.getErrors()) ;    
                    this.lserrors.add(err);                 
                }
            }
        }
    }

    global void finish(Database.BatchableContext bc){
        if(this.isrunNextJob){
            Set<String> pkpiIds = new Set<String>();
            cc_KPI_GeneratedetailFile_batch generatefile = new cc_KPI_GeneratedetailFile_batch(this.kpiPeriod, pkpiIds);
            Database.executeBatch(generatefile, 20);      
        }
    }
}