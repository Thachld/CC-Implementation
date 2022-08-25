/**
 * @Author: ThachLd.
 * @Date: 2020 Oct 22
 * Class cc_TriggerFactory
 *
 * Used to instantiate and execute Trigger Handlers associated with sObjects.
 * @Original:https://code.google.com/archive/p/apex-trigger-architecture-framework/
 */
public with sharing class cc_TriggerFactory
{
    /**
     * Public static method to create and execute a trigger handler
     *
     * Arguments:   Schema.sObjectType soType - Object type to process (SObject.sObjectType)
     *
     * Throws a cc_TriggerException if no handler has been coded.
     */
    //public static void createHandler(Schema.sObjectType soType)
    public static void createHandler(String clsName)
    {
        // Get a handler appropriate to the object being processed
        cc_ITrigger handler = getHandler(clsName);
        
        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null)
        {
            throw new cc_TriggerException('No Trigger Handler registered for Object class named: ' + clsName);
        }
        
        // Execute the handler to fulfil the trigger
        execute(handler);
    }
    
    /**
     * private static method to control the execution of the handler
     *
     * Arguments:   ITrigger handler - A Trigger Handler to execute
     */ 
    private static void execute(cc_ITrigger handler)
    {
        // Before Trigger
        if (Trigger.isBefore)
        {
            
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();            
            
            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete)
            {
            
                System.debug('[cc_TriggerFactory] - execute() :Trigger Before delete Run');
                
                for (SObject so : Trigger.old)
                {
                    handler.beforeDelete(so);
                }
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
            
                System.debug('[cc_TriggerFactory] - execute(): Trigger Before insert Run');
                
                for (SObject so : Trigger.new)
                {
                    handler.beforeInsert(so);
                }
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
            
                System.debug('[cc_TriggerFactory] - execute(): Trigger Before update Run');
                
                for (SObject so : Trigger.old)
                {
                    handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification
            handler.bulkAfter();
            
            // Iterate through the records undeleted passing them to the handler.
            if (Trigger.isUnDelete)
            {
            
                System.debug('[cc_TriggerFactory] - execute(): Trigger After unDelete Run');
                
                for (SObject so : Trigger.new)
                {
                    handler.afterUnDelete(so);
                }
            }
            
            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete)
            {
            
                System.debug('[cc_TriggerFactory] - execute(): Trigger After Delete Run');
                
                for (SObject so : Trigger.old)
                {
                    handler.afterDelete(so);
                }
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                
                System.debug('[cc_TriggerFactory] - execute(): Trigger After insert Run');
                
                for (SObject so : Trigger.new)
                {
                    handler.afterInsert(so);
                }
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                
                System.debug('[cc_TriggerFactory] - execute(): Trigger After update Run');
                
                for (SObject so : Trigger.old)
                {
                    handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                }
            }
        }
        
        // Perform any post processing
        handler.andFinally();
    }
    
    /**
     * private static method to get the appropriate handler for the object type.
     * Modify this method to add any additional handlers.
     *
     * Arguments:   Schema.sObjectType soType - Object type tolocate (SObject.sObjectType)
     *
     * Returns:     ITrigger - A trigger handler if one exists or null.
     */
    //private static ITrigger getHandler(Schema.sObjectType soType)
    private static cc_ITrigger getHandler(String clsName)
    {
        /*
        if (soType == Account.sObjectType)
        {
            return new AccountHandler();
        }
        */
        try
        {
            Type t = Type.forName(clsName);
            return (cc_ITrigger)t.newInstance();
        }
        catch(Exception e)
        {
            system.debug('[cc_TriggerFactory] - execute() -> Exception e: ' + e.getMessage());
        }

        return null;
    }
}