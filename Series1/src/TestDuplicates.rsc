module TestDuplicates

import Duplicate;
import IO;

// duplicates
test bool exactMatch(){
	duplicates = findDuplicates(|project://CodeWithDuplicates|);
	fileLocation = |java+compilationUnit://CodeWithDuplicates/src/ClassWithDuplicates1.java|;
	firstMethodLocation = fileLocation(37,94,<3,0>,<8,6>);
	secondMethodLocation = fileLocation(170,94,<12,0>,<17,6>);
	return <firstMethodLocation,secondMethodLocation> in  duplicates;
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

//test bool noHashClash(str lineone, str linetwo){
//	if (lineone == linetwo) { 
//		return true;
//	}
//	return hash(lineone) != hash(linetwo);
//}

// To do, handle Java docs?