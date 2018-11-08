package testCode;

public class ClassWithComplexityMethods {
	public void ifMethod() {
		if (true) {
			
		}
	}
	
	public void ifElseMethod() {
		if (true) {
			
		}
		else
		{
		
		}
	}
	
	public void conditionalMethod() {
		bool condition = false;
	    String temp2 = condition ? "trueChoice" : "falseChoice";
	}
	
	public void whileMethod() {
        int count = 1;
        while (count < 11) {
            count++;
        }
	}
	
	public void doWhileMethod() {
        int count = 1;
        do {
            count++;
        } while (count < 11);
	}
	
	public void forMethod() {
        int count = 1;
        for (int x = 2; x <= 4; x++) {
            count++;
        }
	}	
	
	public void forNoConditionMethod() {
        int count = 1;
        for ( ; ; ) {
            count++;
        }
	}

	public void oneCaseMethod() {
		int temp = 1;
		switch(temp) {
		   case 1 :
		      break;
		}
	}
	
	public void twoCaseMethod() {
		int temp = 1;
		switch(temp) {
		   case 1 :
			      break;
		   case 2 :
			      break;
		}
	}
	
	public void threeCaseMethod() {
		int temp = 1;
		switch(temp) {
		   case 1 :
			   break;
		   case 2 :
			      break;
		   case 3 :
			      break;
		}
	}

	public void defaultCaseMethod() {
		int temp = 1;
		switch(temp) {
		   case 1 :
		      break;
		   default:
			   break;
		}
	}
		
	public void forEachMethod() {
		String[] fruits = new String[] { "Orange", "Apple", "Pear", "Strawberry" };
		for (String fruit : fruits) {
		}
	}
	
}
