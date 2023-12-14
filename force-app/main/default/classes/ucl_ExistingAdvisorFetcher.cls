public class ucl_ExistingAdvisorFetcher {
    public static Map<String, Legal_Advisor__c> fetchAdvisors(Map<String, Legal_Advisor__c> advisorMap) {
        for (Legal_Advisor__c existingLegalAdvisor : [
            SELECT Id, Account_Name__c, Account_Number__c, Account_Status__c , As_of_Date__c, Name
            FROM Legal_Advisor__c
        ]) {
            advisorMap.put(existingLegalAdvisor.Account_Number__c, existingLegalAdvisor);
        }
        return advisorMap;
    }
}