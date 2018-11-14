module testLocPerMethod

import LinesOfCodePerMethod;

import lang::java::jdt::m3::AST;
import Set;
import Relation;
import IO;


public void SingleCommentLinePerMethod(){
    PerMethodClass = |project://CodeToTest/src/testCode/LinesOfCodeTests/SingleCommentLinePerMethod.java|;
    // return calculateLinesOfCodePerMethod(PerMethodClass) == 1;
    println("AAAAAAAAAAAAAAAAAAAAAAA");
    println(calculateLinesOfCodePerMethod(PerMethodClass));
    
}