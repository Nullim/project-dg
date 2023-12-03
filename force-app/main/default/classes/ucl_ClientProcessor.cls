public class ucl_ClientProcessor {
    public static List<Client__c> processLegalAdvisorClients(
        List<ucl_LegalAdvisor> importedLegalAdvisors,
        Map<String, Legal_Advisor__c> updatedLegalAdvisorMap,
        Map<String, Client__c> fetchedClientsMap
    ) {
        List<Client__c> clientsToUpdate = new List<Client__c>();

        for (ucl_LegalAdvisor importedLegalAdvisor : importedLegalAdvisors) {
            if (importedLegalAdvisor.Clients != null && importedLegalAdvisor.AccountStatus != 'Disabled') {
                // Use the newly created advisors's Ids to assign their clients
                Legal_Advisor__c updatedLegalAdvisor = updatedLegalAdvisorMap.get(importedLegalAdvisor.AccountNumber);
                for (ucl_Client importedClient : importedLegalAdvisor.Clients) {
                    String clientIdentifier = importedLegalAdvisor.AccountNumber + importedClient.ClientNumber;
                    Client__c existingClient = fetchedClientsMap.get(clientIdentifier);

                    if (existingClient == null && updatedLegalAdvisor != null) {
                        Client__c newClient = createNewClient(importedClient, updatedLegalAdvisor);
                        clientsToUpdate.add(newClient);
                    } else if (existingClient != null) {
                        updateExistingClient(importedClient, existingClient);
                        clientsToUpdate.add(existingClient);
                    }
                }
            }
        }
        return clientsToUpdate;
    }
    
    public static Set<String> collectClientIdentifiers (List<ucl_LegalAdvisor> incomingLegalAdvisors) {
        Set<String> clientIdentifiers = new Set<String>();
        for (ucl_LegalAdvisor incomingLegalAdvisor : incomingLegalAdvisors) {
            if (incomingLegalAdvisor.Clients != null && incomingLegalAdvisor.AccountStatus != 'Disabled') {
                for (ucl_Client incomingClient : incomingLegalAdvisor.Clients) {
                    String clientIdentifier = incomingLegalAdvisor.AccountNumber + incomingClient.ClientNumber;
                    ClientIdentifiers.add(clientIdentifier);
                }
            }
        }
        return clientIdentifiers;
    }
    
    private static Client__c createNewClient(ucl_Client importedClient, Legal_Advisor__c updatedLegalAdvisor) {
        if (String.IsBlank(importedClient.LastName) ||
            String.IsBlank(importedClient.Email)) {
            throw new AuraHandledException('Failed to create Client: The imported Client is missing required fields.');
        }
        return new Client__c(
            First_Name__c = importedClient.FirstName,
            Last_Name__c = importedClient.LastName,
            Name = importedClient.FirstName + ' ' + importedClient.LastName,
            Email__c = importedClient.Email,
            Phone__c = importedClient.Phone,
            Address__c = importedClient.Address,
            Added_by_Admin__c = false,
            Legal_Advisor__c = updatedLegalAdvisor.Id,
            Client_Number__c = importedClient.ClientNumber
        );
    }

    private static void updateExistingClient(ucl_Client importedClient, Client__c existingClient) {
        existingClient.First_Name__c = importedClient.FirstName;
        existingClient.Last_Name__c = importedClient.LastName;
        existingClient.Name = importedClient.FirstName + ' ' + importedClient.LastName;
        existingClient.Email__c = importedClient.Email;
        existingClient.Phone__c = importedClient.Phone;
        existingClient.Address__c = importedClient.Address;
    }
}