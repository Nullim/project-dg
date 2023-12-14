@isTest
private class ucl_ExceptionLogTriggerTest {
    @isTest
    static void testSentMail() {
        Exception_Log__c log = new Exception_Log__c (
            Exception_Message__c = 'I am an error',
            Exception_Type__c = 'I am an error type'
        );
        Test.startTest();
        insert log;
        Integer emailInvocations = Limits.getEmailInvocations();
        Test.stopTest();
        system.assertEquals(1, emailInvocations, 'An email should be sent');
    }
}