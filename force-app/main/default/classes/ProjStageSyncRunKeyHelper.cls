public with sharing class ProjStageSyncRunKeyHelper {
    public class UnsupportedObjectApiNameException extends Exception {}
    public class MissingCustomSettingException extends Exception {}
    public class MissingFieldMappingException extends Exception {}
    public class MissingSettingsRecordException extends Exception {}
    private static Map<String, String> runKeys = new Map<String, String>();
    private static Set<String> enqueuedObjects = new Set<String>();
    
    public ProjStageSyncRunKeyHelper() {
        // static helper only
    }

    public static String getRunKey(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        if (!runKeys.containsKey(objectApiName)) {
            String rk = objectApiName + '_hrs_' + String.valueOf(DateTime.now().getTime()) + '_' + String.valueOf(Math.abs((Integer)(Math.random() * 1000000)));
            runKeys.put(objectApiName, rk);
        }
        return runKeys.get(objectApiName);
    }

    /**
     * Returns true if this call successfully marked the transaction as having queued a job
     * for the given object. Ensures only one Queueable is enqueued per object per transaction.
     */
    public static Boolean markEnqueued(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        if (enqueuedObjects.contains(objectApiName)) return false;
        enqueuedObjects.add(objectApiName);
        return true;
    }

    public static void clearEnqueued(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');
        enqueuedObjects.remove(objectApiName);
        runKeys.remove(objectApiName);
    }

    /**
     * Returns whether processing is enabled via the ProjectStageSyncSettings__c custom setting.
     * If the setting or field is missing, defaults to true (enabled).
     * Caller MUST pass the target object's API name; supported values are
     * 'pse__Assignment__c' and 'pse__Resource_Request__c'.
     */
    public static Boolean isEnabled(String objectApiName) {
        System.assert(!String.isBlank(objectApiName), 'objectApiName is required');

        // Validate supported object names so unsupported names fail fast
        if (objectApiName != 'pse__Assignment__c' && objectApiName != 'pse__Resource_Request__c') {
            throw new UnsupportedObjectApiNameException('Unsupported objectApiName: ' + objectApiName);
        }

        // Use dynamic describe and dynamic SOQL to avoid compile-time dependency on a
        // custom setting or its fields. If the object/field or records are missing,
        // fail loudly so callers are aware of missing configuration.
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        if (!gd.containsKey('ProjectStageSyncSettings__c')) {
            throw new MissingCustomSettingException('ProjectStageSyncSettings__c custom setting is not present in this org');
        }

        Schema.SObjectType sd = gd.get('ProjectStageSyncSettings__c');
        Map<String, Schema.SObjectField> fieldMap = sd.getDescribe().fields.getMap();
        String fieldName = null;
        if (objectApiName == 'pse__Assignment__c') {
            fieldName = 'Assignment_Enable_ProjectStage_Sync__c';
        }
        if (objectApiName == 'pse__Resource_Request__c') {
            fieldName = 'ResourceRequest_Enable_ProjectStage_Sync__c';
        }

        if (fieldName == null) {
            throw new MissingFieldMappingException('No field mapping configured for object: ' + objectApiName);
        }

        if (!fieldMap.containsKey(fieldName)) {
            throw new MissingFieldMappingException('Expected field ' + fieldName + ' not found on ProjectStageSyncSettings__c');
        }

        try {
            String soql = 'SELECT ' + fieldName + ' FROM ProjectStageSyncSettings__c LIMIT 1';
            List<SObject> rows = Database.query(soql);
            if (rows.isEmpty()) {
                throw new MissingSettingsRecordException('No ProjectStageSyncSettings__c record found');
            }
            SObject rec = rows[0];
            Object val = rec.get(fieldName);
            if (val == null) {
                throw new MissingSettingsRecordException('Field ' + fieldName + ' on ProjectStageSyncSettings__c is null');
            }
            if (val instanceof Boolean) return (Boolean)val;
            return String.valueOf(val).toLowerCase() == 'true';
        } catch (Exception e) {
            // Re-throw known helper exceptions so callers can handle them; otherwise wrap
            if (e instanceof MissingCustomSettingException || e instanceof MissingFieldMappingException || e instanceof MissingSettingsRecordException) throw e;
            throw e;
        }
    }

}