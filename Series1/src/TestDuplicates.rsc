module TestDuplicates

import Duplicate;
import IO;

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


