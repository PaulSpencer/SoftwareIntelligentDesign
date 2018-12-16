module DuplicateT2

import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Type;
import Map;
import Set;
import DateTime;
import ValueIO;
import lang::csv::IO;
import LineCleanerT2;

public loc smallSqlProject = |project://smallsql0.21_src|;
public loc hsqldbProject = |project://hsqldb-2.3.1|;

public str uniqueLineSeperator = "\n \b";

public map[str, set[loc]] findDuplicateGroupsT2(loc project) {
	println("findDuplicateGroups");
	fileLines = getCleanedFileLinesForProjectT2(project);
	
	
	println("filelines: <size(fileLines)>");
	duplicates = getDuplicatesFromLinesT2(fileLines); 
	println("duplicates: <size(duplicates)>");
	return groupDuplicatesT2(duplicates);
}

public rel[loc,loc] findDuplicatesT2(loc project) {
	fileLines = getCleanedFileLinesForProjectT2(project);
	dups = getDuplicatesFromLinesT2(fileLines);		
	return {<l1,l2>  | <l1,l2,_> <- dups};
}

public int getTotalDuplicatedLinesT2(loc project){
	fileLines = getCleanedFileLinesForProjectT2(project);
	duplicates = getDuplicatesFromLinesT2(fileLines); 
	duplicateGroups = groupDuplicatesT2(duplicates);
	return (0 | it + (numberOfLines(key) * numberOfDuplicatesT2(duplicateGroups,key)) | key <- duplicateGroups);
}

int numberOfLinesT2(str text) = size(findAll(text,uniqueLineSeperator)) +1; 
int numberOfDuplicatesT2(map[str, set[loc]] duplicateGroups, str key) = size(duplicateGroups[key])-1; 

map[str, set[loc]] groupDuplicatesT2(rel[loc, loc, str] duplicates){
	set[loc] emptyLocSet = {};
	map[str, set[loc]] duplicateGroups = ();
	for (<l1,l2,key> <- duplicates) {
		duplicateGroups[key]?emptyLocSet += {l1,l2};
	}
	return duplicateGroups;
}

rel[loc, loc, str] getDuplicatesFromLinesT2(set[list[tuple[loc, str]]] fileLines) {
	println("get TextMap");
	textMap = createMapOfTextsAndLocationsT2(fileLines);
	println("textMap = <size(textMap)>");
	println("get duplicateLocations");
	duplicateLocations = extractDuplicatesFromTextMapT2(textMap);
	println("duplicateLocations = <size(duplicateLocations)>");
	println("get subsetDuplicates");
	subsetDuplicates = getSubsetDuplicateLocationsT2(textMap,duplicateLocations);
	println("subsetDuplicates = <size(subsetDuplicates)>");
	return  duplicateLocations - subsetDuplicates;
}

rel[loc,loc,str] getSubsetDuplicateLocationsT2(map[str, list[loc]] textMap, rel[loc,loc,str] duplicateLocations){
	subsetTexts = getAllSuperSetsExistingForTextsT2(textMap);
	subsetLocs = getLocationsForSubSetsT2(textMap, subsetTexts);
	return getSubsetDuplicatesT2(duplicateLocations,subsetLocs);
}

rel[loc,loc,str] getSubsetDuplicatesT2(rel[loc,loc,str] duplicateLocations, map[loc, set[tuple[loc,str]]] subsetLocs) {
	rel[loc,loc,str] subsetDuplicates = {};	
	for (<l1, l2,text>  <- {<l1, l2,text>  | <l1, l2,text> <- duplicateLocations, l1 in subsetLocs && l2 in subsetLocs}) {

		l1Sets = subsetLocs[l1];
		l2Sets = subsetLocs[l2];
	
		for (<l1Bigger,l1Text> <- l1Sets, <l2Bigger,_> <- l2Sets){
			if (<l1Bigger, l2Bigger,l1Text> in duplicateLocations || <l2Bigger, l1Bigger,l1Text> in duplicateLocations){
				subsetDuplicates += <l1, l2,text>;
			}
		}		
	}	
	
	return subsetDuplicates;	
} 

map[loc, set[tuple[loc,str]]] getLocationsForSubSetsT2(map[str, list[loc]] textMap, map[str, set[str]] subsetTexts){
	map[loc, set[tuple[loc,str]]] subsetLocs = ();
	set[tuple[loc,str]] emptyLocSet = {};
	for	(subsetText <- subsetTexts, supersetText <- subsetTexts[subsetText]) {
		for (subset <- textMap[subsetText], superset <-textMap[supersetText], subset.path == superset.path && subset < superset){
			subsetLocs[subset]?emptyLocSet += {<superset,supersetText>};
		}
	}
	return subsetLocs;
}

map[str, set[str]] getAllSuperSetsExistingForTextsT2(map[str, list[loc]] textMap){
	map[str, set[str]] subsetTexts = ();
	set[str] emptySet = {};
	for (text <- textMap){		
		minusFirstLine = substring(text, findFirst(text,uniqueLineSeperator)+size(uniqueLineSeperator));		
		if(minusFirstLine in textMap) {
			subsetTexts[minusFirstLine]?emptySet += {text};
		}

		minusLastLine = substring(text, 0, findLast(text,uniqueLineSeperator));
		if(minusLastLine in textMap) {
			subsetTexts[minusLastLine]?emptySet += {text};
		}
	}
	return subsetTexts;
}


map[str, list[loc]] createMapOfTextsAndLocationsT2(set[list[tuple[loc, str]]] fileLines){
	map[str, list[loc]] textMap = ();
	list[loc] emptyLocList = [];
	for (lines <- breakOnUniqueLinesT2(fileLines)){
		if(size(lines) > 100) {
			println("file segment size <size(lines)>");
			line = head(lines);
			println("<line>");
		}
		lineLocationPairs = {<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, (l1.begin.line +5) <= l2.begin.line};
			
		for (lineLocationPair <- lineLocationPairs) {
			spanLocation = getSpanT2(lineLocationPair);
			spanText = getSpanTextT2(lines,spanLocation);
			if(numberOfLinesT2(spanText) >= 6) {
				textMap[spanText]?emptyLocList += [spanLocation];
			}
		}
	}

	return (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);
}

set[list[tuple[loc, str]]] breakOnUniqueLinesT2(set[list[tuple[loc, str]]] fileLines) {
	uniqueLines = getUniqueLinesT2(fileLines);
	fileSegments = {};

	for (lines <- fileLines) {
		fileSegment = [];
		
		for (<lineLoc, lineText> <- lines) {
			if(lineText in uniqueLines) {
				fileSegments += {fileSegment};
				fileSegment = [];
			} else {				
				fileSegment += <lineLoc, lineText>;
			}
		}
		
		fileSegments += {fileSegment};			
	}
	return fileSegments;
}


set[str] getUniqueLinesT2(set[list[tuple[loc, str]]] fileLines){
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
    
    return {text | text <- uniqueLineMap, uniqueLineMap[text]};
}

rel[loc,loc,str] extractDuplicatesFromTextMapT2(map[str, list[loc]] textMap) { 	
	textMap = (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);

	rel[loc,loc,str] duplicateLocations = {};
    for (text <- textMap) {
    	for (firstLoc <- textMap[text], nextLoc <- textMap[text], firstLoc != nextLoc && <nextLoc, firstLoc,text> notin duplicateLocations) {
    		duplicateLocations += <firstLoc, nextLoc,text>;
    	}
    }
	
    return duplicateLocations;
}    

str getSpanTextT2(list[tuple[loc, str]] lines, loc span) = intercalate(uniqueLineSeperator, [text | <line, text> <- lines, line <= span, text != ""]);

loc getSpanT2(tuple[loc, loc] locationPair){
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
