/**
 * @description       : 
 * @author            : @Thach Le
 * @group             : 
 * @last modified on  : 08-10-2022
 * @last modified by  : @Thach Le
**/
@istest
public with sharing class cc_static_Message_Test {
    @istest
    public static void testStatic(){
        cc_static_Message.Payment_Done = 'Done';
        cc_static_Message.Payment_Fail = 'Failure';
        cc_static_Message.Payment_Coupon = 'Coupon';
    
        cc_static_Message.Payment_Method_Credit = 'Credit';
        cc_static_Message.Payment_Type_Credit = 'CREDIT';
    
        cc_static_Message.Payment_RecordType_Standard = 'Standard payment';
        cc_static_Message.Payment_RecordType_Transfer = 'Transfer payment';
        cc_static_Message.Payment_RecordType_Refund = 'Refund payment';
        cc_static_Message.Payment_RecordType_Advance = 'Advance Payment';
        cc_static_Message.Payment_RecordType_Normal = 'Normal payment';
        cc_static_Message.Payment_RecordType_Real_Payment = 'Real Payment';
    
    
    
        cc_static_Message.isUpdateBalance = false;
        cc_static_Message.isCreateQCAccountViaAPI = false;
        cc_static_Message.isCreateCaseFeedViaAPI = false;
        cc_static_Message.isUpdateCaseFeedViaAPI = false;
        cc_static_Message.isUpdateCaseViaAPI = false;

        cc_static_Message.isDoneCouponViaAPI = false;
    }
}