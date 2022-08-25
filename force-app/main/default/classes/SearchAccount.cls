public without sharing class SearchAccount
{
    @InvocableMethod(label='Search for Account' description='Returns the list of accounts with keyword' )
    public static List<List<Account>> searchAccountNames(List<List<String>> listKeyword) 
    {
        Set<Account> accountSet = new Set<Account>();
        List<String> keywords = listKeyword[0];
        for (String keyword:keywords)
        {
            List<List<Account>> searchresult = [FIND :keyword IN ALL FIELDS RETURNING Account(id,Name,ownerid,website)];
            List<Account> accountlist = searchresult.get(0);
            accountSet.addAll(accountlist);
        }
        List<Account> finalAccounts = new List<Account>(accountSet);
        List<List<Account>> finalresult = new List<List<Account>>();
        finalresult.add(finalAccounts);
        return finalresult;
    }
}