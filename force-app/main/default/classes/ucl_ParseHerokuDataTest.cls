@isTest
private class ucl_ParseHerokuDataTest {
    public static String CRON_EXP = '0 0 0 * * ?';
    @isTest
    static void testScheduledJob() {
        Test.setMock(HttpCalloutMock.class, new ucl_HerokuIntegrationMock());
        
        insertExceptionLogs();
        
        Test.startTest();
        
        ucl_ParseHerokuData sch = new ucl_ParseHerokuData();
        sch.execute(null);
        
        Test.stopTest();
        
        List<Legal_Advisor__c> advisors = [SELECT Id FROM Legal_Advisor__c];
        List<Exception_Log__c> logs = [SELECT Id, CreatedDate FROM Exception_Log__c];
        System.assertEquals(1, advisors.size(), 'Advisors were not inserted');
        System.assertEquals(1, logs.size(), 'Old error log was not deleted');
    }
	private static void insertExceptionLogs() {
    List<Exception_Log__c> exceptionLogs = new List<Exception_Log__c>();
    Exception_Log__c newLog = new Exception_Log__c(
        Stack_Trace__c = 'test stack trace',
        Class_Name__c = 'TestClassName',
        Method_Name__c = 'TestMethodName',
        Line_Number__c = 456,
        Exception_Type__c = 'test type',
        Exception_Cause__c = 'test cause',
        Exception_Message__c = 'A error occured!'
    );
    exceptionLogs.add(newLog);
        
    Exception_Log__c oldLog = new Exception_Log__c(
        Stack_Trace__c = 'test stack trace',
        Class_Name__c = 'TestClassName',
        Method_Name__c = 'TestMethodName',
        Line_Number__c = 123,
        Exception_Type__c = 'test type',
        Exception_Cause__c = 'test cause',
        Exception_Message__c = 'An error occured!'
    );
    exceptionLogs.add(oldLog);
    insert exceptionLogs;
    Test.setCreatedDate(oldLog.Id, DateTime.now().addDays(-31));
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