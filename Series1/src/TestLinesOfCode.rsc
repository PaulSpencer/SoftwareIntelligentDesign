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

test bool MultiLineCommentsNotCounted() {
    fileWithBlankLines = |project://CodeToTest/src/testCode/LinesOfCodeTests/MultiCommentLine.java|;
	return linesOfCode(fileWithBlankLines) == 4;
}

test bool commentsInMultiLineCommentsNotCountedTwice() {
    fileWithMultiLine = |project://CodeToTest/src/testCode/LinesOfCodeTests/MultiCommentLine2.java|;
	return linesOfCode(fileWithMultiLine) == 4;
}

test bool blankLinesInMultiLineCommentsNotCountedTwice() {
    fileWithMultiLine = |project://CodeToTest/src/testCode/LinesOfCodeTests/BlankLinesInMultiCommentLine.java|;
	return linesOfCode(fileWithMultiLine) == 4;
}

test bool MultiLineCommentsAfterTextCountsline() {
    fileWithMultiLine = |project://CodeToTest/src/testCode/LinesOfCodeTests/MultiCommentLineTextBefore.java|;
	return linesOfCode(fileWithMultiLine) == 4;
}



