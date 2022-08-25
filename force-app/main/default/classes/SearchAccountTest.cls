@isTest
private class SearchAccountTest {
    @isTest
    private static void testSearchName() {
        Account acc = cc_initData.initAccount();
        insert acc;
        List<String> keyword = new List<String>{'test'};
        List<List<String>> keywords = new List<List<String>>();
        keywords.add(keyword);
        Test.startTest();
        List<List<Account>> returnaccts = SearchAccount.searchAccountNames (keywords);
        Test.stopTest();
    }
}