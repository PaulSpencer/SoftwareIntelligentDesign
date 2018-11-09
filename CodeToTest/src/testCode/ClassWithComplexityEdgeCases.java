package testCode;

import java.sql.*;
import java.util.ArrayList;

public class ClassWithComplexityMethods {
	volatile Throwable throwable;

    public void testConcurrentRead() throws Throwable{
        throwable = null;
        int count = 0;
        while(count > 10){
            count++;
        }
        
        for(int i = 0; i < 200; i++) {
        	Thread thread = new Thread(new Runnable(){
	            public void run(){
	                try{
	                    int i;
	                }catch(Throwable ex){
	                    throwable = ex;
	                }
	            }
            });
        }
    
        for(int i = 0; i < 100; i++){
        	int b;
        }
        
        if(throwable != null){
            throw throwable;
        }
    }	
}
