package someTests;

public class firstTest {
    private boolean identity;
    private boolean caseSensitive;
    private boolean nullable = true;
    

	int getFlag(){
	    return (identity        ? 1 : 0) |
	           (caseSensitive   ? 2 : 0) |
	           (nullable        ? 4 : 0);
	}
}
