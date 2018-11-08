module CyclomaticComplexity

import lang::java::jdt::m3::AST; 

public rel[loc, int] calculateComplexity(loc location) {
    metric = {};
	for(/method(_, _, _, _, Statement impl, decl=methodLocation) := createAstFromFile(location, true)){
	    metric = metric + <methodLocation, calculateMethodComplexity(impl)>;
	}
	
    for(/constructor(_, _, _, Statement impl, decl=methodLocation) := createAstFromFile(location, true)){
	    metric = metric + <methodLocation, calculateMethodComplexity(impl)>;
	}
	return metric;
}

public int calculateMethodComplexity(Statement statement){
    return 1;
}
