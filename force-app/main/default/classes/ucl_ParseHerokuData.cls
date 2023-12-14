public class ucl_ParseHerokuData implements Schedulable {
    public void execute(SchedulableContext ctx) {
        deleteOldErrorLogs();
        performAsyncCallout();
    }
    @future(callout=true)
    public static void performAsyncCallout() {
        ucl_LegalAdvisorParser.parseLegalAdvisors();
    }
    public static void deleteOldErrorLogs() {
        Date thirtyDaysAgo = System.today().addDays(-30);
        List<Exception_Log__c> oldErrorLogs = [SELECT Id FROM Exception_Log__c WHERE DAY_ONLY(CreatedDate) <= :thirtyDaysAgo];
        if (!oldErrorLogs.isEmpty()) {
            delete oldErrorLogs;
        }
    }
}