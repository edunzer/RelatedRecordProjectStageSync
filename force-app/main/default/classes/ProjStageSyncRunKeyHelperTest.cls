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

}