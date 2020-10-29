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

    public static Prediction scanBusinessCard(string imageUrl) {
        string modelId = 'OCRModel';
        string task = 'contact';
        string endpoint = 'https://api.einstein.ai/v2/vision/ocr';

        string contentType = HttpFormBuilder.GetContentType();
        //  Compose the form
        string form64 = '';

        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(modelId, 'UTF-8'));
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('task', task);
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', imageUrl);
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + accessToken());
        httpRequest.setEndpoint(endpoint);

        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);

        Prediction predictResponse;
        if (res.getStatusCode() == 200) {
            predictResponse = (Prediction) JSON.deserialize(res.getBody(), Prediction.class);
        }
        else {
            predictResponse = new Prediction();
            predictResponse.error = res.getBody();
        }
        return predictResponse;
    }

    public static Prediction scanTable(string imageUrl) {
        string modelId = 'tabulatev2';
        string task = 'table';
        string endpoint = 'https://api.einstein.ai/v2/vision/ocr';

        string contentType = HttpFormBuilder.GetContentType();
        //  Compose the form
        string form64 = '';

        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('modelId', EncodingUtil.urlEncode(modelId, 'UTF-8'));
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('task', task);
        form64 += HttpFormBuilder.WriteBoundary();
        form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', imageUrl);
        form64 += HttpFormBuilder.WriteBoundary(HttpFormBuilder.EndingType.CrLf);

        blob formBlob = EncodingUtil.base64Decode(form64);
        string contentLength = string.valueOf(formBlob.size());
        //  Compose the http request
        HttpRequest httpRequest = new HttpRequest();

        httpRequest.setBodyAsBlob(formBlob);
        httpRequest.setHeader('Connection', 'keep-alive');
        httpRequest.setHeader('Content-Length', contentLength);
        httpRequest.setHeader('Content-Type', contentType);
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setHeader('Authorization','Bearer ' + accessToken());
        httpRequest.setEndpoint(endpoint);

        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);

        Prediction predictResponse;
        if (res.getStatusCode() == 200) {
            predictResponse = (Prediction) JSON.deserialize(res.getBody(), Prediction.class);
            system.debug(predictResponse);
        }
        else {
            predictResponse = new Prediction();
            predictResponse.error = res.getBody();
        }
        return predictResponse;
    }
}
