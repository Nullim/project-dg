public class ucl_LegalAdvisorProcessor {
    public static List<Legal_Advisor__c> processLegalAdvisors(
        List<ucl_LegalAdvisor> importedLegalAdvisors,
        Map<String, Legal_Advisor__c> fetchedLegalAdvisorsMap
    ) {
        List<Legal_Advisor__c> legalAdvisorsToUpdate = new List<Legal_Advisor__c>();

        for (ucl_LegalAdvisor importedLegalAdvisor : importedLegalAdvisors) {
            Legal_Advisor__c fetchedLegalAdvisor = fetchedLegalAdvisorsMap.get(importedLegalAdvisor.AccountNumber);

            if (fetchedLegalAdvisor == null && importedLegalAdvisor.AccountStatus != 'Disabled') {
                Legal_Advisor__c newLegalAdvisor = createNewLegalAdvisor(importedLegalAdvisor);
                legalAdvisorsToUpdate.add(newLegalAdvisor);
            } else if (fetchedLegalAdvisor != null) {
                updateExistingLegalAdvisor(importedLegalAdvisor, fetchedLegalAdvisor, legalAdvisorsToUpdate);
            }
        }

        return legalAdvisorsToUpdate;
    }

    private static Legal_Advisor__c createNewLegalAdvisor(ucl_LegalAdvisor importedLegalAdvisor) {
        return new Legal_Advisor__c(
            Account_Number__c = importedLegalAdvisor.AccountNumber,
            Account_Name__c = importedLegalAdvisor.AccountName,
            Name = importedLegalAdvisor.AccountName,
            As_of_Date__c = dateFormatter(importedLegalAdvisor.AsOfDate),
            Account_Status__c = importedLegalAdvisor.AccountStatus
        );
    }

    private static void updateExistingLegalAdvisor(
        ucl_LegalAdvisor importedLegalAdvisor,
        Legal_Advisor__c fetchedLegalAdvisor,
        List<Legal_Advisor__c> legalAdvisorsToUpdate
    ) {
        if (importedLegalAdvisor.AccountStatus == 'Disabled') {
            fetchedLegalAdvisor.Account_Status__c = 'Disabled';
            legalAdvisorsToUpdate.add(fetchedLegalAdvisor);
        } else if (fetchedLegalAdvisor.Account_Status__c != 'Disabled') {
            fetchedLegalAdvisor.As_of_Date__c = dateFormatter(importedLegalAdvisor.AsOfDate);
            fetchedLegalAdvisor.Account_Name__c = importedLegalAdvisor.AccountName;
            fetchedLegalAdvisor.Name = importedLegalAdvisor.AccountName;
            legalAdvisorsToUpdate.add(fetchedLegalAdvisor);
        }
    }

    private static Date dateFormatter(String dateString) {
        List<String> dateComponents = dateString.split('/');
        Integer year = Integer.valueOf(dateComponents[2]);
        Integer month = Integer.valueOf(dateComponents[0]);
        Integer day = Integer.valueOf(dateComponents[1]);
        return Date.newInstance(year, month, day);
    }
}