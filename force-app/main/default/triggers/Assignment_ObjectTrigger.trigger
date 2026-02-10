trigger Assignment_ObjectTrigger on pse__Assignment__c (before insert, before update, after insert, after update) {
    
    // Hours Distribution Sync 
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c')) return;
	HoursDistroSync_Handler.processTriggerAssignment(Trigger.new, Trigger.oldMap);

	// Project Stage Sync 
	if (!ProjStageSyncRunKeyHelper.isEnabled('pse__Assignment__c')) return;
	ProjStageSyncHandler.processTriggerAssignment(Trigger.new, Trigger.oldMap);

}