module Duplicate

import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Type;

public loc smallSqlProject = |project://smallsql0.21_src|;

public rel[loc,loc] findDuplicates(loc project) {
	lines = getCleanedLinesForProject(project);
	return getDuplicatesFromLines(lines);
}

public rel[loc, loc] getDuplicatesFromLines(list[tuple[loc, str]] lines) {
	duplicates = {};
	allLineSpans = {};
	for (lineLocationPair <- [<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, l1.begin.line <= l2.begin.line]) {
		allLineSpans += getSpan(lineLocationPair);
	}
		
	return {<s1, s2> | s1 <- allLineSpans, s2 <- allLineSpans};
}

public loc getSpan(tuple[loc, loc] locationPair){
	<beginLocation, endLocation> = locationPair;
	path = beginLocation.path;
	offset = beginLocation.offset;
	length = (endLocation.offset - beginLocation.offset) + endLocation.length;
	beginLine = beginLocation.begin.line;
	endLine = endLocation.end.line;
	endColumn = endLocation.end.column;
	span = |java+compilationUnit:///| + path;
	return span(offset, length,<beginLine,0>,<endLine, endColumn>);
}

public list[tuple[loc, str]] getCleanedLinesForProject(loc project) {
    lines = [];
    for (file <- files(createM3FromEclipseProject(project))) {
		lines += getCleanedLinesForFile(file);
	}
	return lines;
}

public list[tuple[loc, str]] getCleanedLinesForFile(loc file) {
	lines = [];
	linenr=0;
	offset=0;
	isInMultilineComment = false;
	for (line <- readFileLines(file)) {
		<linenr, offset, location> = getLineLocation(linenr, offset, file, line);
		<isInMultilineComment, line> = removeComments(isInMultilineComment, line);
		line = trim(line);
		lines += <location, line>;
	}
	return lines;
}



tuple[int, int, loc] getLineLocation(int linenr, int offset, loc file, str line) {
    firstPart =|java+compilationUnit:///| + file.path;	
    length = size(line);
    lineLocation = firstPart(offset,length+1,<linenr,0>,<linenr,length>);
	return <linenr + 1, offset + length +2, lineLocation>;
}

public list[int] getQuotes(str line){
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