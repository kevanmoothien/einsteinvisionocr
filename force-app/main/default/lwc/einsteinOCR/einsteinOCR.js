import { LightningElement } from 'lwc'
import scanBusinessCard from '@salesforce/apex/EinsteinController.scanBusinessCard'

export default class EinsteinOCR extends LightningElement {
    imageUrl
    scanResult
    scan() {
        this.scanResult = null
        this.imageUrl = this.template.querySelector('.input-image-url').value
        scanBusinessCard({ imageUrl: this.imageUrl }).then((res)=>{
            if (res != null) {
                this.scanResult = res;
            }
        })
    }
}