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
	for(str s <- fred){ 
		firstQuotePosition = findFirst(s, "\"");
		if(firstQuotePosition != -1){
			lastQuotePosition = findLast(s, "\"");
			if(lastQuotePosition != -1){
				firstBit = substring(s,0,firstQuotePosition);
				lastBit = substring(s, lastQuotePosition);
				quoteBit = substring(s,firstQuotePosition,lastQuotePosition);
				quoteBit = replaceAll(quoteBit,"/*","");
				quoteBit = replaceAll(quoteBit,"*/","");
				quoteBit = replaceAll(quoteBit,"//","");
				s = firstBit + quoteBit + lastBit;
			}
		}
		if (findFirst(trim(s),"/*") != -1) {
		    inMultiLineComment = true;
		    if(!startsWith(trim(s),"/*") ){
		    	count -= 1;
		    }
		}
		
		if(inMultiLineComment){
		   count +=1;
		} else {		
			if(startsWith(trim(s),"//") ){
				count +=1;
			}
			if(trim(s) == ""){
				count +=1;
			} 
		}
		
		if(findFirst(trim(s),"*/") != -1) {
		    inMultiLineComment = false;
		    if (!endsWith(trim(s),"*/")) {
	          count -=1;      
		    }
		}
	}
	return count;
}