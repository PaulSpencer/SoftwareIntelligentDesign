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
	return complexityFromMethod("ifMethod",2);
}

test bool methodWithIfElseScoresTwo(){
	return complexityFromMethod("ifElseMethod",2);
}

test bool methodWithConditionalScoresTwo(){
	return complexityFromMethod("conditionalMethod",2);
}

test bool methodWithWhileScoresTwo(){
	return complexityFromMethod("whileMethod",2);
}

test bool methodWithDoWhileScoresTwo(){
	return complexityFromMethod("doWhileMethod",2);
}

test bool methodWithForScoresTwo(){
	return complexityFromMethod("forMethod",2);
}

test bool methodWithConditionalessForScoresTwo(){
	return complexityFromMethod("forNoConditionMethod",2);
}

test bool methodWithForEachScoresTwo(){
	return complexityFromMethod("forEachMethod",2);
}

test bool methodWithCaseScoresOnePerCase1(){
	return complexityFromMethod("oneCaseMethod",2);
}

test bool methodWithCaseScoresOnePerCase2(){
	return complexityFromMethod("twoCaseMethod",3);
}

test bool methodWithCaseScoresOnePerCase3(){
	return complexityFromMethod("threeCaseMethod",4);
}

test bool methodWithDefaultCaseOnePerCasePlusDefault(){
	return complexityFromMethod("defaultCaseMethod",3);
}

test bool methodWithCatchScoresTwo(){
	return complexityFromMethod("catchMethod",2);
}


test bool methodWithIfAndOrScoresThree(){
	return complexityFromMethod("ifAndOrMethod",3);
}

test bool methodWithIfAndTwoOrsScoresFour(){
	return complexityFromMethod("ifAndTwoOrsMethod",4);
}

test bool methodWithIfAndAndScoresThree(){
	return complexityFromMethod("ifAndAndMethod",3);
}

test bool methodWithIfAndTwoAndsScoresFour(){
	return complexityFromMethod("ifAndTwoAndsMethod",4);
}

test bool ifElseAndOrMethodScoresThree(){
	return complexityFromMethod("ifElseAndOrMethod",3);
}

test bool conditionalAndAndMethodScoresThree(){
	return complexityFromMethod("conditionalAndAndMethod",3);
}

test bool conditionalAndAndMethodScoresThree(){
	return complexityFromMethod("conditionalAndAndMethod",3);
}

test bool caseDoesnotCountFallThrough(){
	return complexityFromMethod("fallThroughCaseMethod",5);
}

test bool caseDoesnotCountFallThroughUnlessAllEmpty(){
	return complexityFromMethod("fallThroughCaseNoBreakMethod",2);
}

bool complexityFromMethod(str methodName, int expectedComplexity){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	location = |java+method:///testCode/ClassWithComplexityMethods/| + (methodName + "()");
	expectedValue = <location,expectedComplexity>;
	return expectedValue in result;
}

bool complexityForLocation(loc location, int expectedComplexity){
    success = true;
	for(/method(_, _, _, _, Statement impl) := createAstFromFile(location, true)){
	  success = success && (expectedComplexity == calculateMethodComplexity(impl));
	}
	return success;
}