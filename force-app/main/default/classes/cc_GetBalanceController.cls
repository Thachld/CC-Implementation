public with sharing class cc_GetBalanceController {
    public Id paymentId {get;set;}   
    public Boolean refreshPage {get;set;}
    public cc_GetBalanceController(Apexpages.StandardController std) {
        this.paymentId = std.getId();
    }

    public Pagereference getBalance(){
        try {
            getBalanceinfo();
            PageReference tempPage = ApexPages.currentPage();           
            tempPage.setRedirect(true);
            this.refreshPage = true;
            return null; 
        }catch(Exception ex){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
    }


    public void getBalanceinfo(){
        Set<String> pyBalanceService = new Set<String>();
        pyBalanceService.add(paymentId);

        BalanceServiceHelper.attemptgetBalanceService(pyBalanceService);        
    }

}