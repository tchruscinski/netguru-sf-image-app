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
}