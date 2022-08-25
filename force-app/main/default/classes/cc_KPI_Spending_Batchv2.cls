global class cc_KPI_Spending_Batchv2 implements Database.Batchable<sObject>, Database.Stateful{
    public datetime minDate {get;set;}
    public datetime maxDate {get;set;}
    global cc_setting__c setting;
    public string adminUserId = '0050o00000XLyrMAAT';
    global set<string> qcAccountErrorSet;
    global Map<string,Sale_target_v1__c> salesLocalTargetMap;
    global Map<string,Sale_target_v1__c> salesGlobalTargetMap;
    global Map<string,Sale_target_v1__c> salesIndustryTargetMap;
    global Map<string,Sale_target_v1__c> salesIsDirectTargetMap;
    global Map<string,Sale_target_v1__c> salesXaxisTargetMap;
    
    global set<string> saleTargetErrorSet;
    
    global Map<string, decimal> qcAccountNumber;
    global Map<string, decimal> accNumber;
	 public cc_KPI_Spending_Batchv2(string strDate){
        setting = cc_Util.getCustomSetting();
        qcAccountErrorSet = new set<string>();
        saleTargetErrorSet = new set<string>();
        salesLocalTargetMap = new Map<string,Sale_target_v1__c>();
        salesGlobalTargetMap = new Map<string,Sale_target_v1__c>();
        salesIsDirectTargetMap = new Map<string,Sale_target_v1__c>();
        salesIndustryTargetMap = new Map<string,Sale_target_v1__c>();
        salesXaxisTargetMap = new Map<string,Sale_target_v1__c>();
        qcAccountNumber = new Map<string,Decimal>();
        accNumber = new Map<string,Decimal>();
        //xaxisAccNumber = new Map<string,Decimal>();
         
        date dtToday = date.today();
        if( !string.isBlank(strDate)){
            string[] M = strDate.split('/');
            dtToday = date.NewInstance(integer.valueOf(M[2]), integer.valueOf(M[1]),integer.valueOf(M[0]));
        }
        minDate = dtToday;
        maxDate = dtToday;
        
        List<Sale_target_v1__c> salesTargetList = [select id,Name,Agency__c,Calculate_fomular__c,End_date__c,Gross_Spending__c,Spending_Share__c,
                                                   Industry__c,Leader__c,Mannually_Calculate__c,Position__c,Start_date__c,User__c, is_Xaxis__c,
                                                   RecordType.Name           
                                                   from Sale_target_v1__c 
                                                   where Start_date__c <=: dtToday and End_date__c >=: dtToday and Mannually_Calculate__c != true 
                                                  ];
        for(Sale_target_v1__c item: salesTargetList){
            item.End_datetime__c = datetime.newInstance(item.End_date__c.year(), item.End_date__c.month(), item.End_date__c.day(), 23,59,59);
            if( item.Start_date__c != null && minDate > item.Start_date__c ){
                minDate = item.Start_date__c;
            }
            if( item.End_date__c != null && maxDate < item.End_date__c){
                maxDate = item.End_date__c;
            }
            if(item.RecordType.Name == cc_Messages.Sharing_Percent_RecordType_Global){
                item.Gross_Spending__c = 0;
                if(item.is_Xaxis__c){
                    salesXaxisTargetMap.put(item.User__c, item);
                }
                if( !salesGlobalTargetMap.containsKey(item.User__c)){
                    salesGlobalTargetMap.put(item.User__c, item);
                }
            }
            if(item.RecordType.Name == cc_Messages.Sharing_Percent_RecordType_Local && (item.Position__c == cc_Messages.Account_Executive || item.Position__c == cc_Messages.Account_Director ||                                  	
				item.Position__c == cc_Messages.Account_Supervisor || item.Position__c ==cc_Messages.Account_Manager || item.Position__c == cc_Messages.Account_Admin
                || item.Name == cc_Messages.Total_Local || item.Name == cc_Messages.Ads_Total_Local)){
                  item.Gross_Spending__c = 0;
                   
                 if(item.Name == cc_Messages.Total_Local || item.Name == cc_Messages.Ads_Total_Local){
                     if( !salesLocalTargetMap.containsKey(item.Name) ){
                         salesLocalTargetMap.put(item.Name, item);   
                     }
                     continue;
                  }                                     
                   if(!salesLocalTargetMap.containsKey(item.User__c)){
                        salesLocalTargetMap.put(item.User__c, item);
                   }                                   
                	continue;
                                                   
            }
             if( item.RecordType.Name ==  cc_Messages.Sharing_Percent_RecordType_Is_Direct){
                string key = item.Name;
                item.Gross_Spending__c = 0;
                item.Spending_Share__c = 0;
                if( item.Name == cc_Messages.Total_Direct || item.Name == cc_Messages.Ads_Total_Direct){
                    key = item.Name;
                }
                else{
                    key = item.User__c;
                }
                if( !salesIsDirectTargetMap.containsKey(key)){
                    salesIsDirectTargetMap.put(key, item);
                }
                
            }
            if( item.RecordType.Name ==  cc_Messages.Sharing_Percent_RecordType_Industry)
            {
                item.Gross_Spending__c = 0;
                item.Spending_Share__c = 0;
                if(!salesIndustryTargetMap.containsKey(item.Name + '#' + item.Agency__c)){
                    salesIndustryTargetMap.put(item.Name + '#' + item.Agency__c, item);
                }
            }
        }
        //minDate = date.newInstance(2020, 01, 03);
        //maxDate = date.newInstance(2020, 01, 05);
        minDate = Datetime.newInstance(minDate.year(), minDate.month(), minDate.day(), 0,0,0);
        maxDate = Datetime.newInstance(maxDate.year(), maxDate.month(), maxDate.day(), 23,59,59);        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return  Database.getQueryLocator([select id, name, QC_Account__c,QC_Account__r.Name,Accounts__c,Accounts__r.Name,syn_date__c,
                                          Agency__c, Total_Spending__c,Industry__c, Sale__c,Sale__r.LastName,Sale__r.Name, Support__c,Support__r.LastName,Support__r.Name 
                                          from QC_Account_Data__c 
                                          where syn_date__c >=: minDate and syn_date__c<=:  maxDate and QC_Account__r.Type__c =: 'Normal' and QC_Account__r.ownerId !=: adminUserId and Total_Spending__c >0]);
    }
    global void execute(Database.BatchableContext bc, List<QC_Account_Data__c> scope){
        Set<Id> accIdSet = new Set<id>();
        Set<Id> qcAccountSet = new Set<Id>();
        for(QC_Account_Data__c item: scope){
            if( !string.isBlank( item.Accounts__c)){
                accIdSet.add(item.Accounts__c);
            }
            if( item.Agency__c == cc_Messages.Agency_Local_Agency && !string.isBlank(item.QC_Account__c)){
                qcAccountSet.add(item.QC_Account__c);
            }
        }
         List<QC_Account__c> qcAccountList = [select id, name, industry__c, (select id, name, Spending_Percent1__c,Cash_Percent__c, Sale__c,Sale__r.name, QC_Account__r.industry__c,QC_Account__r.name   from Sharing_Percent__r) 
                                             from QC_Account__c where id in:qcAccountSet];
        Map<string, List<Sharing_Percent__c>> qcAccountShare = new Map<string, List<Sharing_Percent__c>>();
        for(QC_Account__c item: qcAccountList ){
            List<Sharing_Percent__c> sharingPercentList = new  List<Sharing_Percent__c>();
            if(!qcAccountShare.containsKey(item.id)){
                if(item.Sharing_Percent__r != null && item.Sharing_Percent__r.size() > 0){
                    for(Sharing_Percent__c item1: item.Sharing_Percent__r){
                        if(item1.Spending_Percent1__c != null){
                            sharingPercentList.add(item1);
                        }
                    }
                    if(sharingPercentList.size() > 0){
                        qcAccountShare.put(string.valueOf(item.id), sharingPercentList);
                    }
                }
            }
        }
        List<Account> accList = [select id, name, (select id,  Percent__c, UserId,User.name  from AccountTeamMembers ) 
                                 from account where id in:accIdSet];
        Map<string, List<AccountTeamMember>> accShare = new Map<string, List<AccountTeamMember>>();
        for(Account item: accList ){
            List<AccountTeamMember> sharingPercentList = new  List<AccountTeamMember>();
            if(!accShare.containsKey(item.id)){
                if(item.AccountTeamMembers != null && item.AccountTeamMembers.size() > 0){
                    for(AccountTeamMember item1: item.AccountTeamMembers){
                        if(item1.Percent__c != null){
                            sharingPercentList.add(item1);
                        }
                    }
                    if(sharingPercentList.size() > 0){
                        accShare.put(string.valueOf(item.id), sharingPercentList);
                    }
                }
            }
        }
        
        for(QC_Account_Data__c item: scope){
            if(  string.isBlank(item.Agency__c) || item.Agency__c == 'Other' || string.isBlank(item.Sale__c)){
                if(!qcAccountErrorSet.contains( item.QC_Account__c + '###' + item.QC_Account__r.Name )){
                    qcAccountErrorSet.add(item.QC_Account__c + '###' + item.QC_Account__r.Name);
                }
                continue;
            }
            item.syn_date__c = item.syn_date__c.addHours(7);
            if(item.Agency__c == cc_Messages.Agency_Global_Agency){
                
                List<AccountTeamMember> sharingPercentList = accShare.get(item.Accounts__c);
                if(sharingPercentList != null && sharingPercentList.size() > 0){
                    for(AccountTeamMember sp: sharingPercentList){
                        if(item.Accounts__r.Name == setting.Xaxis_Name__c){
                            Sale_target_v1__c stShare = salesXaxisTargetMap.get(sp.userId);
                        	calculateSpendingShare(stShare, accNumber, item,sp.userId , sp.Percent__c);
                        }
                        else{
                            Sale_target_v1__c stShare = salesGlobalTargetMap.get(sp.userId);
                        	calculateSpendingShare(stShare, accNumber, item,sp.userId , sp.Percent__c);
                        }
                    }
                   continue;
                }
                Sale_target_v1__c st = salesGlobalTargetMap.get(item.Sale__c);
                calculateSpending(st, item, item.Sale__r.Name);
                continue;
            }
            
            if( item.Agency__c == cc_Messages.Agency_Local_Agency){
                Sale_target_v1__c st = salesLocalTargetMap.get(item.Sale__c);
                calculateSpending(st, item, item.Sale__r.Name);
                if( !string.isBlank(item.Industry__c)){
                    Sale_target_v1__c st1 = salesIndustryTargetMap.get(item.Industry__c + '#' + cc_Messages.Agency_Local_Agency);
                	calculateSpending(st1, item, item.Industry__c + '#' + cc_Messages.Agency_Local_Agency);
                }
                List<Sharing_Percent__c> sharingPercentList = qcAccountShare.get(item.QC_Account__c);
                if(sharingPercentList != null && sharingPercentList.size() > 0){
                    for(Sharing_Percent__c sp: sharingPercentList){
                        Sale_target_v1__c stShare = salesIsDirectTargetMap.get(sp.Sale__c);
                        calculateSpendingShare(stShare,qcAccountNumber, item,sp.Sale__c , sp.Spending_Percent1__c);
                        if( !string.isBlank(item.Industry__c)){
                            Sale_target_v1__c stIndustryShare = salesIndustryTargetMap.get(item.Industry__c + '#' + cc_Messages.Agency_Direct_Business);
                            calculateSpendingShare(stIndustryShare,qcAccountNumber, item,item.Industry__c + '#' + cc_Messages.Agency_Direct_Business , sp.Spending_Percent1__c);
                        }
                    }
                }
            }
            if( item.Agency__c == 'Client' || item.Agency__c == 'PersonAccount' || item.Agency__c == 'Person Account'){
                Sale_target_v1__c st = salesIsDirectTargetMap.get(item.Sale__c);
                calculateSpending(st, item, item.Sale__r.Name);
                if( !string.isBlank(item.Industry__c)){
                    Sale_target_v1__c st1 = salesIndustryTargetMap.get(item.Industry__c + '#' + cc_Messages.Agency_Direct_Business);
                    calculateSpending(st1, item, item.Industry__c + '#' + cc_Messages.Agency_Direct_Business);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext bc){
        if( qcAccountErrorSet.size() >0){
            cc_Util.writeLog('Spending sharing - qc account are incorrect', '', system.JSON.serialize(qcAccountErrorSet));
        }
         if( saleTargetErrorSet.size() >0){
            cc_Util.writeLog('Spending saletargets - are missing', '', system.JSON.serialize(saleTargetErrorSet));
        }
        for(string item: accNumber.keySet()){
            decimal temp = accNumber.get(item);
            String[] M = item.split('_');
            string key = M[0];
            decimal percent = decimal.valueOf(M[1]);
            Sale_target_v1__c stShare;
            if(item.contains(setting.Xaxis_Name__c)){
                stShare = salesXaxisTargetMap.get(key);
            }
            else{
                stShare = salesGlobalTargetMap.get(key);
            }
            if( stShare != null){
                stShare.Gross_Spending__c = stShare.Gross_Spending__c == null? 0: stShare.Gross_Spending__c;
            	stShare.Gross_Spending__c += temp * percent/100;
            }
        }
        for(string item: qcAccountNumber.keySet()){
            decimal temp = qcAccountNumber.get(item);
            String[] M = item.split('_');

            string key = M[0];
            decimal percent = decimal.valueOf(M[1]);
            Sale_target_v1__c stShare = salesIsDirectTargetMap.get(key);
            if( stShare != null){
                stShare.Spending_Share__c = stShare.Spending_Share__c == null? 0: stShare.Spending_Share__c;
            	stShare.Spending_Share__c += temp * percent/100;
            }
            Sale_target_v1__c stIndustryShare = salesIndustryTargetMap.get(key);
            if( stIndustryShare != null){
                stIndustryShare.Spending_Share__c = stIndustryShare.Spending_Share__c == null? 0: stIndustryShare.Spending_Share__c;
            	stIndustryShare.Spending_Share__c += temp * percent/100;
            }
           
        }
        
        update salesLocalTargetMap.values();
        update salesIndustryTargetMap.values();
        update salesIsDirectTargetMap.values();
        update salesGlobalTargetMap.values();
        update salesXaxisTargetMap.values();
    }
     public void calculateSpending(Sale_target_v1__c st, QC_Account_Data__c item, string key){
        if( st == null  ){
            if(!saleTargetErrorSet.contains(key))
            	saleTargetErrorSet.add(key);
            return;
        }
         if( st.Start_date__c <= item.syn_date__c && st.End_datetime__c >= item.syn_date__c ){
             st.Gross_Spending__c = st.Gross_Spending__c == null ? 0: st.Gross_Spending__c;
             st.Gross_Spending__c += item.Total_Spending__c;
         }
    }
    public void calculateSpendingShare(Sale_target_v1__c st, Map<string, decimal> mapNumber,  QC_Account_Data__c item, string key, Decimal percent){
        if( st == null  ){
            if(!saleTargetErrorSet.contains(key))
                saleTargetErrorSet.add(key);
            return;
        }
        if( st.Start_date__c <= item.syn_date__c && st.End_datetime__c >= item.syn_date__c ){
            string key1 = key + '_' + percent;
            if( item.Accounts__r.Name == setting.Xaxis_Name__c){
                key1 += '_' + setting.Xaxis_Name__c;
            }
            if( !mapNumber.containsKey(key1)){
                mapNumber.put(key1, item.Total_Spending__c);
            }
            else{
                decimal temp = mapNumber.get(key1);
                temp += item.Total_Spending__c;
                mapNumber.remove(key1);
                mapNumber.put(key1, temp);
            }
         }
    }
}