global class cc_Spending_Report_GetQCAccount_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global set<id> qcAccountSet {get;set;}
    public dateTime dtFrom {get;set;}
    public dateTime dtTo {get;set;}
    public string strDate {get;set;}
	public cc_Spending_Report_GetQCAccount_Batch(string strDateTemp){
        qcAccountSet = new set<id>();
        strDate = strDateTemp;
        Datetime dtlastMonth = datetime.now();
        if( !string.isBlank(strDate)){
            string[] M = strDate.split('/');
            dtlastMonth = DateTime.NewInstance(integer.valueOf(M[2]), integer.valueOf(M[1]),integer.valueOf(M[0]));
        }
        else{
            dtlastMonth = dtlastMonth.addMonths(-1);
        }
        
        integer noOfDays = Date.daysInMonth(dtlastMonth.year(), dtlastMonth.month());
        //NewInstanceGMT
        dtFrom = DateTime.NewInstance( dtlastMonth.year(), dtlastMonth.month(), 1, 0,0,0);
        dtTo = DateTime.NewInstance( dtlastMonth.year(), dtlastMonth.month(), noOfDays,23,59,59);
       
        
    }
     global Database.QueryLocator start(Database.BatchableContext bc) {
       
       return database.getqueryLocator([select id, syn_date__c,QC_Account__r.Sale_Email__c ,QC_Account__r.Owner.Name, QC_Account__c,QC_Account__r.Name, QC_Account__r.AccountOwner__r.name,QC_Account__r.Agency_Email__c
                                        from QC_Account_Data__c 
                                        where syn_date__c >=: dtFrom and syn_date__c <=: dtTo]);
    }
     global void execute(Database.BatchableContext bc, List<QC_Account_Data__c> qcAccountDataList){
         for(QC_Account_Data__c item: qcAccountDataList){
             if(!qcAccountSet.contains(item.QC_Account__c)){
                 qcAccountSet.add(item.QC_Account__c);
             }
         }
     }
     global void finish(Database.BatchableContext bc){ 
         integer i = 0; 
         Set<Id> qcAccountSetTemp = new Set<Id>();
         for(id item: qcAccountSet){
             qcAccountSetTemp.add(item);
             i++;
             if(i == 1000){
                i = 0;
                cc_Spending_Report_Batch temp = new cc_Spending_Report_Batch(strDate, qcAccountSetTemp);
				database.executeBatch(temp);
                qcAccountSetTemp  = new set<id>();
             }
         }
         if(qcAccountSetTemp.size() >0){
             cc_Spending_Report_Batch temp = new cc_Spending_Report_Batch(strDate, qcAccountSetTemp);
			database.executeBatch(temp);
         }
     }
}