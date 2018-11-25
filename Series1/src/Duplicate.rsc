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

public int getTotalDuplicatedLines(loc project){
	fileLines = getCleanedFileLinesForProject(project);
	duplicates = getDuplicatesFromLines(fileLines); 
	
	set[loc] emptyLocSet = {};
	map[str, set[loc]] duplicateGroups = ();
	for (<l1,l2,key> <- duplicates) {
		duplicateGroups[key]?emptyLocSet += {l1,l2};
	}
	
	totalDuplicatedLines = 0;
	for (key <- duplicateGroups) {
		duplicatesInGroup = duplicateGroups[key];
		lines = size(findAll(key,uniqueLineSeperator)) +1;
		duplicatedLines = lines *(size(duplicatesInGroup) -1);
		totalDuplicatedLines += duplicatedLines;
	}
	
	return totalDuplicatedLines;
}


public rel[loc,loc] findDuplicates(loc project) {
	fileLines = getCleanedFileLinesForProject(project);

	dups = getDuplicatesFromLines(fileLines);
	
	map[str, set[loc]] duplicateGroups = ();
	for (dup <- dups) {
		<l1,l2,key> = dup;
		if (key in duplicateGroups){
			duplicateGroups[key] = duplicateGroups[key] + {l1,l2};
		} else {
			duplicateGroups += (key : {l1,l2});
		}		
	}
	
	totalDuplicate = 0;
	totalGroupCount = 0;
	totalGroupQty = 0;
	for (key <- duplicateGroups){
		totalGroupCount += 1;
		
		groupz = duplicateGroups[key];		
		totalGroupQty += size(groupz);
		lineCount = size(findAll(key,uniqueLineSeperator));
		duplicateLineCount = lineCount *(size(groupz) -1);
		totalDuplicate += duplicateLineCount;
		/*
		println();println();println();
		println("----------------------------------------------");
		println("the following <size(groupz)> locations are equal: ");
		println("they each have <lineCount> lines making <duplicateLineCount> duplicate lines");
		println("----------------------------------------------");
		for(location <- groupz){
			println("<location>");
			println("...");
			println(readFile(location));
			println("...");
		}
		*/
	}
	
	return {<l1,l2>  | <l1,l2,_> <- dups};
}



rel[loc, loc, str] getDuplicatesFromLines(set[list[tuple[loc, str]]] fileLines) {
	textMap = createMapOfTextsAndLocations(fileLines);
	duplicateLocations = extractDuplicatesFromTextMap(textMap);
	subsetDuplicates = getSubsetLocations(textMap,duplicateLocations);
		
	return  duplicateLocations - subsetDuplicates;
}

rel[loc,loc,str] getSubsetLocations(map[str, list[loc]] textMap,rel[loc,loc,str] duplicateLocations){
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
	
	map[loc, set[tuple[loc,str]]] subsetLocs = ();
	set[tuple[loc,str]] emptyLocSet = {};
	for	(subsetText <- subsetTexts, supersetText <- subsetTexts[subsetText]) {
		for (subset <- textMap[subsetText], superset <-textMap[supersetText], subset.path == superset.path && subset < superset){
			subsetLocs[subset]?emptyLocSet += {<superset,supersetText>};
		}
	}
	
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

map[str, list[loc]] createMapOfTextsAndLocations(set[list[tuple[loc, str]]] fileLines){
	map[str, list[loc]] textMap = ();
	blocksWithDuplicateSingleLines = breakOnUniqueLines(fileLines);
	for (lines <-blocksWithDuplicateSingleLines){
		lineLocationPairs = {<l1,l2> | <l1,_> <- lines, <l2,_> <- lines, (l1.begin.line +5) <= l2.begin.line};
			
		for (lineLocationPair <- lineLocationPairs) {
			<l1,l2> = lineLocationPair;
			spanLocation = getSpan(lineLocationPair);
			spanText = getSpanText(lines,spanLocation);
			lineCount = size(findAll(spanText, uniqueLineSeperator));
			if(lineCount >= 5) {
				if (spanText in textMap) {
					textMap[spanText] = textMap[spanText] + [spanLocation];	
				} else {		
					textMap += (spanText : [spanLocation]);
				}
			}
		}
	}

	return (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);
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

rel[loc,loc,str] extractDuplicatesFromTextMap(map[str, list[loc]] textMap) { 	
	duplicateTexts = (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);

	rel[loc,loc,str] duplicateLocations = {};
    for (text <- duplicateTexts) {
    	locations = textMap[text];
    	
    	for (firstLoc <- locations, nextLoc <- locations, firstLoc != nextLoc) {
    		if(<nextLoc, firstLoc,text> notin duplicateLocations) {
    			duplicateLocations += <firstLoc, nextLoc,text>;
    		}
    	}
    }
	
    return duplicateLocations;
}    

str getSpanText(list[tuple[loc, str]] lines, loc span) {
	linesInSpan = [text | <line, text> <- lines, line <= span, text != ""];
	allLines = intercalate(uniqueLineSeperator, linesInSpan);
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
