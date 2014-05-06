//
//  LibxmlDriver.h
//  
//
//  Created by O'Neil Delpratt on 23/04/2014.
//
//

#ifndef _SAXONHECDRIVER_h
#define _SAXONHECDRIVER_h

#include "main.h"
#include <libxslt/xslt.h>
#include <libxslt/transform.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/extensions.h>
#include <libxslt/xsltutils.h>

//#include "XsltProcessor.h"
//#include "XdmValue.h"
#include <stdio.h>


class SaxonHECDriver : public IDriver {
public:
    SaxonHECDriver(string cwdi){
        processor = new SaxonProcessor(false);
//	printf("Proc in driver %p\n", processor);
        cwd = cwdi;
	processor->setcwd(cwd.c_str());
	xsltProcessor = processor->newTransformer();
        setName("SaxonC");
	sourceNode = NULL;
	
    }
    void buildSource(string sourceUri){
	sourceFile = sourceUri;
	sourceNode = xsltProcessor->parseXmlFile(sourceUri.c_str());
    }
    
    
    void compileStylesheet(string stylesheetUri){
	xsltProcessor->releaseStylesheet();
	xsltProcessor->compile(stylesheetUri.c_str());
        
    }

    void compileStylesheetString(string style) {
	xsltProcessor->releaseStylesheet();
	xsltProcessor->compileString(style.c_str());

	}

	
    void treeToTreeTransform(){
       
	 if(sourceFile.empty() || sourceNode == NULL){
            cout<<"FAILURE - doc is NULL in treeToTreeTransform"<<endl;
	    exit(0);
        }
	nodeStr.clear();
	 XdmValue * node /*nodeStr*/ = xsltProcessor->xsltApplyStylesheetToValue(NULL, NULL);
        
        if(node == NULL) {
            cout<<"FAILURE - res in tree-to-tree transform"<<endl;
        }
	int errorCount = xsltProcessor->exceptionCount();
	if(errorCount > 0){
		cout<<"Error found in treeTotree transformation, Count="<<errorCount<<endl;	
		exit(0);
	}
	
	//cout<<nodeStr<<endl;
	node->releaseXdmValue(processor);
	
	delete node;
	
    }
    
    
    void fileToFileTransform(string sourceUri, string resultFileLocation){
	outputFile = resultFileLocation;

	//test code
	nodeStr = xsltProcessor->xsltApplyStylesheet(sourceUri.c_str(), NULL);
	SaxonApiException * ex1 = xsltProcessor->checkException();
	if(ex1 != NULL){
		cout<<"Errors"<<ex1->count()<<endl;	
	}
 	int errorCount = xsltProcessor->exceptionCount();
	if(errorCount > 0){
		cout<<"Error found in filetofile transformation, Count="<<errorCount<<endl;	
		exit(0);
	}

 FILE *fp = fopen(resultFileLocation.c_str(), "ab");
    if (fp != NULL)
    {
        fputs(nodeStr.c_str(), fp);
        fclose(fp);
    }
/*	ofstream myfile;
  	myfile.open ("resultFileLocation");
 	 myfile << nodeStr;
  	myfile.close();*/
/*
	outputFile = resultFileLocation;
       xsltProcessor->xsltSaveResultToFile(sourceFile.c_str(), NULL, resultFileLocation.c_str());
 	
	SaxonApiException * ex1 = xsltProcessor->checkException();
	if(ex1 != NULL){
		cout<<"Errors"<<ex1->count()<<endl;	
	}
 	int errorCount = xsltProcessor->exceptionCount();
	if(errorCount > 0){
		cout<<"Error found in filetofile transformation, Count="<<errorCount<<endl;	
		exit(0);
	}*/
    }
    bool testAssertion(string assertion){
	outputFile = cwd + outputFile;

	res  = xmlParseFile(outputFile.c_str());
//	res  = xmlParseMemory(nodeStr.c_str(), nodeStr.length());
            if(res == NULL) {
            cout<<"FAILURE - res in testAssertion"<<endl;
            return false;
        }
        xmlXPathContextPtr xpathCtx;
        xpathCtx = xmlXPathNewContext(res);
        
        if(xpathCtx == NULL) {
            cout<<"Error: unable to create new XPath context"<<endl;
           
            return false;
        }
        xmlXPathCompExprPtr assertCompExpr = xmlXPathCompile(BAD_CAST assertion.c_str());
        int outcome  = xmlXPathCompiledEvalToBoolean(assertCompExpr, xpathCtx);
        xmlXPathFreeCompExpr(assertCompExpr);
	xmlFreeDoc(res);
	res = NULL;

        if(outcome != 1) {
            cout<<"Failure in the assertions"<<endl;
            return false;
        }
        return outcome;
        return false;}


    void displayResultDocument(){}
    double getXsltVersion(){return 2.0;}
    
    void cleanUp(){
	if(sourceNode != NULL) {
	     	sourceNode->releaseXdmValue(processor); 
		delete  sourceNode;
		sourceNode == NULL;
	}
	if(xsltProcessor != NULL)	
		xsltProcessor->releaseStylesheet();
	nodeStr.clear();
    }
    

    //map["LibxmlDriver"] = &createInstance<LibxmlDriver>;
private:
    SaxonProcessor *processor = NULL;
    XsltProcessor * xsltProcessor;
    string cwd, sourceFile, stylesheetFile, outputFile, nodeStr;
    xmlDocPtr res = NULL;
    XdmValue * sourceNode= NULL;
    
};


#endif
