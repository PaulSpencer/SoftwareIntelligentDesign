module TestDuplicates

import Duplicate;

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

