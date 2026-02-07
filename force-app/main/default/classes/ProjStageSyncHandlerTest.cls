@isTest
private class ProjStageSyncHandlerTest {
	static testMethod void testTypedBeforeAndAfterResourceRequest() {
		List<pse__Resource_Request__c> incoming = new List<pse__Resource_Request__c>();
		for (Integer i=0;i<2;i++) {
			pse__Resource_Request__c r = new pse__Resource_Request__c();
			r.ProjectStage_Sync_Status__c = 'Pending';
			incoming.add(r);
		}

		// Call the typed before wrapper
		ProjStageSyncHandler.handleBeforeUpdate(incoming, null);
		for (pse__Resource_Request__c r : incoming) {
			System.assertNotEquals(null, r.get('ProjectStage_Sync_RunKey__c'));
			System.assertEquals('Pending', r.ProjectStage_Sync_Status__c);
		}

		// Call the typed after wrapper - this will attempt to enqueue a job; wrap in test start/stop
		Test.startTest();
		ProjStageSyncHandler.handleAfterUpdate(incoming, null);
		Test.stopTest();
	}

	static testMethod void testTypedBeforeAndAfterAssignment() {
		List<pse__Assignment__c> incoming = new List<pse__Assignment__c>();
		for (Integer i=0;i<2;i++) {
			pse__Assignment__c a = new pse__Assignment__c();
			a.ProjectStage_Sync_Status__c = 'Pending';
			incoming.add(a);
		}

		ProjStageSyncHandler.handleBeforeUpdate(incoming, null);
		for (pse__Assignment__c a : incoming) {
			System.assertNotEquals(null, a.get('ProjectStage_Sync_RunKey__c'));
			System.assertEquals('Pending', a.ProjectStage_Sync_Status__c);
		}

		Test.startTest();
		ProjStageSyncHandler.handleAfterUpdate(incoming, null);
		Test.stopTest();
	}

        @isTest
    static void testHandleBeforeUpdateSetsFieldsForResourceRequest() {
        pse__Resource_Request__c r = new pse__Resource_Request__c();
        List<pse__Resource_Request__c> listR = new List<pse__Resource_Request__c>{ r };

        ProjStageSyncHandler.handleBeforeUpdate(listR, null);

        System.assertNotEquals(null, listR[0].get('ProjectStage_Sync_RunKey__c'));
        System.assertEquals('Pending', String.valueOf(listR[0].get('ProjectStage_Sync_Status__c')));
    }

    @isTest static void testHandleBeforeUpdateSetsFieldsForAssignment() {
        pse__Assignment__c a = new pse__Assignment__c();
        List<pse__Assignment__c> listA = new List<pse__Assignment__c>{ a };

        ProjStageSyncHandler.handleBeforeUpdate(listA, null);

        System.assertNotEquals(null, listA[0].get('ProjectStage_Sync_RunKey__c'));
        System.assertEquals('Pending', String.valueOf(listA[0].get('ProjectStage_Sync_Status__c')));
    }

    @isTest static void testHandleAfterUpdateEnqueuesAndClears() {
        String objectApiName = 'pse__Resource_Request__c';
        // ensure clean enqueued state
        ProjStageSyncRunKeyHelper.clearEnqueued(objectApiName);

        pse__Resource_Request__c r = new pse__Resource_Request__c();
        List<pse__Resource_Request__c> listR = new List<pse__Resource_Request__c>{ r };

        Test.startTest();
        ProjStageSyncHandler.handleAfterUpdate(listR, null);
        Test.stopTest();

        // After the handler enqueues and the queueable runs, the enqueued flag should be cleared
        Boolean canMarkAgain = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, canMarkAgain);
    }

    @isTest static void testHandleAfterUpdateEnqueuesAndClears_Assignment() {
        String objectApiName = 'pse__Assignment__c';
        ProjStageSyncRunKeyHelper.clearEnqueued(objectApiName);

        pse__Assignment__c a = new pse__Assignment__c();
        List<pse__Assignment__c> listA = new List<pse__Assignment__c>{ a };

        Test.startTest();
        ProjStageSyncHandler.handleAfterUpdate(listA, null);
        Test.stopTest();

        Boolean canMarkAgain = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, canMarkAgain);
    }
}