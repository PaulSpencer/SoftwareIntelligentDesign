module MyCyclomaticComplexity

import lang::java::jdt::m3::AST; 
import lang::java::jdt::m3::Core; 
import List;
import IO;
import String;
import lang::csv::IO;

public map[str, int] calculate(loc project) {
  map[str, int] metric = ();
  //also need to do this for constructors
  
  for(/method(_, _, _, _, Statement impl, decl=location) := createAstsFromEclipseProject(project, true)){
    fqn = replaceAll(location.path,"/",".");
    fqn = replaceFirst(fqn,".","");
    metric[fqn] ? 0 += 1;
    visit (impl) {
      case \if(_,_) : metric[fqn] ? 0 += 1;
      case \if(_,_,_) : metric[fqn] ? 0 += 1; // why is thsi 1 not 2
      case \case(Expression exp) : metric[fqn] ? 0 += emptyExpression(exp);
      case \defaultCase() : metric[fqn] ? 0 += 1;
      case \while(_,_) : metric[fqn] ? 0 += 1;
      case \for(_,_,_) : metric[fqn] ? 0 += 1;
      case \for(_,_,_,_) : metric[fqn] ? 0 += 1;
      case \do(_,_) : metric[fqn] ? 0 += 1; // is this already covered by while?
      case \foreach(_,_,_) : metric[fqn] ? 0 += 1; 
      case \catch(_,_): metric[fqn] ? 0 += 1; //  why is this being called 300+ times
      case \expressionStatement(Expression stmt) : metric[fqn] ? 0 += getAndsAndOrs(stmt);
    }
  }
  writeMapToCsv(metric);
  
  return metric;
}

public int emptyExpression(Expression exp) {
  visit(exp){
     case \break() : return 1;
     case \break(_) : return 1;
     case \return() : return 1;
     case \return(_): return 1;
     case \continue() : return 1;
     case \continue(_) : return 1;
  }
  return 0;
}

public int getAndsAndOrs(Expression stmt) {
  ops = 0;
  
  visit (stmt) {
    case \infix(_,str operator,_) : println(operator); // ops += operator == "|" ? 1 : 0;
  }
  return ops;
}

public loc hwl = |project://first|;

public loc ssql = |project://smallsql0.21_src|;
//public loc hwl = |project://first/src/first/firstClass.java|;

public void writeMapToCsv(map[str, int] forOutput) {
	writeCSV(mapToRel(forOutput),|file:///C:/temp/paul.csv|);
}

rel[str methodName, int metric] mapToRel(map[str, int] metrics)
   = { <metric, metrics[metric]> | metric <- metrics};
   
   
public loc firstTestLocation = |project://someTests/src/someTests/firstTest.java|;
public bool firstTest = 