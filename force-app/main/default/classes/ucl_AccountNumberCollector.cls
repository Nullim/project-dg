public class ucl_AccountNumberCollector {
    public class ucl_AccountInfo {
        public Set<String> accountNumbers { get; set; }
        public Set<String> clientIdentifiers { get; set; }

        public ucl_AccountInfo() {
            this.accountNumbers = new Set<String>();
            this.clientIdentifiers = new Set<String>();
        }
    }

    public static ucl_AccountInfo collectAccountNumbers(List<ucl_LegalAdvisor> importedLegalAdvisors) {
        ucl_AccountInfo result = new ucl_AccountInfo();

        for (ucl_LegalAdvisor importedLegalAdvisor : importedLegalAdvisors) {
            result.accountNumbers.add(importedLegalAdvisor.AccountNumber);

            if (importedLegalAdvisor.Clients != null) {
                for (ucl_Client importedClient : importedLegalAdvisor.Clients) {
                    String clientIdentifier = importedLegalAdvisor.AccountNumber + importedClient.ClientNumber;
                    result.clientIdentifiers.add(clientIdentifier);
                }
            }
        }

        return result;
    }
}