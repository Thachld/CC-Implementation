public with sharing class PaymentConstant {
    public static final String ALGORITHMNAME = 'AES256';    
    //Stage
    public static final String STAGE_NEW = 'New';
    public static final String STAGE_CHECKING = 'Checking';
    public static final String STAGE_COLLECTING_MONEY = 'Collecting money';
    public static final String STAGE_APPROVING = 'Approving';
    public static final String STAGE_FAILURE = 'Failure';
    public static final String STAGE_DONE = 'Done';

    //Payment Type 
    public static final String TYPE_INCOME = 'INCOME';
    public static final String TYPE_COUPON = 'COUPON';
    public static final String TYPE_CREDIT = 'CREDIT';
    public static final String TYPE_WITHDRAWAL_COUPON = 'WITHDRAWAL_COUPON';
    public static final String TYPE_WITHDRAWAL_INCOME = 'WITHDRAWAL_INCOME';
    public static final String TYPE_WITHDRAWAL = 'WITHDRAWAL';
    public static final String TYPE_ADVANCE = 'ADVANCE';

    //Payment Method
    public static final String PAYMENT_METHOD_CASH = 'Cash';
    public static final String PAYMENT_METHOD_BANKTRANSFER = 'Bank Transfer';
    public static final String PAYMENT_METHOD_PAYMENT_GATEWAY = 'Payment Gateway';
    public static final String PAYMENT_METHOD_COUPON = 'Coupon';
    public static final String PAYMENT_METHOD_INTERNAL = 'Internal';
    public static final String PAYMENT_METHOD_COUPON_REFUND = 'Coupon Refund';
    public static final String PAYMENT_METHOD_CREDIT = 'Credit';

    //Payment Record Type DEV Name
    public static final String RECORDTYPE_ADVANCE_PAYMENT = 'Advance_Payment';
    public static final String RECORDTYPE_NORMAL_PAYMENT = 'Normal_payment';
    public static final String RECORDTYPE_REAL_PAYMENT = 'Real_Payment';
    public static final String RECORDTYPE_REFUND_PAYMENT = 'Refund_payment';
    public static final String RECORDTYPE_STANDARD_PAYMENT = 'Standard_payment';
    public static final String RECORDTYPE_TRANSFER_PAYMENT = 'Transfer_payment';

    //Withdrawal from QC
    public static final String WITHDRAWAL_FROM_QC_YES = 'Yes';
    public static final String WITHDRAWAL_FROM_QC_NO = 'No';

    //Real Money Type
    public static final String REAL_MONEY_TYPE_PAY_DEPT = 'Pay Dept';
    public static final String REAL_MONEY_TYPE_INCOME = 'Income';


    //Refund Type
    public static final String REFUND_TYPE_REFUND_TO_CLIENT = 'Refund to Client';
    public static final String REFUND_TYPE_REFUND_FOR_TRANSFER = 'Refund for Transfer';
    public static final String REFUND_TYPE_INTERNAL_REFUND = 'Internal refund';
}