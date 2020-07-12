/**
* Apex Controller for the searchImages Lightning Web Component
 */
public with sharing class SearchImagesController {

    @AuraEnabled(Cacheable = true)
    public static List<Image__c> fetchImages(String imageTitle) {
        imageTitle = '%' + imageTitle + '%';
        List<Image__c> images = new List<Image__c>();
        images = [
            SELECT  Id, Name, ImageTitle__c, ImageApiId__c, ImageUrl__c
            FROM Image__c
            WHERE ImageTitle__c LIKE :imageTitle
        ];
        if(images.isEmpty()) {
            throw new AuraHandledException(Label.NoRecordsFound);
        }
        return images;
    }

    @AuraEnabled
    public static void sendMailToUser(String emailAddress, List<Image__c> images) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new List<String>{emailAddress};
        message.subject = Constants.IMAGES_EMAIL_SUBJECT;

        for(Integer i = 0; i < images.size(); i++) {
            message.plainTextBody += String.valueOf(i+1) + ') Image Name: ' + images[i].Name + ', Image URL: ' + images[i].ImageUrl__c + '\n';
        }

        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{message};
        try {
            Messaging.sendEmail(messages);
        } catch (Exception ex) {
            insert new ErrorLog__c(
                ErrorCode__c = Constants.ERROR_LOG_EMAIL_SERVICE_ERROR,
                ErrorMessage__c = ex.getMessage()
            );
            throw new CustomException(ex.getMessage());
        }
    }
}