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
	println("start: <now()>");
	versionedDuplicateGroups = [<findDuplicateGroups(projectLoc),versionDate> | <projectLoc,versionDate> <-versionedProjects];
	writeCSV(bubbleGraphOutput(versionedDuplicateGroups),|file:///C:/temp/bubbleDuplicates4.csv|);

    <classNames, connections, fulltext>  = getAllConnections(versionedDuplicateGroups);
    writeCSV(sort(classNames,bool(tuple[int,int,str,str,str] a, tuple[int,int,str,str,str] b){<a1,_,_,_,_> = a; <b1,_,_,_,_> = b; return a1 < b1;}), |file:///C:/temp/classnames.csv|);
	writeCSV(connections,|file:///C:/temp/connections.csv|);
	writeCSV(fulltext,|file:///C:/temp/fulltext.csv|);
	println("end: <now()>");
}

public void FindAllHsqldbDuplicates(){
	versions = 
		[
		//<|project://hsqldb-svn-r50|,2007>//, 
		//<|project://hsqldb-svn-r432|,2008>,
		//<|project://hsqldb-svn-r2957|,2009>//,
		//<|project://hsqldb-svn-r3561|,2010>
		//<|project://hsqldb-svn-r4171|,2011>//,
		//<|project://hsqldb-svn-r4963%20-%20Copy|,2012>
		//<|project://hsqldb-svn-r4963 - Copy|,2012>//,TODO//4963 = 2012
		//<|project://hsqldb-svn-r5222|,2013>//TODO /5222 = 2013
		//<|project://hsqldb-svn-r5365|,2014>//TODO5365 = 2014
		//<|project://hsqldb-svn-r5454|,2015>//TODO5454 = 2015
		//<|project://hsqldb-svn-r5581|,2016>//TODO5581 = 2016
		<|project://hsqldb-svn-r5734|,2017>
		
		//<|project://hsqldb-2.3.1|,2019>
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

tuple[
	rel[int index, int year, str package, str class, str direction],
	rel[int source, int target, loc originLocation, loc destLocation, int duplicateSize],
	rel[int version, loc location, str text]] getAllConnections(list[tuple[map[str, set[loc]],int]] versionedDuplicateGroups){
	
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
	
	int index = 0;
	uniqueClasses = { <versionDate, package, class> | <versionDate, package, class, _,_,_,_,_> <-connections};
	rel[int,int,str,str, str] orderedClasses = {}; 
	for	(<versionDate, package, class> <- uniqueClasses) {
		orderedClasses += <index, versionDate, package, class, "From">;		
		orderedClasses += <index +1, versionDate, package, class, "To">;
		index += 2;
	}
	
	rel[int,int,loc,loc,int] outputConnection = {};
	for (<d,p1,c1,l1,p2,c2,l2,ds> <- connections) {
		source = getOneFrom({i | <i,od,op,oc,dir> <- orderedClasses, od == d && op == p1 &&  oc == c1, dir == "From"});
	 	target = getOneFrom({i | <i,od,op,oc,dir> <- orderedClasses, od == d && op == p2 &&  oc == c2, dir == "To"});

		outputConnection += <source,target,l1,l2,ds>;
	}
	
	fullText = {<d,l,readFile(l)> | <d,_,_,l,_,_,_,_> <-connections};
	
	return <orderedClasses, outputConnection, fullText>;	
}

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

