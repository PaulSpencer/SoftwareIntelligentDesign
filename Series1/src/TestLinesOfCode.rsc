module TestLinesOfCode

import LinesOfCode;
import IO;

test bool onlyCodeReturnsAllLines(){
	fileWithJustCode = |project://CodeToTest/src/testCode/LinesOfCodeTests/OnlyCode.java|;
	return linesOfCode(fileWithJustCode) == 3;
}

test bool onlyCodeReturnsTenLines(){
	fileWithJustCode = |project://CodeToTest/src/testCode/LinesOfCodeTests/OnlyCodeTen.java|;
	return linesOfCode(fileWithJustCode) == 10;
}

test bool singleSingleCommentLineReturnsOneLessLine(){
    fileWithJustCode = |project://CodeToTest/src/testCode/LinesOfCodeTests/SingleCommentLine.java|;
	println(linesOfCode(fileWithJustCode));
	return linesOfCode(fileWithJustCode) == 4;
}


test bool singleSingleCommentLineReturnsOneLessLine2(){
    fileWithJustCode = |project://CodeToTest/src/testCode/LinesOfCodeTests/SingleCommentLine2.java|;
	println(linesOfCode(fileWithJustCode));
	return linesOfCode(fileWithJustCode) == 4;
}