public class ucl_ExistingAdvisorFetcher {
    public static Map<String, Legal_Advisor__c> fetchAdvisors(
        Map<String, Legal_Advisor__c> advisorMap,
        Set<String> accountNumbers
    ) {
        for (Legal_Advisor__c existingLegalAdvisor : [
            SELECT Id, Account_Status__c, Account_Number__c
            FROM Legal_Advisor__c
            WHERE Account_Number__c IN :accountNumbers
        ]) {
            advisorMap.put(existingLegalAdvisor.Account_Number__c, existingLegalAdvisor);
        }
        return advisorMap;
    }
}