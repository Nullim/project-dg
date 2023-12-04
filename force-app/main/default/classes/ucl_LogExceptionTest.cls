@isTest
private class ucl_LogExceptionTest {

    @isTest
    static void testLogException() {
        ucl_LogException logger = new ucl_LogException();
        Exception errorResult;

        Test.startTest();
        try {
            Integer a = 1 / 0;
            System.assert(false, 'Exception did not occur');
        } catch (Exception ex) {
            errorResult = ex;
            logger.log(ex);
        }

        List<Exception_Log__c> logs = [SELECT Stack_Trace__c, Class_Name__c, Method_Name__c,
                                       Line_Number__c, Exception_Type__c,
                                       Exception_Cause__c, Exception_Message__c
                                       FROM Exception_Log__c LIMIT 1];
        Test.stopTest();
        System.assertNotEquals(null, errorResult, 'Expected an exception, received null instead');

        System.assertNotEquals(null, logs[0], 'Expected at least one result, received null');
        System.assertNotEquals(null, logs[0].Stack_Trace__c, 'Expected stack trace to not be null');
        System.assertNotEquals(null, logs[0].Class_Name__c, 'Expected class name to not be null');
        System.assertNotEquals(null, logs[0].Method_Name__c, 'Expected method name to not be null');
        System.assertNotEquals(null, logs[0].Line_Number__c, 'Expected line number to not be null');
        System.assertNotEquals(null, logs[0].Exception_Type__c, 'Expected exception type to not be null');
        System.assertNotEquals(null, logs[0].Exception_Message__c, 'Expected exception message to not be null');
    }
}