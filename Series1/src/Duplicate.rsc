module Duplicate

import lang::java::jdt::m3::Core; 
import IO;
import String;

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

public tuple[bool, str] removeComments(bool isInMultiline, str line){
	return <false, line>;
}