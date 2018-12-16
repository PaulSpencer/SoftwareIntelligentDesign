module LineCleanerT2

import lang::java::jdt::m3::Core; 
import IO;
import List;
import String;

set[list[tuple[loc, str]]] getCleanedFileLinesForProjectT2(loc project) {
	fileLines = {};
    for (file <- files(createM3FromEclipseProject(project))) {
    	lines = getCleanedLinesForFileT2(file);
    	lines = [<lineLocation, text> | <lineLocation, text> <- lines, text != ""];
		fileLines += {lines};
	}
	
	return fileLines;
}


list[tuple[loc, str]] getCleanedLinesForFileT2(loc file) {
	lines = [];
	eolSize = getEndOfLineSizeT2(file);
	linenr=0;
	offset=0;
	isInMultiline = false;
	for (line <- readFileLines(file)) {
		<linenr, offset, location> = getLineLocationT2(linenr, offset, file, line, eolSize);
		<isInMultiline, line> = removeCommentsT2(isInMultiline, line);
		line = trim(line);
		lines += <location, line>;
	}
	return lines;
}

int getEndOfLineSizeT2(loc file) {
	fullText = readFile(file);
	fileLines = readFileLines(file);
	eolSize = 1;
	if(size(fileLines)>2) {
		firstline = fileLines[0];
		fullText = substring(fullText,size(firstline));

		if (fullText[0] == "\r" && fullText[1] == "\n") {
			eolSize = 2;
		}
	}
	return eolSize;
}

tuple[int, int, loc] getLineLocationT2(int linenr, int offset, loc file, str line, int eolSize) {
    firstPart =|java+compilationUnit:///| + file.path;	
    length = size(line);
    lineLocation = firstPart(offset, length+1, <linenr,0>, <linenr,length>);
	return <linenr + 1, offset + length + eolSize, lineLocation>;
}

tuple[list[int],list[int],list[int],list[int]] getTokensT2(str line) {
	quotes = findAll(line,"\"") - [quote+1 | quote <- findAll(line,"\\\"")];
	multiLineStarts = findAll(line,"/*");
	multiLineEnds = findAll(line,"*/");
	singleLines = findAll(line,"//");
	return <quotes,multiLineStarts,multiLineEnds,singleLines>;
}

public tuple[bool, str] removeCommentsT2(bool isInMultiline, str originalLine){
	remainingCharacters = originalLine;
	commentFreeLine = "";	
	
	while (size(remainingCharacters) > 0) {
		<quotes,multiLineStarts,multiLineEnds,singleLines> = getTokensT2(remainingCharacters);
		
		if(isInMultiline && isEmpty(multiLineEnds)) {	
			commentFreeLine	+= "";
			remainingCharacters = "";
			continue;
		} 
		
		if (isInMultiline) {
			isInMultiline = false;
			remainingCharacters = substring(remainingCharacters,head(multiLineEnds)+2);
			continue;
		}
	
		combinedTokens = quotes + multiLineStarts + singleLines;
		remainingComments = multiLineStarts + singleLines;
		
		if (isEmpty(remainingComments)) {
			commentFreeLine += remainingCharacters;
			remainingCharacters = "";
			continue;
		} 
	
		if (min(combinedTokens) in quotes) {
			commentFreeLine += substring(remainingCharacters,0,quotes[1] +1);
			remainingCharacters = substring(remainingCharacters,quotes[1] +1);
			continue;
		} 
	
		if(min(combinedTokens) in singleLines) {
			commentFreeLine += substring(remainingCharacters, 0, min(singleLines));
			remainingCharacters = "";
		} else {
			isInMultiline = true;
			commentFreeLine += substring(remainingCharacters, 0, min(multiLineStarts));
			remainingCharacters = substring(remainingCharacters,min(multiLineStarts)+2);
		}
	}
	
	return <isInMultiline, commentFreeLine>;
}