@isTest
private class ucl_ClientProcessorTest {
    @isTest
    static void testProcessClients() {
        List<ucl_LegalAdvisor> importedLegalAdvisors = new List<ucl_LegalAdvisor>();
        String jsonData = getStaticResourceContent('GetLegalAdvisorListResource');
        importedLegalAdvisors = (List<ucl_LegalAdvisor>)JSON.deserialize(jsonData, List<ucl_LegalAdvisor>.class);
        Set<String> accNumbers = new Set<String>{'1asd', 'd5fb601e-a697-4b4e-b88a-2d8adc1639e0'};
        Map<String, Legal_Advisor__c> fetchedLegalAdvisorsMap = createLegalAdvisors(accNumbers);   
        Map<String, Client__c> testClientsMap = createTestClients(fetchedLegalAdvisorsMap.values());
        
        Legal_Advisor__c advisor = [SELECT Id, Account_Number__c FROM Legal_Advisor__c WHERE Account_Number__c = 'd5fb601e-a697-4b4e-b88a-2d8adc1639e0' LIMIT 1];
        Client__c existingClient = new Client__c(
            Client_Number__c = 'fd59a784-d763-4679-96a2-a9696b064762',
            Email__c = 'jsilverhand0@samurai.nc',
            First_Name__c = 'Johnny',
            Last_Name__c = 'Silverhand',
            Legal_Advisor__c = advisor.Id
        );
        String existingClientIdentifier = advisor.Account_Number__c + existingClient.Client_Number__c;
        testClientsMap.put(existingClientIdentifier, existingClient);

        Test.startTest();
        insert testClientsMap.values();
        List<Client__c> result = ucl_ClientProcessor.processLegalAdvisorClients(importedLegalAdvisors, fetchedLegalAdvisorsMap, testClientsMap);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Client list should not be null');
        Integer clientCount = 0;
        Boolean existingClientUpdated = false;
        Boolean existingUnidentifiedClientUpdated = false;
        for (Client__c client : result) {
    		if (client.Name == 'Kane Dearl') {
        		clientCount++;
    		}
            if (client.Name != 'Johnny Silverhand') {
                existingClientUpdated = true;
            }
            if (client.Name == 'Test User #1') {
                existingUnidentifiedClientUpdated = true;
            }
		}
        System.assertEquals(1, clientCount, 'Missing clients when all clients should have been added');
        System.assertEquals(true, existingClientUpdated, 'Existing client was not updated when it should have been');
        System.assertEquals(false, existingUnidentifiedClientUpdated, 'Existing client missing from incoming JSON data was updated when it should not');
    }
    @isTest
    static void testClientIdentifierCollector() {
        List<ucl_LegalAdvisor> importedLegalAdvisors = new List<ucl_LegalAdvisor>();
        String jsonData = getStaticResourceContent('GetLegalAdvisorListResource');
        importedLegalAdvisors = (List<ucl_LegalAdvisor>)JSON.deserialize(jsonData, List<ucl_LegalAdvisor>.class);
        
        Set<String> result = ucl_ClientProcessor.collectClientIdentifiers(importedLegalAdvisors);
        System.debug(result);
        String missingClientIdentifier = 'a209ebbb-39c6-4852-8732-82237c0674fb12afa152-8115-492b-bb49-87399ab49af8';
        
        System.assertNotEquals(null, result, 'No client identifiers found when they should have been');
        System.assertNotEquals(true, result.contains(missingClientIdentifier), 'Missing client identifiers should not have been found');
        
    }
    private static String getStaticResourceContent(String resourceName) {
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        return sr.Body.toString();
    }
    private static Map<String, Legal_Advisor__c> createLegalAdvisors(Set<String> accountNumbers) {
        Map<String, Legal_Advisor__c> legalAdvisorsMap = new Map<String, Legal_Advisor__c>();

        Integer counter = 1;
        for (String accNumber : accountNumbers) {
            Legal_Advisor__c advisor = new Legal_Advisor__c(
                Account_Number__c = accNumber,
                Account_Name__c = 'Test User #' + counter,
                Account_Status__c = 'Enabled',
                As_of_Date__c = Date.valueOf('2019-12-0' + counter)
            );
            counter++;
            legalAdvisorsMap.put(accNumber, advisor);
        }
        insert legalAdvisorsMap.values();
        return legalAdvisorsMap;
    }
    private static Map<String, Client__c> createTestClients(List<Legal_Advisor__c> legalAdvisors) {
        Map<String, Client__c> testClientsMap = new Map<String, Client__c>();
        Integer counter = 1;
        for (Legal_Advisor__c advisor : legalAdvisors) {
            String clientKey = advisor.Account_Number__c + '_CL_ASD' + counter;
            testClientsMap.put(clientKey, new Client__c(
                Client_Number__c = 'CL_ASD' + counter,
                Email__c = 'johndoe' + counter + '@test.com',
                Last_Name__c = 'Doe #' + counter,
                Legal_Advisor__c = advisor.Id
            ));
            counter++;
        }
        return testClientsMap;
    }
}