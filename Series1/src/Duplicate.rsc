module Duplicate

import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Type;
import Map;
import Set;

public loc smallSqlProject = |project://smallsql0.21_src|;

public rel[loc,loc] findDuplicates(loc project) {
	pages = getCleanedFileLinesForProject(project);
	return getDuplicatesFromLines(pages);
}
	
rel[loc, loc] getDuplicatesFromLines(list[list[tuple[loc, str]]] fileLines) {	
	textMap = makeTextMapFromLines(fileLines);
	duplicateLocations = extractDuplicatesFromTextMap(textMap);
	subsetDuplicates = getIncludedSmallerDuplicates(duplicateLocations);
	
	return duplicateLocations - subsetDuplicates;
}

map[str, list[loc]] makeTextMapFromLines(list[list[tuple[loc, str]]] fileLines){
	map[str, list[loc]] textMap = ();
	for (lines <-fileLines){
		lineLocationPairs = {<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, (l1.begin.line +5) <= l2.begin.line && l1.path == l2.path};
		
		for (lineLocationPair <- lineLocationPairs) {
			spanLocation = getSpan(lineLocationPair);
			spanText = getSpanText(lines,spanLocation);
			if (spanText in textMap) {
				textMap[spanText] = textMap[spanText] + [spanLocation];
			} else {		
				textMap += (spanText : [spanLocation]);
			}
		}
	}
	return textMap;
}
	
rel[loc,loc] extractDuplicatesFromTextMap(map[str, list[loc]] textMap) { 	
	duplicateTexts = (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);
		
	rel[loc,loc] duplicateLocations = {};
    for (text <- duplicateTexts) {
    	locations = textMap[text];
    	
    	for (firstLoc <- locations, nextLoc <- locations, firstLoc != nextLoc) {    		
    		duplicateLocations += <firstLoc, nextLoc>;
    	}
    }
    return duplicateLocations;
}    

rel[loc,loc] getIncludedSmallerDuplicates(rel[loc,loc] duplicateLocations) {
	rel[loc,loc] subsetDuplicates = {};
	for (<small1,small2> <- duplicateLocations, <big1,big2> <- duplicateLocations) {
		if ((small1 < big1 || small1 < big2) && (small2 < big1 || small2 < big2)){
			if(small1 < big1) {
				if (small1.path != big1.path){
					continue;
				}
			} else {				
				if (small1.path != big2.path){
					continue;
				}					
			}
			if(small2 < big1) {
				if (small2.path != big1.path){
					continue;
				}			
			} else {
				if (small2.path != big2.path){
					continue;
				}			
			}
			subsetDuplicates += <small1, small2>;
		}
    }
    return subsetDuplicates; 
}

public str getSpanText(list[tuple[loc, str]] lines, loc span) {
	linesInSpan = [text | <line, text> <- lines, line <= span];
	allLines = intercalate("\n", linesInSpan);
	return allLines;
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

public list[list[tuple[loc, str]]] getCleanedFileLinesForProject(loc project) {
    fileLines = [];
    for (file <- files(createM3FromEclipseProject(project))) {
    	lines = getCleanedLinesForFile(file);
    	lines = [<lineLocation, text> | <lineLocation, text> <- lines, text != ""];
		fileLines += [lines];
	}
	return fileLines;
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