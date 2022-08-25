global class cc_AggregateResultIterable implements Iterable<AggregateResult>{
    private String query;

    global cc_AggregateResultIterable(String soql){
        query = soql;
    }
  
    global Iterator<AggregateResult> Iterator(){
        return new cc_AggregateResultIterator(query);
    }
}