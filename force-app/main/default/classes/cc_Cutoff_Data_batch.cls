public class cc_Cutoff_Data_batch implements Database.Batchable<SObject> {

    public cc_Cutoff_Data_batch() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator([SELECT Date_Field__c, Object_Name__c, Period_of_Data_exists__c, Special_Condition__c
                                    FROM Cutoff_Data_Setting__mdt WHERE IsActive__c = true]);          

    }

    public void execute(Database.BatchableContext bc, List<Cutoff_Data_Setting__mdt> scope){

        List<String> listSOQLs= new List<String>();        

        for(Cutoff_Data_Setting__mdt cutoff: scope){
            if(!String.isBlank(cutoff.Object_Name__c) 
                && !String.isBlank(cutoff.Date_Field__c)
                && cutoff.Period_of_Data_exists__c > 0){
                
                String soqlStr = '';
                Date cutoffdate = System.today().addMonths(-(Integer)cutoff.Period_of_Data_exists__c);
                String cutoffdtstr = String.valueOf(cutoffdate);

                soqlStr = 'SELECT Id FROM '+ cutoff.Object_Name__c
                        + 'WHERE ' + cutoff.Date_Field__c  + ' < ' + cutoffdtstr;
                
                if(!String.isBlank(cutoff.Special_Condition__c)){
                    soqlStr  = soqlStr  + ' ' + cutoff.Special_Condition__c;
                }

                if(!String.isBlank(soqlStr)){
                    listSOQLs.add(soqlStr);
                }

            }
        }

        //Query cut-off data
        if(listSOQLs.size() > 0){
            for (String soqlQuery : listSOQLs) {
                List<SObject> deleteRecords = doQuery(soqlQuery);
                if(deleteRecords != null){
                    Database.delete(deleteRecords, false);
                }
            }
        }

    }


    public void finish(Database.BatchableContext bc){

    }


    public static List<SObject> doQuery(String soqlQuery){
        try {
            List<SObject> result = Database.query(soqlQuery);
            return result;
        } catch (Exception ex) {
            System.debug('Query Error :' + ex.getMessage());
            return null;
        }
    }
}