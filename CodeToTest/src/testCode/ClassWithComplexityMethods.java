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

	public void fallThroughCaseMethod() {
		int temp = 1;
		myLabel: 
			
		switch(temp) {
		   case 1 :
		   case 2 :
		   case 3 :
		   case 4 :
			   break;
		   case 5 :
			   break myLabel ;
		   case 6 :
			   return;
		   default: 
			   throw new Error();
		}
	}
	
	public void fallThroughCaseNoBreakMethod() {
		int temp = 1;
		
		switch(temp) {
		   case 1 :
		   case 2 :
			   int i;
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
	
	public void catchMethod() {
		try
		{
			
		}
		catch (Exception e)
		{
			
		}
	}

	public void ifAndOrMethod() {
		if (true || false) {
			
		}
	}
	
	public void ifAndTwoOrsMethod() {
		if (true || false || false) {
			
		}
	}
	
	public void ifAndAndMethod() {
		if (true && false) {
			
		}
	}
	
	public void ifAndTwoAndsMethod() {
		if (true && false && false) {
			
		}
	}

	public void ifElseAndOrMethod() {
		if (true || false) {
			
		}
		else {
			
		}
	}
	
	public void conditionalAndAndMethod() {		
	    String temp2 = true && true ? "trueChoice" : "falseChoice";
	}
	
	
}
