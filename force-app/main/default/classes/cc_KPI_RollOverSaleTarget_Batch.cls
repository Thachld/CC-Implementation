global class cc_KPI_RollOverSaleTarget_Batch implements Database.Batchable<SObject>,Database.Stateful{
    public String quater {get;set;}
    global cc_KPI_RollOverSaleTarget_Batch(String pquater) {
        this.quater = pquater;
    }


    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Id, ManagerId, KPI_Category__c, Trac_Name__c, Working_direct__c, Profile.Name
                                        FROM User 
                                        WHERE Profile.Name IN ('Sales Profile','Support Profile','HotLine Profile')
                                            AND KPI_Category__c != ''
                                            AND IsActive = true]);       
    
    }

    global void execute (Database.BatchableContext bc, List<User> scope){     
        List<KPI_Target__c> kpitargettoInsert = new List<KPI_Target__c>();
        Map<String,List<User>> mapManager = new Map<String,List<User>>();
        Map<String,User> mapUser = new Map<String,User>();

        for(User us: scope){
            if(!String.isBlank(us.ManagerId)){
                if(mapManager.containsKey(us.ManagerId)){
                    mapManager.get(us.ManagerId).add(us);
                } else {
                    mapManager.put(us.ManagerId, new List<User>{us});
                }
            }

            mapUser.put(us.Id, us);
        }


        for(String mngId: mapManager.keySet()){      
            if(mapUser.containsKey(mngId)){
                String salerecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_KPI').getRecordTypeId();     
                String mngrecordtypeId = Schema.SObjectType.KPI_Target__c.getRecordTypeInfosByDeveloperName().get('Sale_Manager_KPI').getRecordTypeId();         
                System.debug('mngId = >' + mngId);

                //Team KPI
                if(mapUser.get(mngId).Profile.Name == 'Sales Profile'){
                    KPI_Target__c target = new KPI_Target__c();            
                    target.Name = 'KPI Team member - ' + mapUser.get(mngId).Trac_Name__c + ' - Q' + this.quater;
                    target.Quarter__c = this.quater;
                    target.Sale_Manager__c = mngId;
                    target.Approval_Status__c = 'New';
                    target.Status__c = 'New';
                    target.recordtypeId = salerecordtypeId;
                    target.OwnerId = mngId;

                    if(mapUser.get(mngId).Working_direct__c){
                        target.Include_Manager__c = true;
                    }
                    kpitargettoInsert.add(target);
                }
                    
                //Manager KPI
                KPI_Target__c mngtarget = new KPI_Target__c();            
                mngtarget.Name = 'KPI Manager - ' + mapUser.get(mngId).Trac_Name__c + ' - Q' + this.quater;
                mngtarget.Quarter__c = this.quater;
                mngtarget.Sale_Manager__c = mngId;
                mngtarget.Approval_Status__c = 'New';
                mngtarget.Status__c = 'New';
                mngtarget.recordtypeId = mngrecordtypeId;
                mngtarget.OwnerId = mngId;

                kpitargettoInsert.add(mngtarget);
            }
        }        


        if(kpitargettoInsert.size() >0){
            insert kpitargettoInsert;
        }
    }

    global void finish(Database.BatchableContext bc){
        cc_KPI_RollOverTargetDetails_Batch detailbatch = new cc_KPI_RollOverTargetDetails_Batch(this.quater);
        Database.executeBatch(detailbatch, 50);
    }
}