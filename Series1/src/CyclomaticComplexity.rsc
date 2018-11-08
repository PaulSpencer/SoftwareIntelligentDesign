module CyclomaticComplexity

import lang::java::jdt::m3::AST; 
import IO;

public int calculateMethodComplexity(Statement statement){
  return 1;
}

test bool emptyMethodScoresOne(){
    success = true;
    emptyClass = |project://CodeToTest/src/testCode/EmptyClass.java|;
    expectedComplexity = 1;
	for(/method(_, _, _, _, Statement impl) := createAstsFromEclipseProject(emptyClass, true)){
	  success = success && (expectedComplexity == calculateMethodComplexity(impl));
	}
	return success;
}