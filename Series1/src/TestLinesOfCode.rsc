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
    fileWithSingleLineComment = |project://CodeToTest/src/testCode/LinesOfCodeTests/SingleCommentLine.java|;
	return linesOfCode(fileWithSingleLineComment) == 4;
}

test bool singleSingleCommentLineReturnsOneLessLine2(){
    fileWithSingleLineComment = |project://CodeToTest/src/testCode/LinesOfCodeTests/SingleCommentLine2.java|;
	return linesOfCode(fileWithSingleLineComment) == 4;
}

test bool endOfLineCommentDoesNotEffectCount() {
    fileWithSingleLineComment = |project://CodeToTest/src/testCode/LinesOfCodeTests/SingleLineCommentEndOfLine.java|;
	return linesOfCode(fileWithSingleLineComment) == 4;
}

test bool blankLinesNotCounted() {
    fileWithBlankLines = |project://CodeToTest/src/testCode/LinesOfCodeTests/WithBlankLines.java|;
	return linesOfCode(fileWithBlankLines) == 5;

}