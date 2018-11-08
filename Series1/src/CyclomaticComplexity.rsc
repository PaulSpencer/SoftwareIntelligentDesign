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
    }
    return complexity;
}
