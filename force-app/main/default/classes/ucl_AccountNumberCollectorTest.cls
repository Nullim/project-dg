@isTest
private class ucl_AccountNumberCollectorTest {
    @isTest static void testCollectAccountNumbers() {
        ucl_LegalAdvisor legalAdvisor = new ucl_LegalAdvisor();
        legalAdvisor.AccountNumber = '123';
        
        ucl_Client client = new ucl_Client();
        client.ClientNumber = '456';
        
        legalAdvisor.Clients = new List<ucl_Client>{client};

        List<ucl_LegalAdvisor> legalAdvisors = new List<ucl_LegalAdvisor>{legalAdvisor};

        ucl_AccountNumberCollector.ucl_AccountInfo result = ucl_AccountNumberCollector.collectAccountNumbers(legalAdvisors);

        System.assertEquals(1, result.accountNumbers.size(), 'Incorrect number of account numbers');
        System.assertEquals(1, result.clientIdentifiers.size(), 'Incorrect number of client identifiers');
        System.assert(result.accountNumbers.contains('123'), 'Account number 123 not found');
        System.assert(result.clientIdentifiers.contains('123456'), 'Client identifier 123456 not found');
    }
    @isTest static void testCollectMultipleAccountNumbers() {
        ucl_LegalAdvisor legalAdvisor1 = new ucl_LegalAdvisor();
        ucl_LegalAdvisor legalAdvisor2 = new ucl_LegalAdvisor();
        legalAdvisor1.AccountNumber = '123';
        legalAdvisor2.AccountNumber = '456';
        
        ucl_Client client1 = new ucl_Client();
        ucl_Client client2 = new ucl_Client();
        client1.ClientNumber = '111';
        client2.ClientNumber = '222';
        
        legalAdvisor1.Clients = new List<ucl_Client>{client1, client2};
        legalAdvisor2.Clients = new List<ucl_Client>{client1, client2};

        List<ucl_LegalAdvisor> legalAdvisors = new List<ucl_LegalAdvisor>{legalAdvisor1, legalAdvisor2};
            
        ucl_AccountNumberCollector.ucl_AccountInfo result = ucl_AccountNumberCollector.collectAccountNumbers(legalAdvisors);
        
        System.assertEquals(2, result.accountNumbers.size(), 'Incorrect number of account numbers');
        System.assert(result.accountNumbers.contains('123'), 'Account number 123 not found');
        System.assert(result.accountNumbers.contains('456'), 'Account number 456 not found');
        
        System.assertEquals(4, result.clientIdentifiers.size(), 'Incorrect number of client identifiers');    
        System.assert(result.clientIdentifiers.contains('123111'), 'Client identifier 123111 not found');
        System.assert(result.clientIdentifiers.contains('123222'), 'Client identifier 123222 not found');
        System.assert(result.clientIdentifiers.contains('456111'), 'Client identifier 456111 not found');
        System.assert(result.clientIdentifiers.contains('456222'), 'Client identifier 456222 not found');
    }
    @isTest static void testMissingClients() {
        ucl_LegalAdvisor legalAdvisor = new ucl_LegalAdvisor();
        legalAdvisor.AccountNumber = '123';
        legalAdvisor.Clients = null;
        
        List<ucl_LegalAdvisor> legalAdvisors = new List<ucl_LegalAdvisor>{legalAdvisor};
        ucl_AccountNumberCollector.ucl_AccountInfo result = ucl_AccountNumberCollector.collectAccountNumbers(legalAdvisors);
        
        System.assertEquals(1, result.accountNumbers.size(), 'Incorrect number of account numbers');
        System.assertEquals(0, result.clientIdentifiers.size(), 'Client identifiers should be empty when Clients is null');
        System.assert(result.accountNumbers.contains('123'), 'Account number 123 not found');
    }
}