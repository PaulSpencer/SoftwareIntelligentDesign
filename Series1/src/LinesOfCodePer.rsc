module LinesOfCodePer

import lang::java::jdt::m3::Core;
import LinesOfCode;
import Relation;

public rel[loc, int] countLinesPerMethod(loc prj){
	myModel = createM3FromEclipseProject(prj);
	return {<method, linesOfCode(method)> | method <- methods(myModel)};
}