module TestLinesOfCode

import LinesOfCode;

test bool onlyCodeReturnsAllLines(){
	fileWithJustCode = |project://CodeToTest/src/testCode/LinesOfCodeTests/OnlyCode.java|;
	return linesOfCode(fileWithJustCode) == 3;
}

test bool onlyCodeReturnsAllLines(){
	fileWithJustCode = |project://CodeToTest/src/testCode/LinesOfCodeTests/OnlyCodeTen.java|;
	return linesOfCode(fileWithJustCode) == 10;
}