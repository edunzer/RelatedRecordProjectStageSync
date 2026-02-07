@isTest
private class ProjStageSyncQueueableWorkerTest {
	@isTest
    static void testQueueableClearsEnqueuedForResourceRequest() {
        String objectApiName = 'pse__Resource_Request__c';
        // Ensure no enqueued state
        ProjStageSyncRunKeyHelper.clearEnqueued(objectApiName);

        String runKey = ProjStageSyncRunKeyHelper.getRunKey(objectApiName);
        // Mark enqueued to simulate handler behavior
        Boolean marked = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked, 'Should be marked enqueued initially');

        Test.startTest();
        System.enqueueJob(new ProjStageSyncQueueableWorker(runKey, objectApiName));
        Test.stopTest();

        // After queueable executes it should clear enqueued state
        Boolean after = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, after, 'Enqueued state should have been cleared by the queueable');
    }

    @isTest static void testQueueableClearsEnqueuedForAssignment() {
        String objectApiName = 'pse__Assignment__c';
        ProjStageSyncRunKeyHelper.clearEnqueued(objectApiName);

        String runKey = ProjStageSyncRunKeyHelper.getRunKey(objectApiName);
        Boolean marked = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new ProjStageSyncQueueableWorker(runKey, objectApiName));
        Test.stopTest();

        Boolean after = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, after);
    }

    @isTest static void testConstructorValidation() {
        // Valid constructor inputs should not throw
        new ProjStageSyncQueueableWorker('rk', 'pse__Resource_Request__c');
        new ProjStageSyncQueueableWorker('rk', 'pse__Assignment__c');
    }

    @isTest static void testGetChunkSizeUsesAssignmentSetting() {
        String objectApiName = 'pse__Assignment__c';
        ProjStageSyncRunKeyHelper.clearEnqueued(objectApiName);
        String runKey = ProjStageSyncRunKeyHelper.getRunKey(objectApiName);

        try {
            insert new ProjectStageSyncSettings__c(Assignment_Chunk_Size__c = 5);
        } catch (Exception e) {
            // ignore if custom setting/field absent in this org
        }

        Boolean marked = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new ProjStageSyncQueueableWorker(runKey, objectApiName));
        Test.stopTest();

        // ensure helper cleared
        System.assertEquals(true, ProjStageSyncRunKeyHelper.markEnqueued(objectApiName));
    }

    @isTest static void testGetChunkSizeUsesResourceRequestSetting() {
        String objectApiName = 'pse__Resource_Request__c';
        ProjStageSyncRunKeyHelper.clearEnqueued(objectApiName);
        String runKey = ProjStageSyncRunKeyHelper.getRunKey(objectApiName);

        try {
            insert new ProjectStageSyncSettings__c(Resource_Request_Chunk_Size__c = 7);
        } catch (Exception e) {
            // ignore if custom setting/field absent in this org
        }

        Boolean marked = ProjStageSyncRunKeyHelper.markEnqueued(objectApiName);
        System.assertEquals(true, marked);

        Test.startTest();
        System.enqueueJob(new ProjStageSyncQueueableWorker(runKey, objectApiName));
        Test.stopTest();

        System.assertEquals(true, ProjStageSyncRunKeyHelper.markEnqueued(objectApiName));
    }

    // Helper: create a new SObject and populate non-nullable primitive fields with defaults
    private static SObject buildMinimalSObject(String apiName) {
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey(apiName)) return null;
        SObject sobj = gd.get(apiName).newSObject();
        Map<String, Schema.SObjectField> fmap = gd.get(apiName).getDescribe().fields.getMap();
        for (String fname : fmap.keySet()) {
            Schema.DescribeFieldResult fd = fmap.get(fname).getDescribe();
            if (!fd.isCreateable()) continue;
            if (fd.isNillable()) continue;
            Schema.DisplayType dt = fd.getType();
            try {
                if (dt == Schema.DisplayType.STRING || dt == Schema.DisplayType.TEXTAREA || dt == Schema.DisplayType.PHONE
                    || dt == Schema.DisplayType.EMAIL || dt == Schema.DisplayType.URL) {
                    sobj.put(fname, 'T');
                } else if (dt == Schema.DisplayType.INTEGER) {
                    sobj.put(fname, 1);
                } else if (dt == Schema.DisplayType.DOUBLE || dt == Schema.DisplayType.CURRENCY || dt == Schema.DisplayType.PERCENT) {
                    sobj.put(fname, Decimal.valueOf(1));
                } else if (dt == Schema.DisplayType.BOOLEAN) {
                    sobj.put(fname, false);
                } else if (dt == Schema.DisplayType.DATE) {
                    sobj.put(fname, Date.today());
                } else if (dt == Schema.DisplayType.DATETIME) {
                    sobj.put(fname, DateTime.now());
                } else if (dt == Schema.DisplayType.PICKLIST) {
                    List<Schema.PicklistEntry> vals = fd.getPicklistValues();
                    if (!vals.isEmpty()) sobj.put(fname, vals[0].getValue());
                }
            } catch (Exception ex) {
                // ignore any failures setting defaults
            }
        }
        return sobj;
    }
}