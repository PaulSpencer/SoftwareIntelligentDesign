module CyclomaticComplexity

import lang::java::jdt::m3::AST; 
import IO;

public int calculateMethodComplexity(Statement statement){
  return 1;
}

test bool emptyMethodScoresOne(){
    emptyClass = |project://CodeToTest/src/testCode/EmptyClass.java|;
    expectedComplexity = 1;
    return complexityForLocation(emptyClass, expectedComplexity);
}

test bool noComplexityMethodScoresOne(){
    noComplexityClass = |project://CodeToTest/src/testCode/NoComplexityClass.java|;
    expectedComplexity = 1;
    return complexityForLocation(noComplexityClass, expectedComplexity);
}



bool complexityForLocation(loc location, int expectedComplexity){
    success = true;
	for(/method(_, _, _, _, Statement impl) := createAstsFromEclipseProject(location, true)){
	  success = success && (expectedComplexity == calculateMethodComplexity(impl));
	}
	return success;
}