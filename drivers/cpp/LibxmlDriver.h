//
//  LibxmlDriver.h
//  
//
//  Created by O'Neil Delpratt on 23/04/2014.
//
//

#ifndef _LibxmlDriver_h
#define _LibxmlDriver_h

#include "main.h"
#include <libxslt/xslt.h>
#include <libxslt/transform.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/extensions.h>
#include <libxslt/xsltutils.h>
#include <stdio.h>

extern int xmlLoadExtDtdDefaultValue;
class LibxmlDriver : public IDriver {
public:
    LibxmlDriver(string cwdi){
        xmlSubstituteEntitiesDefault(1);
        xmlLoadExtDtdDefaultValue = 1;
        cwd = cwdi;
        setName("LibXSLT");
	stylesheet = NULL;
    }
    void buildSource(string sourceUri){
        string sourceFilename = cwd + sourceUri;
        doc = xmlParseFile(sourceFilename.c_str());
        
        if(doc == NULL) {
            cout<<"FAILURE - doc in buildSource"<<endl;
        }
    }
    
    
    void compileStylesheet(string stylesheetUri){
        string filename = cwd + stylesheetUri;
        
        
        if(stylesheet == NULL) {
		
            stylesheet = xsltParseStylesheetFile(BAD_CAST filename.c_str());
        } else {
		xsltStylesheetPtr stylesheeti = xsltParseStylesheetFile(BAD_CAST filename.c_str());

	        if(stylesheeti == NULL){
	            cout<<"FAILURE - stylesheet is NULL in compileStylesheet: "<<filename<<endl;;
	            return;
	        }
              xsltFreeStylesheet(stylesheeti);
		xsltCleanupGlobals();
        }
        
        
        
    }
    void treeToTreeTransform(){
        if(doc==NULL){
            cout<<"FAILURE - doc is NULL in treeToTreeTransform"<<endl;
            return;
        }
        if(stylesheet == NULL ){
            cout<<"FAILURE - stylesheet is NULL in treeToTreeTransform"<<endl;
            return;
        }
        res = xsltApplyStylesheet(stylesheet, doc, NULL);
        if(res == NULL) {
            cout<<"FAILURE - res in tree-to-tree transform"<<endl;
	    exit(0);
        }

  //test code below
        /*xmlChar *xmlbuff;
        int buffersize;
        xmlDocDumpFormatMemory(res, &xmlbuff, &buffersize, 1);
        printf("%s", (char *) xmlbuff);*/
          //  xmlFreeDoc(res);
      
        xsltCleanupGlobals();
    }
    
    
    void fileToFileTransform(string sourceUri, string resultFileLocation){
        if(stylesheet == NULL){
            cout<<"FAILURE - stylesheet is NULL in FiletoFileTransform"<<endl;
            return;
        }
        string sourceFilename = cwd + sourceUri;
        string filename = cwd + resultFileLocation;
	outputFile = filename;
        FILE * pFile;
        xmlDocPtr doc1 = xmlParseFile(sourceFilename.c_str());
             if(doc1==NULL){
            cout<<"FAILURE - doc is NULL in FiletoFileTransform"<<endl;
            return;
        }
        pFile = fopen (filename.c_str() , "w");
        if (pFile == NULL) perror ("Error creating file");
        if(xsltSaveResultToFile(pFile, doc1, stylesheet) == -1){
            cout<<"FAILURE - Not able to write file: "<< resultFileLocation<<endl;
        } 
        fclose (pFile);
        xmlFreeDoc(doc1);
        xsltCleanupGlobals();
	xmlCleanupParser();
    }
    bool testAssertion(string assertion){
        /*xmlChar *xmlbuff;
        int buffersize;
        xmlDocDumpFormatMemory(res, &xmlbuff, &buffersize, 1);
        printf("%s", (char *) xmlbuff);*/
        if(res == NULL) {
            cout<<"FAILURE - res in testAssertion"<<endl;
            return false;
        }
	xmlDocPtr doc1  = xmlParseFile(outputFile.c_str());
        xmlXPathContextPtr xpathCtx;
        xpathCtx = xmlXPathNewContext(doc1);
        
        if(xpathCtx == NULL) {
            cout<<"Error: unable to create new XPath context"<<endl;
           
            return false;
        }
        if(res == NULL) {
            cout<<"Error: unable to parser file in assertion"<<endl;
           
            return false;
        }
        xmlXPathCompExprPtr assertCompExpr = xmlXPathCompile(BAD_CAST assertion.c_str());
        int outcome  = xmlXPathCompiledEvalToBoolean(assertCompExpr, xpathCtx);
        xmlXPathFreeCompExpr(assertCompExpr);
  	//xmlFreeDoc(doc1);
        //xmlXPathFreeContext(xpathCtx);
        /*
        if(outcome == 0 ){
            
            xmlChar *xmlbuff;
            int buffersize;
            xmlDocDumpFormatMemory(res, &xmlbuff, &buffersize, 1);
            cout<<(char *) xmlbuff<<endl;
            cout<<"Assertion XXXXXXXXXXXX: "<<assertion<<endl;
        }*/
        if(outcome != 1) {
            cout<<"Failure in the assertions"<<endl;
            return false;
        }
        return outcome;}
    void displayResultDocument(){}
    double getXsltVersion(){return 1.0;}
    
    void cleanUp(){
        if(stylesheet != NULL){
            xsltFreeStylesheet(stylesheet);
	   xsltCleanupGlobals();
            stylesheet = NULL;
        }
        if(doc != NULL)
            xmlFreeDoc(doc);
        doc = NULL; 
        	if(res != NULL)
            xmlFreeDoc(res);
        res = NULL;
    }
    

    //map["LibxmlDriver"] = &createInstance<LibxmlDriver>;
private:
    //static DerivedRegister<LibxmlDriver> reg;

    xsltStylesheetPtr stylesheet;
    xmlDocPtr doc, res;
    string cwd, outputFile;
    

};


#endif
