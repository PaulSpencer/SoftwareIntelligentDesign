module testLinesOfCodePer

import LinesOfCodePer;
import LinesOfCode;
import IO;
import Set;
import lang::csv::IO;
import List;
import Map;

test bool emptyFile(){
	rel[loc tp, int nm] methodSet = {}; 
	myEmptyFile = |project://main/src/main/emptyFile.java|;
	methodSet = countLinesPerMethod(myEmptyFile);
	println(methodSet);
	return true;
}

test bool emptyFile2(){
	rel[loc tp, int nm] methodSet = {}; 
	myEmptyFile = |project://main/src/main/emptyFile.java|;
	methodSet = {<myEmptyFile,linesOfCode(myEmptyFile)>};
	println(methodSet);
	return true;
}

/*
test bool threeMethods(){
	rel[loc tp, int nm] methodSet = {}; 
	isTrue = 0;
	myFile = |project://main|;
	methodSet = countLinesPerMethod(myFile);
	println("THREE METHODS FUN");
	println(methodSet);
	println(size(methodSet));
	for(s<-methodSet){
		if(s.tp == |java+method:///main/helloWorld/twod()|){
			isTrue += 1;
		}
	}
	println(isTrue);
	return isTrue == 1;
}
*/


//Writes in a csv file the metrics of count lines of whole project per method
public void wExcel(){
	rel[loc tp, int nm] methodSet = {}; 
	myProjectFile = |project://main|;
	methodSet = countLinesPerMethod(myProjectFile);
	writeCSV(methodSet, |file:///E:/metr.csv|);
}

public void wExcel2(){
	rel[loc tp, int nm] methodSet = {}; 
	//myProjectFile = |project://smallsql0.21_src|;
	myProjectFile = |project://hsqldb-2.3.1|;
	methodSet = countLinesPerMethod(myProjectFile);
	c = 0;
	for (s<-methodSet){
		c += s.nm;
	}
	//writeCSV(methodSet, |file:///E:/small.csv|);
	//println("The number of lines of all methods is:");
	//println(c);
	methodSizeToMap(methodSet);
}

 public void methodSizeToMap(rel[loc, int] methodSet){
 	rel[loc tp, int nm] MyMethodSet = {};
 	MyMethodSet = methodSet; 
	map [str, int] methodDist = ("l":0,"m":0,"h":0,"vh":0);	
	for(s<-MyMethodSet){
		if(s.nm <= 30 ){
			methodDist["l"] += s.nm;	
		}
		if(s.nm > 30 && s.nm <= 44){
			methodDist["m"] += s.nm;
		}
		if(s.nm > 44 && s.nm <= 74){
			methodDist["h"] += s.nm;
		}
		if(s.nm > 74){
			methodDist["vh"] += s.nm;
		}
	} 
	println(methodDist);
}







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
