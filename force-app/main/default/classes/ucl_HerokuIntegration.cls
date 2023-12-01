public class ucl_HerokuIntegration {
    public static List<ucl_LegalAdvisor> getHerokuData() {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://altimetrik-bootcamp.herokuapp.com/LegalAccounts');
        request.setMethod('GET');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            String responseData = response.getBody();
            return ucl_HerokuIntegration.deserializeJSONString(responseData);
        } else {
            String errorMessage = 'Error: ' + response.getStatusCode() + ' ' + response.getStatus();
            return null;
        }
    }
    private static List<ucl_LegalAdvisor> deserializeJSONString(String incomingJSON) {
        List<ucl_LegalAdvisor> legalAdvisors = (List<ucl_LegalAdvisor>)JSON.deserialize(incomingJSON, List<ucl_LegalAdvisor>.class);
        return legalAdvisors;
    }
}