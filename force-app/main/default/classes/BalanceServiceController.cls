public with sharing class BalanceServiceController {
    private final static Integer MAX_RESULTS = 10;

    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> searchQCAccount(String searchTerm, List<String> selectedIds) {        
        searchTerm += '*';
        
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                QC_Account__c(Id, Name, QC_Account_Id__c WHERE id NOT IN :selectedIds)
            LIMIT :MAX_RESULTS
        ];
        
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        
        String accountIcon = 'custom:custom26';
        QC_Account__c[] accounts = (List<QC_Account__c>) searchResults[0];
        for (QC_Account__c account : accounts) {
            String subtitle = account.QC_Account_Id__c == null ? 'QC Account' : 'QC Account • ' + account.QC_Account_Id__c ;
            results.add(new LookupSearchResult(account.Id, 'QC Account',accountIcon, account.Name, subtitle, account.QC_Account_Id__c));
        }      
        
        results.sort();

        return results;
    }

    @AuraEnabled
    public static List<BalanceWrapper> getBalanceByQcAccount(List<String> qcIds, Datetime balanceTodate){
        try {
            List<BalanceWrapper> result = new List<BalanceWrapper>();
            List<String> userIds = new List<String>();
            for(QC_Account__c qc: [SELECT QC_Account_Id__c FROM QC_Account__c WHERE Id IN :qcIds]){
                userIds.add(qc.QC_Account_Id__c);
            }

            if(userIds.size() > 0){
                result = getBalance(userIds,balanceTodate);
            }

            return result;
        } catch (Exception ex) {
            throw new AuraHandledException('exceptionText: ' + ex.getMessage());
        }
    }


    @AuraEnabled
    public static List<BalanceWrapper> getBalancebyPayment(String paymentId, Datetime balanceTodate){
        try {
            List<BalanceWrapper> result = new List<BalanceWrapper>();
            List<String> userIds = new List<String>();
            Set<String> transIds = new Set<String>();
            for(Payment__c py: [SELECT Name, QC_Account__r.QC_Account_Id__c FROM Payment__c WHERE Id = :paymentId]){
                userIds.add(py.QC_Account__r.QC_Account_Id__c);
                transIds.add(py.Name);
            }

            if(userIds.size() > 0){
                List<BalanceWrapper> blresult = getBalance(userIds,balanceTodate);

                if(blresult != null){
                    BalanceWrapper filterRs = new BalanceWrapper();
                    BalanceWrapper rs = blresult[0];
                    filterRs.summary = rs.summary;
                    filterRs.userId = rs.userId;
                    filterRs.qcId = rs.qcId;
                    filterRs.userEmail = rs.userEmail;
                    filterRs.todt = rs.todt;

                    if(rs.detail != null && rs.detail.size()>0){
                        List<DetailWrapper> dtls = new List<DetailWrapper>();
                        for(DetailWrapper dt : rs.detail){
                            if(transIds.contains(dt.transId)){
                                dtls.add(dt);
                            }
                        }

                        if(dtls.size() > 0){
                            filterRs.detail = dtls;
                        }
                    }


                    result.add(filterRs);
                }
            }

            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());           
        }
    }

    @AuraEnabled
    public static List<BalanceWrapper> getBalancebyWithdrawal(String paymentId, Datetime balanceTodate, Boolean checkAll){
        try {
            List<BalanceWrapper> result = new List<BalanceWrapper>();
            List<String> userIds = new List<String>();
            Set<String> transIds = new Set<String>();
            for(Payment__c py: [SELECT Name, QC_Account__r.QC_Account_Id__c, Withdrawal_TransId__c FROM Payment__c WHERE Id = :paymentId]){
                userIds.add(py.QC_Account__r.QC_Account_Id__c);
                transIds.add(py.Withdrawal_TransId__c);
            }

            if(userIds.size() > 0){
                List<BalanceWrapper> blresult = getBalance(userIds,balanceTodate);

                if(blresult != null){
                    BalanceWrapper filterRs = new BalanceWrapper();
                    BalanceWrapper rs = blresult[0];
                    filterRs.summary = rs.summary;
                    filterRs.userId = rs.userId;
                    filterRs.qcId = rs.qcId;
                    filterRs.userEmail = rs.userEmail;
                    filterRs.todt = rs.todt;

                    if(rs.detail != null && rs.detail.size()>0){
                        List<DetailWrapper> dtls = new List<DetailWrapper>();
                        for(DetailWrapper dt : rs.detail){
                            if(!checkAll){
                                if(transIds.contains(dt.transId)){
                                    dtls.add(dt);
                                }
                            }else {
                                dtls.add(dt);
                            }
                        }

                        if(dtls.size() > 0){
                            filterRs.detail = dtls;
                        }
                    }


                    result.add(filterRs);
                }
            }

            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());           
        }
    }

    @AuraEnabled
    public static List<BalanceWrapper> getBalancebyTransaction(String qcId, String transid, Datetime balanceTodate){
        try {
            List<BalanceWrapper> result = new List<BalanceWrapper>();
            List<String> userIds = new List<String>();
            Set<String> transIds = new Set<String>();
            
            userIds.add(qcId);
            if(userIds.size() > 0){
                List<BalanceWrapper> blresult = getBalance(userIds,balanceTodate);

                if(blresult != null){
                    BalanceWrapper filterRs = new BalanceWrapper();
                    BalanceWrapper rs = blresult[0];
                    filterRs.summary = rs.summary;
                    filterRs.userId = rs.userId;
                    filterRs.qcId = rs.qcId;
                    filterRs.userEmail = rs.userEmail;
                    filterRs.todt = rs.todt;

                    if(rs.detail != null && rs.detail.size()>0){
                        List<DetailWrapper> dtls = new List<DetailWrapper>();
                        for(DetailWrapper dt : rs.detail){
                            if(dt.transId == transid){
                                dtls.add(dt);
                            }
                        }

                        if(dtls.size() > 0){
                            filterRs.detail = dtls;
                        }
                    }


                    result.add(filterRs);
                }
            }

            return result;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());           
        }
    }

    @AuraEnabled
    public static List<BalanceWrapper> getBalance(List<String> userIds, Datetime balanceTodate){
        try {
            Set<String> setUserId = new Set<String>();
            List<BalanceWrapper> blresults = new List<BalanceWrapper>();
            Map<String, Payment__c> mapPys = new Map<String, Payment__c>();
            Map<String, QC_Account__c> mapQCs = new Map<String, QC_Account__c>();   

            Datetime todt;
            if(balanceTodate != null){
                todt = balanceTodate;
            }else {                
                todt = Datetime.now();
            }

            setUserId.addAll(userIds);
            List<BalanceServiceWrapper.BalanceWrapper> blresult = getBalanceService(setUserId, todt);
            if(blresult != null){                
                System.debug('blresult=>' + blresult);
                
                for(Payment__c py : [SELECT Id, Name  FROM Payment__c WHERE QC_Account__r.QC_Account_Id__c IN :setUserId]){
                    mapPys.put(py.Name, py);
                }

                for(QC_Account__c qc : [SELECT Id, Name, QC_Account_Id__c  FROM QC_Account__c WHERE QC_Account_Id__c IN :setUserId]){
                    mapQCs.put(qc.QC_Account_Id__c, qc);
                }                

                for(BalanceServiceWrapper.BalanceWrapper blance: blresult){
                    BalanceWrapper result = new BalanceWrapper();
                    System.debug('blance=>' + blance);
                    System.debug('summary=>' + blance.summary);
                    if(blance != null){
                        
                        if(mapQCs.containsKey(blance.user_id)){
                            result.userEmail = mapQCs.get(blance.user_id).Name;
                            result.qcId = mapQCs.get(blance.user_id).Id;
                            result.userId = blance.user_id; 
                            result.todt = todt;                        

                            System.debug('blance.detail=>' + blance.detail);
                            if(blance.detail.size() > 0){
                                List<DetailWrapper> dts = new list<DetailWrapper>();
                                for(BalanceServiceWrapper.DetailWrapper detail : blance.detail){
                                    if(detail.type != 'REFUND'){
                                        Payment__c py = mapPys.get(detail.id);
                                        System.debug('py=>' + py);
                                        System.debug('py=>' + mapPys.keySet());

                                        DetailWrapper dt = new DetailWrapper();
                                        dt.transId =  detail.id;
                                        dt.balance = detail.balance;
                                        dt.timestamp = detail.timestamp;
                                        dt.type = detail.type;
                                        dt.internal_type = detail.internal_type;
                                        dt.userId = blance.user_id;
                                        dt.qcId = mapQCs.get(blance.user_id).Id;

                                        if(py != null){
                                            dt.paymentId = py.Id == null?'': py.Id;
                                        }else {
                                            dt.paymentId = '';
                                        }                              

                                        dts.add(dt);         
                                    }                           
                                }

                                if(dts.size() > 0){
                                    result.detail = dts;
                                }
                            }

                            result.summary = blance.summary;
                            result.summary.qcId = result.qcId;
                            result.summary.userId = result.userId;
                            result.summary.userEmail = result.userEmail;
                        }

                        if(result != null && result.summary != null){
                            blresults.add(result);
                        }                        
                    }

                }
                   
            }

            return blresults;

        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            System.debug( 'error' + e.getMessage());
            return null;
        }
    }


    public static List<BalanceServiceWrapper.BalanceWrapper> getBalanceService(Set<String> userIds, Datetime balanceTodate){
        List<BalanceServiceWrapper.BalanceWrapper> blresult = new List<BalanceServiceWrapper.BalanceWrapper>();
        HttpResponse response = new HttpResponse();      
        CouponIntegration__c updatecouponapi = CouponIntegration__c.getInstance('balancebervice_v2');
        String apiendpoint = updatecouponapi.apiuri__c;
        String method = updatecouponapi.method__c;
        Integer timeout = (Integer)updatecouponapi.timeout__c;  
        Long dtepoct;
        Datetime todt;
        if(balanceTodate != null){
            dtepoct = balanceTodate.getTime();
            todt = balanceTodate;
        }else {
            dtepoct = Datetime.now().getTime();   
            todt = Datetime.now();
        }
        
        System.debug('userIds=>' + userIds);
        List<String> listUserId = new List<String>();
        listUserId.addAll(userIds);
        String userIdParam = String.join(listUserId,',');   

        if(!String.isBlank(userIdParam)){
            String jsonbody ='';
            String endpoint = apiendpoint + '?user-ids=' + userIdParam + '&epoch-in-milliseconds=' + dtepoct;
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
                }
            }
        }
        
        if(response != null){
            blresult = BalanceServiceWrapper.parse(response.getBody());
        }
        
        return blresult;
    }


    @AuraEnabled(Cacheable=true)
    public static List<LookupSearchResult> getRecentlyViewed() {
        Set<String> qcIds = new Set<String>();
        List<LookupSearchResult> results = new List<LookupSearchResult>();
        // Get recently viewed records of type Account or Opportunity
        List<RecentlyViewed> recentRecords = [
            SELECT Id, Name,Type
            FROM RecentlyViewed
            WHERE Type = 'QC_Account__c'
            ORDER BY LastViewedDate DESC
            LIMIT :MAX_RESULTS
        ];

        for (RecentlyViewed recentRecord : recentRecords){
            qcIds.add(recentRecord.Id);
        }

        Map<Id, QC_Account__c> mapQC = new Map<Id, QC_Account__c>([SELECT Id, Name, QC_Account_Id__c FROM QC_Account__c WHERE Id IN :qcIds]);


        // Convert recent records into LookupSearchResult
        for (RecentlyViewed recentRecord : recentRecords) {
            if (recentRecord.Type == 'QC_Account__c') {
                results.add(
                    new LookupSearchResult(
                        recentRecord.Id,
                        'QC_Account__c',
                        'custom:custom26',
                        recentRecord.Name,
                        'QC Account • ' + recentRecord.Name,
                        mapQC.get(recentRecord.Id).QC_Account_Id__c
                    )
                );
            }
        }
        return results;
    }

    @AuraEnabled(Cacheable=true)
    public static List<TransTypeWrapper> getTranstype(){
        try {
            List<TransTypeWrapper> options = new List<TransTypeWrapper>();
            Set<String> setOptions = new Set<String>();
            for(Transactions_Type__c tran: [SELECT Allow_Coupon__c, Internal_Type__c FROM Transactions_Type__c WHERE Allow_Withdraw__c = True ]){

                if(!tran.Allow_Coupon__c){
                    TransTypeWrapper op = new TransTypeWrapper();
                    op.label = PaymentConstant.TYPE_INCOME;
                    op.value = PaymentConstant.TYPE_INCOME;
                    if(!setOptions.contains(op.value)){
                        options.add(op);
                        setOptions.add(op.value);
                    }
                    
                }else {
                    TransTypeWrapper op = new TransTypeWrapper();
                    op.label = PaymentConstant.TYPE_COUPON;
                    op.value = PaymentConstant.TYPE_COUPON;
                    if(!setOptions.contains(op.value)){
                        options.add(op);
                        setOptions.add(op.value);
                    }
                }                
            }           

            System.debug('options=>' + options);
            return options;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class TransTypeWrapper{
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String value {get;set;}
    }


    public class BalanceWrapper{       
        @AuraEnabled
        public List<DetailWrapper> detail {get;set;}
        @AuraEnabled
        public BalanceServiceWrapper.SummaryWrapper summary {get;set;}
        @AuraEnabled
        public String userId {get;set;}
        @AuraEnabled
        public String userEmail {get;set;}
        @AuraEnabled
        public String qcId {get;set;}
        @AuraEnabled
        public Datetime todt {get;set;}
    }

    public  class DetailWrapper {
        @AuraEnabled
        public String paymentId {get;set;}
        @AuraEnabled
        public String transId {get;set;}
        @AuraEnabled
		public Decimal balance {get;set;}	
        @AuraEnabled
		public String timestamp {get;set;}
        @AuraEnabled
		public String type {get;set;}
        @AuraEnabled
		public String internal_type{get;set;}
        @AuraEnabled
		public String userId{get;set;}
        @AuraEnabled
		public String qcId{get;set;}        
	}    
}