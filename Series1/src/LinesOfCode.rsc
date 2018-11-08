module LinesOfCode

import List;
import IO;
import String;

public int linesOfCode(loc location){
	return size(readFileLines(location)) - singleComment(readFileLines(location));
}

public int singleComment(list[str] fred){
	count = 0;
	for(str s <- fred){
		if(startsWith(trim(s),"//") ){
			count +=1;
		}
		if(trim(s) == ""){
			count +=1;
		} 
	}
	return count;
}