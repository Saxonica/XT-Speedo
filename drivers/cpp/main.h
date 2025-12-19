//
//  main.h
//  
//
//  Created by O'Neil Delpratt on 16/04/2014.
//
//

#ifndef ____main__
#define ____main__

#include <iostream>
#include <fstream>
#include <map>
#include <list>
#include <utility>
#include <stdlib.h>
#include <string>
#include <time.h>
#include <sstream> 
#include <iomanip>
#include <saxonc/SaxonProcessor.h>
#include <saxonc/Xslt30Processor.h>
#include <saxonc/XsltExecutable.h>
#include <saxonc/DocumentBuilder.h>
#include "IDriver.h"
#define MAX_ITERATIONS 20
#define MAX_TOTAL_TIME 60

using namespace std;




class RunSpeedo {
public:
    RunSpeedo(string cwdi=""){
        cwd = cwdi;
        processor = new SaxonProcessor(true);
        processor->setcwd(cwd.c_str());
    }
    
    void run(string catalogFile, string driverFile, string outputDirectory, string testPattern);
    
private:
    void buildDriverList(string driverFile, DocumentBuilder * builder);
    string cwd;
    std::list <IDriver*>drivers;
    SaxonProcessor * processor;
    DocumentBuilder * builder;
};





#endif /* defined(____main__) */
