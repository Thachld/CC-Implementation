public class cc_PaymentStreaming_Wrapper {    

    public class ConfirmedPayment{
        public String id;
        public String name;       
        public Decimal final_Amount;      
        public String note; 
        public String stage;       
    }    

    public class CreatedPaymentWrapper{
        public String id;
        public String name;
        public String qcemail;
        public String qcid;
        public Decimal finalAmount;
        public String paymentmethod;
        public String stage;
        public String type;
        public String typemappingid;
        public String note;   
        public String withdrawaltransId;
        public String confirmByEmail;    
    }
}