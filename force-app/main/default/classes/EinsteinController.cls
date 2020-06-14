public with sharing class EinsteinController {
    @AuraEnabled
    public static Prediction scanBusinessCard(string imageUrl) {
        return EinsteinVisionUtils.scanBusinessCard(imageUrl);
    }
}
