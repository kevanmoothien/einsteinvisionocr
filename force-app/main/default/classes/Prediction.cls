public class Prediction {
    @AuraEnabled public string task;
    @AuraEnabled public list<Probabilities> probabilities;
    @AuraEnabled public string error;

    public class Probabilities {
        @AuraEnabled public decimal probability;
        @AuraEnabled public string label;
        @AuraEnabled public BoundingBox boundingBox;
        @AuraEnabled public Attribute attributes;
    }

    public class BoundingBox {
        @AuraEnabled public integer minX;
        @AuraEnabled public integer minY;
        @AuraEnabled public integer maxX;
        @AuraEnabled public integer maxY;
    }

    public class Attribute {
        @AuraEnabled public string tag;
        @AuraEnabled public CellLocation cellLocation;
    }

    public class CellLocation {
        @AuraEnabled public integer rowIndex;
        @AuraEnabled public integer colIndex;
    }
}
