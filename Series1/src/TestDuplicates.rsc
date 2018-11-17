module TestDuplicates

import Duplicate;
import IO;

// duplicates

test bool exactMatch(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit:///src/ClassWithDuplicates1.java|;
	firstMethodLocation = fileLocation(39,70,<2,0>,<7,2>);
	secondMethodLocation = fileLocation(152,70,<11,0>,<16,2>);
	return <firstMethodLocation,secondMethodLocation> in  duplicates;
}

test bool exactMatch2(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit:///src/ClassWithDuplicates1.java|;
	firstMethodLocation = fileLocation(39,70,<2,0>,<7,2>);
	secondMethodLocation = fileLocation(281,70,<21,0>,<26,2>);
	return <firstMethodLocation,secondMethodLocation> in  duplicates;
}

test bool matchWithCommentsAndBlankLines(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit:///src/ClassWithDuplicates1.java|;
	firstMethodLocation = fileLocation(39,70,<2,0>,<7,2>);
	secondMethodLocation = fileLocation(410,112,<31,0>,<41,2>);
	return <firstMethodLocation,secondMethodLocation> in  duplicates;
}

test bool dontIncludeSmallerMatchIfOnlyBiggerAvailable(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit:///src/ClassWithBigerDuplicates.java|;
	firstBigLocation = fileLocation(45,89,<2,0>,<9,2>);
	secondBigLocation = fileLocation(199,89,<14,0>,<21,2>);
	
	firstSmallerLocation = fileLocation(45,87,<2,0>,<8,8>);
	secondSmallerLocation = fileLocation(199,87,<14,0>,<20,8>);
	
	return <firstBigLocation,secondBigLocation> in duplicates &&
		<firstSmallerLocation,secondSmallerLocation> notin duplicates;
}


test bool doIncludeSmallerMatchIfBiggerAndSmallerAvailable(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit:///src/ClassWithBigerDuplicates.java|;
	firstBigLocation = fileLocation(526,125,<40,0>,<50,1>);
	secondBigLocation = fileLocation(355,125,<27,0>,<37,1>);
	
	firstSmallerLocation = fileLocation(526,91,<40,0>,<46,9>);
	secondSmallerLocation = fileLocation(697,91,<53,0>,<59,9>);
	
	return <firstBigLocation,secondBigLocation> in duplicates &&
		<firstSmallerLocation,secondSmallerLocation> in duplicates;
}



test bool dontMatch(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit:///src/ClassWithDuplicates1.java|;
	firstMethodLocation = fileLocation(39,70,<2,0>,<7,2>);
	secondMethodLocation = fileLocation(178,47,<12,0>,<17,1>);
	return <firstMethodLocation,secondMethodLocation> notin  duplicates;
}


// comment removal
test bool removeCommentsEmptyReturnsEmpty(){
	<_,cleaned> = removeComments(false, "");
	return cleaned == "";
}

test bool removeCommentsTabReturnsTab(){
	<_,cleaned> = removeComments(false, "	");
	return cleaned == "	";
}

test bool removeCommentsTextReturnsText(){
	<_,cleaned> = removeComments(false, "123abc");
	return cleaned == "123abc";
}

test bool removeCommentsSingleLineRemovesText(){
	<_,cleaned> = removeComments(false, "//this is a comment");
	return cleaned == "";
}

test bool removeCommentsSingleLineRemovesTextPreservesPrior1(){
	<_,cleaned> = removeComments(false, "	//this is a comment");
	return cleaned == "	";
}

test bool removeCommentsSingleLineRemovesTextPreservesPrior2(){
	<_,cleaned> = removeComments(false, "abc123 //this is a comment");
	return cleaned == "abc123 ";
}

test bool removeCommentsInMultilineNoEndTagStillInMultiline(){
	<multilineFlag,_> = removeComments(true, "whatever");
	return multilineFlag == true;
}

test bool removeCommentsNotInMultilineNoStartTagStillNot(){
	<multilineFlag,_> = removeComments(false, "whatever");
	return multilineFlag == false;
}

test bool removeCommentsInMultilineNoEndTagTextGone(){
	<_,cleaned> = removeComments(true, "whatever");
	return cleaned == "";
}

test bool removeCommentsInMultilineHasEndTagNotInMultiline(){
	<multilineFlag,_> = removeComments(true, "dpofgjdpogk */");
	return multilineFlag == false;
}

test bool removeCommentsInMultilineHasEndTagReturnsTextAfterTag(){
	<_,cleaned> = removeComments(true, "before */ after");
	return cleaned == " after";
}

test bool removeCommentsIfMultilineStartsKeepTextBefore(){
	<_,cleaned> = removeComments(false, "before /* after");
	return cleaned == "before ";
}

test bool removeCommentsIfMultilineStartsIsInMultiline(){
	<multilineFlag,_> = removeComments(false, "before /* after");
	return multilineFlag == true;
}

test bool removeCommentsIfMultilineStartsAndEndsOnlyCommentGoes(){
	<_,cleaned> = removeComments(false, "before /* */ after");
	return cleaned == "before  after";
}

test bool removeCommentsIfMultilineStartsAndEndsOnlyCommentGoes2(){
	<_,cleaned> = removeComments(false, "before /* */ middle /* */ after");
	return cleaned == "before  middle  after";
}

test bool removeCommentCommentsInStrings(){
	<_,cleaned> = removeComments(false, "String myString = \"// /* */\"");
	return cleaned == "String myString = \"// /* */\"";
}

test bool removeCommentsStringInSingleLine(){
	<_,cleaned> = removeComments(false, "temp = \"\";// \"// /* */\"");
	return cleaned == "temp = \"\";";
}

test bool removeCommentsStringInMultiLine1(){
	<_,cleaned> = removeComments(false, "temp = \"\"/* \"xxx\"*/;");
	return cleaned == "temp = \"\";";
}

test bool removeCommentsStringInMultiLine2(){
	<_,cleaned> = removeComments(false, "temp = \"\"/* \" // \"*/;");
	return cleaned == "temp = \"\";";
}

test bool removeCommentsStringInMultiLine3(){
	<_,cleaned> = removeComments(false, "temp = \"\"/* \" /* \"*/;");
	return cleaned == "temp = \"\";";
}

test bool removeCommentsStringInMultiLine5(){
	<_,cleaned> = removeComments(true, " \"xxx\" */123;");
	return cleaned == "123;";
}

test bool removeCommentsStringInMultiLine6(){
	<_,cleaned> = removeComments(false, "123;/* \"xxx\"");
	return cleaned == "123;";
}

test bool removeCommentsStringInMultiLine7(){
	<_,cleaned> = removeComments(false, "123/* \"xxx\"*/456");
	return cleaned == "123456";
}

test bool removeCommentEscapedQuotesInStrings(){
	<_,cleaned> = removeComments(false, "String myString = \"\\\"//\"");
	return cleaned == "String myString = \"\\\"//\"";
}

// To do, handle Java docs?