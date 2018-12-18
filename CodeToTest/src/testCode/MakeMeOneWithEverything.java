package testCode;

import java.util.zip;

public class MakeMeOneWithEverything {

	private enum Bar {
	   A, 
	   B, 
	   C;
	} 
   
	int myField    =   0;
	
	public MakeMeOneWithEverything(int x) {
		
	}
	
	protected String MethodOne() {
		String blah = "";
		boolean isCool = true;
		boolean really = false;
		return blah;
	}
	
	private int MethodTwo() {
		boolean tempboolean;
		byte tempbyte;
		char tempchar;
		double tempdouble;
		float tempfloat;
		long templong;
		short tempshort;
		int[] temparray;
		
		int temp = 1;
		Bar myemum = Bar.A;
		temp += 1;
		temp = temp + 1 + 11 + 1 + 12 + 2 + 22;
		String noWay = MethodOne(); 
		return temp;
	}
	
	static void voidMethod() {
		
	}
}
