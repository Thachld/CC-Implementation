public with sharing class cc_KPI_Calculation_Helper {    

    public class SpendingWrapper{
        public String saleId;
        public String industry;
        public String agency;
        public Boolean isXaxis;
        public Boolean isXaxisOwner;
        public Boolean isSpecialclient;
        public Boolean isStrategicClient;
        public Boolean isHNRegion;        
        public Decimal Amount;        
    }

    public class PaymentWrapper{
        public String saleId;
        public String industry;
        public String agency;
        public Boolean isXaxis;
        public Boolean isXaxisOwner;
        public Boolean isSpecialclient;
        public Boolean isStrategicClient;
        public Boolean isHNRegion;        
        public Decimal Amount;        
    }

    public static cc_QCData_wraper getSupportSpendingKPICategory(User urs, SpendingWrapper spendingdata){
        cc_QCData_wraper qc  = new  cc_QCData_wraper();
        qc.Amount = spendingdata.Amount;
        qc.Industry =  spendingdata.industry;        
        qc.SpecialClient = spendingdata.isSpecialclient;
        qc.Xaxis = spendingdata.isXaxis;
        qc.Agency = spendingdata.agency;  
        String KPICat;
        
        if(urs !=null){
            if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_GLOBAL_AGENCY){
                if(!String.isBlank(spendingdata.agency.trim())){
                    KPICat = spendingdata.agency.trim();
                }else {
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_LOCAL_AGENCY){
                if(!String.isBlank(spendingdata.agency.trim())){
                    KPICat = spendingdata.agency.trim();   
                }else{
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_DIRECT){
                if(!String.isBlank(spendingdata.industry)){
                    if(spendingdata.industry == 'Retails' 
                        || spendingdata.industry == 'FMCG'){
                        KPICat = 'FMCG-Retails';
                    }else{
                        KPICat = spendingdata.industry.trim();
                    }
                }else {
                    KPICat = 'Blank Industry';
                }    
            }
        }

        qc.KPICategory = KPICat;

        return qc;
    }

    public static cc_QCData_wraper getSupportPaymentKPICategory(User urs, PaymentWrapper paymentdata){
        cc_QCData_wraper qc  = new  cc_QCData_wraper();
        qc.Amount = paymentdata.Amount;
        qc.Industry =  paymentdata.industry;        
        qc.SpecialClient = paymentdata.isSpecialclient;
        qc.Xaxis = paymentdata.isXaxis;
        qc.Agency = paymentdata.agency;  
        String KPICat;
        
        if(urs !=null){
            if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_GLOBAL_AGENCY){
                if(!String.isBlank(paymentdata.agency.trim())){
                    KPICat = paymentdata.agency.trim();
                }else {
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_LOCAL_AGENCY){
                if(!String.isBlank(paymentdata.agency.trim())){
                    KPICat = paymentdata.agency.trim();   
                }else{
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_DIRECT){
                if(!String.isBlank(paymentdata.industry)){
                    if(paymentdata.industry == 'Retails' 
                        || paymentdata.industry == 'FMCG'){
                        KPICat = 'FMCG-Retails';
                    }else{
                        KPICat = paymentdata.industry.trim();
                    }
                }else {
                    KPICat = 'Blank Industry';
                }    
            }
        }

        qc.KPICategory = KPICat;

        return qc;
    }


    public static cc_QCData_wraper getSaleSpendingKPICategory(User urs, SpendingWrapper spendingdata){
        cc_QCData_wraper qc  = new  cc_QCData_wraper();
        qc.Amount = spendingdata.Amount;
        qc.Industry =  spendingdata.industry;        
        qc.SpecialClient = spendingdata.isSpecialclient;
        qc.Xaxis = spendingdata.isXaxis;        
        qc.Agency = spendingdata.agency;  
       
        String KPICat;
        
        if(urs !=null){
            if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_GLOBAL_AGENCY){
                if(!String.isBlank(spendingdata.agency.trim())){
                    if(spendingdata.isXaxis){
                        if(spendingdata.IsXaxisOwner){
                            KPICat = spendingdata.Agency.trim() + '-Xaxis';
                        }else {
                            KPICat = spendingdata.Agency.trim();
                        }
                    }else{
                        if(spendingdata.IsXaxisOwner){
                            KPICat = spendingdata.Agency.trim() + '-Non Xaxis';
                        }else {
                            KPICat = spendingdata.Agency.trim();
                        }
                    }
                }else {
                    KPICat = 'Blank Global Agency';
                }                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_LOCAL_AGENCY){
                if(!String.isBlank(spendingdata.agency.trim())){
                    if(spendingdata.isHNRegion){
                        KPICat = spendingdata.agency.trim() + ' HN';
                    }else{
                        KPICat = spendingdata.Agency.trim() + ' HCM';
                    }                    

                    if(spendingdata.isSpecialclient){
                        KPICat = KPICat + '-Special Client';
                    } 
                }else{
                    KPICat = 'Blank Agency';
                }
                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_DIRECT){
                if(!String.isBlank(spendingdata.industry)){
                    if(spendingdata.isSpecialclient){
                        KPICat = spendingdata.industry.trim() + '-Special';
                    }else {
                        if(spendingdata.industry == 'Retails' || spendingdata.industry == 'FMCG'){
                            KPICat = 'FMCG-Retails';
                        }else{
                            KPICat = spendingdata.industry.trim();
                        }
                    }
                }else {
                    KPICat = 'Blank Industry';
                }    
            }
        }

        qc.KPICategory = KPICat;

        return qc;
    }

    public static cc_QCData_wraper getSalePaymentKPICategory(User urs, PaymentWrapper paymentdata){
        cc_QCData_wraper qc  = new  cc_QCData_wraper();
        qc.Amount = paymentdata.Amount;
        qc.Industry =  paymentdata.industry;        
        qc.SpecialClient = paymentdata.isSpecialclient;
        qc.Xaxis = paymentdata.isXaxis;        
        qc.Agency = paymentdata.agency;  
       
        String KPICat;
        
        if(urs !=null){
            if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_GLOBAL_AGENCY){
                if(!String.isBlank(paymentdata.agency.trim())){
                    if(paymentdata.isXaxis){
                        if(paymentdata.IsXaxisOwner){
                            KPICat = paymentdata.Agency.trim() + '-Xaxis';
                        }else {
                            KPICat = paymentdata.Agency.trim();
                        }
                    }else{
                        if(paymentdata.IsXaxisOwner){
                            KPICat = paymentdata.Agency.trim() + '-Non Xaxis';
                        }else {
                            KPICat = paymentdata.Agency.trim();
                        }
                    }
                }else {
                    KPICat = 'Blank Global Agency';
                }                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_LOCAL_AGENCY){
                if(!String.isBlank(paymentdata.agency.trim())){
                    if(paymentdata.isHNRegion){
                        KPICat = paymentdata.agency.trim() + ' HN';
                    }else{
                        KPICat = paymentdata.Agency.trim() + ' HCM';
                    }                    

                    if(paymentdata.isSpecialclient){
                        KPICat = KPICat + '-Special Client';
                    } 
                }else{
                    KPICat = 'Blank Local Agency';
                }
                
            }else if(urs.Sale_Team__c == KPIConstant.SALE_TEAM_DIRECT){
                if(!String.isBlank(paymentdata.industry)){
                    if(paymentdata.isSpecialclient){
                        KPICat = paymentdata.industry.trim() + '-Special';
                    }else {
                        if(paymentdata.industry == 'Retails' || paymentdata.industry == 'FMCG'){
                            KPICat = 'FMCG-Retails';
                        }else{
                            KPICat = paymentdata.industry.trim();
                        }
                    }
                }else {
                    KPICat = 'Blank Industry';
                }    
            }
        }

        qc.KPICategory = KPICat;

        return qc;
    }
}