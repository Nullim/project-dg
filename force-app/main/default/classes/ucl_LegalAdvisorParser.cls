public class ucl_LegalAdvisorParser {
    @AuraEnabled
    public static String parseLegalAdvisors() {
        ucl_LogException logger = new ucl_LogException();
        List<ucl_LegalAdvisor> importedLegalAdvisors = new List<ucl_LegalAdvisor>();
        // Fetch Legal Advisors and Clients from Heroku
        try {
            importedLegalAdvisors = ucl_HerokuIntegration.getHerokuData();
        } catch (Exception e) {
            logger.log(e);
            return 'Failed to retrieve Heroku data';
        }

        // Collect Account and clientIdentifiers from imported data
        ucl_AccountNumberCollector.ucl_AccountInfo result = ucl_AccountNumberCollector.collectAccountNumbers(importedLegalAdvisors);

        Set<String> accountNumbers = result.accountNumbers;
        Set<String> clientIdentifiers = result.clientIdentifiers;

        // Fetch existing Legal Advisors
        Map<String, Legal_Advisor__c> fetchedLegalAdvisorMap = new Map<String, Legal_Advisor__c>();
        ucl_ExistingAdvisorFetcher.fetchAdvisors(fetchedLegalAdvisorMap);

        // Fetch existing Clients based on Client Identifiers
        Map<String, Client__c> fetchedClientMap = new Map<String, Client__c>();
        ucl_ExistingClientFetcher.fetchClients(fetchedClientMap, clientIdentifiers);

        // Process Legal Advisors to be upserted
        List<Legal_Advisor__c> legalAdvisorsToUpdate = new List<Legal_Advisor__c>();
        try {
            legalAdvisorsToUpdate = ucl_LegalAdvisorProcessor.processLegalAdvisors(importedLegalAdvisors, fetchedLegalAdvisorMap);
        } catch (Exception e) {
            logger.log(e);
            return 'Failed to process Legal Advisors';
        }

        // Perform Legal Advisor upsert and retrieve them
        Map<String, Legal_Advisor__c> updatedLegalAdvisorMap = performAdvisorDMLOperations(legalAdvisorsToUpdate);
        Integer legalAdvisorsUpserted = updatedLegalAdvisorMap.size();

        // Process Clients to be upserted
        List<Client__c> clientsToUpdate = new List<Client__c>();
        try {
            clientsToUpdate = ucl_ClientProcessor.processLegalAdvisorClients(
                importedLegalAdvisors,
                updatedLegalAdvisorMap,
                fetchedClientMap
            );
        } catch (Exception e) {
            logger.log(e);
            return 'Failed to process Clients';
        }

        // Collect Client Identifiers to identify incoming clients
        Set<String> incomingClientIdentifiers = ucl_ClientProcessor.collectClientIdentifiers(importedLegalAdvisors);

        // Select clients that are missing from the incoming JSON Data
        List<Client__c> clientsToDelete = identifyMissingClients(incomingClientIdentifiers, fetchedLegalAdvisorMap);

        // Perform Client upsert and delete clients that are not in the incoming Client data
        performClientDMLOperations(clientsToUpdate, clientsToDelete);

        Integer clientsUpserted = clientsToUpdate.size();
        Integer clientsDeleted = clientsToDelete.size();
        return 'Operations Successful! Retrieved data for ' + legalAdvisorsUpserted + ' advisors and ' + clientsUpserted + ' clients and deleted ' + clientsDeleted + ' unidentified clients';
    }

    private static List<Client__c> identifyMissingClients(
        Set<String> clientIdentifiers,
        Map<String, Legal_Advisor__c> existingLegalAdvisorMap
    ) {
        List<Client__c> clientsSelectedForDeletion = new List<Client__c>();
        List<Client__c> clientsToDeleteQuery = [
            SELECT Id
            FROM Client__c
            WHERE Legal_Advisor__c IN :existingLegalAdvisorMap.values()
            AND Client_Identifier__c NOT IN :clientIdentifiers
            AND Added_by_Admin__c = false
        ];
        clientsSelectedForDeletion.addAll(clientsToDeleteQuery);
        return clientsSelectedForDeletion;
    }

    private static void performClientDMLOperations(
        List<Client__c> updatedClients,
        List<Client__c> deletionClients
    ) {
        if (!updatedClients.isEmpty()) {
            upsert updatedClients;
        }

        if (!deletionClients.isEmpty()) {
            delete deletionClients;
        }
    }

    private static Map<String, Legal_Advisor__c> performAdvisorDMLOperations(List<Legal_Advisor__c> legalAdvisorsToUpdate) {
        Map<String, Legal_Advisor__c> updatedLegalAdvisorMap = new Map<String, Legal_Advisor__c>();
        if (!legalAdvisorsToUpdate.isEmpty()) {
            upsert legalAdvisorsToUpdate;
            // Add inserted advisors to add their clients
            for (Legal_Advisor__c updatedAdvisor : legalAdvisorsToUpdate) {
                updatedLegalAdvisorMap.put(updatedAdvisor.Account_Number__c, updatedAdvisor);
            }
        }
        return updatedLegalAdvisorMap;
    }
}