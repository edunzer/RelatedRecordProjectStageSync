@isTest
private class ProjStageSyncRunKeyHelperTest {
	static testMethod void testRunKeyAndEnqueueBehavior() {
		String obj = 'pse__Assignment__c';
		String rk1 = ProjStageSyncRunKeyHelper.getRunKey(obj);
		System.assertNotEquals(null, rk1, 'runKey should be generated');
		String rk2 = ProjStageSyncRunKeyHelper.getRunKey(obj);
		System.assertEquals(rk1, rk2, 'subsequent getRunKey calls for same object should return same key');

		Boolean first = ProjStageSyncRunKeyHelper.markEnqueued(obj);
		System.assertEquals(true, first, 'first markEnqueued should return true');
		Boolean second = ProjStageSyncRunKeyHelper.markEnqueued(obj);
		System.assertEquals(false, second, 'second markEnqueued same transaction should return false');

		ProjStageSyncRunKeyHelper.clearEnqueued(obj);
		Boolean afterClear = ProjStageSyncRunKeyHelper.markEnqueued(obj);
		System.assertEquals(true, afterClear, 'after clearEnqueued markEnqueued should allow enqueueing again');
	}

	static testMethod void testIsEnabledAndUnsupported() {
		// Default behaviour when settings are not present: enabled (true)
		Boolean en1 = ProjStageSyncRunKeyHelper.isEnabled('pse__Assignment__c');
		System.assertEquals(true, en1);

		Boolean en2 = ProjStageSyncRunKeyHelper.isEnabled('pse__Resource_Request__c');
		System.assertEquals(true, en2);

		// Unsupported object should throw the helper's custom exception
		try {
			ProjStageSyncRunKeyHelper.isEnabled('Account');
			System.assert(false, 'UnsupportedObjectApiNameException expected for Account');
		} catch (ProjStageSyncRunKeyHelper.UnsupportedObjectApiNameException e) {
			// expected
		}
	}

    @isTest
    static void testGetRunKeyConsistencyAndFormat_ResourceRequest() {
        String obj = 'pse__Resource_Request__c';
        String rk1 = ProjStageSyncRunKeyHelper.getRunKey(obj);
        String rk2 = ProjStageSyncRunKeyHelper.getRunKey(obj);
        System.assertEquals(rk1, rk2, 'Run keys should be stable within the same transaction');
        System.assert(rk1.startsWith(obj + '_hrs_'), 'Run key should start with objectApiName + _hrs_');
    }

    @isTest static void testMarkEnqueuedAndClear_ResourceRequest() {
        String obj = 'pse__Resource_Request__c';
        // ensure clean state
        ProjStageSyncRunKeyHelper.clearEnqueued(obj);

        Boolean first = ProjStageSyncRunKeyHelper.markEnqueued(obj);
        Boolean second = ProjStageSyncRunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, first, 'First markEnqueued should return true');
        System.assertEquals(false, second, 'Second markEnqueued in same transaction should return false');

        ProjStageSyncRunKeyHelper.clearEnqueued(obj);
        Boolean third = ProjStageSyncRunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, third, 'After clearEnqueued, markEnqueued should return true again');
    }

    @isTest
    static void testGetRunKeyConsistencyAndFormat_Assignment() {
        String obj = 'pse__Assignment__c';
        String rk1 = ProjStageSyncRunKeyHelper.getRunKey(obj);
        String rk2 = ProjStageSyncRunKeyHelper.getRunKey(obj);
        System.assertEquals(rk1, rk2, 'Run keys should be stable within the same transaction');
        System.assert(rk1.startsWith(obj + '_hrs_'), 'Run key should start with objectApiName + _hrs_');
    }

    @isTest static void testMarkEnqueuedAndClear_Assignment() {
        String obj = 'pse__Assignment__c';
        // ensure clean state
        ProjStageSyncRunKeyHelper.clearEnqueued(obj);

        Boolean first = ProjStageSyncRunKeyHelper.markEnqueued(obj);
        Boolean second = ProjStageSyncRunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, first, 'First markEnqueued should return true');
        System.assertEquals(false, second, 'Second markEnqueued in same transaction should return false');

        ProjStageSyncRunKeyHelper.clearEnqueued(obj);
        Boolean third = ProjStageSyncRunKeyHelper.markEnqueued(obj);
        System.assertEquals(true, third, 'After clearEnqueued, markEnqueued should return true again');
    }

    @isTest static void testIsEnabledDefaultsAndSettings() {
        // Remove any existing settings to validate default behavior
        try {
            List<ProjectStageSyncSettings__c> existing = [SELECT Id FROM ProjectStageSyncSettings__c];
            if (!existing.isEmpty()) delete existing;
        } catch (Exception e) {
            // ignore if settings object not present in test org
        }

        System.assertEquals(true, ProjStageSyncRunKeyHelper.isEnabled('pse__Resource_Request__c'));
        System.assertEquals(true, ProjStageSyncRunKeyHelper.isEnabled('pse__Assignment__c'));

        // Insert a settings record with explicit booleans and verify
        ProjectStageSyncSettings__c s = new ProjectStageSyncSettings__c();
        s.ResourceRequest_Enable_ProjectStage_Sync__c = false;
        s.Assignment_Enable_ProjectStage_Sync__c = true;
        insert s;

        System.assertEquals(false, ProjStageSyncRunKeyHelper.isEnabled('pse__Resource_Request__c'));
        System.assertEquals(true, ProjStageSyncRunKeyHelper.isEnabled('pse__Assignment__c'));

        delete s;
    }

    @isTest static void testUnsupportedAndBlankAssertions() {
        // Unsupported object should throw our specific exception
        try {
            ProjStageSyncRunKeyHelper.isEnabled('Account');
            System.assert(false, 'Expected UnsupportedObjectApiNameException for unsupported object');
        } catch (Exception e) {
            System.assert(e instanceof ProjStageSyncRunKeyHelper.UnsupportedObjectApiNameException, 'Exception should be UnsupportedObjectApiNameException');
        }

        // Skip testing methods that assert on blank inputs to avoid uncatchable assertion failures
    }

}