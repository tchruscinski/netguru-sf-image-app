import { LightningElement, track } from 'lwc';
import fetchImages from '@salesforce/apex/SearchImagesController.fetchImages';

const columns = [
    {
        label: 'Name',
        fieldName: 'Id',
        type: 'url',
        typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}
    }, {
        label: 'Image Title',
        fieldName: 'ImageTitle__c',
    }, {
        label: 'Image API Id',
        fieldName: 'ImageApiId__c',
        type: 'text',
    }, {
        label: 'Image URL',
        fieldName: 'ImageUrl__c',
        type: 'text'
    },
];

export default class searchImages extends LightningElement {
    @track fetchedData;
    @track columns = columns;
    @track errorMsg = '';
    imageTitle = '';


    handleTitleChange(event) {
        this.imageTitle = event.detail.value;
    }

    handleSearch() {
        if(!this.imageTitle) {
            this.errorMsg = 'Please enter an image title';
            this.fetchedData = undefined;
            return;
        }

        fetchImages({imageTitle : this.imageTitle})
            .then(result => {
                let resultsClone = JSON.parse(JSON.stringify(result));
                resultsClone.forEach((record) => {
                    record.Id = '/' + record.Id;
                });
                this.fetchedData = resultsClone;
            })
            .catch(error => {
                this.fetchedData = undefined;
                window.console.log('error =====> '+JSON.stringify(error));
                console.log('error =====> '+error);
                if(error) {
                    this.errorMsg = error.body.message;
                }
            })
    }
}