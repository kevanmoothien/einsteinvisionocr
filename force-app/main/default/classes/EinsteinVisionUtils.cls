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

        system.debug('>>>> ' + res.getBody());
        system.debug('>>>> ' + res.getStatusCode());
        Prediction predictResponse;
        if (res.getStatusCode() == 200) {
            predictResponse = (Prediction) JSON.deserialize(res.getBody(), Prediction.class);
            system.debug('>>>> **** **** **** ' + predictResponse);
        }
        else {
            predictResponse = new Prediction();
            predictResponse.error = res.getBody();
        }
        return predictResponse;
    }

    public static void scanImage() {
        string accessToken = accessToken();
        // string imageUrl = 'http://www.asianbusinesscards.com/wp-content/uploads/2019/03/chinese-business-card-translation-samples-walmart-890-eng.jpg';
        string imageUrl = 'https://res.cloudinary.com/hgnzjdie2/image/authenticated/s--mqXqI26Q--/c_crop,h_0.43525951507549915,w_0.42857142857142855,x_0.5082815734989647,y_0.5348086675887506/c_fit,h_1920,w_1920/fl_attachment/f_jpg/dpr_auto,q_auto,f_auto/v1/scpix-herokuapp-com-s3-test-public/scpix-herokuapp-com/storage_files/7b/f4/7bf4168d-97bb-474c-b6f8-3dfa59ffb0f1/design-simple-modern-elegant-business-car.jpg';
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
        // if(isBase64) {
        //  form64 += HttpFormBuilder.WriteBodyParameter('sampleBase64Content', sample);
        // } else {
         form64 += HttpFormBuilder.WriteBodyParameter('sampleLocation', imageUrl);
        // }
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
        httpRequest.setHeader('Authorization','Bearer ' + accessToken);
        httpRequest.setEndpoint(endpoint);

        Http http = new Http();
        HTTPResponse res = http.send(httpRequest);

        system.debug('>>>> ' + res.getBody());
        system.debug('>>>> ' + res.getStatusCode());

        //curl -X POST -H "Authorization: Bearer <TOKEN>" 
        // -F sampleLocation="http://www.asianbusinesscards.com/wp-content/uploads/2019/03/chinese-business-card-translation-samples-walmart-890-eng.jpg" 
        // -F task="contact" 
        // -F modelId="OCRModel" 
        // https://api.einstein.ai/v2/vision/ocr
    }
}
