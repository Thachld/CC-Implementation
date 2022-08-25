public with sharing class SpendingMasterReport_Batch implements Database.Batchable<SObject>{    
    private Datetime startDt;
    private Datetime endDt;
    private Integer limitBatch;

    public SpendingMasterReport_Batch(Date pfromdate, Date ptodate) {
        this.startDt = Datetime.newInstance(pfromdate.year(), pfromdate.month(), pfromdate.day(), 0,0,0);       
        this.endDt = Datetime.newInstance(ptodate.year(), ptodate.month(), ptodate.day(), 23,59,59);       
        this.limitBatch = pfromdate.daysBetween(ptodate) + 1;
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id FROM Account LIMIT :this.limitBatch ]);
    }


    public void execute(Database.BatchableContext bc, List<SObject> scope){
        cc_KPI_Setting__c setting = cc_KPI_Setting__c.getInstance('ccKPISetting');
        List<Spending_Master_Report__c> listInsert = new List<Spending_Master_Report__c>();
        String[] setTeams = new String[] { 'Global', 'Other' , 'Audience' , 'Direct-Local'};
        Map<Date,List<SpendingWrapper>> mapSpending = new Map<Date,List<SpendingWrapper>>();

        for (AggregateResult arr : [SELECT Agency__c Agency__c,                                        
                                        Is_Internal__c Is_Internal__c,                                         
                                        CALENDAR_YEAR(convertTimezone(syn_date__c)) CYEAR,      
                                        CALENDAR_MONTH(convertTimezone(syn_date__c)) CMONTH,      
                                        DAY_IN_MONTH(convertTimezone(syn_date__c)) CDAY,                                 
                                        SUM(Desktop_Spending__c) Desktop_Spending__c,
                                        SUM(Mobile_Spending__c) Mobile_Spending__c,
                                        SUM(Audience_Network_Internal__c) Audience_Network_Internal__c,
                                        SUM(Audience_Network_External__c) Audience_Network_External__c,
                                        SUM(Total_Spending__c) Total_Spending__c
                                        
                                        FROM QC_Account_data__c
                                        WHERE syn_date__c >= :this.startDt
                                            AND syn_date__c <= : this.endDt                                    
                                            AND Total_spending__c > 0
                                        GROUP BY Agency__c , Is_Internal__c, CALENDAR_YEAR(convertTimezone(syn_date__c)),
                                                CALENDAR_MONTH(convertTimezone(syn_date__c)), DAY_IN_MONTH(convertTimezone(syn_date__c)) ]){

            String agency = (String)arr.get('Agency__c');
            Boolean isInternal = (Boolean)arr.get('Is_Internal__c');

            Integer cyear = (Integer)arr.get('CYEAR');
            Integer cmonth = (Integer)arr.get('CMONTH');
            Integer cday = (Integer)arr.get('CDAY');
            Date converDate = Date.newInstance(cyear, cmonth, cday);
            
            Decimal desktopSpending = (Decimal)arr.get('Desktop_Spending__c');
            Decimal mobileSpending = (Decimal)arr.get('Mobile_Spending__c');
            Decimal audienceINSpending = (Decimal)arr.get('Audience_Network_Internal__c');
            Decimal audienceEXSpending = (Decimal)arr.get('Audience_Network_External__c');
            Decimal totalSpending = (Decimal)arr.get('Total_Spending__c');
            

            System.debug('converDate=>' + converDate);
            System.debug('cyear=>' + cyear);
            System.debug('cmonth=>' + cmonth);
            System.debug('cday=>' + cday);
            
            
            if(agency == 'Global Agency'){
                if(isInternal){
                    SpendingWrapper data = new SpendingWrapper();
                    data.Team = 'Other';
                    data.Type = 'Other';
                    data.SpendingAmount = (totalSpending == null ? 0 : totalSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(data);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{data});
                    }

                }else {
                    //Mobile
                    SpendingWrapper datamobile = new SpendingWrapper();
                    datamobile.Team = 'Global';
                    datamobile.Type = 'Mobile';
                    datamobile.SpendingAmount = (mobileSpending == null ? 0 : mobileSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(datamobile);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{datamobile});
                    }

                    //Desktop
                    SpendingWrapper datadesktop = new SpendingWrapper();
                    datadesktop.Team = 'Global';
                    datadesktop.Type = 'Desktop';
                    datadesktop.SpendingAmount = (desktopSpending == null ? 0 : desktopSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(datadesktop);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{datadesktop});
                    }

                    //Audience Internal
                    SpendingWrapper dataAudienceIN = new SpendingWrapper();
                    dataAudienceIN.Team = 'Audience';
                    dataAudienceIN.Type = 'Internal';
                    dataAudienceIN.SpendingAmount = (audienceINSpending == null ? 0 : audienceINSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(dataAudienceIN);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{dataAudienceIN});
                    }

                    //Audience External
                    SpendingWrapper dataAudienceEX= new SpendingWrapper();
                    dataAudienceEX.Team = 'Audience';
                    dataAudienceEX.Type = 'External';
                    dataAudienceEX.SpendingAmount = (audienceEXSpending == null ? 0 : audienceEXSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(dataAudienceEX);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{dataAudienceEX});
                    }
                }

            }else{
                if(isInternal){
                    SpendingWrapper data = new SpendingWrapper();
                    data.Team = 'Other';
                    data.Type = 'Other';
                    data.SpendingAmount = (totalSpending == null ? 0 : totalSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(data);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{data});
                    }

                }else {
                    //Mobile
                    SpendingWrapper datamobile = new SpendingWrapper();
                    datamobile.Team = 'Direct-Local';
                    datamobile.Type = 'Mobile';
                    datamobile.SpendingAmount = (mobileSpending == null ? 0 : mobileSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(datamobile);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{datamobile});
                    }

                    //Desktop
                    SpendingWrapper datadesktop = new SpendingWrapper();
                    datadesktop.Team = 'Direct-Local';
                    datadesktop.Type = 'Desktop';
                    datadesktop.SpendingAmount = (desktopSpending == null ? 0 : desktopSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(datadesktop);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{datadesktop});
                    }

                    //Audience Internal
                    SpendingWrapper dataAudienceIN = new SpendingWrapper();
                    dataAudienceIN.Team = 'Audience';
                    dataAudienceIN.Type = 'Internal';
                    dataAudienceIN.SpendingAmount = (audienceINSpending == null ? 0 : audienceINSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(dataAudienceIN);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{dataAudienceIN});
                    }

                    //Audience External
                    SpendingWrapper dataAudienceEX= new SpendingWrapper();
                    dataAudienceEX.Team = 'Audience';
                    dataAudienceEX.Type = 'External';
                    dataAudienceEX.SpendingAmount = (audienceEXSpending == null ? 0 : audienceEXSpending);
                    
                    if(mapSpending.containsKey(converDate)){
                        mapSpending.get(converDate).add(dataAudienceEX);
                    }else {
                        mapSpending.put(converDate, new List<SpendingWrapper>{dataAudienceEX});
                    }
                }
            }
        }


        System.debug('mapSpending=>' + mapSpending.size());

        for(Date dt : mapSpending.keySet()){

            String datestr = String.valueOf(dt.year())+String.valueOf(dt.month())+String.valueOf(dt.day());
            List<SpendingWrapper> listData = mapSpending.get(dt);
            System.debug('listData=>' + listData.size());

            Decimal globalMobileSpending = 0;
            Decimal globalDesktopSpending = 0;
            Decimal directLocalMobileSpending = 0;
            Decimal directLocalDesktopSpending = 0;
            Decimal otherSpending = 0;
            Decimal internalAudienceSpending = 0;
            Decimal externalAudienceSpending = 0;
            
            if(listData != null &&  listData.size() > 0){
                for(SpendingWrapper data: listData){
                    if(data.Team == 'Global' && data.Type == 'Mobile'){
                        globalMobileSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }else if(data.Team == 'Global' && data.Type == 'Desktop'){
                        globalDesktopSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }else if(data.Team == 'Direct-Local' && data.Type == 'Mobile'){
                        directLocalMobileSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }else if(data.Team == 'Direct-Local' && data.Type == 'Desktop'){
                        directLocalDesktopSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }else if(data.Team == 'Audience' && data.Type == 'Internal'){
                        internalAudienceSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }else if(data.Team == 'Audience' && data.Type == 'External'){
                        externalAudienceSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }else if(data.Team == 'Other' && data.Type == 'Other'){
                        otherSpending += (data.SpendingAmount == null ? 0 : data.SpendingAmount);
                    }
                }
            }

            //Global Mobile Spending
            Spending_Master_Report__c globalMobileReport = new Spending_Master_Report__c();
            globalMobileReport.Date__c = dt;
            globalMobileReport.Name = 'Global-Mobile';
            globalMobileReport.Team__c = 'Global';
            globalMobileReport.Type__c = 'Mobile';
            globalMobileReport.UpsertID__c = datestr+'-Global-Mobile';
            globalMobileReport.OwnerId = setting.Sales_Director__c;
            globalMobileReport.Spending_Amount__c = (globalMobileSpending == null? 0: globalMobileSpending); 
            listInsert.add(globalMobileReport);

            //Global Desktop Spending
            Spending_Master_Report__c globalDesktopReport = new Spending_Master_Report__c();
            globalDesktopReport.Date__c = dt;
            globalDesktopReport.Name = 'Global-Desktop';
            globalDesktopReport.Team__c = 'Global';
            globalDesktopReport.Type__c = 'Desktop';
            globalDesktopReport.UpsertID__c = datestr+'-Global-Desktop';
            globalDesktopReport.OwnerId = setting.Sales_Director__c;
            globalDesktopReport.Spending_Amount__c = (globalDesktopSpending == null? 0: globalDesktopSpending); 
            listInsert.add(globalDesktopReport);

            //Direct-Local Mobile Spending
            Spending_Master_Report__c directLocalMobileReport = new Spending_Master_Report__c();
            directLocalMobileReport.Date__c = dt;
            directLocalMobileReport.Name = 'Direct-Local-Mobile';
            directLocalMobileReport.Team__c = 'Direct-Local';
            directLocalMobileReport.Type__c = 'Mobile';
            directLocalMobileReport.UpsertID__c = datestr+'-Direct-Local-Mobile';
            directLocalMobileReport.Sub_level__c = '';
            directLocalMobileReport.Spending_Amount__c = (directLocalMobileSpending == null? 0: directLocalMobileSpending); 
            listInsert.add(directLocalMobileReport);

            //Direct-Local Desktop Spending            
            Spending_Master_Report__c directLocalDesktopReport = new Spending_Master_Report__c();
            directLocalDesktopReport.Date__c = dt;
            directLocalDesktopReport.Name = 'Direct-Local-Desktop';
            directLocalDesktopReport.Team__c = 'Direct-Local';
            directLocalDesktopReport.Type__c = 'Desktop';
            directLocalDesktopReport.UpsertID__c = datestr+'-Direct-Local-Desktop';
            directLocalDesktopReport.OwnerId = setting.Sales_Director__c;
            directLocalDesktopReport.Spending_Amount__c = (directLocalDesktopSpending == null? 0: directLocalDesktopSpending); 
            listInsert.add(directLocalDesktopReport);

            //Audience Internal Spending
            Spending_Master_Report__c internalAudienceReport = new Spending_Master_Report__c();
            internalAudienceReport.Date__c = dt;
            internalAudienceReport.Name = 'Audience-Internal';
            internalAudienceReport.Team__c = 'Audience';
            internalAudienceReport.Type__c = 'Internal';
            internalAudienceReport.UpsertID__c = datestr+'-Audience-Internal';
            internalAudienceReport.OwnerId = setting.Sales_Director__c;
            internalAudienceReport.Spending_Amount__c = (internalAudienceSpending == null? 0: internalAudienceSpending); 
            listInsert.add(internalAudienceReport);

            //Audience External Spending
            Spending_Master_Report__c externalAudienceReport = new Spending_Master_Report__c();
            externalAudienceReport.Date__c = dt;
            externalAudienceReport.Name = 'Audience-External';
            externalAudienceReport.Team__c = 'Audience';
            externalAudienceReport.Type__c = 'External';
            externalAudienceReport.UpsertID__c = datestr+'-Audience-External';
            externalAudienceReport.OwnerId = setting.Sales_Director__c;
            externalAudienceReport.Spending_Amount__c = (externalAudienceSpending == null? 0: externalAudienceSpending); 
            listInsert.add(externalAudienceReport);
            
            //Other Spending
            Spending_Master_Report__c otherReport = new Spending_Master_Report__c();
            otherReport.Date__c = dt;
            otherReport.Name = 'Other';
            otherReport.Team__c = 'Other';
            otherReport.Type__c = 'Other';
            otherReport.UpsertID__c = datestr+'-Other-Other';
            otherReport.OwnerId = setting.Sales_Director__c;
            otherReport.Spending_Amount__c = (otherSpending == null? 0: otherSpending); 
            listInsert.add(otherReport);
        }

        System.debug('listInsert=>' + listInsert.size());
        if(listInsert.size() > 0){
            Schema.SObjectField f = Spending_Master_Report__c.Fields.UpsertID__c;
            Database.upsert(listInsert, f, false);
        }
    }

    public void finish(Database.BatchableContext bc){
        
    }
}