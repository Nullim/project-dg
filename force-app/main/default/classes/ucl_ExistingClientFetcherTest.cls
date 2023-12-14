@isTest
private class ucl_ExistingClientFetcherTest {
	@isTest
    static void testFetchClients() {
        List<Legal_Advisor__c> legalAdvisors = createLegalAdvisors();
        List<Client__c> testClients = createTestClients(legalAdvisors);
        
        test.startTest();
        insert testClients;
        test.stopTest();
        
        Set<String> clientIdentifiers = new Set<String>{'12asd23CL_ASD1'};
        Map<String, Client__c> clientMap = new Map<String, Client__c>();
        Map<String, Client__c> result = Ucl_ExistingClientFetcher.fetchClients(clientMap, clientIdentifiers);

        System.assertEquals(clientIdentifiers.size(), result.size(), 'Result map should have the same size as clientIdentifiers');

        for (String identifier : clientIdentifiers) {
            System.assert(result.containsKey(identifier), 'Result map should contain the client with identifier: ' + identifier);
            Client__c fetchedClient = result.get(identifier);
            System.assertEquals('12asd23CL_ASD1', fetchedClient.Client_Identifier__c, 'Fetched client must have an identifier matching their Legal Advisor"s account number + their client number');
        }
    }
    
    @isTest
    static void testFetchIdentifiedClients() {
        List<Legal_Advisor__c> legalAdvisors = createLegalAdvisors();
        List<Client__c> testClients = createTestClients(legalAdvisors);
        
        for(Legal_Advisor__c advisor : legalAdvisors) {
            testClients.add(new Client__c(
            	Client_Number__c = 'UNIDENTIFIED',
            	Email__c = 'janedoe@test.com',
            	Last_Name__c = 'Unidentified',
            	Legal_Advisor__c = advisor.Id
        	));
        }
        
        test.startTest();
        insert testClients;
        test.stopTest();
        
        Set<String> clientIdentifiers = new Set<String>{'12asd23CL_ASD1'};
        Map<String, Client__c> clientMap = new Map<String, Client__c>();
        Map<String, Client__c> result = Ucl_ExistingClientFetcher.fetchClients(clientMap, clientIdentifiers);

        System.assertNotEquals(true, result.containsKey('12asd23UNIDENTIFIED'), 'Result map should not contain the unidentified client');
        System.assertEquals(true, result.containsKey('12asd23CL_ASD1'), 'Result map should contain the identified client from the incoming data');
    }
    
    private static List<Legal_Advisor__c> createLegalAdvisors() {
        List<Legal_Advisor__c> legalAdvisors = new List<Legal_Advisor__c>();
        Set<String> accountNumbers = new Set<String>{'12asd23'};

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

        insert legalAdvisors;
        return legalAdvisors;
    }

    private static List<Client__c> createTestClients(List<Legal_Advisor__c> legalAdvisors) {
        List<Client__c> testClients = new List<Client__c>();

        Integer counter = 1;
        for (Legal_Advisor__c advisor : legalAdvisors) {
            testClients.add(new Client__c(
                Client_Number__c = 'CL_ASD' + counter,
                Email__c = 'johndoe' + counter + '@test.com',
                Last_Name__c = 'Doe #' + counter,
                Legal_Advisor__c = advisor.Id
            ));
            counter++;
        }
        return testClients;
    }
}