package testCode;

public class ClassWithComplexityEdgeCases {
    private String convertExpressionIfNeeded( String expr, String other ){
        if(expr == null || other == null){
            return expr;
        }
        int temp1 = 1;
        int temp2 = 10;
        switch(temp1){
        case 1:
        case 2:
        case 3:
            switch(temp2){
            case 10:
            case 11:
            case 12:
            case 13:
            case 14:
            case 15:
            case 16:
                String trim = "";
                return trim;
            case 17:
            case 18:
            case 19:
                if(temp1 > temp2){
                    return "";
                }
                break; 
            }
            break;
        }
        return "";
    }

}
