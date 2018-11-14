module LinesOfCode

import List;
import IO;
import Duplicate;

public int linesOfCode(loc location){
	allLines = size(readFileLines(location));
	emptyLines = (0 | it +1| <_,text> <- getCleanedLinesForFile(location), text == "");
	return allLines - emptyLines;
}
