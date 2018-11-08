module TestCyclomaticComplexity

import CyclomaticComplexity;

import lang::java::jdt::m3::AST;
import Set;
import Relation;
import IO;

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
    return size(result) == 2;
}

test bool classWithFiveMethodsGetsFiveScores(){
    fiveMethodClass = |project://CodeToTest/src/testCode/FiveMethodClass.java|;
    result = calculateComplexity(fiveMethodClass);
    return size(result) == 5;
}

test bool classWithConstructorIncludesConstructor(){
    classWithConstructor = |project://CodeToTest/src/testCode/ClassWithConstructor.java|;
    result = calculateComplexity(classWithConstructor);
    return size(result) == 1;
}

test bool methodWithIfScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/ifMethod()|,2>;
	return expectedValue in result;
}


bool complexityForLocation(loc location, int expectedComplexity){
    success = true;
	for(/method(_, _, _, _, Statement impl) := createAstFromFile(location, true)){
	  success = success && (expectedComplexity == calculateMethodComplexity(impl));
	}
	return success;
}
