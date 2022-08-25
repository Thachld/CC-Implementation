/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 08-05-2022
 * @last modified by  : @Thach Le
**/
public class SyncMobileSpending_Batch implements Database.Batchable<SObject>, Database.AllowsCallouts{
    public String syncType {get;set;}    
    public String soqlStr {get;set;}
    public Date starDate {get;set;}
    public Date endDate {get;set;}
    public Set<String> runQcIds{get;set;}


    public SyncMobileSpending_Batch(String pSyncType , Set<String> prunQcIds, Date pStarDate, Date pEndDate ) {
        this.syncType = String.isBlank(pSyncType)?'Daterange': pSyncType;
        this.starDate = pStarDate==null? Date.today() : pStarDate;
        this.endDate = pEndDate==null? Date.today() : pEndDate;
        this.runQcIds = prunQcIds;
                
        if(this.runQcIds != null){
            this.soqlStr = 'SELECT Id, Name, QC_Account_Id__c, Sales__c, Support__c, Agency__c, Industry__c, AccountOwner__c '; 
            this.soqlStr = this.soqlStr + ' FROM QC_Account__c WHERE Source__c =\'' + QCAccountConstant.SOURCE_MOBILESKIN + '\'';
            this.soqlStr = this.soqlStr + ' AND Status__c =\'' + QCAccountConstant.STATUS_ACTIVE + '\'';
            this.soqlStr = this.soqlStr + ' AND Id IN :runQcIds';
        }else {
            this.soqlStr = 'SELECT Id, Name, QC_Account_Id__c, Sales__c, Support__c, Agency__c, Industry__c, AccountOwner__c '; 
            this.soqlStr = this.soqlStr + ' FROM QC_Account__c WHERE Source__c =\'' + QCAccountConstant.SOURCE_MOBILESKIN + '\'';
            this.soqlStr = this.soqlStr + ' AND Status__c =\'' + QCAccountConstant.STATUS_ACTIVE + '\'';
        }
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(this.soqlStr);
    }

    public void execute(Database.BatchableContext bc,List<QC_Account__c> scope){
        Set<String> qcIds = new Set<String>();
        Set<String> qcAccIds = new Set<String>();
        Map<String,QC_Account__c> mapQC = new Map<String,QC_Account__c>();
        List<QC_Account_data__c> insertQcAccount = new List<QC_Account_data__c>();       
        List<QC_Account_data__c> updateQcAccount = new List<QC_Account_data__c>();       

        for(QC_Account__c qcacc: scope){
            if(!String.isBlank(qcacc.QC_Account_Id__c)){
                qcIds.add(qcacc.QC_Account_Id__c);
                qcAccIds.add(qcacc.Id);
                mapQC.put(qcacc.QC_Account_Id__c, qcacc);
            }
        }

        if(qcIds.size() > 0){
            Map<String,MobileSkinWrapper.Item> mapResult = getCPDData(qcIds, this.syncType, this.starDate, this.endDate);
            if(mapResult.size() >0){                        
                Map<String, QC_Account_Data__c> mapData = getQCAccountData(qcAccIds);
                
                upsertData(mapResult, mapData, mapQC);
            }
        }
    }


    public void finish(Database.BatchableContext bc){}

    public static Map<String, QC_Account_Data__c> getQCAccountData(Set<String> qcAccIds){  
        Map<String, QC_Account_Data__c> mapData = new Map<String, QC_Account_Data__c>();

        for(QC_Account_Data__c data : [SELECT Id, QC_Account__c, QC_Account__r.QC_Account_Id__c, Spending_date__c, 
                                            MobileSkin_clicks__c, MobileSkin_Shows__c,MobileSkin_Spending__c 
                                        FROM QC_Account_Data__c 
                                        WHERE QC_Account__c IN :qcAccIds]){
            
            if(!String.isBlank(data.QC_Account__r.QC_Account_Id__c) && data.Spending_date__c != null){
                String day = data.Spending_date__c.day() < 10?'0' + String.valueOf(data.Spending_date__c.day()) : String.valueOf(data.Spending_date__c.day());
                String month = data.Spending_date__c.month() < 10?'0' + String.valueOf(data.Spending_date__c.month()) : String.valueOf(data.Spending_date__c.month());
                String year = String.valueOf(data.Spending_date__c.year());
                String spdate = year + '-' + month +'-' + day ;

                String key = data.QC_Account__r.QC_Account_Id__c + '###' + spdate;

                mapData.put(key, data);                
            }            
        }

        return mapData;
    }


    public static Map<String,MobileSkinWrapper.Item> getCPDData(Set<String> qcIds, String syncType, Date starDate, Date endDate){
        List<CalloutLog__c> calloutLogs = new List<CalloutLog__c>();        
        Map<String,String> headers = new Map<String,String>();      
        HttpResponse response = new HttpResponse();        
        Map<String,MobileSkinWrapper.Item> mapResult = new Map<String,MobileSkinWrapper.Item>();         

        CouponIntegration__c updatecouponapi = CouponIntegration__c.getInstance('mobileskindata');
        String apiendpoint = updatecouponapi.apiuri__c;
        String method = updatecouponapi.method__c;
        Integer timeout = (Integer)updatecouponapi.timeout__c;  

        if(qcIds.size() > 0){
            String jsonbody ='';
            String uri = generateUri(qcIds, syncType, starDate, endDate);
            String endpoint = apiendpoint + uri ;
            System.debug('endpoint=>' + endpoint);
            cc_Callout callout = new cc_Callout(jsonbody, endpoint, method, null);                    
            HttpRequest req = cc_HttpCallout.setupHttpRequestToQCByOrgDefault(callout);
            if(req != null){                    
                HttpResponse res = cc_HttpCallout.makeRequest(req);
                System.debug('res.getStatusCode()=>' + res.getStatusCode());
                System.debug('res.getBody()=>' + res.getBody());
                System.debug('req.getEndpoint()=>' + req.getEndpoint());
                if(res.getStatusCode() == 200 || res.getStatusCode() == 201){
                    response = res;   
                }else {
                    LogFileWrapper.FileWrapper log = new LogFileWrapper.FileWrapper();                   
                    log.message = 'Failed to Mobible skin data';
                }
            }   
        }

        if(response != null){            
            cc_PaymentWrapper.Responds log = new cc_PaymentWrapper.Responds();
            
            String reponeJs = response.getBody();
            mapResult = MobileSkinWrapper.parseToMap(reponeJs);                  
        }  

        return mapResult;
    }

    public static void upsertData(Map<String,MobileSkinWrapper.Item> mapResult, Map<String, QC_Account_Data__c> mapData, Map<String,QC_Account__c> mapQC){
        List<QC_Account_Data__c> dataToInsert = new List<QC_Account_Data__c>();
        List<QC_Account_Data__c> dataToUpdate = new List<QC_Account_Data__c>();

        for(String keyItem :mapResult.keySet()){
            MobileSkinWrapper.Item item = mapResult.get(keyItem);
            QC_Account_Data__c existsData = mapData.get(keyItem);

            System.debug('keyItem=>' + keyItem);
            System.debug('existsData=>' + existsData);
            if(existsData != null){ 
                existsData.MobileSkin_Spending__c = item.stats.spending;
                existsData.MobileSkin_Shows__c = item.stats.shows;
                existsData.MobileSkin_clicks__c = item.stats.clicks;

                dataToUpdate.add(existsData);

            }else{

                QC_Account__c qc = mapQC.get(item.details.client_id);
                if(qc != null){
                    QC_Account_Data__c insertData = new QC_Account_Data__c();
                    insertData.QC_Account__c =  qc.id;
                    insertData.MobileSkin_Spending__c = item.stats.spending;
                    insertData.MobileSkin_Shows__c = item.stats.shows;
                    insertData.MobileSkin_clicks__c = item.stats.clicks;
                    insertData.Accounts__c = qc.AccountOwner__c;
                    insertData.Agency__c = qc.Agency__c;
                    insertData.Industry__c = qc.Industry__c;
                    insertData.Support__c = qc.Support__c;
                    insertData.Sale__c = qc.Sales__c;                    
                    
                    Date syncdate = Date.valueOf(item.details.date_x);
                    Datetime syncdt = Datetime.newInstance(syncdate.year(), syncdate.month(), syncdate.day(), 0,0,0);     

                    insertData.syn_date__c = syncdt;

                    String daystr = syncdate.day() < 10?'0' + String.valueOf(syncdate.day()) : String.valueOf(syncdate.day());
                    String monthstr = syncdate.month() < 10?'0' + String.valueOf(syncdate.month()) : String.valueOf(syncdate.month());
                  
                    String strDate = daystr + '/' + monthstr + '/' + String.valueOf(syncdate.year());
                    insertData.Name = qc.Name + ' ' + strDate;

                    dataToInsert.add(insertData);
                }
            }
        }


        System.debug('dataToUpdate=>' + dataToUpdate.size());
        if(dataToUpdate.size() > 0){
            update dataToUpdate;
        }

        System.debug('dataToInsert=>' + dataToInsert.size());
        if(dataToInsert.size() > 0){
            insert dataToInsert;
        }
    }

    public static String generateUri(Set<String> qcIds, String syncType, Date starDate, Date endDate){
        String uri = '';
        if(syncType == 'Daterange'){
            
            String day = starDate.day() < 10?'0' + String.valueOf(starDate.day()) : String.valueOf(starDate.day());
            String month = starDate.month() < 10?'0' + String.valueOf(starDate.month()) : String.valueOf(starDate.month());
            String year = String.valueOf(starDate.year());
            String filterStartdate = year + '-' + month +'-' + day ;

            day = endDate.day() < 10?'0' + String.valueOf(endDate.day()) : String.valueOf(endDate.day());
            month = endDate.month() < 10?'0' + String.valueOf(endDate.month()) : String.valueOf(endDate.month());
            year = String.valueOf(endDate.year());
            String filterEnddate = year + '-' + month +'-' + day ;
            
            uri = uri + '&start=' + filterStartdate + '&end=' + filterEnddate;
            System.debug('uri-Daterange=>' + uri);
        }else {
            uri = uri + '&start=-1';
            System.debug('uri-Other=>' + uri);
        }     

        JSONGenerator gen = JSON.createGenerator(true);  

        gen.writeStartObject();     
            gen.writeStringField('field', 'details.client_id');
            gen.writeStringField('operator', 'IN');  
            gen.writeFieldName('value');  
            gen.writeStartArray();   
                for(String qcid: qcIds){
                    gen.writeNumber(Integer.valueOf(qcid));
                }                                
            gen.writeEndArray();

        gen.writeEndObject();

        String filter = gen.getAsString().replace('\n', '');

        uri = uri +  '&filters=[' + filter.replace(' ', '') + ']';

        return uri;
    }
}