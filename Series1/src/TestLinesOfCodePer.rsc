module TestLinesOfCodePer

import LinesOfCodePer;
import IO;
import Set;
import lang::csv::IO;
import List;
import Map;

//TODO make tests
/*  
test bool singleLineMethod(){
	rel[loc tp, int nm] methodSet = {}; 
	myFile = |project://main/src/main/helloWorld2.java|;
	methodSet = countLinesPerMethod(myFile);
	for(s <- methodSet){
		println(s);
		if(s.tp == |java+method:///main/helloWorld2/oneline()|){
			return s.nm == 1;
		}
	}
	return false;
}

test bool tenEmptyLines(){
	rel[loc tp, int nm] methodSet = {}; 
	myFile = |project://main/src/main/method10lines.java|;
	methodSet = countLinesPerMethod(myFile);
	for(s <- methodSet){
		if(s.tp == |java+method:///main/method10lines/ten()|){
			return s.nm == 2;
		}
	}
	return false;
}

test bool singleMulti(){
	rel[loc tp, int nm] methodSet = {}; 
	myFile = |project://main/src/main/singleMulti.java|;
	methodSet = countLinesPerMethod(myFile);
	for(s <- methodSet){
		if(s.tp == |java+method:///main/singleMulti/sm()|){
			return s.nm == 6;
		}
	}
	return false;
}
*/