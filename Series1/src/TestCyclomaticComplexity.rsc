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

test bool methodWithIfElseScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/ifElseMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithConditionalScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/conditionalMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithWhileScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/whileMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithDoWhileScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/doWhileMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithForScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/forMethod()|,2>;
	return expectedValue in result;
}


test bool methodWithConditionalessForScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/forNoConditionMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithForEachScoresTwo(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/forEachMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithCaseScoresOnePerCase1(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/oneCaseMethod()|,2>;
	return expectedValue in result;
}

test bool methodWithCaseScoresOnePerCase2(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/twoCaseMethod()|,3>;
	return expectedValue in result;
}

test bool methodWithCaseScoresOnePerCase3(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/threeCaseMethod()|,4>;
	return expectedValue in result;
}

test bool methodWithCaseWithOnePerCasePlusDefault(){
	classWithIf = |project://CodeToTest/src/testCode/ClassWithComplexityMethods.java|;
	result = calculateComplexity(classWithIf);
	expectedValue = <|java+method:///testCode/ClassWithComplexityMethods/defaultCaseMethod()|,3>;
	return expectedValue in result;
}




bool complexityForLocation(loc location, int expectedComplexity){
    success = true;
	for(/method(_, _, _, _, Statement impl) := createAstFromFile(location, true)){
	  success = success && (expectedComplexity == calculateMethodComplexity(impl));
	}
	return success;
}
