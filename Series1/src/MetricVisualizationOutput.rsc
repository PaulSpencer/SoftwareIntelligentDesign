module MetricVisualizationOutput

import lang::java::jdt::m3::Core; 
import IO;
import String;
import List;
import Set;
import DateTime;
import lang::csv::IO;
import LineCleaner;
import Duplicate;
import LinesOfCodePer;
import util::Math;

public loc smallSqlProject = |project://smallsql0.21_src|;
public loc hsqldbProject = |project://hsqldb-2.3.1|;
public datetime tempdate = $2010-07-15$;

public str uniqueLineSeperator = "\n \b";


public void findDuplicates(list[tuple[loc,int]] versionedProjects) {
	versionedDuplicateGroups = [<findDuplicateGroups(projectLoc),versionDate> | <projectLoc,versionDate> <-versionedProjects];
//	writeCSV(bubbleGraphOutput(versionedDuplicateGroups),|file:///C:/temp/bubbleDuplicates2.csv|);
//	writeCSV(duplicateSnippets(duplicateGroups),|file:///C:/temp/allDuplicates.csv|);
	writeCSV(getAllConnections(versionedDuplicateGroups),|file:///C:/temp/allConnections.csv|);
}

public void FindAllHsqldbDuplicates(){
	versions = 
		[
		<|project://hsqldb-svn-r50|,2007>,
		<|project://hsqldb-svn-r432|,2008>
		//<|project://hsqldb-svn-r2957|,2009>,
		//<|project://hsqldb-svn-r3561|,2010>
		//<|project://hsqldb-svn-r4171|,2011>
		//4963 = 2012
		//5222 = 2013
		//5365 = 2014
		//5454 = 2015
		//5581 = 2016
		//<|project://hsqldb-svn-r5734|,2017>
		];
		
	findDuplicates(versions);		
}


rel[int versionDate, str packageName, str className, int classSize, int duplicateCount, int duplicateLines, int largestDuplicate] bubbleGraphOutput(list[tuple[map[str, set[loc]],int]] versionedDuplicateGroups){
	rel[int,str,str,int,int,int,int] bubbles = {};
	
	map[tuple[int,str,str],tuple[int,int,int,int]] bubbleMap = ();
	for (<duplicateGroups,versionDate> <-versionedDuplicateGroups){
		println("<versionDate>");
		for(textKey <- duplicateGroups){
			duplicateGroup = duplicateGroups[textKey];
			
			for (duplicateLocation <- duplicateGroup){
				key = <versionDate, getPackage(duplicateLocation), getClass(duplicateLocation)>;
				
				
				duplicateSize = size(findAll(textKey,uniqueLineSeperator));
				
				if(key in bubbleMap) {
					<classSize,dulicateCount, duplicatedLineCount,largestDuplicate> = bubbleMap[key];
					newValue = 
						<classSize, 
						dulicateCount+1,
						duplicatedLineCount+duplicateSize, 
						max(largestDuplicate,duplicateSize)>;
					bubbleMap[key] = newValue;
				} else {
					classSize = getClassLines(duplicateLocation);
					bubbleMap[key] = <classSize,1,duplicateSize,duplicateSize>;
				}			
			}		
		}
	}
	
	for(key <- bubbleMap){
		<versionDate,packageName,className> = key;
		<classSize, duplicateCount, duplicateLineCount, largestDuplicates> = bubbleMap[key];
		bubbles += <versionDate, packageName, className, classSize, duplicateCount, duplicateLineCount, largestDuplicates>;
	}
	
	return bubbles;
}

int getClassLines(loc snippetLocation){
	return countLinesPerFile(toLocation(snippetLocation.uri));
}

rel[int year, str originPackage, str originClass, loc originLocation, str destPackage, str destClass, loc destLocation, int duplicateSize] getAllConnections(list[tuple[map[str, set[loc]],int]] versionedDuplicateGroups){
	rel[int,str,str,loc,str,str,loc,int] connections = {};
	for (<duplicateGroups,versionDate> <-versionedDuplicateGroups){
		println("<versionDate>");	
		for(textKey <- duplicateGroups){
			duplicateGroup = duplicateGroups[textKey];
			duplicateSize = size(findAll(textKey,uniqueLineSeperator));
			for (first <- duplicateGroup, second <-duplicateGroup, first != second && first.path != second.path){
				connections +=
				    <versionDate,
				    getPackage(first),
					getClass(first),
					first,
					getPackage(second),
					getClass(second),
					second,
					duplicateSize>;
			}
		}
	}
	return connections;	
}

/*

rel[loc,int,str,str,str,str,datetime,set[loc]] toSnippets(map[str, set[loc]] duplicateGroups){
	rel[loc,int,str,str,str,str,datetime,set[loc]]  snippets = {};
	
	for(textKey <- duplicateGroups){
		duplicateGroup = duplicateGroups[textKey];
		for (duplicateLocation <- duplicateGroup){
		
			snippets +=
			    <duplicateLocation,
				numberOfLines(textKey),
				getPackage(duplicateLocation),
				getClass(duplicateLocation),
				textKey,
				readFile(duplicateLocation),
				versionDate,
				duplicateGroup - duplicateLocation
			>;
		}
	}
	
	return snippets;
}
*/

str getPackage(loc location) {
	path = location.path;
	path = substring(path,0,findLast(path,"/"));
	path = substring(path,1);
	path = replaceAll(path,"/",".");
	return path;
}
str getClass(loc location) {
	path = location.path;
	path = substring(path,findLast(path,"/")+1);
	path = substring(path,0,findLast(path,".java"));

	return path;
}

int numberOfLines(str text) = size(findAll(text,uniqueLineSeperator)) +1; 

