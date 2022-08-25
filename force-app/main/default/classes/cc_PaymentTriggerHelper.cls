global class cc_PaymentTriggerHelper {    

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Method to get recordtype Id from recordtype Name
    * @return   Id
    *********************************************************************************************************/
    public id getRecordId(string recordTypeName, List<RecordType> pamentRecordTypeList){
        for(RecordType item: pamentRecordTypeList){
            if(item.name == recordTypeName )
            {
                return item.id;
            }
        }
        return '';
    }
    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Dispatch function to rollup Balance amount for qc account 
    * @return   void
    *********************************************************************************************************/
    public static void attemptCalculateBalaneOnQCAccount(Set<String> qcIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnRCalculateBalaneOnQC(qcIds);
        }else {
            attemptSycnRCalculateBalaneOnQC(qcIds);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Dispatch function to rollup Real payment amount for HOM 
    * @return   void
    *********************************************************************************************************/
    public static void attemptRollupPaymentForHOM(Set<String> homIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnRollupForHOM(homIds);
        }else {
            attemptSycnRollupForHOM(homIds);
        }
    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Dispatch function to calculation paid amount for Adavance payment
    * @return   void
    *********************************************************************************************************/
    public static void attemptCalculateParrentPaidAmount(Set<String> pyIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnRollupPaidAmount(pyIds);
        }else {
            attemptSycnRollupPaidAmount(pyIds);
        }
    }



    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Dispatch function to calculation transfer amount for parrent payment
    * @return   void
    *********************************************************************************************************/    
    public static void attemptCalculateTransferredAmount(Set<String> pyIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnRollupRemainingAmount(pyIds);
        }else {
            attemptSycnRollupTransferredAmount(pyIds);
        }
    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Dispatch function to recorded support user on QC Account
    * @return   void
    *********************************************************************************************************/
    public static void attemptUpdateBlankSupport(Set<String> qcIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnUpdateBlankSupport(qcIds);
        }else {
            attemptSycnUpdateBlankSupport(qcIds);
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   Dispatch function to automate set support user on QC Account with blank support by industry
    * @return   void
    *********************************************************************************************************/
    public static void attemptUpdateDefaultSupport(Set<String> dfqcIds){
        if(!System.isBatch() && !System.isFuture()){
            attemptAsycnUpdateDefaultSupport(dfqcIds);
        }else {
            attemptSycnUpdateDefaultSupport(dfqcIds);
        }
    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   future method use to calulation balance for QC Account
    * @return   void
    *********************************************************************************************************/    
    @future
    public static void attemptAsycnRCalculateBalaneOnQC(Set<String> qcAccIds){
        attemptSycnRCalculateBalaneOnQC(qcAccIds);
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   method use to calulation balance for QC Account
    * @return   void
    *********************************************************************************************************/  
    public static void attemptSycnRCalculateBalaneOnQC(Set<String> qcAccIds){
        List<QC_Account__c> upQCAccs = new List<QC_Account__c>();
        
        for(AggregateResult arr: [SELECT QC_Account__c QC_Account__c,  SUM(Real_Money_Balance__c) Real_Money_Balance__c, SUM(Real_Money_Dept__c) Real_Money_Dept__c 
                                        FROM Payment__c 
                                        WHERE QC_Account__c IN :qcAccIds 
                                        AND Stage__c =: PaymentConstant.STAGE_DONE
                                        AND Is_Standard__c = True
                                        AND ( RecordType.DeveloperName =: PaymentConstant.RECORDTYPE_REAL_PAYMENT
                                              OR  RecordType.DeveloperName =: PaymentConstant.RECORDTYPE_TRANSFER_PAYMENT)
                                        GROUP BY QC_Account__c]){
                                        
            String qcAccId =  (String)arr.get('QC_Account__c');                
            Double realMoneyBalance = (Double)arr.get('Real_Money_Balance__c');
            Double realMoneyDept = (Double)arr.get('Real_Money_Dept__c');

            if(!String.isBlank(qcAccId)){
                QC_Account__c qcAcc = new QC_Account__c();
                qcAcc.Id = qcAccId;
                qcAcc.Real_Money_Dept__c = realMoneyDept;
                qcAcc.Real_Money_Balance__c = realMoneyBalance;                

                upQCAccs.add(qcAcc);
            }
        }

        System.debug('upQCAccs=> ' + upQCAccs.size());
        if(upQCAccs.size() > 0){
            update upQCAccs;
        }
    }
    

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   future method to automate set support user on QC Account with blank support
    * @return   void
    *********************************************************************************************************/    
    @future
    public static void attemptAsycnUpdateDefaultSupport(Set<String> dfqcIds){
        attemptSycnUpdateDefaultSupport(dfqcIds);
    }   

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   method to automate set support user on QC Account with blank support
    * @return   void
    *********************************************************************************************************/  
    public static void attemptSycnUpdateDefaultSupport(Set<String> dfqcIds){
        List<QC_Account__c> upQCAccs = new List<QC_Account__c>();
        AdsOpManager__mdt defaltSetting = new AdsOpManager__mdt();
        defaltSetting = [SELECT FinalAmount__c, Industry__c, ManagerId__c, IsDefault__c FROM AdsOpManager__mdt WHERE Active__c = true AND IsDefault__c = true LIMIT 1];

        for(QC_Account__c qc : [SELECT Id, Industry__c, Support__c FROM QC_Account__c WHERE Id IN :dfqcIds]){
            if(String.isBlank(qc.Support__c)){
                if(defaltSetting != null){
                    String hotlinemanagerId = defaltSetting.ManagerId__c;
                    if(!String.isBlank(hotlinemanagerId)){
                        qc.Support__c = hotlinemanagerId;
    
                        upQCAccs.add(qc);
                    }   
                }
            }
        }

        System.debug('upQCAccs=> ' + upQCAccs.size());
        if(upQCAccs.size() > 0){
            update upQCAccs;
        }
    }



    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   future method to automate set support user on QC Account with blank support by industry
    * @return   void
    *********************************************************************************************************/  
    @future
    public static void attemptAsycnUpdateBlankSupport(Set<String> qcIds){
        attemptSycnUpdateBlankSupport(qcIds);
    }   

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   method to automate set support user on QC Account with blank support by industry
    * @return   void
    *********************************************************************************************************/  
    public static void attemptSycnUpdateBlankSupport(Set<String> qcIds){
        List<QC_Account__c> upQCAccs = new List<QC_Account__c>();
        Map<String,AdsOpManager__mdt> mapSetting = new Map<String,AdsOpManager__mdt>();
        AdsOpManager__mdt defaltSetting = new AdsOpManager__mdt();


        for (AdsOpManager__mdt adm: [SELECT FinalAmount__c, Industry__c, ManagerId__c, IsDefault__c FROM AdsOpManager__mdt WHERE Active__c = true]){
            mapSetting.put(adm.Industry__c, adm);

            if(adm.IsDefault__c){
                defaltSetting = adm;
            }
        }

        for(QC_Account__c qc : [SELECT Id, Industry__c, Support__c FROM QC_Account__c WHERE Id IN :qcIds AND Industry__c != '' ]){
            if(!String.isBlank(qc.Industry__c) && String.isBlank(qc.Support__c)){
                AdsOpManager__mdt setting = mapSetting.get(qc.Industry__c);
                if(setting != null){
                    String adsOpmanagerId = setting.ManagerId__c;

                    if(!String.isBlank(adsOpmanagerId)){
                        qc.Support__c = adsOpmanagerId;
                        upQCAccs.add(qc);
                    }                    
                }else{
                    if(defaltSetting != null){
                        String hotlinemanagerId = defaltSetting.ManagerId__c;
                        if(!String.isBlank(hotlinemanagerId)){
                            qc.Support__c = hotlinemanagerId;
    
                            upQCAccs.add(qc);
                        }                         
                    }
                }
            }
        }

        System.debug('upQCAccs=> ' + upQCAccs.size());
        if(upQCAccs.size() > 0){
            update upQCAccs;
        }

    }


    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   future method to rollup transfer amount for parrent payment
    * @return   void
    *********************************************************************************************************/  
    @future
    public static void attemptAsycnRollupRemainingAmount(Set<String> pyIds){
        attemptSycnRollupTransferredAmount(pyIds);
    }
    
    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   method to rollup transfer amount for parrent payment
    * @return   void
    *********************************************************************************************************/  
    public static void attemptSycnRollupTransferredAmount(Set<String> pyIds){
        cc_Payment_Setting__c pySetting = cc_Util.getPaymentSetting('ccpaymentsetting');        
        List<Payment__c> listPYtoUpdate = new List<Payment__c>();
        Set<String> pyWithoutChild = new Set<String>();

        if(pySetting != null){
            pyWithoutChild = pyIds;
            String recordType = pySetting.Transferred_Payment__c == null ? '': pySetting.Transferred_Payment__c;
            String[] sRecordType = recordType.split(';');

            if(sRecordType != null){
                System.debug('pyIds=>' + pyIds);
                Map<String,Payment__c> mapPayment = new Map<String,Payment__c>([SELECT Id, Transferred_Amount__c 
                                                                                            FROM Payment__c 
                                                                                            WHERE Id IN: pyIds]);
                
                for(AggregateResult arr: [SELECT Parent_Payment__c Parent_Payment__c,  SUM(Calcuate_Amount__c) Calcuate_Amount__c   
                                            FROM Payment__c 
                                            WHERE Parent_Payment__c IN :pyIds 
                                            AND Stage__c = 'Done'
                                            AND RecordType.DeveloperName IN :sRecordType
                                            GROUP BY Parent_Payment__c]){
                                        
                    String parentpyId =  (String)arr.get('Parent_Payment__c');                
                    Double totalPaymentAmount = (Double)arr.get('Calcuate_Amount__c');

                    if(mapPayment.containsKey(parentpyId) && !String.isBlank(parentpyId)){
                        Payment__c py = mapPayment.get(parentpyId);
                        py.Transferred_Amount__c = totalPaymentAmount ==null? 0: totalPaymentAmount;

                        listPYtoUpdate.add(py);

                        pyWithoutChild.remove(parentpyId);
                    }
                }

                if(pyWithoutChild.size() > 0){
                    
                    for(String pyId: pyWithoutChild){
                        Payment__c py = new Payment__c();
                        py.Id = pyId;
                        py.Transferred_Amount__c = 0;
                    }
                }

                if(listPYtoUpdate.size() > 0){
                    update listPYtoUpdate;
                }
            }
        }
    }



    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   future method to rollup Paid Amount for HOM
    * @return   void
    *********************************************************************************************************/  
    @future
    public static void attemptAsycnRollupForHOM(Set<String> homIds){
        attemptSycnRollupForHOM(homIds);
    }
    
    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   method to rollup Paid Amount for HOM
    * @return   void
    *********************************************************************************************************/  

    public static void attemptSycnRollupForHOM(Set<String> homIds){
        List<HandOver_Minute__c> listHOMtoUpdate = new List<HandOver_Minute__c>();
        cc_Payment_Setting__c pySetting = cc_Util.getPaymentSetting('ccpaymentsetting');   
        Set<String> homWithoutPY = new Set<String>();

        System.debug('homIds.size()' + homIds.size() + 'homIds=>' + homIds);     
        if(pySetting != null && homIds!= null && homIds.size() > 0){
            String recordType = pySetting.HOM_Calculation__c;
            String[] sRecordType = recordType.split(';');  
            System.debug('sRecordType=>' + sRecordType);     
            if(sRecordType != null ){            
                homWithoutPY = homIds;
                Map<String,HandOver_Minute__c> mapHOM = new Map<String,HandOver_Minute__c>([SELECT Id, Total_Payment_Amount__c 
                                                                                            FROM HandOver_Minute__c 
                                                                                            WHERE Id IN: homIds]);

                System.debug('homWithoutPY' + homWithoutPY + 'listHOMtoUpdate=>' + listHOMtoUpdate.size());              
                for(AggregateResult arr: [SELECT HandOver_Minutes__c HandOver_Minutes__c, SUM(Calcuate_Amount__c) Calcuate_Amount__c , SUM(Final_Amount__c ) Final_Amount__c  
                                            FROM Payment__c 
                                            WHERE HandOver_Minutes__c IN :homIds 
                                            AND Stage__c = 'Done'
                                            AND RecordType.DeveloperName IN :sRecordType
                                            GROUP BY HandOver_Minutes__c]){
                                            
                    String homId =  (String)arr.get('HandOver_Minutes__c');
                    Double totalPaymentAmount = (Double)arr.get('Calcuate_Amount__c');
                    Double Final_Amount = (Double)arr.get('Final_Amount__c');

                    System.debug('totalPaymentAmount=>' + totalPaymentAmount +  'Final_Amount>' + Final_Amount + 'homId=>' + homId + 'mapHOM=>' + mapHOM + 'homIds=>' + homIds);                     

                                
                    if(mapHOM.containsKey(homId) && !String.isBlank(homId)){

                        HandOver_Minute__c hom = mapHOM.get(homId);
                        hom.Total_Payment_Amount__c = totalPaymentAmount == null? 0: totalPaymentAmount;

                        listHOMtoUpdate.add(hom);

                        homWithoutPY.remove(homId);
                    }
                }

                System.debug('homWithoutPY' + homWithoutPY + 'listHOMtoUpdate=>' + listHOMtoUpdate.size());       
                if( homWithoutPY != null){
                    for (String homId : homWithoutPY){
                        if(!String.isBlank(homId)){
                            HandOver_Minute__c hom = new HandOver_Minute__c();
                            hom.Id = homId;
                            hom.Total_Payment_Amount__c = 0;
    
                            listHOMtoUpdate.add(hom);
                        }                       
                    }
                }

                System.debug('listHOMtoUpdate=>' + listHOMtoUpdate);   
                if(listHOMtoUpdate.size() > 0){
                    update listHOMtoUpdate;
                }
            }
        }
    }
    

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   future method to rollup Paid Amount for advance Payment
    * @return   void
    *********************************************************************************************************/  
    @future
    public static void attemptAsycnRollupPaidAmount(Set<String> pyIds){
        attemptSycnRollupPaidAmount(pyIds);
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 August 27
    * @description   method to rollup Paid Amount for advance Payment
    * @return   void
    *********************************************************************************************************/  
    public static void attemptSycnRollupPaidAmount(Set<String> pyIds){   
        cc_Payment_Setting__c pySetting = cc_Util.getPaymentSetting('ccpaymentsetting');        
        List<Payment__c> listPYtoUpdate = new List<Payment__c>();   
        Set<String> pyWithoutChild = new Set<String>();

        if(pySetting != null){

            String recordType = pySetting.Paid_Amount_Calculation__c;
            String[] sRecordType = recordType.split(';');     
            
            if(sRecordType !=null){
                pyWithoutChild = pyIds;
                System.debug('pyIds=>' + pyIds);
                Map<String,Payment__c> mapPayment = new Map<String,Payment__c>([SELECT Id, Paid_amount__c 
                                                                                            FROM Payment__c 
                                                                                            WHERE Id IN: pyIds]);
            
                for(AggregateResult arr: [SELECT Parent_Payment__c Parent_Payment__c,  SUM(Calcuate_Amount__c) Calcuate_Amount__c   
                                            FROM Payment__c 
                                            WHERE Parent_Payment__c IN :pyIds 
                                            AND Stage__c = 'Done'
                                            AND RecordType.DeveloperName IN :sRecordType
                                            GROUP BY Parent_Payment__c]){
                                        
                    String parentpyId =  (String)arr.get('Parent_Payment__c');                
                    Double totalPaymentAmount = (Double)arr.get('Calcuate_Amount__c');

                    if(mapPayment.containsKey(parentpyId) && !String.isBlank(parentpyId)){
                        Payment__c py = mapPayment.get(parentpyId);
                        py.Paid_amount__c = totalPaymentAmount ==null? 0: totalPaymentAmount;

                        listPYtoUpdate.add(py);
                        pyWithoutChild.remove(parentpyId);
                    }
                }

                if(pyWithoutChild.size() > 0){
                    
                    for(String pyId: pyWithoutChild){
                        Payment__c py = new Payment__c();
                        py.Id = pyId;
                        py.Transferred_Amount__c = 0;
                    }
                }

                if(listPYtoUpdate.size() > 0){
                    update listPYtoUpdate;
                }
            }
        }
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method Init field value on Payment base on QC Account - On Trigger Insert
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/
    public static  Map<Id,QC_Account__c> SetRelatedQCAccountOnInsert(List<Payment__c> payments){
        Set<String> qcAccountIdSet = new Set<String>();
        Map<Id, qc_Account__c> qcAccountMap;
        Map<Id, Client_Sharing_Detail__c> mapClientSharing = new Map<Id, Client_Sharing_Detail__c>();
        Map<Id, Date> mapQCAccount = new Map<Id, Date>();

        for(Payment__c payment: payments){
            if( payment.Stage__c == PaymentConstant.STAGE_DONE 
                || payment.Stage__c == PaymentConstant.STAGE_FAILURE){
                qcAccountIdSet.add(payment.QC_Account__c);  
                mapQCAccount.put(payment.QC_Account__c, payment.Effective_date__c.date());       
            }
        }       
            
        if(qcAccountIdSet.size() > 0){            
            for(Client_Sharing_Detail__c cl : [SELECT QC_Account__c, Id, Share_To__c, Start_Date__c, End_Date__c
                                            FROM Client_Sharing_Detail__c 
                                            WHERE QC_Account__c IN: qcAccountIdSet 
                                            AND Status__c =: ClientSharingConstant.STATUS_IN_PROGRESS]){

                Date effdt = mapQCAccount.get(cl.QC_Account__c);
                if(effdt != null && cl.Start_Date__c <=  effdt && cl.End_Date__c >= effdt){
                    mapClientSharing.put(cl.QC_Account__c, cl);
                }
            }

            qcAccountMap = new Map<Id, qc_Account__c>([SELECT Id,Name,Real_Money_Balance__c,Real_Money_Dept__c,
                                                                Industry__c, Sales__c, Support__c, Source__c, Agency__c, 
                                                                ownerId, Type__c
                                                                FROM qc_Account__c WHERE Id IN: qcAccountIdSet]);
        }

        for(Payment__c payment: (List<Payment__c>)Trigger.new){
            if( payment.Stage__c == PaymentConstant.STAGE_DONE ){
                qc_Account__c qcTemp = qcAccountMap.get(payment.QC_Account__c);
                payment.industry__c = qcTemp.Industry__c;                
                payment.support__c = qcTemp.Support__c;
                payment.Source__c = qcTemp.Source__c;
                payment.Agency__c = qcTemp.Agency__c; 

                //Recorded Payment for Sale
                Client_Sharing_Detail__c clientShare = mapClientSharing.get(payment.QC_Account__c);
                if(clientShare != null){
                    payment.sale__c = clientShare.Share_To__c;
                    payment.IsCrossSelling__c = true;
                }else{
                    payment.sale__c = qcTemp.Sales__c;
                }
            }
        }

        return qcAccountMap == null? new Map<Id, qc_Account__c>(): qcAccountMap;
    }

    /********************************************************************************************************
    * @author        CocCoc - THACHLD
    * @date          2021 Dec 15
    * @description   Method Init field value on Payment base on QC Account - On Trigger Update
    * @return   Map<Id,QC_Account__c>
    *********************************************************************************************************/

    public static Map<Id,QC_Account__c> SetRelatedQCAccountOnUpdate(List<Payment__c> payments, Map<Id, Payment__c> oldMap){
        Set<String> qcIds = new Set<String>();
        Set<String> donePyQCIds = new Set<String>();
        Map<Id, QC_Account__c> qcAccountMap;
        Map<Id, Client_Sharing_Detail__c> mapClientSharing = new Map<Id, Client_Sharing_Detail__c>();
        Map<Id, Date> mapQCAccount = new Map<Id, Date>();

        for(Payment__c payment: payments){
            Payment__c oldPayment = oldMap.get(payment.Id);

            if( payment.Stage__c != oldPayment.Stage__c
                && payment.Stage__c == PaymentConstant.STAGE_DONE){
                qcIds.add(payment.QC_Account__c);  
                mapQCAccount.put(payment.QC_Account__c, payment.Effective_date__c.date());    
                donePyQCIds.add(payment.QC_Account__c);
            }

            if(payment.isApproval__c != oldPayment.isApproval__c && (payment.isApproval__c == 1 || payment.isApproval__c == -1) ){                
                qcIds.add(payment.QC_Account__c);  
            }
        }       
            
        if(donePyQCIds.size() > 0){            
            for(Client_Sharing_Detail__c cl : [SELECT QC_Account__c, Id, Share_To__c, Start_Date__c, End_Date__c
                                            FROM Client_Sharing_Detail__c 
                                            WHERE QC_Account__c IN: donePyQCIds 
                                            AND Status__c =: ClientSharingConstant.STATUS_IN_PROGRESS]){

                Date effdt = mapQCAccount.get(cl.QC_Account__c);
                System.debug('effdt=>' + effdt);
                if(effdt != null && cl.Start_Date__c <=  effdt && cl.End_Date__c >= effdt){
                    mapClientSharing.put(cl.QC_Account__c, cl);
                }
            }
        }

        if(qcIds.size() > 0){            
            qcAccountMap = new Map<Id, qc_Account__c>([SELECT Id,Name,Real_Money_Balance__c,Real_Money_Dept__c,
                                                                Industry__c, Sales__c, Support__c, Source__c, Agency__c, 
                                                                OwnerId, Type__c
                                                                FROM QC_Account__c WHERE Id IN: qcIds]);
        }       

        for(Payment__c payment: (List<Payment__c>)Trigger.new){
            Payment__c oldPayment = oldMap.get(payment.Id);

            if( payment.Stage__c != oldPayment.Stage__c
                && payment.Stage__c == PaymentConstant.STAGE_DONE ){
                qc_Account__c qcTemp = qcAccountMap.get(payment.QC_Account__c);
                payment.industry__c = qcTemp.Industry__c;                
                payment.support__c = qcTemp.Support__c;
                payment.Source__c = qcTemp.Source__c;
                payment.Agency__c = qcTemp.Agency__c; 

                //Recorded Payment for Sale
                Client_Sharing_Detail__c clientShare = mapClientSharing.get(payment.QC_Account__c);
                if(clientShare != null){
                    payment.sale__c = clientShare.Share_To__c;
                    payment.IsCrossSelling__c = true;
                }else{
                    payment.sale__c = qcTemp.Sales__c;
                }
            }
        }

        return qcAccountMap == null? new Map<Id, qc_Account__c>(): qcAccountMap;
    }
}