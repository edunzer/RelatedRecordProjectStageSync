@isTest
private class ProjStageSyncQueueableWorkerTest {
	static testMethod void testResourceRequestProcessing() {
		String rk = 'test_rk_rr';
		List<pse__Resource_Request__c> toInsert = new List<pse__Resource_Request__c>();
		for (Integer i=0;i<3;i++) {
			pse__Resource_Request__c r = new pse__Resource_Request__c();
			r.ProjectStage_Sync_RunKey__c = rk;
			r.ProjectStage_Sync_Status__c = 'Pending';
			toInsert.add(r);
		}
		insert toInsert;

		Test.startTest();
		Id jobId = System.enqueueJob(new ProjStageSyncQueueableWorker(rk, 'pse__Resource_Request__c'));
		Test.stopTest();

		List<pse__Resource_Request__c> rows = [SELECT Id, ProjectStage_Sync_Status__c FROM pse__Resource_Request__c WHERE ProjectStage_Sync_RunKey__c = :rk];
		// At least one record should have been moved to Processing
		Boolean found = false;
		for (pse__Resource_Request__c r : rows) {
			if (r.ProjectStage_Sync_Status__c == 'Processing') { found = true; break; }
		}
		System.assert(found, 'At least one Resource Request should be marked Processing after queueable execution');
	}

	static testMethod void testAssignmentProcessing() {
		String rk = 'test_rk_asg';
		List<pse__Assignment__c> toInsert = new List<pse__Assignment__c>();
		for (Integer i=0;i<2;i++) {
			pse__Assignment__c a = new pse__Assignment__c();
			a.ProjectStage_Sync_RunKey__c = rk;
			a.ProjectStage_Sync_Status__c = 'Pending';
			toInsert.add(a);
		}
		insert toInsert;

		Test.startTest();
		Id jobId = System.enqueueJob(new ProjStageSyncQueueableWorker(rk, 'pse__Assignment__c'));
		Test.stopTest();

		List<pse__Assignment__c> rows = [SELECT Id, ProjectStage_Sync_Status__c FROM pse__Assignment__c WHERE ProjectStage_Sync_RunKey__c = :rk];
		Boolean found = false;
		for (pse__Assignment__c a : rows) {
			if (a.ProjectStage_Sync_Status__c == 'Processing') { found = true; break; }
		}
		System.assert(found, 'At least one Assignment should be marked Processing after queueable execution');
	}
}