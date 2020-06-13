public with sharing class EinsteinSetupController {
    @AuraEnabled
    public static Id saveCredential(string email, string cert) {
        EinsteinVision__c setup = EinsteinVision__c.getOrgDefaults();
        setup.Email__c = email;

        for(integer i = 1; i < 11; i++) {
            setup.put('CertificatePart_' + i + '__c', null);
        }
        list<string> chunks = cert.split('(?<=\\G.{250})');
        system.debug(chunks);
        for(integer i = 0; i < chunks.size(); i++) {
            setup.put('CertificatePart_' + (i + 1) + '__c', chunks[i]);
        }
        upsert setup;

        return setup.Id;
    }

    @AuraEnabled
    public static map<string, string> importCredential() {
        EinsteinVision__c setup = EinsteinVision__c.getOrgDefaults();
        map<string, string> outputMap = new map<string, string>{
            'email' => string.isNotBlank(setup.email__c) ? setup.email__c : ''
        };
        return outputMap;
    }

    @AuraEnabled
    public static boolean testEinsteinAPI(){
        if (String.isNotBlank(EinsteinVisionUtils.accessToken())) {
            return true;
        }
        return false;
    }
}
