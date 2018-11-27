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
	projectVolume = countLinesPerProject(project);
	println("Volume (total Lines of Code) : <projectVolume>");
	println("SIG Volume Risk (<sigVolume(projectVolume)>)");
	println();
	println(getMethodSizeSummary(project));
	println();
	println(getCyclomaticComplexitySummary(project));
	println();
	duplicateLineCount = getTotalDuplicatedLines(project);
	println("Duplicate lines (6+) Total: <duplicateLineCount> (<percent(duplicateLineCount,projectVolume)>%)");
	println("SIG Duplicate Line Risk (<sigDuplicate(duplicateLineCount,projectVolume)>)");
	endTime = now();
	timeTaken = endTime - startTime;
	println("time taken: <timeTaken.minutes>:<timeTaken.seconds>");
}

str sigDuplicate(int duplicateCount, projectVolume) {
	percentage = percent(duplicateCount,projectVolume);
	if (percentage > 20) return "- -";
	if (percentage > 10) return "-";
	if (percentage >  5) return "0";
	if (percentage >  3) return "+";
	return "+ +";
}

str sigVolume(int volume){
	if (volume > 1310000) return "- -";
	if (volume >  665000) return "-";
	if (volume >  246000) return "0";
	if (volume >   66000) return "+";
	return "+ +";
}

public str getCyclomaticComplexitySummary(loc project){
	methodSet = calculateComplexityForProject(project);
	distribution = getCyclomaticComplexityDistribution(methodSet);
	
	summary = "Cyclomatic Complexity per Method:" + newLine;
	summary += summaryCCLine("low","1 - 6",distribution);
	summary += summaryCCLine("moderate","6 - 8",distribution);
	summary += summaryCCLine("high","8 - 14",distribution);
	summary += summaryCCLine("very high","\> 14",distribution);
	summary += "Sig Complexity Risk (<sigDistribution(distribution)>)";
	return summary;
}

str sigDistribution(map [str, int] distribution){
	moderate = distribution["moderate"];
	high = distribution["high"];
	veryHigh = distribution["very high"];
	if(veryHigh > 5 || high > 15 || moderate > 50) return "- -";
	if(veryHigh > 0 || high > 10 || moderate > 40) return "-";
	if(veryHigh > 0 || high >  5 || moderate > 50) return "0";
	if(veryHigh > 0 || high >  0 || moderate > 25) return "+";
	return "+ +";
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
	summary += summaryLine("moderate","31 - 44",distribution);
	summary += summaryLine("high","45 - 74",distribution);
	summary += summaryLine("very high","greater than 74",distribution);
	summary += "Sig Unit Size Risk (<sigDistribution(distribution)>)";
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
	map [str, int] methodDistribution = ("low":0,"moderate":0,"high":0,"very high":0);	
	
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
			methodDistribution["moderate"] += methodLineCount;
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

