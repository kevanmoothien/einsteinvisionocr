import { LightningElement } from 'lwc'
import scanBusinessCard from '@salesforce/apex/EinsteinController.scanBusinessCard'
import scanTable from '@salesforce/apex/EinsteinController.scanTable'

export default class EinsteinOCR extends LightningElement {
    imageUrl
    scanResult
    scan() {
        this.scanResult = null
        this.imageUrl = this.template.querySelector('.input-business-url').value
        scanBusinessCard({ imageUrl: this.imageUrl }).then((res)=>{
            if (res != null) {
                this.scanResult = res;
            }
        })
    }

    scanTable() {
        this.scanResult = null
        this.imageUrl = this.template.querySelector('.input-table-url').value
        scanTable({ imageUrl: this.imageUrl }).then((res)=>{
            if (res != null) {
                this.scanResult = res;
            }
        })
    }
}
