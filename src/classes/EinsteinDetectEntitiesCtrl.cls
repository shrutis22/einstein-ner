public with sharing class EinsteinDetectEntitiesCtrl {
    @AuraEnabled
    public static EAPI_ActionResponse detectEntities(String textToClassify) {
        try {
            return new EAPI_ActionResponse(
                true,
                null,
                EAPI_Core.detectEntities(textToClassify)
            );
        } catch (Exception e) {
            return new EAPI_ActionResponse(
                false,
                'An error has occurred. Error: ' + e.getMessage()
            );
        }
    }
}