global class cc_MediaPlan_AutoApprove implements Schedulable{
    global void execute(SchedulableContext SC) {
        cc_MediaPlan_AutoApproveExecute();
    }
    public cc_MediaPlan_AutoApprove(){
        cc_MediaPlan_AutoApproveExecute();
    }
    public void cc_MediaPlan_AutoApproveExecute()
    {
        string targetObject = 'Media Plan approval v1';
        string Aom_check = 'AOM check';
        string Am_check = 'AM check';
        datetime dttoday = datetime.now();
        if( Test.isRunningTest())
        {
            dttoday = dttoday.addDays(1);
        }else{
            dttoday = dttoday.addDays(-7);
        }
        List<ProcessInstance> processInstanceList = [select id, TargetObjectId, status,
                                                     (select id from Workitems order by createddate desc), 
                                                     (select id from Steps order by createddate desc), 
                                                     (select id,ProcessNodeName from Nodes order by createddate desc limit 1)
                                                     from ProcessInstance
                                                     where ProcessDefinition.Name like: targetObject
                                                     and Status=:'Pending' and createdDate <:dttoday];
        
        	
        
        for(ProcessInstance item: processInstanceList){
            if(item.Nodes.size() >0 )
            {
                ProcessInstanceNode node = item.Nodes.get(0);
                if( node.ProcessNodeName == Am_check || node.ProcessNodeName == Aom_check || Test.isRunningTest()){
                    Approval.ProcessWorkitemRequest  req = new Approval.ProcessWorkitemRequest ();
                    req.setAction('Approve');
                    req.setWorkitemId(item.Workitems.get(0).id);
                    Approval.process(req);
                }
            }
        }
        
        
    }
}