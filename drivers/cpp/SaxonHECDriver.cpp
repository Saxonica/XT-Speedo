#include "SaxonHECDriver.h"


SaxonHECDriver::SaxonHECDriver(string cwdi){
	processor = new SaxonProcessor(true);
	processor->setcwd(cwdi.c_str());
	setName("SaxonHECDriver");
	xsltProcessor = nullptr;
	builder = nullptr;
	validator = nullptr;
	executable = nullptr;
	xdmNode = nullptr;
	sourceNode = nullptr;
	schemaAware = false;
}

void SaxonHECDriver::setOption(string name, string value){

	string featureUri = "http://saxon.sf.net/feature/" + name;
	processor->setConfigurationProperty(featureUri.c_str(), value.c_str());
}

void SaxonHECDriver::buildSource(string sourceUri){
	if (builder == nullptr) {
		builder = processor->newDocumentBuilder();
	}
	sourceNode = builder->parseXmlFromFile(sourceUri.c_str());

	if(sourceNode == nullptr){
		std::cerr << "Source node is null. Failed to build source."  << std::endl;
	}

}


void SaxonHECDriver::compileStylesheet(string stylesheetUri){
	processor->setConfigurationProperty("http://saxon.sf.net/feature/schema-validation-mode", (schemaAware ? "strict" : "strip"));
	xsltProcessor = processor->newXslt30Processor();
	xsltProcessor->setJustInTimeCompilation(true);
	executable = xsltProcessor->compileFromFile(stylesheetUri.c_str());

}

void SaxonHECDriver::compileStylesheetString(string style){
	processor->setConfigurationProperty("http://saxon.sf.net/feature/schema-validation-mode", (schemaAware ? "strict" : "strip"));
	xsltProcessor = processor->newXslt30Processor();
	xsltProcessor->setJustInTimeCompilation(true);
	executable = xsltProcessor->compileFromString(style.c_str());
}

void SaxonHECDriver::loadSchema(string schemaUri){
	if(builder != nullptr){
		delete builder;
	}

	if(validator != nullptr){
		delete validator;
	}
	validator = processor->newSchemaValidator();
	validator->registerSchemaFromFile(schemaUri.c_str());
	builder  = processor->newDocumentBuilder();
	builder->setSchemaValidator(validator);

	schemaAware = true;

}

void SaxonHECDriver::treeToTreeTransform(){

	if (sourceNode != nullptr){
		executable->setGlobalContextItem((XdmItem *)sourceNode);
		XdmValue * tempValue = executable->applyTemplatesReturningValue();

		resultDocument = (XdmNode *)(tempValue->getHead());
	}
	else {
		resultDocument = (XdmNode *)executable->callTemplateReturningValue ("main");
	}
}


void SaxonHECDriver::fileToFileTransform(string sourceUri, string resultFileLocation){
	if(executable == nullptr){
		std::cerr << "executable is NULL!"  << std::endl;
		return;
	}
	if (sourceNode != nullptr){
		executable->setGlobalContextItem(sourceNode);
		executable->setInitialMatchSelection(sourceNode);
		executable->applyTemplatesReturningFile(resultFileLocation.c_str());
	}
	else {
		if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
			if(!resultFileLocation.empty()){
				std::cerr << "resultFileLocation: "<<resultFileLocation << std::endl;
			} else {
				std::cerr << "resultFileLocation is empty"  << std::endl;
			}
		}
		executable->callTemplateReturningFile("main", resultFileLocation.c_str());
	}
	resultFile = resultFileLocation;
}

bool SaxonHECDriver::testAssertion(string assertion){
    bool docOK = true;
    bool fileOK = true;
	XdmNode * tempResultDoc = nullptr;
	XPathProcessor * xpathProcessor = processor->newXPathProcessor();
    if (resultDocument != nullptr) {

		//compiler.setSchemaAware(true);
        xpathProcessor->setContextItem((XdmItem *)resultDocument);

	}
    if (resultFile != "") {

        DocumentBuilder * builder = processor->newDocumentBuilder();
        tempResultDoc = builder->parseXmlFromFile(resultFile.c_str());

    	xpathProcessor->setContextItem((XdmItem *)tempResultDoc);
    }
	docOK = xpathProcessor->effectiveBooleanValue(assertion.c_str());

	if(tempResultDoc != nullptr){
		delete tempResultDoc;
	}

	delete xpathProcessor;

    return docOK && fileOK;
}


void SaxonHECDriver::displayResultDocument(){}

void SaxonHECDriver::cleanUp(){
	if(sourceNode != nullptr) {

		delete  sourceNode;
		sourceNode = nullptr;
	}

	nodeStr.clear();

	//TODO other data needs to be cleared
}