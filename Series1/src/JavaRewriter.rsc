module JavaRewriter
import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST; 
import Prelude;
import String;
import IO;
import analysis::m3::AST;
import List;


public str transcriber(loc file){
	originalFileText = readFile(file);
	
	originalAst = createAstFromFile(file, false);
	originalAst = visit (originalAst){
		case \variable(x,y) => \variable(x,y) 
		case \variable(x,y,z) => \variable(x,y,z) 
		case \simpleName(x) => \simpleName(x)
	} 	
	
	transformedAst = visit (originalAst){
		case \variable(x,y) => \variable("__VARIABLE__",y) 
		case \variable(x,y,z) => \variable("__VARIABLE__",y,z) 
		case \simpleName(_) => \simpleName("__SIMPLENAME__")
	} 
	
	originalLocations = getLocations(originalAst);
	transformedLocations = getLocations(transformedAst);
	
	originalLocations = sort(originalLocations,bool(tuple[loc,str] a, tuple[loc,str] b){<a1,_> = a; <b1,_> = b; return a1.offset > b1.offset;}); 
		
	changes = [];
	for(originalLocation <- originalLocations) {
		<olocation, ostuff> = originalLocation;
		matches = [<tlocation, tstuff> | <tlocation, tstuff> <-  transformedLocations, tlocation == olocation];
		
		if (size(matches) == 1) {
			
			transformedLocation = head(matches);
			<tlocation, tstuff> = transformedLocation;
			if(ostuff != tstuff) {				
				changelist = [change | <change,_> <- changes, tlocation > change];
				if (size(changelist) == 0){
					changes += <tlocation,diff(ostuff,tstuff)>;
				}			
			}
		} 

	}
	for (change <-changes) {
		<changeLocation, changeStrings> = change;
		offset = changeLocation.offset;
		length = changeLocation.length;
		
		priorText = substring(originalFileText,0,offset);
		textToChange = substring(originalFileText,offset,offset+length);
		posteriorText = substring(originalFileText,offset + 1 + length);
		for (changeString <- changeStrings) {
			<ostring, tstring> = changeString;
			textToChange = replaceFirst(textToChange, ostring, tstring);
		}
		originalFileText = priorText + textToChange + posteriorText;
	}
	
	return originalFileText;
}

list[tuple[str,str]] diff(str original, str tranformed){
	return [<oString, tString> | <oString,tString> <- zip(extractStrings(original),extractStrings(tranformed)), oString != tString];
}

list[str] extractStrings(str original){
	line = original;
	originalStrings = [];
	originalWord = "";	
	isInString = false;
	while (size(line) > 0) {
        quotes = findAll(line,"\"") - [quote+1 | quote <- findAll(line,"\\\"")]; 
		if (isEmpty(quotes)) {
			line = "";
			continue;
		} 
		firstQuote = head(quotes);
		if (isInString) {
			originalStrings += substring(line,0,firstQuote);			
		} 
		line = substring(line,firstQuote+1);
		isInString = !isInString;
	}
	return originalStrings;
}


list[tuple[loc, str]] getLocations(Declaration ast2){
	locations  = [];
	for(/Statement x := ast2) {
		if (x.src != |unknown:///|) {
			locations += <x.src, toString(x)>;
		}
	}
	for(/Declaration x := ast2) {
		if (x.src != |unknown:///|) {
			locations += <x.src, toString(x)>;
		}
	}
	
	for(/Expression x := ast2) {
		if (x.src != |unknown:///|) {
			locations += <x.src, toString(x)>;
		}
	}
	
	return locations;
}