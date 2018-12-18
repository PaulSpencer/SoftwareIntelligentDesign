module JavaRewriter
import lang::java::jdt::m3::Core; 
import lang::java::jdt::m3::AST; 
import lang::java::m3::TypeSymbol;
import Prelude;
import String;
import IO;
import analysis::m3::AST;

import List;


public str transcriber(loc file){
	originalFileText = readFile(file);
	originalSize = size(originalFileText);
	
	println(originalFileText);
	println();

	originalAst = createAstFromFile(file, true);
	originalAst = visit (originalAst){
		case \variable(x,y) => \variable(x,y) 
		case \variable(x,y,z) => \variable(x,y,z) 
		case \simpleName(x) => \simpleName(x)
		case \method(x, y, z, a, b) => \method(x, y, z, a, b)
		case \method(x, y, z, a) => \method(x, y, z, a)
		case \methodCall(x, y, z) => \methodCall(x, y, z)
		case \methodCall(x, y, z, a) => \methodCall(x, y, z, a)  
		case \package(x) => package(x)  
		case \package(x,y) => package(x,y)  
		case \class(x, y, z, a) => \class(x, y, z, a)
		case \constructor(x, y, z, a) => \constructor(x, y, z, a)
		case \parameter(x, y, z) => \parameter(x, y, z) 
		case \number(x) => \number(x)
		case \enum(x, y, z, a) => enum(x, y, z, a)
    	case \enumConstant(x, y, z) => \enumConstant(x, y, z)
    	case \enumConstant(x, y) => \enumConstant(x, y)
    	case \interface(x, y, z, a) => \interface(x, y, z, a)
    	case \import(x) => \import(x)
    	case \infix(x, y, z) => \infix(x, y, z) 
    	case \postfix(x, y) => \postfix(x, y)
    	case \prefix(x,y) => \prefix( x,y)
		case \vararg(x, y) => \vararg(x, y)
    	
    	case \stringLiteral(x) => \stringLiteral(x)
    	case \booleanLiteral(x) => \booleanLiteral(x)
	} 	
	
	
	transformedAst = visit (originalAst){
		case \variable(x,y) => \variable("__VARIABLE__",y) 
		case \variable(x,y,z) => \variable("__VARIABLE__",y,z) 
		case \simpleName(_) => \simpleName("__SIMPLENAME__") 
		case \method(x, _, z, a, b) => \method(x, "__METHODNAME__", z, a, b) 
		case \method(x, _, z, a) => \method(x, "__METHODNAME__", z, a)
		case \methodCall(x, _, z) => \methodCall(x, "__METHODCALL__", z)
		case \methodCall(x, y, _, z) => \methodCall(x, y, "__METHODCALL__", z) 
		case \package(_) => \package("__PACKAGE__")
		case \package(x,_) => package(x,"__PACKAGE__")  
		case \class(_, y, z, a) => \class("__CLASS__", y, z, a)		
		case \constructor(_, y, z, a) => \constructor("__CONSTRUCTOR__", y, z, a)
		case \parameter(x, _, z) => \parameter(x, "__PARAMETER__", z)
		case \number(_) => \number("__NUMBER__")
		case \enum(_, y, z, a) => enum("__ENUM__", y, z, a)
    	case \enumConstant(_, y, z) => \enumConstant("__ENUMCONSTANT__", y, z)
    	case \enumConstant(_, y) => \enumConstant("__ENUMCONSTANT__", y)
		case \interface(_, y, z, a) => \interface("_INTERFACE__", y, z, a)
		case \import(_) => \import("__IMPORT__")	
		case \infix(x, _, y) => \infix(x, "__OPERATOR__", y) 
    	case \postfix(x, _) => \postfix(x, "__OPERATOR__")
    	case \prefix(_, x) => \prefix( "__OPERATOR__", x)
    	case \vararg(x, _) => \vararg(x, "__ARGUMENTS__")
		
		case \stringLiteral(_) => \stringLiteral("\"__STRINGLITERAL__\"") // not working
    	case \booleanLiteral(x) => \booleanLiteral(!x) // not in a string 
	} 
	
 
  	/*
	iprint(originalAst);
	println("--------");
	iprint(transformedAst);
	*/

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
//				println(diff(ostuff,tstuff));
//				println();
				changes += <tlocation,diff(ostuff,tstuff)>;
			}
		} 
	}
	
	for (change <-changes) {
		<changeLocation, changeStrings> = change;
		offset = changeLocation.offset;
		length = changeLocation.length;
		
		priorText = substring(originalFileText,0,offset);
		textToChange = substring(originalFileText,offset,offset+length);
		posteriorText = substring(originalFileText,offset+ length);
	
		for (changeString <- changeStrings) {
			<ostring, tstring> = changeString;
			/*
			println();
			
			println("orig: <ostring>");
			println("new: <tstring>");
			println("before: ");
			println("<textToChange>");
			*/
			textToChange = replaceFirstWord(textToChange, ostring, tstring);
			/*
			println();
			println("after: ");
			println("<textToChange>");
			println("----------------------");
			*/
		}
		eol = "\n";
		originalFileText = priorText + textToChange + posteriorText;
		if(size(originalFileText) < originalSize) {
		 	originalFileText = originalFileText + eol;
		}
	}
	
	println(originalFileText);
	println("---------------");
	println();
	return originalFileText;
}

str replaceFirstWord(str textToChange, str ostring, str tstring) {
	// all word deliniators
	delims = [" ",".",",","(",")","[","]","{","}","\n","\r","\t","=","+","-","/","&","^","%","@",";","\"","\>","\<","!"];
	delimPairs = [<prefix,suffix> | prefix <- delims, suffix <-delims];
	// loop through combinations
	for (<prefix,suffix> <- delimPairs) {
		if(contains(textToChange, prefix + ostring + suffix)) {
			return replaceLast(textToChange,prefix + ostring + suffix,prefix + tstring + suffix);
		}
	}
	//replace if first
	if(findFirst(textToChange, ostring) == 0) {
		for (suffix <- delims) { 
			if(findFirst(textToChange, ostring + suffix) == 0) {
				return replaceFirst(textToChange, ostring + suffix, tstring + suffix);
			} 
		}
	}
	
	// replace if last
	lastPos =findLast(textToChange, ostring) ;
	if (lastPos != -1 && (lastPos + size(ostring) == size( textToChange))){
		for (prefix <- delims) { 
			if(findFirst(textToChange, prefix + ostring) != -1) {
				return replaceLast(textToChange, prefix + ostring, prefix + tstring);
			} 
		}	
	}
	
	return textToChange;	
}

list[tuple[str,str]] diff(str original, str tranformed){
	return [<oString, tString> | <oString,tString> <- zip(extractStrings(original),extractStrings(tranformed)), oString != tString] +
		extractBooleanLiterals(original) + 
		extractTypes(original); 
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
			originalString = substring(line,0,firstQuote);
			originalString = replaceAll(originalString, "\\\"", "\"");
			originalStrings += originalString;			
		} 
		line = substring(line,firstQuote+1);
		isInString = !isInString;
	}

	return originalStrings;
}

list[tuple[str,str]] extractBooleanLiterals(str original){
	truelist = [<"true","__BOOLEANLITERAL__"> | _ <- findAll(original,"booleanLiteral(true)")] ;
	falselist =  [<"false","__BOOLEANLITERAL__"> | _ <- findAll(original,"booleanLiteral(false)")];
	return truelist + falselist;
}


list[tuple[str,str]] extractTypes(str original){
	return  [<"boolean","__TYPE__"> | _ <- findAll(original,"boolean()")] +
		[<"boolean","__TYPE__"> | _ <- findAll(original,"boolean()")] +
		[<"void","__TYPE__"> | _ <- findAll(original,"void()")] +
		[<"byte","__TYPE__"> | _ <- findAll(original,"byte()")] +
		[<"char","__TYPE__"> | _ <- findAll(original,"char()")] +
		[<"double","__TYPE__"> | _ <- findAll(original,"double()")] +
		[<"float","__TYPE__"> | _ <- findAll(original,"float()")] +
		[<"long","__TYPE__"> | _ <- findAll(original,"long()")] +
		[<"short","__TYPE__"> | _ <- findAll(original,"short()")] +
		[<"int","__TYPE__"> | _ <- findAll(original,"int()")] +
		[<"?","__TYPE__"> | _ <- findAll(original,"wildcard()")] ;

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
