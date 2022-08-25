//Author: ThachLe
//Date : 09/21/2020
//Description: Auto Create All HOMs
global class cc_HOM_AutoCreateHOM_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public date minDate {get;set;}
    public date maxDate {get;set;}
    public Datetime minDateTime {get;set;}
    public Datetime maxDateTime {get;set;}
    public String runingperiod {get;set;}
    public string userAssign {get;set;}
    public boolean isUpdateToPreviousCoupond {get;set;}
    public Set<String> setAccIds {get;set;}  
    public Map<String,Set<String>> mapQCAccs {get;set;}     
    public Set<String> blankAccountQCIds {get;set;}  
    public Map<String, Set<String>> mapHOMQcs {get;set;}
    public Map<String, HandOver_Minute__c> mapHoms {get;set;}
    public Set<Id> homIds {get;set;}    
    public Map<String, Contract__c>  mapCon {get;set;}
    public Set<String> qcIdsonContract {get;set;}


    public cc_HOM_AutoCreateHOM_Batch(  String pperiod, 
                                        Boolean pisUpdateToPreviousCoupond, 
                                        Map<String,Set<String>> pmapQCAccs,
                                        Set<String> pblankAccountQCIds,
                                        Date pminDate,
                                        Date pmaxDate,
                                        Datetime pminDateTime,
                                        Datetime pmaxDateTime) {
        this.isUpdateToPreviousCoupond = pisUpdateToPreviousCoupond;
        this.runingperiod = pperiod;            
        this.mapHOMQcs = new Map<String, Set<String>>();
        this.mapHoms = new Map<String, HandOver_Minute__c>();
        this.homIds = new Set<Id>();
        this.mapCon = new Map<String, Contract__c>();
        this.qcIdsonContract = new Set<String>();

        cc_setting__c settting = cc_Util.getCustomSetting();
        this.userAssign = settting.Hom_assign__c; 
        this.minDate = pminDate;        
        this.maxDate = pmaxDate;        
        this.minDateTime = pminDateTime;       
        this.maxDateTime = pmaxDateTime; 

        this.mapQCAccs = pmapQCAccs; 
        this.setAccIds = pmapQCAccs.keySet();
        this.blankAccountQCIds = pblankAccountQCIds;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([SELECT Id, 
                                                Name, 
                                                Contract_Start_Date__c, 
                                                Contract_End_Date__c, 
                                                Contract_Number__c,
                                                Number_Of_Annex__c, 
                                                Payment_method__c,
                                                Account__c, 
                                                Account__r.OwnerId , 
                                                Account__r.Account_number__c, 
                                                No_expire_date__c,
                                                (
                                                    SELECT QC_Account__c FROM Contract_links__r
                                                )   
                                          FROM Contract__c 
                                          WHERE Status__c = 'Done'
                                                AND
                                                (
                                                    (  
                                                        (
                                                            (Contract_Start_Date__c <=: minDate AND Contract_End_Date__c >=: minDate)
                                                            OR 
                                                            (Contract_Start_Date__c >=: minDate AND Contract_Start_Date__c<=: maxDate)
                                                        ) 
                                                        AND No_expire_date__c != true
                                                    ) 
                                                    OR 
                                                    (
                                                        No_expire_date__c =  true AND 
                                                        ( Contract_Start_Date__c <=: minDate OR Contract_Start_Date__c <=: maxDate)
                                                    )
                                                )]);
    }

    global void execute(Database.BatchableContext bc, List<Contract__c> scope){
        System.debug('Start :execute');
        System.debug('scope =>' + scope.size());
        System.debug('minDateTime =>' + minDateTime);
        System.debug('maxDateTime =>' + maxDateTime);
        System.debug('setAccIds =>' + setAccIds.size());
        System.debug('mapQCAccs =>' + mapQCAccs.size());
       
        //Create HOM base on Active Contracts 
        for(Contract__c con: scope){   
            mapCon.put(con.id, con);      
            HandOver_Minute__c hom = new HandOver_Minute__c();

            System.debug('con.Id =>' + con.Id);
            System.debug('con.Account__r.Account_number__c =>' + con.Account__r.Account_number__c);
            string HOMNumber = con.Contract_Number__c + '_' + con.Account__r.Account_number__c + '_' + this.minDateTime.format('yyyyMMdd') + '_' + this.maxDateTime.format('yyyyMMdd');
            
            if( !string.isBlank(con.Account__c) && this.setAccIds.contains(con.Account__c)){
                this.setAccIds.remove(con.Account__c);
            }
             
            hom.HOM_Number__c = HOMNumber;
            hom.name = 'Hom for '  + con.Name + ' ' +  this.minDate.month() + '-' + this.minDate.year();
            hom.Account__c = con.Account__c;
            hom.Status__c = 'New';
            hom.Type__c = 'Auto';
            hom.Assign_to__c = userAssign;
            hom.Start_date__c = mindate;
            hom.End_date__c = maxdate;
            if(con.Contract_Start_Date__c != null && hom.Start_date__c < con.Contract_Start_Date__c){
                hom.Contract_Start_Date__c = con.Contract_Start_Date__c;
            }
            
            if(con.No_expire_date__c != true && con.Contract_End_Date__c != null && hom.End_date__c > con.Contract_End_Date__c ){
                hom.Contract_End_Date__c = con.Contract_End_Date__c;
            }

            hom.Custom_Contract__c = con.Id;
            this.mapHoms.put(HOMNumber,hom);


            //Remove qc account already Create HOM with contract
            Set<String> qcbyAccountIds = this.mapQCAccs.get(con.Account__c); 
                  
            if(con.Contract_links__r.Size() >0){
                for(Contract_link__c ctl: con.Contract_links__r){

                    this.qcIdsonContract.add(ctl.QC_Account__c);
                    System.debug('Contract_link__c => ' );
                    if(qcbyAccountIds != null){
                        if(qcbyAccountIds.contains(ctl.QC_Account__c)){
                            this.mapQCAccs.get(con.Account__c).remove(ctl.QC_Account__c);
                        }
                    }
                    
                    if(this.mapHOMQcs.containsKey(HOMNumber)){
                        this.mapHOMQcs.get(HOMNumber).add(ctl.QC_Account__c);
                    }else{
                        this.mapHOMQcs.put(HOMNumber, new Set<String>{ctl.QC_Account__c});
                    }                    
                }
            }
             
        }

        System.debug('End :execute');
    }

    global void finish(Database.BatchableContext bc){
        //Create HOM base on Active Account not include account in Active contracts case
        Map<String, Account> mapAccount = new Map<String, Account>([SELECT Id, Name, Account_Number__c FROM Account WHERE Id IN : this.mapQCAccs.keySet() ]);
        
        System.debug('mapAccount => ' + mapAccount.size());
        System.debug('this.setAccIds => ' + this.setAccIds.size());
        System.debug('this.mapQCAccs => ' + this.mapQCAccs.size());

        if(this.setAccIds.size() > 0){    
            for (String accId: this.setAccIds){
                if(mapAccount.containsKey(accId)){
                    HandOver_Minute__c hom = new HandOver_Minute__c();

                    System.debug('accId => ' + accId);
                    System.debug('mapAccount.get(accId) => ' + mapAccount.get(accId));

                    string HOMNumber = mapAccount.get(accId).Account_Number__c + '_' + this.minDateTime.format('yyyyMMdd') + '_' + this.maxDateTime.format('yyyyMMdd');
                    
                    hom.HOM_Number__c = HOMNumber;
                    hom.name = 'Hom for '  + mapAccount.get(accId).Name + ' ' +  this.minDate.month() + '-' + this.minDate.year();
                    if( hom.name.length() > 80){
                        hom.name = hom.name.substring( 0, 80 );
                    }
                    hom.Account__c = accId;
                    hom.Status__c = 'New';
                    hom.Type__c = 'Auto';
                    hom.Assign_to__c = userAssign;
                    hom.Start_date__c = mindate;
                    hom.End_date__c = maxdate;   

                    this.mapHoms.put(HOMNumber,hom);                    

                    Set<String> qcByAccountIds = this.mapQCAccs.get(accId);
                    System.debug('qcByAccountIds =>' + qcByAccountIds);

                    for(String qcId : qcByAccountIds){
                        //QcAccount Already Add to Contract for mcc Case
                        if(!this.qcIdsonContract.contains(qcId)){
                            if( this.mapHOMQcs.containsKey(HOMNumber) ){
                                this.mapHOMQcs.get(HOMNumber).add(qcId);
                            }else{
                                this.mapHOMQcs.put(HOMNumber, new Set<String>{qcId});
                            }
                        }   
                    }

                    //Remove qc account already Create HOM with Account
                    if( this.mapQCAccs.containsKey(accId) ){
                        this.mapQCAccs.remove(accId);
                    }
                }
            }
        }

        if(this.mapQCAccs.size() > 0){
            for(String accId: this.mapQCAccs.keySet()){
                if(mapAccount.containsKey(accId)){
                    HandOver_Minute__c hom = new HandOver_Minute__c();
                    string HOMNumber = mapAccount.get(accId).Account_Number__c + '_' + this.minDateTime .format('yyyyMMdd') + '_' + this.maxDateTime.format('yyyyMMdd');
                    
                    hom.HOM_Number__c = HOMNumber;
                    hom.Name = 'Hom for '  + mapAccount.get(accId).Name + ' ' +  this.minDate.month() + '-' + this.minDate.year();
                    if( hom.Name.length() > 80){
                        hom.Name = hom.Name.substring( 0, 80 );
                    }
                    hom.Account__c = accId;
                    hom.Status__c = 'New';
                    hom.Type__c = 'Auto';
                    hom.Assign_to__c = userAssign;
                    hom.Start_date__c = mindate;
                    hom.End_date__c = maxdate;   

                    this.mapHoms.put(HOMNumber,hom);

                    Set<String> qcByAccountIds = this.mapQCAccs.get(accId);
                    for(String qcId : qcByAccountIds){   
                        if(!this.qcIdsonContract.contains(qcId)){                 
                            if( this.mapHOMQcs.containsKey(HOMNumber) ){
                                this.mapHOMQcs.get(HOMNumber).add(qcId);
                            }else{
                                this.mapHOMQcs.put(HOMNumber, new Set<String>{qcId});
                            }
                        }
                    }
                }
            }   
        }

        //QC Account without Account owner
        if ( this.blankAccountQCIds.size() > 0 ){
            HandOver_Minute__c hom = new HandOver_Minute__c();
            string HOMNumber = 'DUMMY_HOM_' + this.minDateTime .format('yyyyMMdd') + '_' + this.maxDateTime.format('yyyyMMdd');
            
            hom.HOM_Number__c = HOMNumber;
            hom.Name = 'Hom for QC Account Blank Account Owner '  +  this.minDate.month() + '-' + this.minDate.year();
            if( hom.Name.length() > 80){
                hom.Name = hom.Name.substring( 0, 80 );
            }
            hom.Status__c = 'New';
            hom.Type__c = 'Auto';
            hom.Assign_to__c = userAssign;
            hom.Start_date__c = mindate;
            hom.End_date__c = maxdate;   

            this.mapHoms.put(HOMNumber,hom);
            
            this.mapHOMQcs.put(HOMNumber, this.blankAccountQCIds);
        }

        System.debug('this.mapHoms = >' + this.mapHoms.size());
        if( this.mapHoms.size() > 0 ){            

            Schema.SObjectField upsertField = HandOver_Minute__c.Fields.HOM_Number__c; 
            Database.UpsertResult[] results = Database.upsert(this.mapHoms.values(), upsertField, false);
            
            /*-------------------------------*/
            /*--Start:Catch Error Log -------*/
            /*-------------------------------*/

            AsyncApexJob asyn = [SELECT id, ApexClassId, ApexClass.name,
                                    JobItemsProcessed, TotalJobItems,
                                    NumberOfErrors, CreatedBy.Email
                                FROM AsyncApexJob
                                WHERE id = :bc.getJobId()];

            Integer successed = 0;
            BatchJobLog__c batchlog = new BatchJobLog__c();
            batchlog.BatchClassName__c = asyn.ApexClass.name;
            batchlog.JobId__c = bc.getJobId();
            batchlog.Period__c = this.runingperiod;
            batchlog.RunningUser__c = UserInfo.getUserId();
            insert batchlog;

            List<BatchJobLogDetail__c> errsLog = new List<BatchJobLogDetail__c>();
            for(Integer index = 0, size = results.size(); index < size; index++) {
                if(results[index].isSuccess()) {
                    this.homIds.add(results[index].getId());                     
                    successed = successed + 1; 
                }else{
                    BatchJobLogDetail__c log = new BatchJobLogDetail__c();
                    System.debug('getErrors = >' + JSON.serialize(results[index].getErrors()));                   
                    log.RecordId__c = results[index].getId();
                    log.ErrorLog__c = JSON.serialize(results[index].getErrors());
                    log.BatchJobLog__c = batchlog.Id;

                    errsLog.add(log);
                }
            }

            //Call batchs Calculation net to gross
            System.debug('this.homIds = >' + this.homIds.size());            
            System.debug('errsLog => ' + errsLog.size());
            System.debug('this.mapHoms.values() => ' + this.mapHoms.values());

            if( this.homIds.size() > 0){
                Set<String> batchHOM = new Set<String>();
                Map<String,Set<String>> mapBatchHOMQC = new Map<String,Set<String>>();
                Set<String> qcIds = new Set<String>();
                for(HandOver_Minute__c hom :this.mapHoms.values() ){
                    batchHOM.add(hom.Id);
                    Set<String> qcIdsByHom = new Set<String>();
                    qcIdsByHom = this.mapHOMQcs.get(hom.HOM_Number__c);
                        
                    System.debug('qcIdsByHom =>' + qcIdsByHom);
                    System.debug('hom.HOM_Number__c =>' + hom.HOM_Number__c);
                    if(qcIdsByHom != null){
                        qcIds.addAll(qcIdsByHom);
                        mapBatchHOMQC.put(hom.Id,qcIdsByHom);
                    }
                    
                }

                System.debug('batchHOM => ' + batchHOM.size());
                if(batchHOM.size() > 0){
                    cc_HOM_CalNetForHom_Batch withoutCon = 
                        new cc_HOM_CalNetForHom_Batch( this.runingperiod,
                                                                this.minDate,
                                                                this.maxDate,
                                                                this.minDateTime,
                                                                this.maxDateTime,
                                                                batchHOM,
                                                                mapBatchHOMQC, 
                                                                this.isUpdateToPreviousCoupond);
                    database.executeBatch(withoutCon,100);                                            
                }
            }

            if (errsLog.size() > 0){
                batchlog.Successed__c = successed;
                update batchlog;
                insert errsLog;
            }

            /*-------------------------------*/
            /*--End:Catch Error Log ---------*/
            /*-------------------------------*/
        }
    }
}