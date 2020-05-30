import { LightningElement, api } from 'lwc';

export default class EinsteinSetup extends LightningElement {
    @api setupRecordId

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        alert("No. of files uploaded : " + uploadedFiles.length);
    }
}