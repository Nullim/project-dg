public class ucl_ExistingClientFetcher {
    public static Map<String, Client__c> fetchClients(
        Map<String, Client__c> clientMap,
        Set<String> clientIdentifiers
    ) {
        for (Client__c existingClient : [
    		SELECT Id, Added_by_Admin__c, Client_Identifier__c
    		FROM Client__c
    		WHERE Client_Identifier__c IN :clientIdentifiers
		]) {
    		clientMap.put(existingClient.Client_Identifier__c, existingClient);
		}
        return clientMap;
    }
}