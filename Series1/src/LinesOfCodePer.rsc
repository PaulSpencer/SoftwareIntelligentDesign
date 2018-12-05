module LinesOfCodePer

import lang::java::jdt::m3::Core;
import Relation;
import IO;
import List;
import LineCleaner;


public int countLinesPerProject(loc prj){
	myModel = createM3FromEclipseProject(prj);
	return (0 | it + linesOfCode(file) | file <- files(myModel));
}

public rel[loc, int] countLinesPerMethod(loc prj){
	myModel = createM3FromEclipseProject(prj);

	return {<method, linesOfCode(method)> | method <- methods(myModel)};
}

public int countLinesPerFile(loc fileLoc){
	return linesOfCode(fileLoc);
}


int linesOfCode(loc location){
	allLines = size(readFileLines(location));
	emptyLines = (0 | it +1| <_,text> <- getCleanedLinesForFile(location), text == "");

	return allLines - emptyLines;
}