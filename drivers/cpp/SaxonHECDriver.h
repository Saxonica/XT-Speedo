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
#include "IDriver.h"
#include <saxonc/SaxonProcessor.h>
#include <saxonc/XdmValue.h>
#include <saxonc/XdmItem.h>
#include <saxonc/XdmNode.h>
#include <saxonc/DocumentBuilder.h>

//#include "XdmValue.h"
#include <stdio.h>


class SaxonHECDriver : public IDriver {
public:
    SaxonHECDriver(string cwdi);
    void buildSource(string sourceUri);
    
    
    void compileStylesheet(string stylesheetUri);

    void compileStylesheetString(string style);

    void loadSchema(string schemaUri);

	
    void treeToTreeTransform();
    
    
    void fileToFileTransform(string sourceUri, string resultFileLocation);
    bool testAssertion(string assertion);


    void displayResultDocument();

	double getXsltVersion(){
		return 3.0;
	}

	void setOption(std::string name, std::string value);
    
    void cleanUp();
    

    //map["LibxmlDriver"] = &createInstance<LibxmlDriver>;
private:
	bool schemaAware;
    SaxonProcessor *processor;
    Xslt30Processor * xsltProcessor;
	DocumentBuilder * builder;
	SchemaValidator * validator;
	XsltExecutable * executable;
	XdmNode * xdmNode;
    XdmNode * resultDocument;
    string cwd, sourceFile, stylesheetFile, resultFile, nodeStr;
    XdmNode * sourceNode;
    
};


#endif
