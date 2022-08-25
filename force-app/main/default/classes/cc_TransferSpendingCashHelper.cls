public with sharing class cc_TransferSpendingCashHelper {
    

    public static void attemptTransferdata(Set<String> rqIds){
        if(!System.isBatch() && !System.isFuture() && !System.isQueueable()){
            attemptAsyncTransferdata(rqIds);
        }else {
            attemptSyncTransferdata(rqIds);
        }
    }


    @future 
    public static void attemptAsyncTransferdata(Set<String> rqIds){
        attemptSyncTransferdata(rqIds);
    }


    public static void attemptSyncTransferdata(Set<String> rqIds){
        List<SObject> upadateRecord = new List<SObject>();
        List<Attachment> atts = new List<Attachment>();
        Map<String,List<String>> mapSpendingDatas = new Map<String,List<String>>();
        Map<String,List<String>> mapPaymentDatas = new Map<String,List<String>>();       

        List<Transfer_Account__c> requests = new List<Transfer_Account__c>();
        requests = [SELECT  Id, Transfer_Request__c, Transfer_Request__r.From_Sale__c , Transfer_Request__r.To_Sale__c, 
                            Transfer_Request__r.ToIndustry__c,Transfer_Request__r.FromIndustry__c,
                            Transfer_Request__r.From_Date__c, Transfer_Request__r.To_Date__c, QC_Account__c,
                            Transfer_Request__r.Transfer_Purpose__c, Transfer_Request__r.Transfer_Type__c, Transfer_Request__r.TransferObject__c,
                            Transfer_Request__r.Approval_Status__c, Transfer_Request__r.Status__c,  Transfer_Request__r.isIncludeIndustry__c 
                FROM Transfer_Account__c 
                WHERE Transfer_Request__r.Status__c != :TransferRequestConstant.STATUS_COMPLETED
                    AND Transfer_Request__r.Approval_Status__c = :TransferRequestConstant.APPROVAL_STATUS_APPROVED
                    AND Transfer_Request__c IN :rqIds 
                    WITH SECURITY_ENFORCED];

                
        if(requests.size() > 0){
            doTransfer(requests);
        }

    }


    public static void doTransfer(List<Transfer_Account__c> requests){
        List<SObject> upadateRecord = new List<SObject>();    
        Map<Id,QC_Account__c> mapQCAccountToUpdate = new Map<Id,QC_Account__c>();
        Map<Id,Payment__c> mapUpdatePayments = new Map<Id,Payment__c>();
        Map<Id,QC_Account_Data__c> mapUpdateQCData = new Map<Id,QC_Account_Data__c>();   
        Map<String,TransferSpendingCash__c> mapRequest = new Map<String,TransferSpendingCash__c>(); 
        List<Attachment> atts = new List<Attachment>();
        Map<String,List<String>> mapSpendingDatas = new Map<String,List<String>>();
        Map<String,List<String>> mapPaymentDatas = new Map<String,List<String>>(); 

        Map<String, List<QC_Account_Data__c>> mapSpending = new Map<String, List<QC_Account_Data__c>>();
        Map<String, List<Payment__c>> mapPayment = new Map<String, List<Payment__c>>();
        Date mindate = System.today();
        Date maxdate = System.today();
        Set<String> qcAccIds = new Set<String>();

        for(Transfer_Account__c rq : requests){
            if(!String.isBlank(rq.QC_Account__c) && 
                rq.Transfer_Request__r.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA){
                qcAccIds.add(rq.QC_Account__c);
            }

            if(rq.Transfer_Request__r.From_Date__c < mindate){
                mindate = rq.Transfer_Request__r.From_Date__c;
            }

            if(rq.Transfer_Request__r.To_Date__c > maxdate){
                maxdate = rq.Transfer_Request__r.To_Date__c;
            }
        }

        Datetime mindatetime = Datetime.newInstance(mindate.year(), mindate.month(), mindate.day(), 0,0,0);
        Datetime maxtetime = Datetime.newInstance(maxdate.year(), maxdate.month(), maxdate.day(), 23,59,59);

        //Get Spending Records
        if(qcAccIds.size() > 0){
            for( QC_Account_Data__c data: [SELECT Id, Sale__c, Industry__c, Support__c, Sale__r.Name, QC_Account__r.Name,
                                                    QC_Account__c, syn_date__c, Name, Total_Spending__c
                                                FROM QC_Account_Data__c 
                                                WHERE QC_Account__c IN :qcAccIds
                                                AND syn_date__c >= :mindatetime
                                                AND syn_date__c <= :maxtetime
                                                WITH SECURITY_ENFORCED]){
                if(mapSpending.containsKey(data.QC_Account__c)){
                    mapSpending.get(data.QC_Account__c).add(data);
                }else{
                    mapSpending.put(data.QC_Account__c, new List<QC_Account_Data__c>{data});
                }                                                   
            }

            //Get Payment Records
            for( Payment__c py: [SELECT Id, Sale__c, Name, EffectiveDate__c, QC_Account__r.Name, Final_Amount__c, Effective_Date__c,
                                    Industry__c, Support__c, QC_Account__c, Stage__c
                                    FROM Payment__c 
                                    WHERE QC_Account__c IN :qcAccIds
                                    AND Effective_Date__c >= :mindatetime
                                    AND Effective_Date__c <= :maxtetime
                                    WITH SECURITY_ENFORCED]){
                if(mapPayment.containsKey(py.QC_Account__c)){
                    mapPayment.get(py.QC_Account__c).add(py);
                }else{
                    mapPayment.put(py.QC_Account__c, new List<Payment__c>{py});
                }
            }
        }
            

        for (Transfer_Account__c rq : requests){
            
 
            Boolean isTransfer = false;
            if(!String.isBlank(rq.Transfer_Request__r.Transfer_Purpose__c) ){
                if(rq.Transfer_Request__r.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_OWNER){
                    if(!String.isBlank(rq.Transfer_Request__r.To_Sale__c)){
                        QC_Account__c qc = new QC_Account__c();
                        qc.Id = rq.QC_Account__c;
                        qc.OwnerId = rq.Transfer_Request__r.To_Sale__c;

                        mapQCAccountToUpdate.put(qc.Id,qc);
                        isTransfer = true;
                    }
                }else if(rq.Transfer_Request__r.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_ADS_OP){
                    if(!String.isBlank(rq.Transfer_Request__r.To_Sale__c)){
                        QC_Account__c qc = new QC_Account__c();
                        qc.Id = rq.QC_Account__c;
                        qc.Support__c = rq.Transfer_Request__r.To_Sale__c;

                        mapQCAccountToUpdate.put(qc.Id,qc);
                        isTransfer = true;
                    }


                }else if(rq.Transfer_Request__r.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA){  
                    if(!String.isBlank(rq.Transfer_Request__r.Transfer_Type__c) 
                        && !String.isBlank(rq.QC_Account__c)
                        && rq.Transfer_Request__r.From_Date__c != null
                        && rq.Transfer_Request__r.To_Date__c != null){

                        Datetime fromdatetime = Datetime.newInstance(rq.Transfer_Request__r.From_Date__c.year(), rq.Transfer_Request__r.From_Date__c.month(), rq.Transfer_Request__r.From_Date__c.day(), 0,0,0);
                        Datetime todatetime = Datetime.newInstance(rq.Transfer_Request__r.To_Date__c.year(), rq.Transfer_Request__r.To_Date__c.month(), rq.Transfer_Request__r.To_Date__c.day(), 23,59,59);
            
                        if(rq.Transfer_Request__r.Transfer_Type__c == TransferRequestConstant.TRANSFER_TYPE_SALE){
                            String [] objects = rq.Transfer_Request__r.TransferObject__c.trim().split(';');
                            // System.debug('objects=>' + objects);
                            if(objects.size() > 0){
                                
                                for(String obj: objects){
                                    if(obj == TransferRequestConstant.TRANSFER_OBJECT_SPENDING){   
                                        List<String>  fileSpendingDatas = new List<String>(); 
                                        List<QC_Account_Data__c> spendingDatas = mapSpending.get(rq.QC_Account__c);
                                        if(spendingDatas != null){                        
                                            for( QC_Account_Data__c data: spendingDatas){
                                                if(data.syn_date__c >= fromdatetime && data.syn_date__c <= todatetime){    
                                                    data.Sale__c = rq.Transfer_Request__r.To_Sale__c;

                                                    //Included transfer Industry
                                                    if( (rq.Transfer_Request__r.isIncludeIndustry__c) &&  !String.isBlank(rq.Transfer_Request__r.ToIndustry__c)){
                                                        data.Industry__c = rq.Transfer_Request__r.ToIndustry__c;
                                                    }

                                                    mapUpdateQCData.put(data.Id,data);
                                                    isTransfer = true;

                                                    String rowdata = '';
                                                    rowdata = (data.Name ==null?'': data.Name)     
                                                            + ',' + (data.QC_Account__r.Name ==null?'': data.QC_Account__r.Name)     
                                                            + ',' + (data.syn_date__c ==null?'':  data.syn_date__c.format('dd/MM/yyyy')) 
                                                            + ',' + (data.Total_Spending__c ==null?'': String.valueOf(data.Total_Spending__c));       
                                                    fileSpendingDatas.add(rowdata);   
                                                }                        
                                            }
                                        }  

                                        if(fileSpendingDatas.size() > 0){
                                            mapSpendingDatas.put(rq.Id, fileSpendingDatas);
                                        }
                                        

                                    }else if(obj == TransferRequestConstant.TRANSFER_OBJECT_PAYMENT){    
                                        List<String>  filePaymentDatas = new List<String>();             
                                        List<Payment__c> paymentDatas = mapPayment.get(rq.QC_Account__c);
                                        if(paymentDatas != null){
                                            for( Payment__c py: paymentDatas){
                                                if(py.EffectiveDate__c >= rq.Transfer_Request__r.From_date__c && py.EffectiveDate__c <= rq.Transfer_Request__r.To_date__c){
                                                    py.Sale__c = rq.Transfer_Request__r.To_Sale__c;

                                                    //Included transfer Industry
                                                    if( (rq.Transfer_Request__r.isIncludeIndustry__c) &&  !String.isBlank(rq.Transfer_Request__r.ToIndustry__c)){
                                                        py.Industry__c = rq.Transfer_Request__r.ToIndustry__c;
                                                    }
                                                    mapUpdatePayments.put(py.Id,py);
                                                    isTransfer = true;

                                                    String rowdata = '';
                                                    rowdata = (py.Name ==null?'': py.Name)     
                                                            + ',' + (py.QC_Account__r.Name ==null?'': py.QC_Account__r.Name)     
                                                            + ',' + (py.Effective_Date__c ==null?'':  py.Effective_Date__c.format('dd/MM/yyyy')) 
                                                            + ',' + (py.Final_Amount__c ==null?'': String.valueOf(py.Final_Amount__c))
                                                            + ',' + (py.Stage__c ==null?'': py.Stage__c);       
                                                    filePaymentDatas.add(rowdata);      
                                                }   
                                            }

                                            if(filePaymentDatas.size() > 0){
                                                mapPaymentDatas.put(rq.Id, filePaymentDatas);
                                            }
                                        }
                                    }
                                }


                                //Include Transfer 
                            }                      
                        }else if(rq.Transfer_Request__r.Transfer_Type__c == TransferRequestConstant.TRANSFER_TYPE_SUPPORT){
                            String [] objects = rq.Transfer_Request__r.TransferObject__c.trim().split(';');
                            // System.debug('objects=>' + objects);
                            if(objects.size() > 0){
                        
                                for(String obj: objects){
                                    if(obj == TransferRequestConstant.TRANSFER_OBJECT_SPENDING){   
                                        List<String>  fileSpendingDatas = new List<String>();                                     
                                        List<QC_Account_Data__c> spendingDatas = mapSpending.get(rq.QC_Account__c);
                                        if(spendingDatas != null){                        
                                            for( QC_Account_Data__c data: spendingDatas){
                                                if(data.syn_date__c >= fromdatetime && data.syn_date__c <= todatetime){  
                                                    data.Support__c = rq.Transfer_Request__r.To_Sale__c;
                                                    mapUpdateQCData.put(data.Id,data);
                                                    isTransfer = true;

                                                    String rowdata = '';
                                                    rowdata = (data.Name ==null?'': data.Name)     
                                                            + ',' + (data.QC_Account__r.Name ==null?'': data.QC_Account__r.Name)     
                                                            + ',' + (data.syn_date__c ==null?'':  data.syn_date__c.format('dd/MM/yyyy')) 
                                                            + ',' + (data.Total_Spending__c ==null?'': String.valueOf(data.Total_Spending__c));   
                                                    fileSpendingDatas.add(rowdata);    
                                                }
                                            }                       
                                        }

                                        if(fileSpendingDatas.size() > 0){
                                            mapSpendingDatas.put(rq.Id, fileSpendingDatas);
                                        }

                                    }else if(obj == TransferRequestConstant.TRANSFER_OBJECT_PAYMENT){   

                                        List<String>  filePaymentDatas = new List<String>();                                                    
                                        List<Payment__c> paymentDatas = mapPayment.get(rq.QC_Account__c);
                                        if(paymentDatas != null){
                                            for( Payment__c py: paymentDatas){
                                                if(py.EffectiveDate__c >= rq.Transfer_Request__r.From_date__c && py.EffectiveDate__c <= rq.Transfer_Request__r.To_date__c){
                                                    py.Support__c = rq.Transfer_Request__r.To_Sale__c;
                                                    mapUpdatePayments.put(py.Id,py);
                                                    isTransfer = true;

                                                    String rowdata = '';
                                                    rowdata = (py.Name ==null?'': py.Name)     
                                                            + ',' + (py.QC_Account__r.Name ==null?'': py.QC_Account__r.Name)     
                                                            + ',' + (py.Effective_Date__c ==null?'':  py.Effective_Date__c.format('dd/MM/yyyy')) 
                                                            + ',' + (py.Final_Amount__c ==null?'': String.valueOf(py.Final_Amount__c)) 
                                                            + ',' + (py.Stage__c ==null?'': py.Stage__c);       
                                                    filePaymentDatas.add(rowdata); 
                                                }
                                            }        
                                        }

                                        if(filePaymentDatas.size() > 0){
                                            mapPaymentDatas.put(rq.Id, filePaymentDatas);
                                        }
                                    }
                                }
                            }                      
                        }else if(rq.Transfer_Request__r.Transfer_Type__c == TransferRequestConstant.TRANSFER_TYPE_INDUSTRY){
                            String [] objects = rq.Transfer_Request__r.TransferObject__c.trim().split(';');
                            // System.debug('objects=>' + objects);
                            if(objects.size() > 0){
                        
                                for(String obj: objects){
                                    if(obj == TransferRequestConstant.TRANSFER_OBJECT_SPENDING){
                                        List<String>  fileSpendingDatas = new List<String>();     
                                        List<QC_Account_Data__c> spendingDatas = mapSpending.get(rq.QC_Account__c);
                                        if(spendingDatas != null){                        
                                            for( QC_Account_Data__c data: spendingDatas){
                                                if(data.syn_date__c >= fromdatetime && data.syn_date__c <= todatetime){  
                                                    data.Industry__c = rq.Transfer_Request__r.ToIndustry__c;
                                                    mapUpdateQCData.put(data.Id,data);
                                                    isTransfer = true;

                                                    String rowdata = '';
                                                    rowdata = (data.Name ==null?'': data.Name)     
                                                            + ',' + (data.QC_Account__r.Name ==null?'': data.QC_Account__r.Name)     
                                                            + ',' + (data.syn_date__c ==null?'':  data.syn_date__c.format('dd/MM/yyyy')) 
                                                            + ',' + (data.Total_Spending__c ==null?'': String.valueOf(data.Total_Spending__c));     
                                                    fileSpendingDatas.add(rowdata);    
                                                }
                                            }                       
                                        }

                                        if(fileSpendingDatas.size() > 0){
                                            mapSpendingDatas.put(rq.Id, fileSpendingDatas);                                    
                                        }

                                    }else if(obj == TransferRequestConstant.TRANSFER_OBJECT_PAYMENT){  
                                        List<String>  filePaymentDatas = new List<String>();                                 
                                        List<Payment__c> paymentDatas = mapPayment.get(rq.QC_Account__c);
                                        if(paymentDatas != null){
                                            for( Payment__c py: paymentDatas){
                                                if(py.EffectiveDate__c >= rq.Transfer_Request__r.From_date__c && py.EffectiveDate__c <= rq.Transfer_Request__r.To_date__c){
                                                    py.Industry__c = rq.Transfer_Request__r.ToIndustry__c;
                                                    mapUpdatePayments.put(py.Id,py);
                                                    isTransfer = true;

                                                    String rowdata = '';
                                                    rowdata = (py.Name ==null?'': py.Name)     
                                                            + ',' + (py.QC_Account__r.Name ==null?'': py.QC_Account__r.Name)     
                                                            + ',' + (py.Effective_Date__c ==null?'':  py.Effective_Date__c.format('dd/MM/yyyy')) 
                                                            + ',' + (py.Final_Amount__c ==null?'': String.valueOf(py.Final_Amount__c))  
                                                            + ',' + (py.Stage__c ==null?'': py.Stage__c);    
                                                    filePaymentDatas.add(rowdata);    
                                                }
                                            }      
                                        }

                                        if(filePaymentDatas.size() > 0){
                                            mapPaymentDatas.put(rq.Id, filePaymentDatas);
                                        }
                                    }
                                }
                            }                      
                        }                
                    }
                }

                if(isTransfer){
                    mapRequest.put(rq.Transfer_Request__c,  new TransferSpendingCash__c(Id = rq.Transfer_Request__c, Status__c = 'Completed'));
                }
            }
        }       

        // System.debug('mapSpendingDatas=>' + mapSpendingDatas);
        if(mapSpendingDatas.size() > 0){

            String spendingfileHeader = 'QC Account Data Name,QC Account,Date,Total Spending'  + '\n';

            for(String rqId : mapSpendingDatas.keySet()){
                List<String> fileSpendingDatas = mapSpendingDatas.get(rqId);
                if(fileSpendingDatas.size() > 0){
                    
                    String fileDatastr = spendingfileHeader + String.join(fileSpendingDatas, '\n');
                    String fileName = 'Transfer Spending Records.csv';
                    Attachment att = new Attachment(Name = fileName, Body = blob.valueOf(fileDatastr), ParentId = rqId, ContentType='application/vnd.ms-excel');
                    
                    atts.add(att);
                }
            }
        }

        if(mapPaymentDatas.size() > 0){
            String paymentfileHeader = 'Payment Number,QC Account,Effective Date,Final Amount,Stage'  + '\n';

            for(String rqId : mapPaymentDatas.keySet()){
                List<String> filePaymentDatas = mapPaymentDatas.get(rqId);                
                if(filePaymentDatas.size() > 0){                    
                    String fileDatastr = paymentfileHeader + String.join(filePaymentDatas, '\n');
                    String fileName = 'Transfer Payment Records.csv';
                    Attachment att = new Attachment(Name = fileName, Body = blob.valueOf(fileDatastr), ParentId = rqId, ContentType='application/vnd.ms-excel');
                    
                    atts.add(att);
                }
            }
        } 
        
        //Update QC Account data records
        if(mapUpdateQCData.size() > 0){
            update mapUpdateQCData.values();
        }

        //Update Payment records
        if(mapUpdatePayments.size() > 0){
            update mapUpdatePayments.values();
        }

        if(mapQCAccountToUpdate.size() > 0){
            update mapQCAccountToUpdate.values();
        }

        //Update Request records
        if(mapRequest.values().size() > 0){
            update mapRequest.values();
        }

        //Insert attactfile records
        // System.debug('atts=>' + atts);
        if(atts.size() > 0){
            insert atts;
        }
    }

}