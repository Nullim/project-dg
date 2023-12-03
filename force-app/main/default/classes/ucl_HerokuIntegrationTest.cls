@isTest
private class ucl_HerokuIntegrationTest {
    @isTest static void testGetHerokuCalloutSuccess() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('GetLegalAdvisorResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);
        List<ucl_LegalAdvisor> result = ucl_HerokuIntegration.getHerokuData();
        
        System.assertNotEquals(null, result, 'The callout returned a null response.');
        System.assertEquals(1, result.size(), 'The response should contain exactly one Legal Advisor.');

    	ucl_LegalAdvisor legalAdvisor = result[0];
    	System.assertEquals('Centidel', legalAdvisor.AccountName, 'Account name is not "Centidel"');
    }
    
    @isTest static void testGetHerokuCalloutFail() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    	mock.setStaticResource('GetLegalAdvisorResource');
    	mock.setStatusCode(500);
    	Test.setMock(HttpCalloutMock.class, mock);

        Exception receivedError;
        try {
            ucl_HerokuIntegration.getHerokuData();
            System.assert(false, 'Expected an exception, but it did not occur');
        } catch (Exception e) {
            receivedError = e;
        }
    	System.assertNotEquals(null, receivedError, 'The callout did not handle the error properly.');
    }
}