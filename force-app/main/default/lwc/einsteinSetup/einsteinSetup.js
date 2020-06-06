import { LightningElement, api } from 'lwc'
import saveCredential from '@salesforce/apex/EinsteinSetupController.saveCredential'
import importCredential from '@salesforce/apex/EinsteinSetupController.importCredential'

export default class EinsteinSetup extends LightningElement {
    cert
    email

    connectedCallback() {
        importCredential().then((res)=>{
            console.log(res)
            this.email = res.email
        })
    }

    save() {
        console.log('omodmeodemode')
        const email = this.template.querySelector('.input-email').value
        saveCredential({ email: email, cert: this.cert }).then((res)=>{
            console.log(res)
        })
    }

    handleFileChange(event) {
        const file = event.detail.files[0]
        this.processCertificateFile(file)
    }

    fileReader(file, callback) {
        let reader = new FileReader()
        reader.onload = ()=>{
            let fileContents = reader.result
            callback(null, fileContents)
        }
        reader.readAsText(file)
    }

    processCertificateFile(file) {
        this.fileReader(file, (error, result)=>{
            this.cert = result.replace(/\r\n/g, '|')
        })
    }
}