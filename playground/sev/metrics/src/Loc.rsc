module Loc
/*
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core; 
import lang::java::m3::Core;
import IO;
import List;
import String;



public set[loc] getSrcFiles(M3 model){
	 return {f | f <- files(model), isSrcEntity(f)};
}

public set[loc] getSrcMethods(set[loc] sourceFiles){
	set[loc] sourceMethods= {};	 
	for(f <- sourceFiles)
		sourceMethods += methods(createM3FromFile(f));
	return sourceMethods;
}




public bool isSrcEntity(loc entity) = 
	contains(entity.path, "/src/") && !contains(entity.path, "/generated/")
	&& !contains(entity.path, "/sample/") && !contains(entity.path, "/samples/")
	&& !contains(entity.path, "/test/") && !contains(entity.path, "/tests/") 
	&& !contains(entity.path, "/junit/") && !contains(entity.path, "/junits/");




public loc helloWorldLocation = |project://first|;

public void countLinesOfCode()
{
  myAst = createAstsFromEclipseProject(helloWorldLocation, false);
  myLines = [visitAst(t) | t <- myAst];  
  for (myLine <- myLines)
  {
    println(myLine);
  }
}

public str visitAst(Declaration ast)
{
  return ast@src;
}




public int calculateProjectLoc(set[loc] projectFiles){
	int totalLoc = 0;
	for(f <- projectFiles)
		totalLoc += calculateLoc(f);
	return totalLoc;
}

public int calculateLoc(loc location){
	return size(getCleanCode(location));
}

*/