global class cc_TF_TransferUser_Batch implements Database.Batchable<sObject> {
    public Set<String> rqIds  {get;set;} 
    public cc_TF_TransferUser_Batch(Set<String> prqIds) {
        this.rqIds = prqIds== null? new Set<String>() : prqIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Transfer_Date__c, 
                                                From_User__c,To_User__c, Transfer_Category__c,
                                                Transfer_Type__c, Type__c
                                            FROM Transfer_Request__c
                                            WHERE Approval_Status__c = 'Approved'
                                                    AND Status__c != 'Completed'
                                                    AND Transfer_Date__c <= :System.today()
                                        ]);
    }
    
    global void execute(Database.BatchableContext bc, List<Transfer_Request__c> scope){
        List<Transfer_Request__c> request = new List<Transfer_Request__c>();
        List<SObject> upadateRecord = new List<SObject>();
        List<SObject> upadateRecord1 = new List<SObject>();
        List<SObject> upadateRecord2 = new List<SObject>();
        
        List<QC_Account_Data__c> upadateData = new List<QC_Account_Data__c>();
        Map<Id,QC_Account__c> mapQCtpUpdate = new Map<Id,QC_Account__c>();

        

        if(this.rqIds.size() != 0){
            for (Transfer_Request__c rq : scope){
                if (this.rqIds.contains(rq.Id)) {
                    request.add(rq);
                }
            }
        }else {
            request.addAll(scope);
        }

        // request.addAll(scope);
        System.debug('this.rqIds=> ' + this.rqIds.size());
        System.debug('scope=> ' + scope.size());
        System.debug('request=> ' + request.size());
        for (Transfer_Request__c rq : request){    

            Datetime fromDT = Datetime.newInstance(rq.Transfer_Date__c.year(), rq.Transfer_Date__c.month(), rq.Transfer_Date__c.day(), 0,0,0);
            String[] category;
            if(rq.Transfer_Type__c == 'Sale User'){
                if(!String.isEmpty(rq.Transfer_Category__c)){
                    category = rq.Transfer_Category__c.split(';');
                }
            }else if(rq.Transfer_Type__c == 'Support User'){
                if(!String.isEmpty(rq.Transfer_Category__c)){
                    category = rq.Transfer_Category__c.split(';');
                }
            }

            System.debug('category=> ' + category);

            for(String cat: category){
                if(cat == 'Account'){
                   for( Account acc: [SELECT Id, OwnerId FROM Account WHERE OwnerId = : rq.From_User__c]){                       
                       acc.OwnerId = rq.To_User__c;
                       upadateRecord.add(acc);
                   }
                }else if(cat == 'Contract'){
                    for( Contract__c con: [SELECT Id, OwnerId FROM Contract__c WHERE OwnerId = : rq.From_User__c And Status__c = 'Done']){
                        con.OwnerId = rq.To_User__c;
                        upadateRecord2.add(con);
                    }
                }else if(cat == 'QC Account'){
                    for(QC_Account__c qc: [SELECT Id, OwnerId, Sales__c,Support__c FROM QC_Account__c WHERE OwnerId = : rq.From_User__c]){
                        if(mapQCtpUpdate.containsKey(qc.Id)){
                            QC_Account__c curr = (QC_Account__c)mapQCtpUpdate.get(qc.id);
                            curr.OwnerId = rq.To_User__c;
                            mapQCtpUpdate.put(qc.Id, curr);
                        }else{
                            mapQCtpUpdate.put(qc.Id, qc);
                        }  
                    }
                }else if(cat == 'Lead'){
                    for( Lead ld: [SELECT Id, OwnerId FROM Lead WHERE IsConverted = false AND OwnerId = : rq.From_User__c]){
                        ld.OwnerId = rq.To_User__c;
                        upadateRecord1.add(ld);
                    }
                }else if(cat == 'Media Plan'){
                    for( Media_Plan__c md: [SELECT Id, OwnerId FROM Media_Plan__c WHERE OwnerId = : rq.From_User__c]){
                        md.OwnerId = rq.To_User__c;
                        upadateRecord1.add(md);
                    }
                }else if(cat == 'Make Design/Content'){
                    for( Make_Design__c mk: [SELECT Id, OwnerId FROM Make_Design__c WHERE OwnerId = : rq.From_User__c]){
                        mk.OwnerId = rq.To_User__c;
                        upadateRecord2.add(mk);
                    }
                }else if(cat == 'Ads Campaign'){
                    for( Ads_Campaign__c ads: [SELECT Id, OwnerId FROM Ads_Campaign__c WHERE OwnerId = : rq.From_User__c]){
                        ads.OwnerId = rq.To_User__c;
                        upadateRecord2.add(ads);
                    }
                }else if(cat == 'Sale'){
                    for( QC_Account_Data__c data: [SELECT Id, Sale__c 
                                                FROM QC_Account_Data__c 
                                                WHERE Sale__c = : rq.From_User__c
                                                AND syn_date__c >= :fromDT]){
                        data.Sale__c = rq.To_User__c;
                        upadateData.add(data);
                    }
                    
                    for(QC_Account__c qc: [SELECT Id, Sales__c, OwnerId, Support__c FROM QC_Account__c WHERE Sales__c = : rq.From_User__c]){
                        if(mapQCtpUpdate.containsKey(qc.Id)){
                            QC_Account__c curr = (QC_Account__c)mapQCtpUpdate.get(qc.id);
                            curr.Sales__c = rq.To_User__c;
                            mapQCtpUpdate.put(qc.Id, curr);
                        }else{
                            mapQCtpUpdate.put(qc.Id, qc);
                        }    
                    }

                }else if(cat == 'Support'){
                    for( QC_Account_Data__c data: [SELECT Id, Support__c 
                                                FROM QC_Account_Data__c 
                                                WHERE Support__c = : rq.From_User__c
                                                AND syn_date__c >= :fromDT]){
                        data.Support__c = rq.To_User__c;
                        upadateData.add(data);
                    }


                    for(QC_Account__c qc: [SELECT Id, Sales__c, OwnerId, Support__c FROM QC_Account__c WHERE Support__c = : rq.From_User__c]){
                        if(mapQCtpUpdate.containsKey(qc.Id)){
                            QC_Account__c curr = (QC_Account__c)mapQCtpUpdate.get(qc.id);
                            curr.Support__c = rq.To_User__c;
                            mapQCtpUpdate.put(qc.Id, curr);
                        }else{
                            mapQCtpUpdate.put(qc.Id, qc);
                        } 
                    }
                }
            }

            rq.Status__c = 'Completed';

            upadateRecord2.add(rq);
        }


        if(upadateRecord.size() > 0){
            Database.SaveResult[] results = Database.update(upadateRecord,true);            
        }

        if(upadateRecord1.size() > 0){
            Database.SaveResult[] results = Database.update(upadateRecord1,true);            
        }

        if(upadateRecord2.size() > 0){
            Database.SaveResult[] results = Database.update(upadateRecord2,true);            
        }

        if(upadateData.size() > 0){
            Database.SaveResult[] results = Database.update(upadateData,false);
        }

        if(mapQCtpUpdate.size() > 0){
            Database.SaveResult[] results = Database.update(mapQCtpUpdate.values(),false);
        }

    }

    global void finish(Database.BatchableContext bc){        
        //Catch Error        
    }

}