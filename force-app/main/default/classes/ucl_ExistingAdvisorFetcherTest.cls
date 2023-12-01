@isTest
public class ucl_ExistingAdvisorFetcherTest {
    @isTest
    static void testFetchAdvisors() {
        List<Legal_Advisor__c> legalAdvisors = new List<Legal_Advisor__c>();
        Set<String> accountNumbers = new Set<String>{'123asdf', '456asdf', '789asdf'};
        
        Integer counter = 1;
        for (String accNumber : accountNumbers) {
            Legal_Advisor__c advisor = new Legal_Advisor__c(
                Account_Number__c = accNumber,
                Account_Name__c = 'Test User #' + counter,
                Account_Status__c = 'Enabled',
                As_of_Date__c = Date.valueOf('2019-12-0' + counter)
            );
            counter++;
            legalAdvisors.add(advisor);
        }
        
        Test.startTest();
        insert legalAdvisors;
        Test.stopTest();
        
        Map<String, Legal_Advisor__c> advisorMap = new Map<String, Legal_Advisor__c>();
        advisorMap = ucl_ExistingAdvisorFetcher.fetchAdvisors(advisorMap);
        
        System.assertEquals(accountNumbers.size(), advisorMap.size(), 'Map size should match the input set size');
        
        for (Legal_Advisor__c advisor : legalAdvisors) {
            Legal_Advisor__c fetchedAdvisor = advisorMap.get(advisor.Account_Number__c);
            System.assertNotEquals(null, fetchedAdvisor, 'Fetched advisor should not be null');
        }
    }
}