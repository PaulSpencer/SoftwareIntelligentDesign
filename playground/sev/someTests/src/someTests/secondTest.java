package someTests;

public class secondTest {

    private int dataType;
    private int scale;
    
    int getScale(){
		switch(dataType){
			case SQLTokenizer.DECIMAL:
			case SQLTokenizer.NUMERIC:
				return scale;
			default:
				return 0;
		}
    }
}

