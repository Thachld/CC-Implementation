public with sharing class TransferRequestController {
    @AuraEnabled(Cacheable=true)
    public static List<QC_Account__c> getQCAccountByRequest(String requestId){

        List<QC_Account__c> result = getQCAccounts(requestId, '' , new List<String>());
        return result;
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<QC_Account__c> getQCAccounts(String requestId, String searchTerm, List<String> exceptIds){
        try {
            Set<String> qcIds = new Set<String>();
            TransferSpendingCash__c request = [SELECT Transfer_Purpose__c, Transfer_Type__c, From_Sale__c, To_Sale__c FROM TransferSpendingCash__c WHERE Id = : requestId];
            for(Transfer_Account__c acc: [SELECT QC_Account__c FROM Transfer_Account__c WHERE Transfer_Request__c =: requestId]){
                qcIds.add(acc.QC_Account__c);
            }

            qcIds.addAll(exceptIds);

            List<QC_Account__c> result = new List<QC_Account__c>();
            System.debug('requestId=>' + requestId);
            System.debug('qcIds=>' + qcIds);
            if(request != null){           
                
                searchTerm = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                
                if(request.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_OWNER){

                    result = [SELECT Id, Name, QC_Account_Id__c, Industry__c, Sales__c, Sale_Email__c, 
                                    Support__c, Support_Email__c 
                                    FROM QC_Account__c
                                    WHERE Sales__c = :request.From_Sale__c     
                                    AND Name LIKE :searchTerm                       
                                    AND Id NOT IN :qcIds
                                    ];
                }else if(request.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_ADS_OP){
                    result = [SELECT Id, Name, QC_Account_Id__c, Industry__c, Sales__c, Sale_Email__c, 
                                    Support__c, Support_Email__c 
                                    FROM QC_Account__c
                                    WHERE Support__c = :request.From_Sale__c     
                                    AND Name LIKE :searchTerm                       
                                    AND Id NOT IN :qcIds
                                    ];            

                }else if(request.Transfer_Purpose__c == TransferRequestConstant.TRANSFER_PURPOSE_TRANSFER_DATA ){
                    if(request.Transfer_Type__c == TransferRequestConstant.TRANSFER_TYPE_SALE 
                        || request.Transfer_Type__c == TransferRequestConstant.TRANSFER_TYPE_INDUSTRY ){
                        result = [SELECT Id, Name, QC_Account_Id__c, Industry__c, Sales__c, Sale_Email__c, 
                                        Support__c, Support_Email__c 
                                        FROM QC_Account__c
                                        WHERE Sales__c = :request.To_Sale__c     
                                        AND Name LIKE :searchTerm                       
                                        AND Id NOT IN :qcIds
                                        ]; 
                    }else if(request.Transfer_Type__c == TransferRequestConstant.TRANSFER_TYPE_SUPPORT){
                        result = [SELECT Id, Name, QC_Account_Id__c, Industry__c, Sales__c, Sale_Email__c, 
                                        Support__c, Support_Email__c 
                                        FROM QC_Account__c
                                        WHERE Support__c = :request.To_Sale__c     
                                        AND Name LIKE :searchTerm                       
                                        AND Id NOT IN :qcIds
                                        ]; 
                    }      
                }
                
            }
            System.debug('result=>' + result);

            return result;
        } catch (Exception e) {
            // System.debug(e.getMessage());
            // return null;
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List<Transfer_Account__c> addTransferAccounts(String requestId, List<String> qcAccounts){
        try {
            List<Transfer_Account__c> addQccAccounts = new List<Transfer_Account__c>();
            for(String qcacc : qcAccounts){
                Transfer_Account__c tfacc = new Transfer_Account__c();
                tfacc.QC_Account__c = qcacc;
                tfacc.Transfer_Request__c = requestId;

                addQccAccounts.add(tfacc);
            }
            
            insert addQccAccounts;
            return addQccAccounts;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

}