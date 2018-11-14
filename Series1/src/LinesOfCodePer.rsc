module LinesOfCodePer

import lang::java::jdt::m3::Core;
import lang::java::m3::Core;
import lang::java::jdt::m3::AST; 
import IO;
import List;
import LinesOfCode;
import Set;
import Relation;


public rel[loc, int] countLinesPerMethod(loc prj){
	info = {}; 
	myModel = createM3FromEclipseProject(prj);
	myMethods = methods(myModel);
	for(s<-myMethods){
		println("FOR LOOP: following the rel");
		info += <s, linesOfCode(s)>;
		println(info);
		
	}
	//return count == 9; //helloWorld.java has 9 lines of code after removing the comments
	println("FINAL REL");
	println(info);
	return info;
}


public void countLinesPerProject(loc prj){
    counter = 0;
    for (file <- files(createM3FromEclipseProject(prj))) {
    	    counter += linesOfCode(file);
	}
	println(counter);	
}



/*
test bool countLinesPerMethodTest(){
	count = 0;
	myModel = createM3FromEclipseProject(|project://main|);
	myMethods = methods(myModel);
	for(s<-myMethods){
		count += linesOfCode(s);
	}
	return count == 9; //helloWorld.java has 9 lines of code after removing the comments
}
*/

