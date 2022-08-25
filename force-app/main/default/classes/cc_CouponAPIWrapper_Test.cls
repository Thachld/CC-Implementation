@istest
public with sharing class cc_CouponAPIWrapper_Test {

    @istest
    public static void testWrapper(){
        cc_CouponAPIWrapper.SuccessCampaignWraper data = new cc_CouponAPIWrapper.SuccessCampaignWraper();
        data.id = '123';
        data.multiple_usage = 'YES';
        data.name = 'TEST Campaign';

        cc_CouponAPIWrapper.InvalidFieldWrapper invalid_field = new cc_CouponAPIWrapper.InvalidFieldWrapper();
        invalid_field.code = '422';
        invalid_field.field = 'Name';
        invalid_field.message = 'Test';

        cc_CouponAPIWrapper.CouponWrapper coupondata = new cc_CouponAPIWrapper.CouponWrapper();
        coupondata.code = '11';
        coupondata.couponCampaignId = '123';
        coupondata.amount = 10;
        coupondata.email = 'test@email.com';
        coupondata.id = '11';
        coupondata.ownerId = null;
        coupondata.expireDate = null;
        coupondata.poi_id = null;
        coupondata.spendingExpireDate = null;
        coupondata.status = null;
        coupondata.timeIssued = null;
        coupondata.timeUsed = null;
        coupondata.usedBy = null;
        coupondata.usedTransactionId = null;


        cc_CouponAPIWrapper.FalseResultWraper failresult = new cc_CouponAPIWrapper.FalseResultWraper();
        failresult.code = '442';
        failresult.message = 'Test';
        failresult.invalid_fields = new List<cc_CouponAPIWrapper.InvalidFieldWrapper>{invalid_field};


        cc_CouponAPIWrapper.CampaignAPIResultWrapper campdata = new cc_CouponAPIWrapper.CampaignAPIResultWrapper();
        campdata.data = data;
        campdata.success = true;
        campdata.error = null;

        cc_CouponAPIWrapper.CouponDataWrapper coupondatas = new cc_CouponAPIWrapper.CouponDataWrapper();
        coupondatas.data = coupondata;
        coupondatas.error = null;
        coupondatas.success = true;

        Set<String> emails = new Set<String>();
        emails.add('test@email.com');
        cc_CouponAPIWrapper.CreateCouponWrapper createcp = new cc_CouponAPIWrapper.CreateCouponWrapper();
        createcp.campaign = '123';
        createcp.couponCampaignId = '123';
        createcp.emails = emails;
        createcp.expireDate = null;
        createcp.Id = '123';
        createcp.ownerId = null;
        createcp.qcemail = 'test@email.com';
        createcp.quantity = 1;
        createcp.spendingExpiredDate = null;
        createcp.value = 1;

        cc_CouponAPIWrapper.EditCouponWrapper editcp = new cc_CouponAPIWrapper.EditCouponWrapper();
        editcp.email = 'test@email.com';
        editcp.ownerId = null;
        editcp.expireDate = null;
        editcp.value = 3000;


        cc_CouponAPIWrapper.Responds respon = new cc_CouponAPIWrapper.Responds();
        respon.message = 'test';
        respon.status = 'success';
    }
}