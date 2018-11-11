module Duplicate

import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Type;

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

public list[int] getQuotes(str line){
	quotes = findAll(line,"\"");	
	escaped = [q+1 | q <- findAll(line,"\\\"")];
	return quotes - escaped;
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