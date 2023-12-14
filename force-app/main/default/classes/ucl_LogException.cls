public class ucl_LogException extends Exception {
    public String StackTrace { get; set; }
    public String ClassName { get; set; }
    public String MethodName { get; set; }

    public void log(Exception ex) {
        extractExceptionData(ex);
        writeToObject(ex);
    }

    private void extractExceptionData(Exception ex) {
        StackTrace = ex.getStackTraceString().substringBefore('\n');
        ClassName = StackTrace.substringAfter('.').substringBefore('.');
        MethodName = StackTrace
            .substringBefore(':')
            .substringAfter(className)
            .substringAfter('.');
    }

    private void writeToObject(Exception ex) {
        Exception_Log__c log = new Exception_Log__c(
            Stack_Trace__c = ex.getStackTraceString(),
            Class_Name__c = ClassName,
            Method_Name__c = MethodName,
            Line_Number__c = ex.getLineNumber(),
            Exception_Type__c = ex.getTypeName(),
            Exception_Cause__c = String.valueOf(ex.getCause()),
            Exception_Message__c = ex.getMessage()
        );
        insert log;
    }
}