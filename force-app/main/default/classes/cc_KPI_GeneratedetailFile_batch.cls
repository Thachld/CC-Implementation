global class cc_KPI_GeneratedetailFile_batch implements Database.Batchable<SObject>, Database.Stateful {
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
    private Set<String> runinkpis {get;set;}
    private String sqlStr {get;set;}    
    

    global cc_KPI_GeneratedetailFile_batch(String period, Set<String> pkpi) {
        this.kpiIds = new Set<String>();        
        this.lserrors = new  List<cc_DMLResult_wrapper>();
        this.KPIs = new List<KPI__c>();
        this.listUpSertSP = new List<Sale_Spending_Payment__c>();
        this.listDeleteSP = new List<Sale_Spending_Payment__c>();
        this.kpiPeriod = period;
        this.kpisetting = cc_Util.getKPISetting('ccKPISetting');
        this.runinkpis = pkpi;        

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


        if(pkpi != null && pkpi.size() > 0){
            this.sqlStr = 'SELECT Id, Name, Sales__c, Sales__r.LastName, Sales__r.Email,';
            this.sqlStr = this.sqlStr + ' SalesManager__c, From_Date__c, To_Date__c, Period__c, KPI_Category__c, Trac_Name__c';
            this.sqlStr = this.sqlStr + ' FROM KPI__c WHERE Period__c =:kpiPeriod';
            this.sqlStr = this.sqlStr + ' AND  RecordType.DeveloperName = \'Sale_KPI\' ';
            this.sqlStr = this.sqlStr + ' AND Status__c != \'Confirmed\'';
            this.sqlStr = this.sqlStr + ' AND Id IN :runinkpis';
        }else{
            this.sqlStr = 'SELECT Id, Name, Sales__c, Sales__r.LastName, Sales__r.Email,';
            this.sqlStr = this.sqlStr + ' SalesManager__c, From_Date__c, To_Date__c, Period__c, KPI_Category__c, Trac_Name__c';
            this.sqlStr = this.sqlStr + ' FROM KPI__c WHERE Period__c =:kpiPeriod';
            this.sqlStr = this.sqlStr + ' AND  RecordType.DeveloperName = \'Sale_KPI\' ';
            this.sqlStr = this.sqlStr + ' AND Status__c != \'Confirmed\'';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
      
        return Database.getQueryLocator(this.sqlStr);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){
        Map<String,String> mapSale = new  Map<String,String>();
        Set<String> kpiIds = new Set<String>();
        Set<String> qcIds = new Set<String>();
        Map<String, List<Sale_Spending_Payment__c>> mapSP= new Map<String, List<Sale_Spending_Payment__c>>();
        Map<String, List<cc_QCData_wraper>> mapSpending = new Map<String, List<cc_QCData_wraper>>();
        Map<String, List<cc_QCData_wraper>> mapPayment = new Map<String, List<cc_QCData_wraper>>();
        Map<String, List<cc_QCData_wraper>> mapRefund = new Map<String, List<cc_QCData_wraper>>();
        List<Attachment> attachs = new List<Attachment>();

        for(KPI__c kpi: scope){

            kpiIds.add(kpi.Id);
            if(!String.isBlank(kpi.Sales__c) ){
                mapSale.put(kpi.Sales__c, kpi.Id);
                this.KPIs.add(kpi);                
            }            
        }

        //delete old attachment
        delete [SELECT Id FROM Attachment WHERE ParentId IN :kpiIds];

        //Spending
        for(AggregateResult arr  :  [SELECT Sale__c Sale__c,
                                            QC_Account__c QC_Account__c,
                                            Industry__c Industry__c,
                                            Agency__c Agency__c,
                                            Xaxis__c Xaxis__c, 
                                            Special_client__c Special_client__c, 
                                            Is_HN_Region__c Is_HN_Region__c,
                                            Xaxis_Owner__c Xaxis_Owner__c, 
                                            Strategic_Client__c Strategic_Client__c,              
                                        SUM(Total_Spending__c) Total_Spending__c                                       
                                        FROM QC_Account_Data__c 
                                        WHERE syn_date__c >=: this.minDateTime 
                                            AND syn_date__c <=:  this.maxDateTime 
                                            AND Sale__c IN  :mapSale.keySet()    
                                            AND QC_Account__r.Type__c != 'Internal'   
                                            AND Total_Spending__c > 0                                   
                                        GROUP BY  Sale__c, QC_Account__c, Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c ,Xaxis_Owner__c, Strategic_Client__c]){

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 

            qc.Amount = (Decimal)arr.get('Total_Spending__c');                   
            String Industry = (String)arr.get('Industry__c');  
            Boolean xaxis = (Boolean)arr.get('Xaxis__c');     
            Boolean Specialclient = (Boolean)arr.get('Special_client__c');     
            String Agency = (String)arr.get('Agency__c');      
            Boolean Is_HN_Region = (Boolean)arr.get('Is_HN_Region__c');      
            Boolean Xaxis_Owner = (Boolean)arr.get('Xaxis_Owner__c');
            Boolean Strategic_Client = (Boolean)arr.get('Strategic_Client__c');           
            String QCAccount = (String)arr.get('QC_Account__c'); 

            qcIds.add(QCAccount);
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
            qc.Agency = Agency;
            qc.QCAccount = QCAccount;

            String sale = (String) arr.get('Sale__c');
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
                                                QC_Account__c QC_Account__c,
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
                                                AND Final_Amount__c > 0
                                                AND Payment_method__c IN :acceptedpaymentmethods 
                                                AND RecordType.DeveloperName IN :acceptedReccordtypes
                                                AND Sale__c IN  :mapSale.keySet()                                                    
                                            GROUP BY Sale__c, QC_Account__c, Industry__c, Xaxis__c, Special_client__c, Agency__c, Is_HN_Region__c, Xaxis_Owner__c,Strategic_Client__c]){

                cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
                qc.Amount = (Decimal)arr.get('Final_Amount__c');                   
                String Industry = (String)arr.get('Industry__c');  
                Boolean xaxis = (Boolean)arr.get('Xaxis__c');     
                Boolean Specialclient = (Boolean)arr.get('Special_client__c');     
                String Agency = (String)arr.get('Agency__c');
                Boolean Is_HN_Region = (Boolean)arr.get('Is_HN_Region__c');            
                Boolean Xaxis_Owner = (Boolean)arr.get('Xaxis_Owner__c');
                Boolean Strategic_Client = (Boolean)arr.get('Strategic_Client__c');
                String QCAccount = (String)arr.get('QC_Account__c');
                qcIds.add(QCAccount);

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
                qc.Agency = Agency;
                qc.QCAccount = QCAccount;

                String sale = (String) arr.get('Sale__c');
                if(mapPayment.containsKey(sale) ){
                    mapPayment.get(sale).add(qc);
                }else{
                    mapPayment.put(sale, new List<cc_QCData_wraper> {qc}); 
                }            
            }
        }

        //Refund Payment
        for(Payment__c py  :  [SELECT Sale__c, Name , Final_Amount__c, QC_Account__r.Name
                                        FROM Payment__c 
                                        WHERE EffectiveDate__c >=: this.minDate 
                                            AND EffectiveDate__c <=: this.maxDate 
                                            AND Stage__c = 'Done'
                                            AND QC_Account__r.Type__c != 'Internal' 
                                            AND Payment_method__c IN :acceptedpaymentmethods
                                            AND RecordType.DeveloperName = 'Refund_payment'
                                            AND Refund_Type__c = 'Refund to Client' 
                                            AND Sale__c IN  :mapSale.keySet()]){

            cc_QCData_wraper qc  = new  cc_QCData_wraper(); 
            qc.Name = py.Name;
            qc.Amount = py.Final_Amount__c;              
            qc.QCAccount = py.QC_Account__r.Name;                 
            String sale = py.Sale__c;    

            if(!String.isBlank(sale)){
                if(mapRefund.containsKey(sale)){
                    mapRefund.get(sale).add(qc);
                }else {
                    mapRefund.put(sale, new List<cc_QCData_wraper>{qc});
                }                
            }                                

        }

        //generate file
        Map<String, String> mapQCAccs = new Map<String, String>();
        for(QC_Account__c qc : [SELECT Id, Name FROM QC_Account__c WHERE Id IN :qcIds]){
            mapQCAccs.put(qc.Id, qc.Name);
        }


        String csvColumnHeader = 'QC Account, KPI Category,  Industry, Agency, Total Amount\n';
        for(KPI__c kpi : scope){
            List<cc_QCData_wraper> spendings = new List<cc_QCData_wraper>(); 
            List<cc_QCData_wraper> payments = new List<cc_QCData_wraper>();
            List<cc_QCData_wraper> refunds = new List<cc_QCData_wraper>();
            spendings = mapSpending.get(kpi.Sales__c);
            payments = mapPayment.get(kpi.Sales__c);
            refunds = mapRefund.get(kpi.Sales__c);

            //Spending file
            if(spendings != null){                
                List<String> csvRowValues = new List<String>();
                for(cc_QCData_wraper sp: spendings){

                    if(sp.Amount > 0){

                        String QCAccount = mapQCAccs.get(sp.QCAccount);
                        String QCAccountName = QCAccount ==null? '' : QCAccount;
                        String KPICategory = sp.KPICategory ==null? '' : sp.KPICategory;
                        String industry = sp.Industry ==null? '' : sp.Industry;
                        String agency = sp.Agency ==null? '' : sp.Agency;
                        String amount = String.valueOf(sp.Amount);

                        String csvRow = QCAccountName + ',' + KPICategory + ',' + industry + ',' + agency + ',' + amount; 
                        csvRowValues.add(csvRow);
                    }
                }

                if(csvRowValues !=null){
                    String csvFile = csvColumnHeader + String.join(csvRowValues, '\n');
                    String filename = (kpi.Trac_Name__c ==null?'': kpi.Trac_Name__c) + ' - Spending Detail - ' + kpi.Period__c + '.csv';
                    Attachment att = new Attachment(Name = filename, Body = Blob.valueOf(csvFile), ParentId = kpi.Id, ContentType='application/vnd.ms-excel', OwnerId = kpi.Sales__c);
                    attachs.add(att);                    
                    
                }
            }


            //Payment file
            if(payments != null){                   
                List<String> csvRowValues = new List<String>();
                for(cc_QCData_wraper py: payments){

                    if(py.Amount > 0){
                        String QCAccount = mapQCAccs.get(py.QCAccount);
                        String QCAccountName = QCAccount ==null? '' : QCAccount;
                        String KPICategory = py.KPICategory ==null? '' : py.KPICategory;
                        String industry = py.Industry ==null? '' : py.Industry;
                        String agency = py.Agency ==null? '' : py.Agency;
                        String amount = String.valueOf(py.Amount);

                        String csvRow = QCAccountName + ',' + KPICategory + ',' + industry + ',' + agency + ',' + amount; 
                        csvRowValues.add(csvRow);
                    }
                }

                if(csvRowValues !=null){
                    String csvFile = csvColumnHeader + String.join(csvRowValues, '\n');
                    String filename = (kpi.Trac_Name__c == null?'': kpi.Trac_Name__c) + ' - Payment Detail - ' + kpi.Period__c + '.csv';
                    Attachment att = new Attachment(Name = filename, Body = Blob.valueOf(csvFile), ParentId = kpi.Id, ContentType='application/vnd.ms-excel', OwnerId = kpi.Sales__c);
                    attachs.add(att);                    
                }
            }


            //Refund

            if(refunds !=null){
                String csvRFColumnHeader = 'QC Account, PaymentName, Total Amount\n';
                List<String> csvRowValues = new List<String>();
                for(cc_QCData_wraper rf: refunds){

                    if(rf.Amount > 0){                        
                        String QCAccountName = rf.QCAccount ==null? '' : rf.QCAccount;                        
                        String pyname = rf.Name ==null? '' : rf.Name;                        
                        String amount = String.valueOf(rf.Amount);

                        String csvRow = QCAccountName + ','  + pyname + ',' + amount; 
                        csvRowValues.add(csvRow);
                    }
                }

                if(csvRowValues !=null){
                    String csvFile = csvRFColumnHeader + String.join(csvRowValues, '\n');
                    String filename = (kpi.Trac_Name__c == null?'': kpi.Trac_Name__c) + ' - Refund Payment Detail - ' + kpi.Period__c + '.csv';
                    Attachment att = new Attachment(Name = filename, Body = Blob.valueOf(csvFile), ParentId = kpi.Id, ContentType='application/vnd.ms-excel', OwnerId = kpi.Sales__c);
                    attachs.add(att);                    
                }
            }




        }

        System.debug('attachs=>' + attachs.size());
        if(attachs != null){
            Database.insert(attachs, false);            
        }
    }

    global void finish(Database.BatchableContext bc){ 
        Set<String> reporttype = new Set<String>();        
        reporttype.add('Sale_KPI');        
        cc_KPI_SendEmail_Batch batch = new cc_KPI_SendEmail_Batch(this.kpiPeriod, reporttype, this.runinkpis);
        database.executeBatch(batch,20);
    }
}