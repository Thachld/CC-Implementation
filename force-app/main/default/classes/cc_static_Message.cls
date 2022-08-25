/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 08-10-2022
 * @last modified by  : @Thach Le
**/
public class cc_static_Message {
	 public static String Payment_Done = 'Done';
     public static String Payment_Fail = 'Failure';
     public static String Payment_Coupon = 'Coupon';
    
     public static String Payment_Method_Credit = 'Credit';
     public static String Payment_Type_Credit = 'CREDIT';
    
    public static String Payment_RecordType_Standard = 'Standard payment';
    public static String Payment_RecordType_Transfer = 'Transfer payment';
    public static String Payment_RecordType_Refund = 'Refund payment';
    public static String Payment_RecordType_Advance = 'Advance Payment';
    public static String Payment_RecordType_Normal = 'Normal payment';
    public static String Payment_RecordType_Real_Payment = 'Real Payment';
    
    
    public static List<QC_Account__Share> qcAccountShareList {get;set;}
    public static List<cc_ChatterBatchWrapper> feedItemQCAccountList{get;set;}
    public static boolean isUpdateBalance {get;set;}
    public static boolean isCreateQCAccountViaAPI {get;set;}
    public static boolean isDoneCouponViaAPI {get;set;}
    public static boolean isCreateCaseFeedViaAPI {get;set;}
    public static boolean isUpdateCaseFeedViaAPI {get;set;}

    public static boolean isUpdateCaseViaAPI {get;set;}
}