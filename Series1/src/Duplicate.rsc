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
	map[str, set[loc]] duplicateGroups = ();
	for (duplicate <- duplicates) {
		<l1,l2,key> = duplicate;
		if (key in duplicateGroups){
			duplicateGroups[key] = duplicateGroups[key] + {l1,l2};
		} else {
			duplicateGroups += (key : {l1,l2});
		}		
	}
	
	totalDuplicatedLines = 0;
	for (key <- duplicateGroups) {
		duplicatesInGroup = duplicateGroups[key];
		lines = size(findAll(key,uniqueLineSeperator));
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
	map[str, list[loc]] textMap = ();
	map[str, int] textlineCount = ();
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
					if (spanText notin textlineCount)	{		
						textlineCount += (spanText : lineCount);
					}
				} else {		
					textMap += (spanText : [spanLocation]);
				}
			}
		}
	}

	textMap = (text : textMap[text] | text <- textMap, size(textMap[text]) > 1);
	
	rel[loc,loc,str] duplicateLocations = extractDuplicatesFromTextMap(textMap);
	
	
	lineCounts = toList(toSet([textlineCount[text] | text <- textlineCount]));
	lineCounts = sort(lineCounts, bool(int a, int b) { return a > b; });
	map[str, set[str]] subsetTexts = ();
	for (lineCount <- lineCounts) {
		for (text <- textlineCount,  textlineCount[text] == lineCount){
			if (text notin textMap) {
				continue;
			}
			
			minusFirstLine = substring(text, findFirst(text,uniqueLineSeperator)+size(uniqueLineSeperator));
			minusLastLine = substring(text, 0, findLast(text,uniqueLineSeperator));
			
			if(minusFirstLine in textMap) {
				if (minusFirstLine in subsetTexts) {
					subsetTexts[minusFirstLine] = subsetTexts[minusFirstLine] + text;
				} else {
					subsetTexts += (minusFirstLine : {text});
				}
			}
			
			if(minusLastLine in textMap) {
				if (minusLastLine in subsetTexts) {
					subsetTexts[minusLastLine] = subsetTexts[minusLastLine] + text;
				} else {
					subsetTexts += (minusLastLine : {text});
				}
			}
		}
	}
	
	map[loc, set[tuple[loc,str]]] subsetLocs = ();
	for	(subsetText <- subsetTexts) {
		for (supersetText <- subsetTexts[subsetText]){
			for (subset <- textMap[subsetText], superset <-textMap[supersetText]){
				if (subset.path == superset.path && subset < superset) {
					if (subset in subsetLocs) {
						subsetLocs[subset] = subsetLocs[subset] + <superset,supersetText>;
					} else {
						subsetLocs += (subset : {<superset,supersetText>});
					}
				}
			}
		}
	}
	
	rel[loc,loc,str] subsetDuplicates = {};	

	for (<l1, l2,text>  <- {<l1, l2,text>  | <l1, l2,text> <- duplicateLocations, l1 in subsetLocs && l2 in subsetLocs}) {

		l1Sets = subsetLocs[l1];
		l2Sets = subsetLocs[l2];
	
		for (<l1Bigger,l1Text> <- l1Sets, <l2Bigger,_> <- l2Sets){
			if (<l1Bigger, l2Bigger,l1Text> in duplicateLocations || <l2Bigger, l1Bigger> in duplicateLocations){
				subsetDuplicates += <l1, l2,text>;
			}
		}		
	}	
	
	return  duplicateLocations - subsetDuplicates;
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
