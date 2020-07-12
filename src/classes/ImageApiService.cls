/**
* Class implementing communication with the Image API
 */
public class ImageApiService {

    public static final IntegrationEndpoint__mdt IMAGE_API_INTEGRATION_ENDPOINT = Utils.getIntegrationEndpoint(
        Constants.IMAGE_API_INTEGRATION_ENDPOINT
    );

    public class PhotosCallout {
        private HttpRequest request;
        private Http httpInitiation;
        private Boolean isException = false;

        public PhotosCallout() {
            this.httpInitiation = new Http();
            this.request = new HttpRequest();
            this.request.setHeader(Constants.CONTENT_TYPE, Constants.CONTENT_TYPE_APP_JSON);
            this.request.setMethod(Constants.REQUEST_GET_METHOD);
            this.request.setEndpoint(IMAGE_API_INTEGRATION_ENDPOINT.EndpointAddress__c);
        }

        /**
        *  Method sending the HTTP request
        * @return HTTPResponse
        */
        public HTTPResponse sendRequest() {
            HTTPResponse response = this.httpInitiation.send(request);
            if (response.getStatusCode() != Constants.API_SUCCESS_CODE && response.getStatusCode() != Constants.API_BAD_REQUEST_CODE) {
                isException = true;
            }

            if (IMAGE_API_INTEGRATION_ENDPOINT.IsLogActive__c) {
                saveIntegrationLog(response);
            }

            return response;
        }

        private void saveIntegrationLog(HTTPResponse response) {
            insert new IntegrationLog__c(
                RequestMessage__c = request.getBody(),
                ResponseMessage__c = response.getBody().substring(0, Constants.TEXT_AREA_LONG_SIZE - 1),
                CommunicationTime__c = System.now(),
                ErrorOccurred__c = isException
            );
        }

    }

    /**
    *  Method fetching photos from the Image API
    */
    public static void fetchPhotos() {
        PhotosCallout callout = new PhotosCallout();
        List<ImageApiJsonParser> parsedImages = ImageApiJsonParser.parse(callout.sendRequest().getBody());
        insertImages(JSON.serialize(parsedImages));
    }

    @future
    private static void insertImages(String imagesJson) {
        List<ImageApiJsonParser> parsedImages = (List<ImageApiJsonParser>) JSON.deserialize(
            imagesJson, List<ImageApiJsonParser>.class
        );

        List<Image__c> imagesToUpsert = new List<Image__c>();
        Set<String> incomingImageIds = new Set<String>();
        for(ImageApiJsonParser imageParser : parsedImages) {
            imagesToUpsert.add(
                new Image__c(
                    ImageApiId__c = imageParser.id,
                    AlbumId__c = imageParser.albumId,
                    ImageUrl__c = imageParser.url,
                    ImageTitle__c = imageParser.title,
                    ThumbnailUrl__c = imageParser.thumbnailUrl
                )
            );
            incomingImageIds.add(imageParser.id);
        }

        Schema.SObjectField imageId = Image__c.Fields.ImageApiId__c;
        Database.UpsertResult [] upsertResults = Database.upsert(imagesToUpsert, imageId,false);
        String errorMessage = '';
        Boolean isError = false;
        for(Integer i = 0; i < upsertResults.size(); i++) {
            if (!upsertResults[i].isSuccess()) {
                isError = true;
                for (Database.Error er : upsertResults[i].getErrors()) {
                    errorMessage += er.getStatusCode() + ': ' + er.getMessage() + '\n';
                }
            }
        }

        if(isError) {
            insert new ErrorLog__c(
                ErrorCode__c = Constants.ERROR_LOG_IMAGE_API_UPSERT_CODE,
                ErrorMessage__c = errorMessage
            );
        }
        deleteImages(incomingImageIds);
    }

    /**
    *  IMPORTANT: Because no specification was provided I assume that the Image Id in the API (set as External Id in Salesforce)
    *  is the identifier which should be used to delete the photos in Salesforce when they disappear
    */
    private static void deleteImages(Set<String> imageIds) {
        List<Image__c> imagesToDelete = [
            SELECT Id
            FROM Image__c
            WHERE ImageApiId__c NOT IN :imageIds
        ];

        Database.DeleteResult [] deleteResults = Database.delete(imagesToDelete, false);
        String errorMessage = '';
        Boolean isError = false;
        for(Integer i = 0; i < deleteResults.size(); i++) {
            if (!deleteResults[i].isSuccess()) {
                isError = true;
                for (Database.Error er : deleteResults[i].getErrors()) {
                    errorMessage += er.getStatusCode() + ': ' + er.getMessage() + '\n';
                }
            }
        }

        if(isError) {
            insert new ErrorLog__c(
                ErrorCode__c = Constants.ERROR_LOG_IMAGE_API_DELETE_CODE,
                ErrorMessage__c = errorMessage
            );
        }
    }
}