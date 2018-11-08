module LinesOfCode

import List;
import IO;

public int linesOfCode(loc location){
	return size(readFileLines(location));
}