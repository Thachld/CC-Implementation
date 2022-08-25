global class cc_Account_SpendingAccumByTime_Batch implements Database.Batchable<sObject>{        
    public String fieldTotal {get;set;}
    public String totalWhereClause {get;set;}
    public String objectAccum {get;set;}
    public String fieldAccum {get;set;}
    public String fieldAccumAlias {get;set;}
    public String fieldAgregate {get;set;}
    public String accumWhereClause {get;set;}
    public String AggregateFunc {get;set;}
    public String soqlString {get;set;}
    public String sfromDt {get;set;}
    public String stoDt {get;set;}
    
    public cc_Account_SpendingAccumByTime_Batch(String pFieldTotal, 
                                                String pTotalWhereClause,
                                                String pObjectAccum,
                                                String pFieldAccum,
                                                String pFieldAccumAlias,
                                                String pAgregateField, 
                                                String pAccumWhereClause,
                                                String pAggregateFunc,    
                                                Date pfromDT, 
                                                Date ptoDT                                            
                                                ){        
        this.fieldAccum = pfieldAccum;
        this.totalWhereClause = pTotalWhereClause;
        this.objectAccum = pObjectAccum;
        this.fieldTotal = pfieldTotal;
        this.AggregateFunc =  pAggregateFunc;    
        this.accumWhereClause = pAccumWhereClause;  
        this.fieldAgregate = pAgregateField;
        this.fieldAccumAlias = pFieldAccumAlias;
        
        this.soqlString = 'SELECT Id, ' + pFieldTotal;
        this.soqlString = this.soqlString + ' FROM Account ';
        if(!String.isBlank( pTotalWhereClause )){
            this.soqlString = + this.soqlString + ' WHERE ' + pTotalWhereClause;
        }        
        if(pfromDT != null && ptoDT != null && pObjectAccum == 'QC_Account_Data__c'){
            Datetime fromDatetime = Datetime.newInstance(pfromDT.year(), pfromDT.month(), pfromDT.day(), 0,0,0);       
            Datetime toDatetime = Datetime.newInstance(ptoDT.year(), ptoDT.month(), ptoDT.day(), 23,59,59);
            this.sfromDt = fromDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
            this.stoDt = toDatetime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''); 
        }
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc){       
                
        return Database.getQueryLocator(this.soqlString) ;  
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope){          
        Map<String,Account> mapAcc = new Map<String,Account>();
        List<Account> listAcctoUpdate = new List<Account>();

        for(sObject sc : scope) { 
            Account acc = (Account)sc;
            mapAcc.put(acc.Id, acc);
        }

        Set<String> keys = mapAcc.keySet();

        String accumSQL;
        accumSQL = 'SELECT ' + this.fieldAccum  + ' ' + this.fieldAccumAlias +  ', ';        
        accumSQL = accumSQL + this.AggregateFunc + '(' + this.fieldAgregate + ') ' + fieldAgregate;
        accumSQL = accumSQL + ' FROM ' + this.objectAccum;
        accumSQL = accumSQL + ' WHERE ' +  this.fieldAccum + ' IN :keys ';

        if(!String.isBlank( this.accumWhereClause )){
            accumSQL = accumSQL + ' AND (' + this.accumWhereClause + ' ) ';
        }

        if(!String.isBlank(this.sfromDt) && !String.isBlank(this.stoDt)){
            accumSQL = accumSQL + ' AND syn_date__c >= ' + this.sfromDt;
            accumSQL = accumSQL + ' AND syn_date__c <= ' + this.stoDt;           
        }

        accumSQL = accumSQL + ' GROUP BY ' + this.fieldAccum;

        System.debug('accumSQL  => ' + accumSQL);
        System.debug('this.soqlString  => ' + this.soqlString);

        List<AggregateResult> arrs = Database.query(accumSQL);
        System.debug('arrs  => ' + arrs.size());

        for(AggregateResult arr : arrs){

            String recId = (String)arr.get(this.fieldAccumAlias);
            Decimal accum = (Decimal)arr.get(this.fieldAgregate);      
            
            Account acc = mapAcc.get(recId);
            acc.put(this.fieldTotal, (accum == null? 0: accum));  

            listAcctoUpdate.add(acc);     
        }

        System.debug('listAcctoUpdate.size()  => ' + listAcctoUpdate.size());
        if(listAcctoUpdate.size() > 0){
            Database.update(listAcctoUpdate, false);
        }                  

    }

    global void finish(Database.BatchableContext bc){}
}