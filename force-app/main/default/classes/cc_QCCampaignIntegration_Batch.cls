global class cc_QCCampaignIntegration_Batch implements Database.Batchable<SObject>,Database.AllowsCallouts{
    public Datetime rundate {get;set;}    
    public String soqlQuery {get;set;}
    public Set<String> campIds {get;set;}

    public cc_QCCampaignIntegration_Batch(Datetime prundate, Set<String> pCampIds) {
        this.rundate = prundate;
        this.campIds = pCampIds;          

        if(prundate == null){
            String query = 'SELECT Id, CampaignId__c, Clicks__c,Impressions__c,Spending__c, Ads_Campaign__c,Ads_Campaign__r.Start_Date__c, Ads_Campaign__r.End_Date__c';
            query = query + ' FROM QC_Campaign__c';
            query = query + ' WHERE CampaignId__c != \'\'';
            query = query + ' AND Ads_Campaign__r.Start_Date__c != null';
            query = query + ' AND Ads_Campaign__r.End_Date__c != null';

            this.soqlQuery = query;
                        
        }else{
            String strrundate = rundate.format('yyyy-MM-dd');
            
            String query = 'SELECT Id, CampaignId__c, Clicks__c,Impressions__c,Spending__c, Ads_Campaign__c,Ads_Campaign__r.Start_Date__c, Ads_Campaign__r.End_Date__c';
            query = query + ' FROM QC_Campaign__c';
            query = query + ' WHERE CampaignId__c != \'\'';
            query = query + ' AND Ads_Campaign__r.Start_Date__c != null';
            query = query + ' AND Ads_Campaign__r.End_Date__c != null';
            query = query + ' AND Ads_Campaign__r.Start_Date__c <= ' + strrundate;
            query = query + ' AND Ads_Campaign__r.End_Date__c >= ' + strrundate;

            this.soqlQuery = query;

        }

        system.debug('this.soqlQuery =>' + this.soqlQuery);
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(this.soqlQuery);
    }

    global void execute(Database.BatchableContext bc,List<QC_Campaign__c> scope){
        // System.debug('this.soqlQuery =>' + this.soqlQuery);
        // System.debug('this.scope =>' + scope.size());
        List<QC_Campaign__c> qccampToUpdate = new List<QC_Campaign__c>();
        Map<String, List<QC_Campaign__c>> mapAdsCamp = new Map<String, List<QC_Campaign__c>>();
        Map<String,String> mapDates = new Map<String,String>();        
        List<QC_Campaign__c> procesCamps = new List<QC_Campaign__c>();
        Date executeDate;
        
        if(this.rundate == null){
            executeDate = System.today() - 1;
        }else {
            Date rundt = Date.newInstance(this.rundate.year(), this.rundate.month(), this.rundate.day());

            if(rundt == System.today()){
                executeDate = rundt -1;
            }else{
                executeDate = rundt;
            }            
        }

        CouponIntegration__c campaignapi = CouponIntegration__c.getInstance('getadscampaignapi');
        String endpoint = campaignapi.apiuri__c;
        String method = campaignapi.method__c;
        Integer timeout = (Integer)campaignapi.timeout__c;

        if(this.campIds != null){
            for(QC_Campaign__c qccamp: scope){
                if(this.campIds.contains(qccamp.CampaignId__c)){
                    procesCamps.add(qccamp);                    
                }
            }
        }else {
            procesCamps.addAll(scope);
        }
        
        // System.debug('campIds =>' + this.campIds.size());
        System.debug('procesCamps =>' + procesCamps.size());
        if(procesCamps != null){
            for(QC_Campaign__c qccamp: procesCamps){            

                if( !String.isBlank(qccamp.CampaignId__c) 
                    && qccamp.Ads_Campaign__r.Start_Date__c != null
                    && qccamp.Ads_Campaign__r.End_Date__c != null ){               
                    
                    if(!mapDates.containsKey(qccamp.Ads_Campaign__c)){
                        String dateParams = '';
                        
                        Date startdt = qccamp.Ads_Campaign__r.Start_Date__c;
                        Date enndt;
                        if(qccamp.Ads_Campaign__r.End_Date__c <= executeDate){
                            enndt = qccamp.Ads_Campaign__r.End_Date__c;
                        }else {
                            enndt = executeDate;
                        }                    

                        String sday = startdt.day() < 10?'0' + String.valueOf(startdt.day()) : String.valueOf(startdt.day());
                        String smonth = startdt.month() < 10?'0' + String.valueOf(startdt.month()) : String.valueOf(startdt.month());

                        String eday = enndt.day() < 10?'0' + String.valueOf(enndt.day()) : String.valueOf(enndt.day());
                        String emonth = enndt.month() < 10?'0' + String.valueOf(enndt.month()) : String.valueOf(enndt.month());

                        String sfromdt =  String.valueOf(startdt.year()) + '-' + smonth + '-' + sday ;
                        String senddt =  String.valueOf(enndt.year()) + '-' + emonth + '-' + eday ;

                        dateParams = '?start=' + sfromdt + '&end=' + senddt;

                        mapDates.put(qccamp.Ads_Campaign__c, dateParams);

                    }
                
                    if(mapAdsCamp.containsKey(qccamp.Ads_Campaign__c)){   
                        mapAdsCamp.get(qccamp.Ads_Campaign__c).add(qccamp);
                    }else{
                        mapAdsCamp.put(qccamp.Ads_Campaign__c, new List<QC_Campaign__c>{qccamp});
                    }  
                }                                                  
            }
        }            

        System.debug('mapAdsCamp =>' + mapAdsCamp.size());
        if(mapAdsCamp.size() > 0 && !String.isBlank(endpoint)){
            for(String adsId: mapAdsCamp.keySet()){
                List<QC_Campaign__c> currCamps = mapAdsCamp.get(adsId);
                if(currCamps != null){
                    String dateParams = mapDates.get(adsId);
                    String idsParams = '&ids=';
                    
                    String strIds = '';
                    for(QC_Campaign__c qcamp: currCamps){
                        String campaignId = qcamp.CampaignId__c;
                        if(String.isBlank(strIds)){
                            strIds = strIds + '' + campaignId.trim();
                        }else {
                            strIds = strIds + ',' + campaignId.trim();
                        }                    
                    }
    
                    idsParams= idsParams + strIds;    
                    
                    if(!String.isBlank(dateParams) && !String.isBlank(idsParams)){
                        String apiendpoint = endpoint + dateParams + idsParams;   
    
                        cc_Callout callout = new cc_Callout('{}', apiendpoint, method, timeout, null);                  
                        HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);


                        if(req != null){
                            HttpResponse res = cc_HttpCallout.makeRequest(req);
                            if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                                String jsbody = res.getBody();
                                if(!String.isBlank(jsbody)){
                                    List<cc_QCCampaignWraper> parsecamps = this.JSONPerserCamp(jsbody);
            
                                    if(parsecamps.size() > 0){
                                        for(cc_QCCampaignWraper camp: parsecamps){
                                            for(QC_Campaign__c crCamp: currCamps){
                                                if(camp.campaignId == crCamp.CampaignId__c){
                                                    crCamp.Clicks__c = camp.clicks;
                                                    crCamp.Impressions__c = camp.impressions;
                                                    crCamp.Spending__c = camp.spendings;
            
                                                    qccampToUpdate.add(crCamp);
                                                }
                                            }
                                        }
                                    }
                                }   
                            }
                        }
                    }
                }    
            }
        }
        

        System.debug('qccampToUpdate =>' + qccampToUpdate.size());
        if(qccampToUpdate.size() > 0){

            List<Database.SaveResult> results = Database.update(qccampToUpdate, false);            
        }
        
        
    }

    global void finish(Database.BatchableContext bc){
        
    }


    public List<cc_QCCampaignWraper> JSONPerserCamp(String jsbody){
        JSONParser parser = JSON.createParser(jsBody);
        List<cc_QCCampaignWraper> listCamps = new List<cc_QCCampaignWraper>();

        while(parser.nextToken() != JSONToken.END_OBJECT) { // we started with an array of objects
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME){
                String parentttr = parser.getText(); //get the text of the field name
                    parser.nextToken(); // move the pointer
                    //start mapping the fields
                if(parentttr == 'items') {
                    System.debug('items');
                    while(parser.nextToken() != JSONToken.END_ARRAY){
                        System.debug('END_ARRAY');
                        cc_QCCampaignWraper camp = new cc_QCCampaignWraper();
                        while(parser.nextToken() != JSONToken.END_OBJECT){ // loop through each object
                            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) { //token should be field name
                                String attr = parser.getText(); //get the text of the field name
                                parser.nextToken(); // move the pointer
                                //start mapping the fields
                                if(attr == 'details') {
                                    System.debug('details');  

                                    while(parser.nextToken() != JSONToken.END_OBJECT) {
                                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                            String dtAttr = parser.getText();
                                            parser.nextToken();

                                            System.debug('dtAttr =>' + dtAttr);
                                            if(dtAttr == 'campaignId'){
                                                camp.campaignId = parser.getText();
                                            }
                                        }
                                    }

                                    
                                } else if(attr == 'stats') {
                                    System.debug('stats');                                    
                                    
                                    while(parser.nextToken() != JSONToken.END_OBJECT) {
                                        if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                                            String statsAttr = parser.getText();
                                            //move the pointer
                                            parser.nextToken();
                                            System.debug('statsAttr =>' + statsAttr);
                                            if(statsAttr == 'clicks') {
                                                camp.clicks = (Double)parser.getDoubleValue();
                                            } else if(statsAttr == 'shows') {
                                                camp.impressions = (Double)parser.getDoubleValue();                                        
                                            }else if(statsAttr == 'spending') {
                                                camp.spendings = (Double)parser.getDoubleValue();
                                            }
                                        }
                                    }                                  

                                }else{
                                    parser.skipChildren();
                                } 
                            }
                        }
                        
                        listCamps.add(camp);
                    }
                }else{
                    parser.skipChildren();
                }
            }
        }	

        System.debug('listCamps =>' + listCamps);
        return listCamps;
    }

    
}