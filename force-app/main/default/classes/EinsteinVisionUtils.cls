public with sharing class EinsteinVisionUtils {
    private static map<string, string> visionSetting;
    
    public static string accessToken() {
        JWT jwt = new JWT('RS256');
        // jwt.cert = 'JWTCert'; // Uncomment this if you used a Salesforce certificate to sign up for an Einstein Platform account
        jwt.pkcs8 = visionSettingMap().get('certificate'); // Comment this if you are using jwt.cert
        jwt.iss = 'developer.force.com';
        jwt.sub = visionSettingMap().get('email');
        jwt.aud = 'https://api.einstein.ai/v2/oauth2/token';
        jwt.exp = '3600';
        String access_token = JWTBearerFlow.getAccessToken('https://api.einstein.ai/v2/oauth2/token', jwt);
        return access_token; 
    }

    public static map<string, string> visionSettingMap() {
        if (visionSetting != null) { return visionSetting; }
        EinsteinVision__c vision = EinsteinVision__c.getOrgDefaults();
        visionSetting = new map<string, string> {
            'email' => vision.Email__c,
            'certificate' => certificate(vision)
        };
        return visionSetting;
    }

    public static string certificate(EinsteinVision__c setting) {
        string keyContents = '';
        for(integer i = 1; i < 11; i++) {
            string part = sanitizeString(setting.get('CertificatePart_' + i + '__c'));
            keyContents += part;
        }
        keyContents = keyContents.replace('-----BEGIN RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('|', '');
        return keyContents;
    }

    private static string sanitizeString(object text) {
        if (string.isBlank(string.valueof(text))) {
            text = '';
        }
        return string.valueOf(text);
    }
}
