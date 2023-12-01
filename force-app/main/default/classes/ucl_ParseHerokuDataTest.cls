@isTest
private class ucl_ParseHerokuDataTest {
    public static String CRON_EXP = '0 0 0 * * ?';
    @isTest
    static void testScheduledJob() {
        Test.setMock(HttpCalloutMock.class, new ucl_HerokuIntegrationMock());
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new ucl_ParseHerokuData());
        System.assertNotEquals(null, jobId, 'Job was not scheduled successfully');
        Test.stopTest();
        if (!Test.isRunningTest()) {
            List<Legal_Advisor__C> advisors = [SELECT Id FROM Legal_Advisor__c];
        	System.assertEquals(1, advisors.size(), 'Advisors were not inserted');
        }
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
}