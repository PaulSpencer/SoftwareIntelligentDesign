module CyclomaticComplexity

import lang::java::jdt::m3::AST; 
import Set;
import IO;

public rel[loc, int] calculateComplexity(loc location) {
    metric = {};
	for(/method(_, _, _, _, Statement impl, decl=methodLocation) := createAstFromFile(location, true)){
	    metric = metric + <methodLocation, 1>;
	}
	return metric;
}

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

test bool classWithTwoMethodsGetsTwoScores(){
    twoMethodClass = |project://CodeToTest/src/testCode/TwoMethodClass.java|;
    result = calculateComplexity(twoMethodClass);
    println(size(result));
    return size(result) == 2;
}

bool complexityForLocation(loc location, int expectedComplexity){
    success = true;
	for(/method(_, _, _, _, Statement impl) := createAstFromFile(location, true)){
	  success = success && (expectedComplexity == calculateMethodComplexity(impl));
	}
	return success;
}