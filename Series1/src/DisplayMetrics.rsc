module DisplayMetrics

import LinesOfCodePer;
import CyclomaticComplexity;
import Duplicate;
import util::Math;
import String;
import IO;
import DateTime;

public loc smallSqlProject = |project://smallsql0.21_src|;
public loc hsqldbProject = |project://hsqldb-2.3.1|;
public str newLine = "\n";

public void displayMetricsForProject(loc project){
	startTime = now();
	println("For the project <project.authority> we have the following metrics:");
	println();
	//projectLoc = countLinesPerProject(project);
	//println("Volume (total Lines of Code) : <projectLoc>");
	//println();
	//println(getMethodSizeSummary(project));
	//println();
	println(getCyclomaticComplexitySummary(project));
	//println();
	//duplicateLineCount = getTotalDuplicatedLines(project);
	//println("Duplicate lines (6+) Total: <duplicateLineCount> (<percent(duplicateLineCount,projectLoc)>%)");
	endTime = now();
	timeTaken = endTime - startTime;
	println("time taken: <timeTaken.minutes>:<timeTaken.seconds>");
}


public str getCyclomaticComplexitySummary(loc project){
	methodSet = calculateComplexityForProject(project);
	distribution = getCyclomaticComplexityDistribution(methodSet);
	
	summary = "Cyclomatic Complexity per Method:" + newLine;
	summary += summaryCCLine("low","1 - 6",distribution);
	summary += summaryCCLine("moderate","6 - 8",distribution);
	summary += summaryCCLine("high","8 - 14",distribution);
	summary += summaryCCLine("very high","\> 14",distribution);

	return summary;
}

str summaryCCLine(str key, str description, map [str, int] distribution) {
	total = (0 | it + distribution[methodName] | methodName <- distribution);
	intro = substring("<key> (<description>)" + "                         ",0,30);
	count = "     " + "<distribution[key]>";
	count = substring(count,size(count)-6);
	percentage = "     " + "<percent(distribution[key], total)>";
	percentage =substring(percentage,size(percentage)-3); 
	return "<intro>  <count>\t <percentage>%"+ newLine;
}

map [str, int] getCyclomaticComplexityDistribution(rel[loc, int] methodsWithCyclomaticComplexity){
	map [str, int] methodDistribution = ("low":0,"moderate":0,"high":0,"very high":0);	
	
	for(methodWithCyclomaticComplexity <-methodsWithCyclomaticComplexity){
		<_, methodCyclomaticComplexity> = methodWithCyclomaticComplexity;
		
		methodDistribution[getCCCategory(methodCyclomaticComplexity)] += methodCyclomaticComplexity;
	} 
	
	println("<methodDistribution>");
	
	return methodDistribution;
}

str getCCCategory(int complexity) {
	if(complexity <= 6) return "low";
	if(complexity <= 8)	return "moderate";
	if(complexity <= 14) return "high";
	return "very high";
}

public str getMethodSizeSummary(loc project){

	methodSet = countLinesPerMethod(project);
	distribution = getMethodSizeDistribution(methodSet);
	summary = "Distribution of Method Line Sizes:" + newLine;
	summary += summaryLine("low","less than 30",distribution);
	summary += summaryLine("medium","31 - 44",distribution);
	summary += summaryLine("high","45 - 74",distribution);
	summary += summaryLine("very high","greater than 74",distribution);

	return summary;
}

str summaryLine(str key, str description, map [str, int] distribution) {
	total = (0 | it + distribution[methodName] | methodName <- distribution);
	intro = substring("<key> (<description>)" + "                         ",0,30);
	count = "     " + "<distribution[key]>";
	count = substring(count,size(count)-6);
	percentage = "     " + "<percent(distribution[key], total)>";
	percentage =substring(percentage,size(percentage)-3); 
	return "<intro>  <count>\t <percentage>%"+ newLine;
}

map [str, int] getMethodSizeDistribution(rel[loc, int] methodsWithLineCount){
	map [str, int] methodDistribution = ("low":0,"medium":0,"high":0,"very high":0);	
	
	lowRange = [0 .. 30];
	mediumRange = [31 .. 44];
	highRange = [45 .. 74];
	allRanges = lowRange + mediumRange + highRange;
	
	for(methodWithLineCount <-methodsWithLineCount){
		<_, methodLineCount> = methodWithLineCount;
		
		if(methodLineCount in lowRange){
			methodDistribution["low"] += methodLineCount;
		}
		
		if(methodLineCount in mediumRange){
			methodDistribution["medium"] += methodLineCount;
		}
		
		if(methodLineCount in highRange){
			methodDistribution["high"] += methodLineCount;
		}
		
		if(methodLineCount notin allRanges){
			methodDistribution["very high"] += methodLineCount;
		}
	} 
	
	return methodDistribution;
}

