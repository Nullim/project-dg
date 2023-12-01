public class ucl_HerokuIntegration {
    public static String getHerokuData(String herokuEndpoint) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(herokuEndpoint);
        request.setMethod('GET');
        
        Http http = new Http();
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            String errorMessage = 'Error: ' + response.getStatusCode() + ' ' + response.getStatus();
            System.debug(errorMessage);
            return null;
        }
    }
}