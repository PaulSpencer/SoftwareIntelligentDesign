module LinesOfCodePer

import lang::java::jdt::m3::Core;
import LinesOfCode;
import Relation;
import IO;


public rel[loc, int] countLinesPerMethod(loc prj){
	myModel = createM3FromEclipseProject(prj);

	return {<method, linesOfCode(method)> | method <- methods(myModel)};
}

public rel[loc, int] countLinesPerFile(loc fl){
	myModel = createM3FromEclipseProject(fl);
	myMethods = methods({fl});
	return {<fl, linesOfCode(myMethods)>};
}


