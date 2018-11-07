module Loc2



import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST; 
import lang::java::m3::Core;
import IO;
import List;
import String;

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
  lineCount = 0;
  locations = [ file | file <- files(createM3FromEclipseProject(|project://first|))];
  for(location <- locations){
    source = readFile(location);
   // println(source);
    changedSource = removeMultiLineComments(source);
    mylines = split("\r\n",changedSource);
    println(changedSource);
    lineCount += size(mylines);
  }
  println(lineCount);
}

str removeMultiLineComments(str source) {
    return visit(source) {
        case /\/\*[\s\S]*?\*\// => ""  
        case /^\s*$(?:\r\n?|\n)/ => ""
    };
}
