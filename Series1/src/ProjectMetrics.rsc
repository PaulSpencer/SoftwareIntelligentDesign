module ProjectMetrics

import CyclomaticComplexity;
import lang::csv::IO;
import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Duplicate;

public loc smallSqlProject = |project://smallsql0.21_src|;

public loc hsqldbProject = |project://hsqldb-2.3.1|;

public void outputDuplicates(loc project){
	writeCSV(findDuplicates(project),|file:///C:/temp/pauldups.csv|);
}

public void outputCyclometricComplexity(loc project){
  rel[loc, int] metrics = {};
  locations = [ file | file <- files(createM3FromEclipseProject(project))];
  println(locations);
  for(location <- locations){
    metrics += calculateComplexity(location);
  }
  
  writeCSV(relLocToFqn(metrics),|file:///C:/temp/paul2.csv|);
}

rel[str methodName, int metric] relLocToFqn(rel[loc, int] metrics)
   = { <removeFqnFromParameters(locToFqn(location)), ccMetric> | <location, ccMetric> <- metrics};
   
str locToFqn(loc location) { 
    fqn = replaceAll(location.path,"/",".");
    return replaceFirst(fqn,".","");
}

str removeFqnFromParameters(str fqn){
    firstPart = substring(fqn,0, findFirst(fqn, "(") +1);
	myparameters = split(",",substring(fqn,findFirst(fqn, "(") +1, findFirst(fqn, ")")));
	return firstPart + intercalate(",",[getMethodName(p) | p <- myparameters]) + ")";
}

str getMethodName(str fqn){
  if(findLast(fqn,".") == -1) {
    return fqn;
  } else {
    return substring(fqn, findLast(fqn,".")+1);
  }  
}

