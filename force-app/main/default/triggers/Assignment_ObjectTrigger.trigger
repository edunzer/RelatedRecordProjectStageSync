trigger Assignment_ObjectTrigger on pse__Assignment__c (before insert, before update, after insert, after update) {
    
    // Hours Distribution Sync 
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Assignment__c')) return;
	HoursDistroSync_Handler.processTriggerAssignment(Trigger.new, Trigger.oldMap);

	// Project Stage Sync 
	try {
		if (!ProjStageSyncRunKeyHelper.isEnabled('pse__Assignment__c')) return;
	} catch (ProjStageSyncRunKeyHelper.MissingCustomSettingException e) {
		System.debug('Project Stage Sync disabled: missing custom setting - ' + e.getMessage());
		return;
	} catch (ProjStageSyncRunKeyHelper.MissingFieldMappingException e) {
		System.debug('Project Stage Sync disabled: missing field mapping - ' + e.getMessage());
		return;
	} catch (ProjStageSyncRunKeyHelper.MissingSettingsRecordException e) {
		System.debug('Project Stage Sync disabled: missing settings record - ' + e.getMessage());
		return;
	}
	ProjStageSyncHandler.processTriggerAssignment(Trigger.new, Trigger.oldMap);

}