public class Utils {
    /**
     * Returns integration endpoint record details defined in the custom metadata.
     * @param integrationEndpointName integration endpoint name
     * @return IntegrationEndpoint__mdt record
     */
    public static IntegrationEndpoint__mdt getIntegrationEndpoint(String integrationEndpointName) {
        try {
            return [
                SELECT EndpointAddress__c, IsActive__c, IsLogActive__c
                FROM IntegrationEndpoint__mdt
                WHERE DeveloperName =: integrationEndpointName
                LIMIT 1
            ];
        } catch(QueryException ex) {
            throw new CustomException(Label.NoIntegrationEndpoint);
        }
    }
}