trigger ResourceRequest_ObjectTrigger on pse__Resource_Request__c (before insert, before update, after insert, after update) {
	
    // Hours Distribution Sync 
	if (!HoursDistroSync_RunKeyHelper.isEnabled('pse__Resource_Request__c')) return;
	HoursDistroSync_Handler.processTriggerResourceRequest(Trigger.new, Trigger.oldMap);

	// Project Stage Sync 
	try {
		if (!ProjStageSyncRunKeyHelper.isEnabled('pse__Resource_Request__c')) return;
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
	ProjStageSyncHandler.processTriggerResourceRequest(Trigger.new, Trigger.oldMap);

}