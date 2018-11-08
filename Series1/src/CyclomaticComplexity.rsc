module CyclomaticComplexity

import lang::java::jdt::m3::AST; 

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
    	case \case(_) : complexity += 1;
    	case \defaultCase() : complexity += 1;
    }
    return complexity;
}
