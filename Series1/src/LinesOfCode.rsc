module LinesOfCode

import List;
import IO;
import String;

public int linesOfCode(loc location){
	return size(readFileLines(location)) - singleComment(readFileLines(location));
}

public int singleComment(list[str] fred){
	count = 0;
	inMultiLineComment = false;
	separateTypeOfComments = false; // false is single com, and true is multi
	for(str s <- fred){
		if (startsWith(trim(s),"/*")) {
		    inMultiLineComment = true;
		    separateTypeOfComments = true;
		}
		
		if(inMultiLineComment){
		   count +=1;
		} 
		if(startsWith(trim(s),"//") && (separateTypeOfComments == false)){
			count +=1;
		}
		if(trim(s) == ""){
			count +=1;
		} 
		
		if(endsWith(trim(s),"*/")) {
		    inMultiLineComment = false;
		}
	}
	return count;
}