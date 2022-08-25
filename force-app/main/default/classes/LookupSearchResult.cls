public virtual class LookupSearchResult implements Comparable {
    protected Id id;
    protected String sObjectType;
    protected String icon;
    protected String title;
    protected String subtitle;
    protected String Stringfield1;
    protected String Stringfield2;
    protected Decimal Decimalfield;
    protected Date Datefield;

    protected LookupSearchResult() {
    }

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, String stringfield1, String stringfield2, Decimal decimalfield, Date datefield) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.Stringfield1 = stringfield1;
        this.Stringfield2 = stringfield2;
        this.Decimalfield = decimalfield;
        this.Datefield = datefield;
    }

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, String stringfield1, String stringfield2, Decimal decimalfield) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.Stringfield1 = stringfield1;
        this.Stringfield2 = stringfield2;
        this.Decimalfield = decimalfield;
    }

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, String stringfield1, String stringfield2) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.Stringfield1 = stringfield1;
        this.Stringfield2 = stringfield2; 
    }

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, String stringfield1) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.Stringfield1 = stringfield1;       
    }
    

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, Decimal decimalfield) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.Decimalfield = decimalfield;       
    }

    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle, Date datefield) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.Datefield = datefield;       
    }



    public LookupSearchResult(Id id, String sObjectType, String icon, String title, String subtitle) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;  
    }

    @AuraEnabled
    public Id getId() {
        return id;
    }

    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }

    @AuraEnabled
    public String getIcon() {
        return icon;
    }

    @AuraEnabled
    public String getTitle() {
        return title;
    }

    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }

    @AuraEnabled
    public String getStringfield1() {
        return Stringfield1;
    }

    @AuraEnabled
    public String getStringfield2() {
        return Stringfield2;
    }

    @AuraEnabled
    public Decimal getDecimalfield() {
        return Decimalfield;
    }

    @AuraEnabled
    public Date getDatefield() {
        return Datefield;
    }

    /**
     * Allow to sort search results based on title
     */
    public Integer compareTo(Object compareTo) {
        LookupSearchResult other = (LookupSearchResult) compareTo;
        if (this.getTitle() == null) {
            return (other.getTitle() == null) ? 0 : 1;
        }
        if (other.getTitle() == null) {
            return -1;
        }
        return this.getTitle().compareTo(other.getTitle());
    }
}