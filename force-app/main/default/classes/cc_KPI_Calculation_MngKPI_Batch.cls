global class cc_KPI_Calculation_MngKPI_Batch implements Database.Batchable<SObject>, Database.Stateful{
    public String kpiperiod {get;set;}
    public List<KPI__c> KPIs {get;set;}
    public cc_KPI_Setting__c kpisetting {get;set;}

    public cc_KPI_Calculation_MngKPI_Batch(String period) {
        this.kpiperiod = period;
        this.KPIs = new List<KPI__c>();
        this.kpisetting = cc_Util.getKPISetting('ccKPISetting');
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, Sales__c, Sales__r.LastName, Sales__r.Email, Sales__r.Trac_Name__c,
                                                Sales__r.Manager_Level__c, 
                                                Sale_Manager_KPI__c,
                                                Sale_Manager_KPI__r.Sales__c,
                                                RecordType.DeveloperName,
                                                SalesManager__c, 
                                                Period__c,
                                                From_Date__c,
                                                To_Date__c,
                                                KPI_Category__c,
                                                Name    
                                        FROM KPI__c 
                                        WHERE Period__c = : this.kpiperiod
                                            AND Status__c != 'Confirmed'
                                            AND RecordType.DeveloperName IN ('Sale_Manager_KPI','Support_Manager_KPI')]);
    }

    global void execute(Database.BatchableContext bc, List<KPI__c> scope){

        Set<String> kpiIds = new Set<String>();
        List<Sale_Spending_Payment__c> listKPIsToUpdate = new List<Sale_Spending_Payment__c>();  
        Map<String, List<Sale_Spending_Payment__c>> mapMngSps = new Map<String, List<Sale_Spending_Payment__c>>();
        Map<String, List<Sale_Spending_Payment__c>> mapTeamSps = new Map<String, List<Sale_Spending_Payment__c>>();
        Map<String, List<Sale_Spending_Payment__c>> maptoUpdateSps = new Map<String, List<Sale_Spending_Payment__c>>();

        for(KPI__c kpi: scope){            
            kpiIds.add(kpi.Id);   
            this.KPIs.add(kpi);        
        }
        System.debug('MngKPI_Batch kpiIds => ' + kpiIds.size());
        for(Sale_Spending_Payment__c sp : [SELECT Id, KPI__c, KPI__r.KPIAutoNumber__c, KPI_Number__c, 
                                                Payment_Amount__c, Spending_Amount__c, KPI_Category__c,
                                                KPI__r.Sale_Manager_KPI__c, Name
                                            FROM Sale_Spending_Payment__c 
                                            WHERE KPI__c =: kpiIds]){
            if(mapMngSps.containsKey(sp.KPI__c)){
                mapMngSps.get(sp.KPI__c).add(sp);
            }else {
                mapMngSps.put(sp.KPI__c, New List<Sale_Spending_Payment__c>{sp});
            }                                    
        }


        for(Sale_Spending_Payment__c teamsp : [SELECT Id, KPI__c, KPI__r.KPIAutoNumber__c, KPI__r.Sale_Manager_KPI__c, KPI_Number__c, 
                                                    Payment_Amount__c, Spending_Amount__c, KPI_Category__c,  Name
                                                FROM Sale_Spending_Payment__c 
                                                WHERE KPI__r.Period__c =: this.kpiperiod
                                                    AND KPI__r.Sale_Manager_KPI__c != ''
                                                    AND KPI__r.RecordType.DeveloperName IN ('Sale_KPI','Support_KPI')
                                                ]){
            if(mapTeamSps.containsKey(teamsp.KPI__r.Sale_Manager_KPI__c)){
                mapTeamSps.get(teamsp.KPI__r.Sale_Manager_KPI__c).add(teamsp);
            }else {
                mapTeamSps.put(teamsp.KPI__r.Sale_Manager_KPI__c, New List<Sale_Spending_Payment__c>{teamsp});
            }                                    
        }
       
        //Roll-up Summary for Manager Lv3
        for(KPI__c kpi : scope){
            if(kpi.Sales__r.Manager_Level__c == 'Level 3'){

                List<Sale_Spending_Payment__c> mngSps = mapMngSps.get(kpi.Id); 
                List<Sale_Spending_Payment__c> teamSps = mapTeamSps.get(kpi.Id);
                
                System.debug('Level 3 => ' + kpi.Name);                
                if(mngSps != null){                    
                    for(Sale_Spending_Payment__c sp: mngSps){
                        sp.Payment_Amount__c = 0;
                        sp.Spending_Amount__c = 0;

                        
                        if(teamSps != null){
                            for(Sale_Spending_Payment__c teamsp: teamSps){
                                if(sp.KPI_Category__c == 'Global Agency' && 
                                    (teamsp.KPI_Category__c == 'Global Agency-Xaxis' 
                                        || teamsp.KPI_Category__c == 'Global Agency-Non Xaxis' 
                                        || teamsp.KPI_Category__c == 'Global Agency') ){

                                    sp.Payment_Amount__c += teamsp.Payment_Amount__c == null?0 : teamsp.Payment_Amount__c;
                                    sp.Spending_Amount__c += teamsp.Spending_Amount__c ==null?0 : teamsp.Spending_Amount__c;                                    
                                    
                                }else if (sp.KPI_Category__c == teamsp.KPI_Category__c) {
                                    sp.Payment_Amount__c += teamsp.Payment_Amount__c ==null?0 : teamsp.Payment_Amount__c;
                                    sp.Spending_Amount__c += teamsp.Spending_Amount__c ==null?0 : teamsp.Spending_Amount__c;                                    
                                
                                
                                }
                            }
                        }


                        System.debug('sp.KPI__r.Sale_Manager_KPI__c => ' + sp.KPI__r.Sale_Manager_KPI__c);
                        if(maptoUpdateSps.containsKey(sp.KPI__r.Sale_Manager_KPI__c)){
                            maptoUpdateSps.get(sp.KPI__r.Sale_Manager_KPI__c).add(sp);
                        }else {
                            maptoUpdateSps.put(sp.KPI__r.Sale_Manager_KPI__c, new List<Sale_Spending_Payment__c>{sp});
                        }
                    }
                }    
            }
        }

       

        //Roll-up Summary for Manager Lv2
        for(KPI__c kpi : scope){
            if(kpi.Sales__r.Manager_Level__c == 'Level 2'){
                List<Sale_Spending_Payment__c> mngSps = mapMngSps.get(kpi.Id); 
                
                List<Sale_Spending_Payment__c> teamSps = mapTeamSps.get(kpi.Id);
                List<Sale_Spending_Payment__c> rollSps = maptoUpdateSps.get(kpi.Id);
                if(rollSps != null){
                    if(teamSps != null){
                        teamSps.addAll(rollSps);
                    }else{
                        teamSps = new List<Sale_Spending_Payment__c>();
                        teamSps.addAll(rollSps);
                    }                    
                }
                
                System.debug('Level 2 => ' + kpi.Name);
                if(mngSps != null){                    
                    for(Sale_Spending_Payment__c sp: mngSps){
                        sp.Payment_Amount__c = 0;
                        sp.Spending_Amount__c = 0;

                        if(teamSps != null){
                            for(Sale_Spending_Payment__c teamsp: teamSps){
                                if(sp.KPI_Category__c == 'Global Agency' && 
                                    (teamsp.KPI_Category__c == 'Global Agency-Xaxis' 
                                        || teamsp.KPI_Category__c == 'Global Agency-Non Xaxis' 
                                        || teamsp.KPI_Category__c == 'Global Agency') ){

                                    sp.Payment_Amount__c += teamsp.Payment_Amount__c == null?0 : teamsp.Payment_Amount__c;
                                    sp.Spending_Amount__c += teamsp.Spending_Amount__c ==null?0 : teamsp.Spending_Amount__c;                                    
                                    
                                }else if (sp.KPI_Category__c == teamsp.KPI_Category__c) {
                                    sp.Payment_Amount__c += teamsp.Payment_Amount__c ==null?0 : teamsp.Payment_Amount__c;
                                    sp.Spending_Amount__c += teamsp.Spending_Amount__c ==null?0 : teamsp.Spending_Amount__c;                                    
                                }
                            }                            
                        }

                        
                        if(maptoUpdateSps.containsKey(sp.KPI__r.Sale_Manager_KPI__c)){
                            maptoUpdateSps.get(sp.KPI__r.Sale_Manager_KPI__c).add(sp);
                        }else {
                            maptoUpdateSps.put(sp.KPI__r.Sale_Manager_KPI__c, new List<Sale_Spending_Payment__c>{sp});
                        }
                    }                    
                }    
            }
        }

        
        //Roll-up Summary for Manager Lv1
        for(KPI__c kpi : scope){
            if(kpi.Sales__r.Manager_Level__c == 'Level 1'){
                List<Sale_Spending_Payment__c> mngSps = mapMngSps.get(kpi.Id); 
                
                List<Sale_Spending_Payment__c> teamSps = mapTeamSps.get(kpi.Id);
                List<Sale_Spending_Payment__c> rollSps = maptoUpdateSps.get(kpi.Id);
                if(rollSps != null){
                    if(teamSps != null){
                        teamSps.addAll(rollSps);
                    }else{
                        teamSps = new List<Sale_Spending_Payment__c>();
                        teamSps.addAll(rollSps);
                    }                    
                }
                
                if(mngSps != null){                    
                    for(Sale_Spending_Payment__c sp: mngSps){
                        sp.Payment_Amount__c = 0;
                        sp.Spending_Amount__c = 0;

                        if(teamSps != null){
                            for(Sale_Spending_Payment__c teamsp: teamSps){
                                if(sp.KPI_Category__c == 'Global Agency' && 
                                    (teamsp.KPI_Category__c == 'Global Agency-Xaxis' 
                                        || teamsp.KPI_Category__c == 'Global Agency-Non Xaxis' 
                                        || teamsp.KPI_Category__c == 'Global Agency') ){

                                    sp.Payment_Amount__c += teamsp.Payment_Amount__c == null?0 : teamsp.Payment_Amount__c;
                                    sp.Spending_Amount__c += teamsp.Spending_Amount__c ==null?0 : teamsp.Spending_Amount__c;                                    
                                    
                                }else if (sp.KPI_Category__c == teamsp.KPI_Category__c) {
                                    sp.Payment_Amount__c += teamsp.Payment_Amount__c ==null?0 : teamsp.Payment_Amount__c;
                                    sp.Spending_Amount__c += teamsp.Spending_Amount__c ==null?0 : teamsp.Spending_Amount__c;
                                    
                                }
                            }                            
                        }

                        if( maptoUpdateSps.containsKey(sp.KPI__r.Sale_Manager_KPI__c)){
                            maptoUpdateSps.get(sp.KPI__r.Sale_Manager_KPI__c).add(sp);
                        }else {
                            maptoUpdateSps.put(sp.KPI__r.Sale_Manager_KPI__c, new List<Sale_Spending_Payment__c>{sp});
                        }
                    }                    
                }    
            }
        }

        
        if(maptoUpdateSps.size() > 0){
            for(String kpiId: maptoUpdateSps.keyset()){
                List<Sale_Spending_Payment__c> sps = maptoUpdateSps.get(kpiId);       
                listKPIsToUpdate.addAll(sps);
            }
        }

        System.debug('listKPIsToUpdate =>' + listKPIsToUpdate.size());
        if(listKPIsToUpdate.size() > 0){
            update listKPIsToUpdate;
        }

    }

    global void finish(Database.BatchableContext bc){
        if(this.kpisetting != null){
            if(this.kpisetting.SendEmailToManager__c){
                Messaging.Email[] messages = new Messaging.Email[0];
                for(KPI__c kpi : this.KPIs){
                    Messaging.SingleEmailMessage email = sendEmail(kpi);
                    messages.add(email);            
                }
                try {
                    Messaging.sendEmail(messages);
                } catch (Exception ex) {
                    
                }    
            }
        }
    }


    public Messaging.SingleEmailMessage sendEmail(KPI__c kpi ){
        Datetime dtNow = System.now();
        String dtNowformat = dtNow.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss.SSSZ');
        
        List<String> emails = new List<String>();  
        
        if(kpi.Sales__c == this.kpisetting.Sales_Director__c){
            User pa = [SELECT Id, Email FROM User WHERE Id = : this.kpisetting.Sales_Director_PA__c];
            if(pa != null){
                emails.add(pa.Email);        
            }else{
                emails.add(kpi.Sales__r.Email);        
            }
        }else {
            emails.add(kpi.Sales__r.Email);        
        }


        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();           
        mail.setSaveAsActivity(false);   
        mail.setSenderDisplayName('Cốc Cốc Salesforce System'); 

        mail.setSubject('[KPI] - Manager KPI Result - '+  kpi.Name);
        mail.setHtmlBody(              
                  '<br/><br/><b>Dear Manager ' + kpi.Sales__r.LastName + '</b>'
				+ '<br/><br/>  Your Manager\' KPI result has been completed to calulation ' 
                + '<br/>KPI Period:' + kpi.Period__c
                + '<br/>From Date:' + kpi.From_Date__c
                + '<br/>End Date:' + kpi.To_Date__c               
                + '<br/>Link: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + kpi.Id

                + '<br/><br/>Thank you!'                
                );

        mail.setToAddresses(emails);

        return mail;
    }
}