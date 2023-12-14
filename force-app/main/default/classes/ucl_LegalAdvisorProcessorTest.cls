@isTest
private class ucl_LegalAdvisorProcessorTest {
    @isTest
    static void testProcessLegalAdvisors() {
        List<ucl_LegalAdvisor> importedLegalAdvisors = new List<ucl_LegalAdvisor>();
        String jsonData = getStaticResourceContent('GetLegalAdvisorListResource');
        importedLegalAdvisors = (List<ucl_LegalAdvisor>)JSON.deserialize(jsonData, List<ucl_LegalAdvisor>.class);
        Map<String, Legal_Advisor__c> fetchedLegalAdvisorsMap = createLegalAdvisors();        
        
        Test.startTest();
        insert fetchedLegalAdvisorsMap.values();
        List<Legal_Advisor__c> result = ucl_LegalAdvisorProcessor.processLegalAdvisors(importedLegalAdvisors, fetchedLegalAdvisorsMap);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Unexpected number of Legal Advisors in the result');
        
        Integer enabledAdvisors = 0;
        for (Legal_Advisor__c insertedAdvisor : result) {
            System.assertNotEquals('Disabled', insertedAdvisor.Account_Status__c, 'Inserted advisor ' + insertedAdvisor.Name + ' has a disabled status');
            if ('Yabox'.equals(insertedAdvisor.Account_Name__c)) {
                enabledAdvisors++;
            }
        }
        System.assertEquals(1, enabledAdvisors, 'Advisor with Enabled status was not added when it should have been');
    }
    
    @isTest
    static void testUpdateLegalAdvisors() {
        List<ucl_LegalAdvisor> importedLegalAdvisors = new List<ucl_LegalAdvisor>();
        String jsonData = getStaticResourceContent('GetLegalAdvisorListResource');
        importedLegalAdvisors = (List<ucl_LegalAdvisor>)JSON.deserialize(jsonData, List<ucl_LegalAdvisor>.class);
        Map<String, Legal_Advisor__c> fetchedLegalAdvisorsMap = createLegalAdvisors();
        Legal_Advisor__c advisorToBeUpdated = new Legal_Advisor__c(
            Account_Number__c = 'd5fb601e-a697-4b4e-b88a-2d8adc1639e0',
            Account_Name__c= 'Delphi',
            Account_Status__c = 'Enabled',
            Name = 'Delphi',
            As_of_Date__c = Date.valueOf('2010-01-25')
        );
        fetchedLegalAdvisorsMap.put(advisorToBeUpdated.Account_Number__c, advisorToBeUpdated);
        Test.startTest();
        insert fetchedLegalAdvisorsMap.values();
        List<Legal_Advisor__c> result = ucl_LegalAdvisorProcessor.processLegalAdvisors(importedLegalAdvisors, fetchedLegalAdvisorsMap);
        Test.stopTest();
        
        System.assertEquals(1, result.size(), 'Unexpected number of Legal Advisors in the result');
        Integer outdatedAdvisors = 0;
        for (Legal_Advisor__c updatedAdvisor : result) {
            System.assertNotEquals('Disabled', updatedAdvisor.Account_Status__c, 'Inserted advisor ' + updatedAdvisor.Name + ' has a disabled status');
            if ('Delphi'.equals(updatedAdvisor.Account_Name__c)) {
                outdatedAdvisors++;
            }
        }
        System.assertEquals(0, outdatedAdvisors, 'Advisor was not updated when it should have been');
    }
    
    @isTest
    static void testDisableAdvisor() {
        List<ucl_LegalAdvisor> importedLegalAdvisors = new List<ucl_LegalAdvisor>();
        Map<String, Legal_Advisor__c> fetchedLegalAdvisorsMap = createLegalAdvisors();
        
        ucl_LegalAdvisor advisorToBeDisabled = new ucl_LegalAdvisor();
        advisorToBeDisabled.AccountNumber = 'delphiadvisor123';
        advisorToBeDisabled.AccountName = 'Delphi';
        advisorToBeDisabled.AccountStatus = 'Disabled';
        
        Legal_Advisor__c enabledAdvisor = new Legal_Advisor__c(
            Account_Number__c = 'delphiadvisor123',
            Account_Name__c= 'Yabox',
            Account_Status__c = 'Enabled',
            Name = 'Yabox'
        );
        fetchedLegalAdvisorsMap.put(enabledAdvisor.Account_Number__c, enabledAdvisor);
        importedLegalAdvisors.add(advisorToBeDisabled);
        
        Test.startTest();
        insert fetchedLegalAdvisorsMap.values();
        List<Legal_Advisor__c> result = ucl_LegalAdvisorProcessor.processLegalAdvisors(importedLegalAdvisors, fetchedLegalAdvisorsMap);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Unexpected number of Legal Advisors in the result');
        
        Integer updatedAdvisors = 0;
        for (Legal_Advisor__c disabledAdvisor : result) {            
            if ('Delphi'.equals(disabledAdvisor.Account_Name__c)) {
                updatedAdvisors++;
            }
            System.assertEquals('Disabled', disabledAdvisor.Account_Status__c, 'Advisor Status was not disabled when it should have been');
        }
        System.assertEquals(0, updatedAdvisors, 'Advisor Name was updated when it should not have been');
    }
    
    private static String getStaticResourceContent(String resourceName) {
        StaticResource sr = [SELECT Body FROM StaticResource WHERE Name = :resourceName LIMIT 1];
        return sr.Body.toString();
    }
    private static Map<String, Legal_Advisor__c> createLegalAdvisors() {
        Map<String, Legal_Advisor__c> legalAdvisorsMap = new Map<String, Legal_Advisor__c>();
        Set<String> accountNumbers = new Set<String>{'1asd', '2asd', '3asd'};

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
        return legalAdvisorsMap;
    }
}