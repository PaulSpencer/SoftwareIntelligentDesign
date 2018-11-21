module Duplicate

import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Type;
import Map;
import Set;
import DateTime;

public loc smallSqlProject = |project://smallsql0.21_src|;
public loc hsqldbProject = |project://hsqldb-2.3.1|;

public rel[loc,loc] findDuplicates(loc project) {
	fileLines = getCleanedFileLinesForProject(project);
	return getDuplicatesFromLines(fileLines);
}

rel[loc, loc] getDuplicatesFromLines(set[list[tuple[loc, str]]] fileLines) {
	textMap = makeTextMapFromLines(fileLines);
	duplicateLocations = extractDuplicatesFromTextMap(textMap);
	subsetDuplicates = getIncludedSmallerDuplicates(duplicateLocations, fileLines);
	return duplicateLocations - subsetDuplicates;
}

map[str, list[loc]] makeTextMapFromLines(set[list[tuple[loc, str]]] fileLines){
	map[str, list[loc]] textMap = ();
	blocksWithDuplicateSingleLines = breakOnUniqueLines(fileLines);
	
	for (lines <-blocksWithDuplicateSingleLines){
		lineLocationPairs = {<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, (l1.begin.line +5) <= l2.begin.line};
			
		for (lineLocationPair <- lineLocationPairs) {
			<l1,l2> = lineLocationPair;
			spanLocation = getSpan(lineLocationPair);
			spanText = getSpanText(lines,spanLocation);
			if(size(findAll(spanText, "\n")) >= 5) {
				if (spanText in textMap) {
					textMap[spanText] = textMap[spanText] + [spanLocation];
				} else {		
					textMap += (spanText : [spanLocation]);
				}
			}
		}
	}
	
	return textMap;
}

set[list[tuple[loc, str]]] breakOnUniqueLines(set[list[tuple[loc, str]]] fileLines) {
	uniqueLines = getUniqueLines(fileLines);
	returnFileLines = {};
	for (lines <- fileLines) {
		fileSegment = [];
		for (<lineLoc, lineText> <- lines) {
			if(lineText in uniqueLines) {
				returnFileLines += {fileSegment};
				fileSegment = [];
			} else {				
				fileSegment += <lineLoc, lineText>;
			}
		}
		
		returnFileLines += {fileSegment};			
	}
		
	return returnFileLines;
}


set[str] getUniqueLines(set[list[tuple[loc, str]]] fileLines){
	map[str,bool] uniqueLineMap = ();
	
	for (lineLocList <- fileLines) {
		for(<_,lineText> <- lineLocList){
			if(lineText notin uniqueLineMap){
				uniqueLineMap += (lineText : true);
			} else {
				uniqueLineMap[lineText] = false;
			}
		}	
	}
    
    return {text | text <- uniqueLineMap, uniqueLineMap[text] == true};
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

rel[loc,loc] getIncludedSmallerDuplicates(rel[loc,loc] duplicateLocations,set[list[tuple[loc, str]]] fileLines) {
	subsets = getSubSets(fileLines);
	rel[loc,loc] subsetDuplicates = {};	

	for (<l1, l2>  <- {<l1, l2>  | <l1, l2> <- duplicateLocations, l1 in subsets && l2 in subsets}) {

		l1Sets = subsets[l1];
		l2Sets = subsets[l2];
	
		for (l1Bigger <- l1Sets, l2Bigger <- l2Sets){
			if (<l1Bigger, l2Bigger> in duplicateLocations){
				subsetDuplicates += <l1, l2>;
			}
		}		
	}

    return subsetDuplicates; 
}

map[loc, set[loc]] getSubSets(set[list[tuple[loc, str]]] fileLines){
	blocksWithDuplicateSingleLines = breakOnUniqueLines(fileLines);
	
	map[loc, set[loc]] subsets = ();
	for (lines <- blocksWithDuplicateSingleLines){
		spans = {};
		lineLocationPairs = {<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, (l1.begin.line +5) <= l2.begin.line};
		for (lineLocationPair <- lineLocationPairs) {
			spanLocation = getSpan(lineLocationPair);
			spanText = getSpanText(lines,spanLocation);
			
			if(size(findAll(spanText, "\n")) >= 5) {
				spans += <spanLocation,size(findAll(spanText, "\n"))>;
			}
		}
		if(isEmpty(spans)){
			continue;
		}

		// this is too long -> rethink how to get the same
		smallerSpans = sort(spans, bool(tuple[loc,int] a, tuple[loc,int] b){ <_,a2> =a; <_,b2> = b;return a2 < b2; });
		<_, smallestSize> = head(smallerSpans);
		
		biggerSpans = {<location,count> | <location,count> <- smallerSpans, count > smallestSize};
		
		for(<smaller,scount> <- smallerSpans){
			if(scount > smallestSize){				
				smallestSize = scount;
				biggerSpans = {<location,count> | <location,count> <- biggerSpans, count > smallestSize};				
			}
			
			for (<bigger,_> <- biggerSpans){
				if (smaller < bigger) {
					if (smaller in subsets) {
						subsets[smaller] = subsets[smaller] + {bigger};
					} else {		
						subsets += (smaller : {bigger});
					}		
				}
			}	
		}
	}
	return subsets;
}

str getSpanText(list[tuple[loc, str]] lines, loc span) {
	linesInSpan = [text | <line, text> <- lines, line <= span, text != ""];
	allLines = intercalate("\n", linesInSpan);
	return allLines;
}

loc getSpan(tuple[loc, loc] locationPair){
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