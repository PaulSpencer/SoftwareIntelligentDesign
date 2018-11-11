module Duplicate

import lang::java::jdt::m3::Core; 
import IO;
import String;

public loc smallSqlProject = |project://smallsql0.21_src|;

/*
public rel[loc, loc] FindDuplicates(loc project) {
    duplicates = {};
    for (file <- files(createM3FromEclipseProject(project))) {
    	firstPart =|java+compilationUnit:///| + file.path;
    	linenr=0;
    	offset=0;
    	isInMultilineComment = false;
    	for (line <- readFileLines(file)) {
    		length = size(line);
    		lineLocation = firstPart(offset,length+1,<linenr,0>,<linenr,length>);
    		println(lineLocation);
    		linenr = linenr + 1;
    		offset = offset + length +2;
    	}
	}
	return duplicates;
}
*/

public tuple[bool, str] removeComments(bool isInMultiline, str originalLine){
	remainingCharacters = originalLine;
	commentFreeLine = "";
	while (size(remainingCharacters) > 0) {
		if(isInMultiline) {
			multiLineClosePosition = findFirst(remainingCharacters,"*/");
			if (multiLineClosePosition !=-1){
				isInMultiline = false;
				commentFreeLine += substring(remainingCharacters, multiLineClosePosition+2);
				remainingCharacters = "";
			} else {
				commentFreeLine += "";				
				remainingCharacters = "";
			}
		} else {			
			multiLineOpenPosition = findFirst(remainingCharacters,"/*");
			if (multiLineOpenPosition !=-1) {
				commentFreeLine = substring(remainingCharacters, 0, multiLineOpenPosition);
				remainingCharacters = "";
				isInMultiline = true;
			}
			singleLineCommentPosition = findFirst(remainingCharacters,"//");
			if (singleLineCommentPosition != -1) {
				commentFreeLine += substring(remainingCharacters, 0, singleLineCommentPosition);
				remainingCharacters = "";
			} else {
				commentFreeLine += remainingCharacters;
				remainingCharacters = "";
			}
		}
	}
	
	return <isInMultiline, commentFreeLine>;
}