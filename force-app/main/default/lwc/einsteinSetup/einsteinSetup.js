import { LightningElement } from 'lwc'
import saveCredential from '@salesforce/apex/EinsteinSetupController.saveCredential'
import importCredential from '@salesforce/apex/EinsteinSetupController.importCredential'
import testEinsteinAPI from '@salesforce/apex/EinsteinSetupController.testEinsteinAPI'

export default class EinsteinSetup extends LightningElement {
    cert
    email
    valid = false

    connectedCallback() {
        importCredential().then((res)=>{
            this.email = res.email
            if (this.email != null) {
                testEinsteinAPI().then((res)=>{
                    this.valid = res
                }).catch(err => {
                    console.log(err)
                })
            }
        })
    }

    save() {
        const email = this.template.querySelector('.input-email').value
        saveCredential({ email: email, cert: this.cert }).then((res)=>{
            if (res != null) {
                testEinsteinAPI().then((success)=> {
                    this.valid = success
                })
            }
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
            this.cert = result.replace(/\n/g, '|')
        })
    }
}