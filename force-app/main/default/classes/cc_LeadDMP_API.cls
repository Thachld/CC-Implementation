@RestResource(urlMapping = '/dmpleadtosf')
global class cc_LeadDMP_API {
    
    @Httppost
    global static String postDMPLeads(){
        
        Lead_Default_Setting__mdt leadDefault = Lead_Default_Setting__mdt.getInstance('DFDMP');
        AdsOpManager__mdt adsOM = AdsOpManager__mdt.getInstance('Default_User');
        AccountToQCWrapper.Responds rp = new AccountToQCWrapper.Responds();
        Integer failedInsertlead = 0;
        Integer successInsertlead = 0;
        Integer failedUDlead = 0;
        Integer successUDlead = 0;
        String campaignName='';
        String errorMsg='';

        try {

            List<Lead> insertLeads = new List<Lead>();
            Map<Id,Lead> mapUpdateLeads = new Map<Id,Lead>();
            List<cc_DMPLeadWrapper> leadsWrapper = cc_DMPLeadWrapper.parse(RestContext.request.requestBody.toString());
            Date today = System.today();
            campaignName = 'Lead DMP-' + String.valueOf(today.year())+ '-' + String.valueOf(today.month())  + '-' + String.valueOf(today.day());

            Id clientAgencyRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Client_Agency').getRecordTypeId();            

            for(cc_DMPLeadWrapper dmp: leadsWrapper){
                Lead dmplead = new Lead();
                if(!String.isBlank(dmp.sfid)){
                    dmplead.Id = dmp.sfid; 
                    dmplead.ads_unique_user__c = dmp.metrics_30d.google_serp.ads_unique_user;
                    dmplead.ads_impression__c = dmp.metrics_30d.google_serp.ads_impression;
                    dmplead.ads_click__c = dmp.metrics_30d.google_serp.ads_click;
                    dmplead.ads_unique_user_click__c = dmp.metrics_30d.google_serp.ads_unique_user_click; 
                    dmplead.Google_Click__c = dmp.metrics_30d.google_serp.serp_click;
                    dmplead.Google_Impression__c = dmp.metrics_30d.google_serp.serp_impression;                          
                    dmplead.Bypass_Api__c = true;     
                    dmplead.DMP_Last_Updated_Date__c = Datetime.now();

                    List<String> setindustry = dmp.industry;
                    if(setindustry != null){
                        String industry = String.join(setindustry, ';');
                        dmplead.DMP_Industry__c = industry;
                    }

                    List<String> settopic = dmp.topics;
                    if(settopic != null){
                        String topic = String.join(settopic, ';');
                        dmplead.DMP_topics__c = topic;
                    }

                    mapUpdateLeads.put(dmp.sfid,dmplead);
                    
                }else{

                    dmplead.LastName = dmp.domain;
                    dmplead.ads_unique_user__c = dmp.metrics_30d.google_serp.ads_unique_user;
                    dmplead.ads_impression__c = dmp.metrics_30d.google_serp.ads_impression;
                    dmplead.ads_click__c = dmp.metrics_30d.google_serp.ads_click;
                    dmplead.ads_unique_user_click__c = dmp.metrics_30d.google_serp.ads_unique_user_click; 
                    dmplead.Google_Click__c = dmp.metrics_30d.google_serp.serp_click;
                    dmplead.Google_Impression__c = dmp.metrics_30d.google_serp.serp_impression;  
                    dmplead.Phone_1__c = dmp.phone;
                    dmplead.Website = dmp.domain;                
                    dmplead.LeadSource = leadDefault.LeadSource__c == null ? 'DMP': leadDefault.LeadSource__c;
                    dmplead.Campaign_Name__c = campaignName;
                    dmplead.Bypass_Api__c = true;
                    dmplead.Status = 'New';
                    dmplead.RecordTypeId = clientAgencyRecordTypeId;

                    List<String> setindustry = dmp.industry;
                    if(setindustry != null){
                        String industry = String.join(setindustry, ';');
                        dmplead.DMP_Industry__c = industry;
                    }

                    List<String> settopic = dmp.topics;
                    if(settopic != null){
                        String topic = String.join(settopic, ';');
                        dmplead.DMP_topics__c = topic;
                    }
                    insertLeads.add(dmplead);
                }
            }

            if(insertLeads.size() > 0){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.AssignmentRuleHeader.UseDefaultRule = true;    
                dmo.OptAllOrNone = false;  
                List<Database.SaveResult> results = Database.insert(insertLeads,dmo);
                
                for(Integer i = 0 ; i < insertLeads.size() ; i++){
                    Database.SaveResult rs = results[i];
                    Lead insertLead = insertLeads[i];

                    if(!rs.isSuccess()){                   
                        failedInsertlead = failedInsertlead + 1;
                        for(Database.Error err : rs.getErrors()) { 
                            errorMsg += ' \n' + ' +  Lead domain=> ' + insertLead.Website +  ' Fields => ' +  err.getFields() + ' Error message => ' + err.getMessage() ;
                            System.debug('errorMsg=>' + errorMsg);
                        }
                    }else {
                        successInsertlead = successInsertlead + 1;                    
                    }
                }           
            }


            if(mapUpdateLeads.size() > 0){
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.DuplicateRuleHeader.AllowSave = true;
                dmo.OptAllOrNone = false;
                List<Database.SaveResult> results = Database.update(mapUpdateLeads.values(), dmo);
                
                for(Integer i = 0 ; i < mapUpdateLeads.values().size() ; i++){
                    Database.SaveResult rs = results[i];
                    Lead insertLead = mapUpdateLeads.values()[i];

                    if(!rs.isSuccess()){                   
                        failedUDlead = failedUDlead + 1;
                        for(Database.Error err : rs.getErrors()) { 
                            errorMsg += ' \n' + ' +  Lead domain=> ' + insertLead.Website +  ' Fields => ' +  err.getFields() + ' Error message => ' + err.getMessage() ;
                            System.debug('errorMsg=>' + errorMsg);
                        }
                    }else {
                        successUDlead = successUDlead + 1;                    
                    }
                }           
            }

            String message = 'Total DMP Leads ' + leadsWrapper.size()  + ' \n';
            message += 'success insert leads: ' + successInsertlead + ' \n';
            message += 'failed insert leads: ' + failedInsertlead + ' \n';
            message += 'success update leads: ' + successUDlead + ' \n';
            message += 'failed update leads: ' + failedUDlead ;

            rp.message = message;
            rp.status = 'success';

        } catch (Exception ex) {
            rp.message = ex.getMessage();            
            rp.status = 'failed';
            errorMsg = ex.getMessage();
            System.debug(ex.getMessage());
        }

        DMP_Lead_Result__e evt = new DMP_Lead_Result__e();
        evt.Campaign_Name__c = campaignName;
        evt.Failed_Leads__c = failedInsertlead;
        evt.Success_Leads__c = successInsertlead;
        evt.Number_Of_Failed_Update_lead__c = failedUDlead;
        evt.Number_Of_Success_Update_lead__c = successUDlead;
        evt.Message__c = errorMsg ;
        evt.Status__c = rp.status;
        Eventbus.publish(evt);

        return JSON.serialize(rp);
    }
}