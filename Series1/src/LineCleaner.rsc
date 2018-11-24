module LineCleaner

import lang::java::jdt::m3::Core; 
import IO;
import List;
import String;

set[list[tuple[loc, str]]] getCleanedFileLinesForProject(loc project) {
	fileLines = {};
    for (file <- files(createM3FromEclipseProject(project))) {
    	lines = getCleanedLinesForFile(file);
    	lines = [<lineLocation, text> | <lineLocation, text> <- lines, text != ""];
		fileLines += {lines};
	}
	
	return fileLines;
}

list[tuple[loc, str]] getCleanedLinesForFile(loc file) {
	lines = [];
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
	linenr=0;
	offset=0;
	isInMultilineComment = false;
	for (line <- readFileLines(file)) {
		<linenr, offset, location> = getLineLocation(linenr, offset, file, line, eolSize);
		<isInMultilineComment, line> = removeComments(isInMultilineComment, line);
		line = trim(line);
		lines += <location, line>;
	}
	return lines;
}

tuple[int, int, loc] getLineLocation(int linenr, int offset, loc file, str line, int eolSize) {
    firstPart =|java+compilationUnit:///| + file.path;	
    length = size(line);
    lineLocation = firstPart(offset,length+1,<linenr,0>,<linenr,length>);
	return <linenr + 1, offset + length + eolSize, lineLocation>;
}

list[int] getQuotes(str line){
	quotes = findAll(line,"\"");	
	escapedQuotes = [q+1 | q <- findAll(line,"\\\"")];
	return quotes - escapedQuotes;
}


public tuple[bool, str] removeComments(bool isInMultiline, str originalLine){
	remainingCharacters = originalLine;
	commentFreeLine = "";

	while (size(remainingCharacters) > 0) {
		qs = getQuotes(remainingCharacters);
		mlcss = findAll(remainingCharacters,"/*");
		mlces = findAll(remainingCharacters,"*/");
		slcs = findAll(remainingCharacters,"//");
		if(isInMultiline) {
			if (isEmpty(mlces)){			
				commentFreeLine += "";				
				remainingCharacters = "";
			} else {				
				isInMultiline = false;
				int split = head(mlces);
				split +=2;
				remainingCharacters = substring(remainingCharacters,split);
			}
		} else {	
			combined = qs + mlcss + slcs;
			commments = mlcss + slcs;
			if (isEmpty(commments)) {
				commentFreeLine += remainingCharacters;
				remainingCharacters = "";
			} else {
				if (min(combined) in qs) {
					int split = qs[1] +1;
					commentFreeLine += substring(remainingCharacters,0,split);
					remainingCharacters = substring(remainingCharacters,split);
				} else {
					if(min(combined) in slcs) {
						int split = min(slcs);
						commentFreeLine += substring(remainingCharacters, 0, split);
						remainingCharacters = "";
					} else {
						isInMultiline = true;
						int split = min(mlcss);
						commentFreeLine += substring(remainingCharacters, 0, split);
						split+=2;
						remainingCharacters = substring(remainingCharacters,split);
					}
				}
			}
		}
	}
	
	return <isInMultiline, commentFreeLine>;
}