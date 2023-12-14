@isTest
private class ucl_LegalAdvisorParserTest {
    @TestSetup
    static void setupTestData() {
        Legal_Advisor__c existingLegalAdvisor = new Legal_Advisor__c(
            Account_Number__c = 'd5fb601e-a697-4b4e-b88a-2d8adc1639e0',
            Account_Status__c = 'Enabled',
            Account_Name__c = 'Delphi',
            Name = 'Delphi'
        );
        insert existingLegalAdvisor;
        
        Legal_Advisor__c advisor = [SELECT Id, Account_Number__c FROM Legal_Advisor__c WHERE Account_Number__c = 'd5fb601e-a697-4b4e-b88a-2d8adc1639e0' LIMIT 1];
        Client__c existingClient = new Client__c(
            Client_Number__c = 'b38e083e-8051-4392-b40e-7ed92b132132',
            First_Name__c = 'David',
            Last_Name__c = 'Martinez',
            Email__c = 'dmartinez0@edgerunner.nc',
            Added_by_Admin__c = false,
            Legal_Advisor__c = advisor.Id
        );
        insert existingClient;
    }

    @isTest
    static void testParseLegalAdvisors() {
        Test.startTest();    
        
        Test.setMock(HttpCalloutMock.class, new ucl_HerokuIntegrationMock());
        String result = ucl_LegalAdvisorParser.parseLegalAdvisors();
        
        System.assertNotEquals('No valid legal advisors found!', result, 'Failed to retrieve advisor data');
        
        List<Legal_Advisor__c> enabledLegalAdvisors = [SELECT Id, Name, Account_Number__c, (SELECT Id, Name FROM Clients__r) FROM Legal_Advisor__c];
        System.assertEquals(1, enabledLegalAdvisors.size(), 'Expected only one Legal Advisor record to be upserted');
        List<Client__c> clients = enabledLegalAdvisors[0].Clients__r;
		System.assertEquals(2, clients.size(), 'Expected only two Clients to be associated with the Legal Advisor');
        
        List<String> clientNames = new List<String>();
		for (Client__c client : clients) {
    		clientNames.add(client.Name);
		}
        System.assertEquals(false, clientNames.contains('David Martinez'), 'Expected Existing client missing from incoming JSON to be deleted');
        String advisorName = enabledLegalAdvisors[0].Name;
        System.assertEquals('Yabox', advisorName, 'Expected the existing Legal Advisor to have its Name field updated');
        List<Legal_Advisor__c> disabledLegalAdvisors = [SELECT Id, Account_Number__c FROM Legal_Advisor__c WHERE Account_Status__c = 'Disabled'];
        System.assertEquals(0, disabledLegalAdvisors.size(), 'Only Legal Advisors with Enabled status should be upserted');

        Test.stopTest();
    }
    
    @isTest
    static void testHandleInvalidAdvisors() {
        Test.startTest();  
        Test.setMock(HttpCalloutMock.class, new ucl_HerokuIntegrationFailedMock());
        String result = ucl_LegalAdvisorParser.parseLegalAdvisors();
        Test.stopTest();
        
        System.assertEquals('Failed to retrieve Heroku data', result, 'An exception was expected but did not occur');
    }

    @isTest
    static void testHandleAdvisorFailedProcessing() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ucl_HerokuIntegrationInvalidAdvisorsMock());
        String result = ucl_LegalAdvisorParser.parseLegalAdvisors();
        Test.stopTest();
        System.assertEquals('Failed to process Legal Advisors', result, 'An exception was expected but did not occur');
    }
    @isTest
    static void testHandleClientFailedProcessing() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ucl_HerokuIntegrationInvalidClientsMock());
        String result = ucl_LegalAdvisorParser.parseLegalAdvisors();
        Test.stopTest();
        System.assertEquals('Failed to process Clients', result, 'An exception was expected but did not occur');
    }
    
    private class ucl_HerokuIntegrationMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String jsonResponse = '[{"AccountNumber":"a209ebbb-39c6-4852-8732-82237c0674fb","AccountName":"Fadeo","AccountStatus":"Disabled","AsOfDate":"2/20/2019","Clients":[{"FirstName":"Fran","LastName":"Ruddick","Email":"fruddick0@issuu.com","Phone":"390-285-2477","Address":"434 Maple Drive","ClientNumber":"12afa152-8115-492b-bb49-87399ab49af8"},{"FirstName":"Merrel","LastName":"Hewes","Email":"mhewes1@paypal.com","Phone":"246-738-5648","Address":"003 Moland Way","ClientNumber":"735add3a-0684-4bd9-beda-04dfb7575ed9"}]},{"AccountNumber":"d5fb601e-a697-4b4e-b88a-2d8adc1639e0","AccountName":"Yabox","AccountStatus":"Enabled","AsOfDate":"3/21/2019","Clients":[{"FirstName":"Konstantin","LastName":"Grinham","Email":"kgrinham0@dagondesign.com","Phone":"384-281-5985","Address":"0 Raven Way","ClientNumber":"fd59a784-d763-4679-96a2-a9696b064762"},{"FirstName":"Phillie","LastName":"Sivyer","Email":"psivyer1@pagesperso-orange.fr","Phone":"188-835-2178","Address":"6 Kings Alley","ClientNumber":"19b69131-9216-4545-a096-138b62c14e14"}]}]';

            HTTPResponse res = new HTTPResponse();
            res.setBody(jsonResponse);
            res.setStatusCode(200);

            return res;
        }    
    }
    
    private class ucl_HerokuIntegrationFailedMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String jsonResponse = '';
            HTTPResponse res = new HTTPResponse();
            res.setBody(jsonResponse);
            res.setStatusCode(404);

            return res;
        }    
    }
    private class ucl_HerokuIntegrationInvalidAdvisorsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String jsonResponse = '[{"AccountNumber": 2}]';
            HTTPResponse res = new HTTPResponse();
            res.setBody(jsonResponse);
            res.setStatusCode(200);

            return res;
        }    
    }
    private class ucl_HerokuIntegrationInvalidClientsMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String jsonResponse = '[{"AccountNumber":"d5fb601e-a697-4b4e-b88a-2d8adc1639e0","AccountName":"Yabox","AccountStatus":"Enabled","AsOfDate":"3/21/2019","Clients":[{"ClientNumber":"I am invalid!"}]}]';
            HTTPResponse res = new HTTPResponse();
            res.setBody(jsonResponse);
            res.setStatusCode(200);
            return res;
        }    
    }
    
    
}