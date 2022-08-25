public class homValuesMapWrapper {
    public string name {get;set;}
    public integer show{get;set;}
    public integer click{get;set;}
    public Decimal netspending{get;set;}
    public Decimal grossspending{get;set;}
    public Decimal discount{get;set;}
    public homValuesMapWrapper(string keyTemp){
        name =keyTemp;
        /*show = 0;
        click = 0;
        netspending = 0;
        grossspending = 0;
        discount = 0;*/
    }
}