public class ucl_ParseHerokuData implements Schedulable {
    public void execute(SchedulableContext ctx) {
        performAsyncCallout();
    }
    @future(callout=true)
    public static void performAsyncCallout() {
        ucl_LegalAdvisorParser.parseLegalAdvisors();
    }
}