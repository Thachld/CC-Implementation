global class cc_KPI_Payment_Batch implements Database.Batchable<sObject>, Database.Stateful{
    public string realPaymentRecordTypeId = '0120o0000017b2p'; //	Real Payment
    public string standardPayment = '0120o000001jwrz'; //Standard payment
    public string adminUserId = '0050o00000XLyrMAAT';
    public datetime minDate {get;set;}
    public datetime maxDate {get;set;}
    global set<string> qcAccountErrorSet;
    global Map<string,Sale_target_v1__c> salesLocalTargetMap;
    global Map<string,Sale_target_v1__c> salesGlobalTargetMap;
    global Map<string,Sale_target_v1__c> salesIndustryTargetMap;
    global Map<string,Sale_target_v1__c> salesIsDirectTargetMap;
    global set<string> saleTargetErrorSet;
    
    global Map<string, decimal> qcAccountNumber;
    
    
    public cc_KPI_Payment_Batch(string strDate){
        qcAccountErrorSet = new set<string>();
        saleTargetErrorSet = new set<string>();
        salesLocalTargetMap = new Map<string,Sale_target_v1__c>();
        salesGlobalTargetMap = new Map<string,Sale_target_v1__c>();
        salesIsDirectTargetMap = new Map<string,Sale_target_v1__c>();
        salesIndustryTargetMap = new Map<string,Sale_target_v1__c>();
        qcAccountNumber = new Map<string,Decimal>();
        date dtToday = date.today();
        if( !string.isBlank(strDate)){
            string[] M = strDate.split('/');
            dtToday = date.NewInstance(integer.valueOf(M[2]), integer.valueOf(M[1]),integer.valueOf(M[0]));
        }
        minDate = dtToday;
        maxDate = dtToday;
        
        List<Sale_target_v1__c> salesTargetList = [select id,Name,Agency__c,Calculate_fomular__c,End_date__c,Gross_Spending__c,Gross_Spending_KPI__c,
                                                   Industry__c,Leader__c,Mannually_Calculate__c,Position__c,Start_date__c,User__c, is_Xaxis__c,
                                                   RecordType.Name ,  payment_share__c,  Payment__c , Payment_share_for_KPI__c , End_datetime__c           
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
                item.Payment__c = 0;
                if( !salesGlobalTargetMap.containsKey(item.User__c)){
                    salesGlobalTargetMap.put(item.User__c, item);
                }
            }
            if(item.RecordType.Name == cc_Messages.Sharing_Percent_RecordType_Local && (item.Position__c == cc_Messages.Account_Executive || item.Position__c == cc_Messages.Account_Director ||                                  	
				item.Position__c == cc_Messages.Account_Supervisor || item.Position__c ==cc_Messages.Account_Manager || item.Position__c == cc_Messages.Account_Admin
                || item.Name == cc_Messages.Total_Local || item.Name == cc_Messages.Ads_Total_Local)){
                  item.Payment__c = 0;
                   
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
                item.Payment__c = 0;
                item.payment_share__c = 0;
				item.Payment_share_for_KPI__c = 0;
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
                item.Payment__c = 0;
                item.payment_share__c = 0;
                if(!salesIndustryTargetMap.containsKey(item.Name + '#' + item.Agency__c)){
                    salesIndustryTargetMap.put(item.Name + '#' + item.Agency__c, item);
                }
            }
            
        }
        minDate = Datetime.newInstance(minDate.year(), minDate.month(), minDate.day(), 0,0,0);
        maxDate = Datetime.newInstance(maxDate.year(), maxDate.month(), maxDate.day(), 23,59,59);
            
		system.debug('debug#local:' + salesLocalTargetMap);        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
       
        return   Database.getQueryLocator([select id, name,  Effective_date__c,Stage__c, Final_Amount__c,Amount__c, QC_Account__c,QC_Account__r.Name,
                                           Sale__r.name, 
                                           Sale__c, support__c, Industry__c,Agency__c
                                           from Payment__c 
                                           where Stage__c =: 'Done' and Type__c =: 'INCOME' and 
                                           (recordtypeid =:realPaymentRecordTypeId or recordtypeid =: standardPayment)
                                           and Effective_date__c >=: minDate and Effective_date__c<=:  maxDate and QC_Account__r.Type__c =: 'Normal' and QC_Account__r.ownerId !=: adminUserId ]);
        
        //and Agency__c ='Global Agency'
    }
    global void execute(Database.BatchableContext bc, List<Payment__c> scope){
        //system.debug('debug#paymentSize: ' + scope.size());
        Set<string> qcAccountSet = new Set<string>();
        for(payment__c item: scope){
            if(!Test.isRunningTest() && item.Agency__c == cc_Messages.Agency_Global_Agency && (string.isBlank(item.Agency__c) || string.isBlank(item.Sale__c))){
                continue;
               
            }else{
                if( !Test.isRunningTest() &&  (string.isBlank(item.Agency__c) || string.isBlank(item.Sale__c) || string.isBlank(item.Industry__c))){
                    continue;
                }
            }
            qcAccountSet.add(item.QC_Account__c);
        }
        List<QC_Account__c> qcAccountList = [select id, name, industry__c, (select id, name, Spending_Percent1__c,Cash_Percent__c, Cash_Percent_for_KPI__c, Sale__c,Sale__r.name, QC_Account__r.industry__c,QC_Account__r.name   from Sharing_Percent__r) 
                                             from QC_Account__c where id in:qcAccountSet];
        Map<string, List<Sharing_Percent__c>> qcAccountShare = new Map<string, List<Sharing_Percent__c>>();
        for(QC_Account__c item: qcAccountList ){
            List<Sharing_Percent__c> sharingPercentList = new  List<Sharing_Percent__c>();
            if(!qcAccountShare.containsKey(item.id)){
                if(item.Sharing_Percent__r != null && item.Sharing_Percent__r.size() > 0){
                    for(Sharing_Percent__c item1: item.Sharing_Percent__r){
                        if(item1.Cash_Percent__c != null && item1.Cash_Percent_for_KPI__c != null){
                            sharingPercentList.add(item1);
                        }
                    }
                    if(sharingPercentList.size() > 0){
                        qcAccountShare.put(string.valueOf(item.id), sharingPercentList);
                    }
                }
            }
        }
        
        for(Payment__c item: scope){
            if(item.Agency__c == cc_Messages.Agency_Global_Agency){
                if(string.isBlank(item.Agency__c) || item.Agency__c == 'Other' || string.isBlank(item.Sale__c)){
                    qcAccountErrorSet.add(item.id + '###' + item.Name);
                    continue;
                }
                Sale_target_v1__c st = salesGlobalTargetMap.get(item.Sale__c);
                calculatePayment(st, item, item.Sale__r.Name);
                continue;
            }
            if( !Test.isRunningTest() && (string.isBlank(item.Agency__c) || item.Agency__c == 'Other' || string.isBlank(item.Sale__c) )){
                qcAccountErrorSet.add(item.id + '###' + item.Name);
                continue;
            }
            if(item.Agency__c == cc_Messages.Agency_Local_Agency){
                
                Sale_target_v1__c st = salesLocalTargetMap.get(item.Sale__c);
                calculatePayment(st, item, item.Sale__r.Name);
                Sale_target_v1__c st1 = salesLocalTargetMap.get(cc_Messages.Total_Local); 
                calculatePayment(st1, item,cc_Messages.Total_Local);
                Sale_target_v1__c st2 = salesLocalTargetMap.get(cc_Messages.Ads_Total_Local);
                calculatePayment(st2, item, cc_Messages.Ads_Total_Local);
                
                if( !string.isBlank(item.Industry__c)){
                    Sale_target_v1__c st3 = salesIndustryTargetMap.get(item.Industry__c + '#' + cc_Messages.Agency_Local_Agency);
                    calculatePayment(st3, item,item.Industry__c + '#' + cc_Messages.Agency_Local_Agency);
                }
                List<Sharing_Percent__c> sharingPercentList = qcAccountShare.get(item.QC_Account__c);
                if(sharingPercentList != null && sharingPercentList.size() > 0){
                    for(Sharing_Percent__c sp: sharingPercentList){
                        Sale_target_v1__c stShare = salesIsDirectTargetMap.get(sp.Sale__c);
                        calculatePaymentShare(stShare, item,sp.Sale__r.Name , sp.Cash_Percent__c, sp.Cash_Percent_for_KPI__c);
                        if( !string.isBlank(item.Industry__c)){
                            Sale_target_v1__c stIndustryShare = salesIndustryTargetMap.get(item.Industry__c + '#' + cc_Messages.Agency_Direct_Business);
                            calculatePaymentShare(stIndustryShare, item,item.Industry__c + '#' + cc_Messages.Agency_Direct_Business , sp.Cash_Percent__c, sp.Cash_Percent_for_KPI__c);
                        }
                    }
                   
                }
            }
            if(item.Agency__c == 'Client' || item.Agency__c == 'PersonAccount' || item.Agency__c == 'Person Account'){
                
                
                Sale_target_v1__c st1 = salesIsDirectTargetMap.get(cc_Messages.Total_Direct);
                calculatePayment(st1, item, cc_Messages.Total_Direct);
                Sale_target_v1__c st2 = salesIsDirectTargetMap.get(cc_Messages.Ads_Total_Direct);
                calculatePayment(st2, item, cc_Messages.Ads_Total_Direct);
                if( !string.isBlank(item.Industry__c)){
                    Sale_target_v1__c st3 = salesIndustryTargetMap.get(item.Industry__c + '#' + cc_Messages.Agency_Direct_Business);
                    calculatePayment(st3, item, item.Industry__c + '#' + cc_Messages.Agency_Direct_Business);
                }
                boolean CalculaforSaleOwner = true;
                List<Sharing_Percent__c> sharingPercentList = qcAccountShare.get(item.QC_Account__c);
                if(sharingPercentList != null && sharingPercentList.size() > 0){
                    decimal tempAmount = item.Final_Amount__c == null ? 0: item.Final_Amount__c;
                    for(Sharing_Percent__c sp: sharingPercentList){
                        if( sp.Cash_Percent__c != null && sp.Cash_Percent__c != 0){
                            item.Final_Amount__c = tempAmount * sp.Cash_Percent__c /100;
                            Sale_target_v1__c stShare = salesIsDirectTargetMap.get(sp.Sale__c);
                            calculatePayment(stShare, item, sp.Sale__r.name);
                            item.Final_Amount__c = tempAmount;
                            CalculaforSaleOwner = false;
                        }
                       
                    }
                }
                if(CalculaforSaleOwner){
                    Sale_target_v1__c st = salesIsDirectTargetMap.get(item.Sale__c);
                	calculatePayment(st, item, item.Sale__r.Name);
                }
               
            }
        }
    }
    global void finish(Database.BatchableContext bc){
         if( qcAccountErrorSet.size() >0){
            cc_Util.writeLog('Payment sharing - qc account are incorrect', '', system.JSON.serialize(qcAccountErrorSet));
        }
         if( saleTargetErrorSet.size() >0){
            cc_Util.writeLog('Payment saletargets - are missing', '', system.JSON.serialize(saleTargetErrorSet));
        }
        for(string item: qcAccountNumber.keySet()){
            decimal temp = qcAccountNumber.get(item);
            String[] M = item.split('_');

            string key = M[0];
            decimal percent = decimal.valueOf(M[1]);
            Sale_target_v1__c stShare = salesIsDirectTargetMap.get(key);
            if( stShare != null){
                stShare.payment_share__c = stShare.payment_share__c == null? 0: stShare.payment_share__c;
            	stShare.payment_share__c += temp * percent/100;
            }
            Sale_target_v1__c stIndustryShare = salesIndustryTargetMap.get(key);
            if( stIndustryShare != null){
                stIndustryShare.payment_share__c = stIndustryShare.payment_share__c == null? 0: stIndustryShare.payment_share__c;
            	stIndustryShare.payment_share__c += temp * percent/100;
            }
           
        }
        
        update salesLocalTargetMap.values();
        update salesIndustryTargetMap.values();
        update salesIsDirectTargetMap.values();
        update salesGlobalTargetMap.values();
    }
    public void calculatePayment(Sale_target_v1__c st, Payment__c item, string key){
        if( st == null  ){
            string key1 = key + ' ' + item.Agency__c + '  ' + 'c';
            if(!saleTargetErrorSet.contains(key1))
            	saleTargetErrorSet.add(key1);
            return;
        }
        
         if( st.Start_date__c <= item.Effective_date__c && st.End_datetime__c >= item.Effective_date__c ){
             st.Payment__c = st.Payment__c == null ? 0: st.Payment__c;
             st.Payment__c += item.Final_Amount__c;
         }
    }
    public void calculatePaymentShare(Sale_target_v1__c st, Payment__c item, string key, Decimal percent, Decimal percentforKPI){
        if( st == null  ){
             string key1 = key + ' ' + item.Agency__c + '  ' + 's';
            if(!saleTargetErrorSet.contains(key1))
            	saleTargetErrorSet.add(key1);
            return;
        }
        if( st.Start_date__c <= item.Effective_date__c && st.End_datetime__c >= item.Effective_date__c ){
            string key1 = key + '_' + percent;
            if( !qcAccountNumber.containsKey(key1)){
                qcAccountNumber.put(key1, item.Final_Amount__c);
            }
            else{
                decimal temp = qcAccountNumber.get(key1);
                temp += item.Final_Amount__c;
                qcAccountNumber.remove(key1);
                qcAccountNumber.put(key1, temp);
            }
			if(percentforKPI != null){
				st.Payment_share_for_KPI__c = st.Payment_share_for_KPI__c == null? 0: st.Payment_share_for_KPI__c;
				st.Payment_share_for_KPI__c += item.Final_Amount__c * percentforKPI /100;
			}
         }
    }
}