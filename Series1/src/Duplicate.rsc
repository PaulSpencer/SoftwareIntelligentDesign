module Duplicate

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
import LineCleaner;

public loc smallSqlProject = |project://smallsql0.21_src|;
public loc hsqldbProject = |project://hsqldb-2.3.1|;

public str uniqueLineSeperator = "\n \b";

public map[str, set[loc]] findDuplicateGroups(loc project) {
	fileLines = getCleanedFileLinesForProject(project);
	duplicates = getDuplicatesFromLines(fileLines); 
	return groupDuplicates(duplicates);
}

public rel[loc,loc] findDuplicates(loc project) {
	fileLines = getCleanedFileLinesForProject(project);
	dups = getDuplicatesFromLines(fileLines);		
	return {<l1,l2>  | <l1,l2,_> <- dups};
}

public int getTotalDuplicatedLines(loc project){
	fileLines = getCleanedFileLinesForProject(project);
	duplicates = getDuplicatesFromLines(fileLines); 
	duplicateGroups = groupDuplicates(duplicates);
	return (0 | it + (numberOfLines(key) * numberOfDuplicates(duplicateGroups,key)) | key <- duplicateGroups);
}

int numberOfLines(str text) = size(findAll(text,uniqueLineSeperator)) +1; 
int numberOfDuplicates(map[str, set[loc]] duplicateGroups, str key) = size(duplicateGroups[key])-1; 

map[str, set[loc]] groupDuplicates(rel[loc, loc, str] duplicates){
	set[loc] emptyLocSet = {};
	map[str, set[loc]] duplicateGroups = ();
	for (<l1,l2,key> <- duplicates) {
		duplicateGroups[key]?emptyLocSet += {l1,l2};
	}
	return duplicateGroups;
}

rel[loc, loc, str] getDuplicatesFromLines(set[list[tuple[loc, str]]] fileLines) {
	textMap = createMapOfTextsAndLocations(fileLines);
	duplicateLocations = extractDuplicatesFromTextMap(textMap);
	subsetDuplicates = getSubsetDuplicateLocations(textMap,duplicateLocations);
	return  duplicateLocations - subsetDuplicates;
}

rel[loc,loc,str] getSubsetDuplicateLocations(map[str, list[loc]] textMap, rel[loc,loc,str] duplicateLocations){
	subsetTexts = getAllSuperSetsExistingForTexts(textMap);
	subsetLocs = getLocationsForSubSets(textMap, subsetTexts);
	return getSubsetDuplicates(duplicateLocations,subsetLocs);
}

rel[loc,loc,str] getSubsetDuplicates(rel[loc,loc,str] duplicateLocations, map[loc, set[tuple[loc,str]]] subsetLocs) {
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

map[loc, set[tuple[loc,str]]] getLocationsForSubSets(map[str, list[loc]] textMap, map[str, set[str]] subsetTexts){
	map[loc, set[tuple[loc,str]]] subsetLocs = ();
	set[tuple[loc,str]] emptyLocSet = {};
	for	(subsetText <- subsetTexts, supersetText <- subsetTexts[subsetText]) {
		for (subset <- textMap[subsetText], superset <-textMap[supersetText], subset.path == superset.path && subset < superset){
			subsetLocs[subset]?emptyLocSet += {<superset,supersetText>};
		}
	}
	return subsetLocs;
}

map[str, set[str]] getAllSuperSetsExistingForTexts(map[str, list[loc]] textMap){
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


map[str, list[loc]] createMapOfTextsAndLocations(set[list[tuple[loc, str]]] fileLines){
	map[str, list[loc]] textMap = ();
	list[loc] emptyLocList = [];
	for (lines <- breakOnUniqueLines(fileLines)){
		lineLocationPairs = {<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, (l1.begin.line +5) <= l2.begin.line};
			
		for (lineLocationPair <- lineLocationPairs) {
			spanLocation = getSpan(lineLocationPair);
			spanText = getSpanText(lines,spanLocation);
			if(numberOfLines(spanText) >= 6) {
				textMap[spanText]?emptyLocList += [spanLocation];
			}
		}
	}

	return (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);
}

set[list[tuple[loc, str]]] breakOnUniqueLines(set[list[tuple[loc, str]]] fileLines) {
	uniqueLines = getUniqueLines(fileLines);
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
    
    return {text | text <- uniqueLineMap, uniqueLineMap[text]};
}

rel[loc,loc,str] extractDuplicatesFromTextMap(map[str, list[loc]] textMap) { 	
	textMap = (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);

	rel[loc,loc,str] duplicateLocations = {};
    for (text <- textMap) {
    	for (firstLoc <- textMap[text], nextLoc <- textMap[text], firstLoc != nextLoc && <nextLoc, firstLoc,text> notin duplicateLocations) {
    		duplicateLocations += <firstLoc, nextLoc,text>;
    	}
    }
	
    return duplicateLocations;
}    

str getSpanText(list[tuple[loc, str]] lines, loc span) = intercalate(uniqueLineSeperator, [text | <line, text> <- lines, line <= span, text != ""]);

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
