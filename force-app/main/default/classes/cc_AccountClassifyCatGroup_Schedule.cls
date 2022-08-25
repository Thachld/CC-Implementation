global with sharing class cc_AccountClassifyCatGroup_Schedule implements Schedulable{
    global void execute(SchedulableContext SC) {
        callBatch();
    }

    global cc_AccountClassifyCatGroup_Schedule()
    {        
        callBatch();
    }

    private void callBatch(){       
        /* ------- Parameter ------------*/

        Date prundate = System.today();
        Date pstartclassifyDate = null;
        String pindustry = '';
        String agency = '';
        Boolean pisManual = false;
        List<ClientCategoryDetail__mdt> pcatdetail = new List<ClientCategoryDetail__mdt>();

        cc_AccountClassifyCategogryGroup_Batch batch = 
            new cc_AccountClassifyCategogryGroup_Batch(prundate, pstartclassifyDate,pindustry,agency,pisManual,pcatdetail);
        Database.executeBatch(batch, 1);
    }
}