import { LightningElement, track } from 'lwc';
import fetchImages from '@salesforce/apex/SearchImagesController.fetchImages';
import sendEmail from '@salesforce/apex/SearchImagesController.sendMailToUser';

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
    @track errorMsg = ' ';
    imageTitle = '';
    email = '';
    isEmailSent = false;


    handleTitleChange(event) {
        this.imageTitle = event.detail.value;
    }

    handleSearch() {
        if(!this.imageTitle) {
            this.template.querySelector('.errorParagraph').style.color = 'red';
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
                this.errorMsg = undefined;
            })
            .catch(error => {
                this.fetchedData = undefined;
                console.log('error =====> ' + error);
                if(error) {
                    this.errorMsg = error.body.message;
                }
            })
    }

    handleSendEmail() {
        if(this.email) {
            let rows = this.template.querySelector('lightning-datatable').getSelectedRows();
            this.isEmailSent = true;
            sendEmail({emailAddress: this.email, images: rows})
                .then().catch(error => {
                    if(error) {
                        this.errorMsg = 'There was a problem with sending your e-mail'
                    }
                    console.log('error =====> ', error);
                })
            this.template.querySelector('.errorParagraph').style.color = '#74eb34';
            this.errorMsg = 'Email sent';
        } else {
            this.template.querySelector('.errorParagraph').style.color = 'red';
            this.errorMsg = 'Please fill in the e-mail address';
        }
    }

    handleEmailChange(event) {
        this.email = event.detail.value;
    }
}