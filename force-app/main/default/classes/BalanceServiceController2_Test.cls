@istest(seeAllData = true)
public with sharing class BalanceServiceController2_Test {

    @istest
    public static void getRecentlyViewed(){
        List<LookupSearchResult> result = BalanceServiceController.getRecentlyViewed();

        System.assert(result.size() > 0);
    }
}