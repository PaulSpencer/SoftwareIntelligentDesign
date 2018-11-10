module CyclomaticComplexity

import lang::java::jdt::m3::AST; 
import IO;
import List;

public rel[loc, int] calculateComplexity(loc location) {
    metric = {};
	for(/method(_, _, _, _, Statement impl, decl=methodLocation) := createAstFromFile(location, true)){
	    metric += <methodLocation, calculateMethodComplexity(impl)>;
	}
	
    for(/constructor(_, _, _, Statement impl, decl=constructorLocation) := createAstFromFile(location, true)){
	    metric += <constructorLocation, calculateMethodComplexity(impl)>;
	}
	return metric;
}

public int calculateMethodComplexity(Statement statement){
    complexity = 1;
    visit (statement) {
    	case \if(_,_) : complexity += 1;
    	case \if(_,_,_) : complexity += 1;
    	case \conditional(_,_,_) : complexity += 1;
    	case \while(_,_) : complexity += 1;
    	case \for(_,_,_,_) : complexity += 1;
    	case \for(_,_,_) : complexity += 1;
    	case \foreach(_,_,_) : complexity += 1;
    	case \do(_,_) : complexity += 1;
    	case \catch(_,_) : complexity += 1;    	
		case \infix(_, "||",_) : complexity += 1;
		case \infix(_, "&&",_) : complexity += 1;
		case \switch(_, statements) : complexity += casesNoFallThrough(statements);
    }
    return complexity;
}

public int casesNoFallThrough(list[Statement] statements){
	breakCount = 0;
	for(statement <- statements){
		visit (statement) {
    	   case \break() : breakCount += 1; 
    	   case \break(_) : breakCount += 1;
    	   case \return() : breakCount += 1;
    	   case \return(_) : breakCount += 1;
    	   case \throw(_) : breakCount += 1;
    	}
    }    
    return breakCount == 0 ? 1 : breakCount;
}