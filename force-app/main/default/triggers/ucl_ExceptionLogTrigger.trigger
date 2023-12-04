trigger ucl_ExceptionLogTrigger on Exception_Log__c (before insert) {
    List<User> adminUsers = new List<User>([SELECT Email FROM User WHERE Profile.Name = 'System Administrator']);

    List<String> adminEmails = new List<String>();
    for (User adminUser : adminUsers) {
        adminEmails.add(adminUser.Email);
    }

    List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();

    Exception_Log__c exceptionLog = Trigger.new[0];
    
    Messaging.SingleEmailMessage adminNotification = new Messaging.SingleEmailMessage();
    adminNotification.setSubject('An error log was created in the UCL app');
    Date today = System.today();
    Integer day = today.day();
    Integer month = today.month();
    Integer year = today.year();
    String body = 'An error log was generated on ' + day + '/' + month + '/' + year + '\n';
    body += 'Here is a summary of what happened: \n';
    body += 'Exception Type: ' + exceptionLog.Exception_Type__c + '\n';
    body += 'Exception Message: ' + exceptionLog.Exception_Message__c + '\n';
    body += 'For more information, please check the generated error log in your Salesforce organization';
    
    adminNotification.setPlainTextBody(body);
    adminNotification.setToAddresses(adminEmails);
    adminNotification.saveAsActivity =  false;

    notifications.add(adminNotification);
    Messaging.sendEmail(notifications);
}