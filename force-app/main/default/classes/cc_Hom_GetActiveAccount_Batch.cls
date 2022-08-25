global class cc_Hom_GetActiveAccount_Batch implements Database.Batchable<AggregateResult> , Database.Stateful{
    public Map<id,Id> accIdMap = new Map<id,Id>();
    public boolean isUpdateToPreviousCoupond {get;set;} 
    public string period {get;set;}    
    public Map<String,Set<String>> mapQCAccs {get;set;}     
    public Set<String> blankAccountQCIds {get;set;} 
    public date minDate {get;set;}
    public date maxDate {get;set;}
    public Datetime minDateTime {get;set;}
    public Datetime maxDateTime {get;set;}

    public cc_Hom_GetActiveAccount_Batch(string pperiod, boolean pisUpdateToPreviousCoupond){
        this.period = pperiod;
        this.isUpdateToPreviousCoupond = pisUpdateToPreviousCoupond;

        date dtToday = date.today();
        Date rundate;
        //Get First day of month and last day Of Month in runing period        
        if(!string.isBlank(pperiod)){    
            string[] M = pperiod.split('-');
            dtToday = date.NewInstance(integer.valueOf(M[1]), integer.valueOf(M[0]), 1 );
            rundate = dtToday;
        }else{           
            rundate = dttoday.addMonths(-1);                
        }

        this.minDate = rundate.toStartOfMonth();        
        this.maxDate = minDate.addDays(Date.daysInMonth(minDate.year(), minDate.month()) - 1);        
        this.minDateTime = Datetime.newInstance(minDate.year(), minDate.month(), minDate.day(), 0,0,0);       
        this.maxDateTime = Datetime.newInstance(maxDate.year(), maxDate.month(), maxDate.day(), 23,59,59); 

        mapQCAccs = new Map<String,Set<String>>();
        blankAccountQCIds = new Set<String>();
    }

    global Iterable<AggregateResult> start(Database.BatchableContext bc){
        String fromDt = minDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        String toDt = maxDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        System.debug('debug#:fromDt:' + fromDt);
        System.debug('debug#:toDt:' + toDt);

        System.debug('debug#:minDate:' + minDate);
        System.debug('debug#:maxDate:' + maxDate);

        String  sqlQuery = 'SELECT Accounts__c Accounts, QC_Account__c QC_Account FROM QC_Account_Data__c '; 
                sqlQuery += ' WHERE syn_date__c >= ' + fromDt ;
                sqlQuery += ' AND syn_date__c <= ' + toDt;                 
                sqlQuery += ' AND Total_Spending__c > 0';
                sqlQuery += ' GROUP BY Accounts__c, QC_Account__c';
        System.debug('debug#:sqlQuery:' + sqlQuery);
        return new cc_AggregateResultIterable (sqlQuery);        
    }
    global void execute(Database.BatchableContext bc, List<sObject> scope){  
        
        System.debug('debug#:scope:' + scope.size());
        for(sObject sc : scope) { 
            AggregateResult arr = (AggregateResult)sc;

            String accId = (String)arr.get('Accounts');
            String qcId = (String)arr.get('QC_Account');

            if (!String.isBlank(accId)){                
                if(this.mapQCAccs.containsKey(accId)){
                    this.mapQCAccs.get(accId).add(qcId);
                }else {
                    this.mapQCAccs.put(accId, new Set<String>{qcId});
                }    
            }else{
                this.blankAccountQCIds.add(qcId);
            }  
        }

        System.debug('debug#:mapQCAccs:' + mapQCAccs.size());
        System.debug('debug#:mapQCAccs1:' + this.mapQCAccs.size());
    }
    global void finish(Database.BatchableContext bc){
        
        cc_HOM_AutoCreateHOM_Batch createHOMs = 
            new cc_HOM_AutoCreateHOM_Batch(this.period, 
                                            this.isUpdateToPreviousCoupond, 
                                            this.mapQCAccs, 
                                            this.blankAccountQCIds,
                                            this.minDate,
                                            this.maxDate,                                            
                                            this.minDateTime,
                                            this.maxDateTime );
        database.executeBatch(createHOMs,50);
    }
}