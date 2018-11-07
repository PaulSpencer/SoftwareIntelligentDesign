module Loc2


/*
import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST; 
import lang::java::m3::Core;
import IO;
import List;

public void getLinesOfCode(){
  locations = [ file | file <- files(createM3FromEclipseProject(|project://first|))];
  for(location <- locations){
    myLines = [ln | ln <- readFileLines(location), ln != "\r\n"];
    for(line <- myLines){
      println(line);
    }
  }
}

public void getLinesOfCode2(){
  locations = [ file | file <- files(createM3FromEclipseProject(|project://first|))];
  for(location <- locations){
    myFileString = readFile(location);
    //println(myFileString);
    println(removeComments2(myFileString));
  }
}


str removeMultiLineComments(str source) {
    return visit(source) {
        case /\/\*[\s\S]*?\*\// => ""  
    };
}
*/