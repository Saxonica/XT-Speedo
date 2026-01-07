//
//  main.cpp
//
//
//  Created by O'Neil Delpratt on 16/04/2014.
//
//

#include "main.h"
//#include "LibxmlDriver.h"
#include "SaxonHECDriver.h"
#include <string.h>
/*#include <libxml/xmlmemory.h>
#include <libxml/debugXML.h>
#include <libxml/HTMLtree.h>
#include <libxml/xmlIO.h>
#include <libxml/xinclude.h>
#include <libxml/catalog.h>
#include <libxml/tree.h>
#include <libxml/parser.h>
#include <libxml/xpath.h>
#include <libxml/xpathInternals.h>

#include <libxslt/xslt.h>
#include <libxslt/xsltInternals.h>
#include <libxslt/transform.h>
#include <libxslt/xsltutils.h>*/
#include <unistd.h>




extern int xmlLoadExtDtdDefaultValue;

static void usage(const char *name) {
    printf("Usage: %s -cwd:[working directory] -cat:[catalog name] -dr:[driver] -out:[result dir] -t:[test case]\n", name);
    
}



int main(int argc, char **argv) {
	int i;
	const char *params[16 + 1];
    string catalog;
    string driverfile;
    string outputDir;
    char cwdi[256];

    string cwd = getcwd(cwdi, sizeof(cwdi));
#ifdef DEBUG
    fprintf(stderr, "%s	", cwd.c_str());
#endif
    string testPattern;
	int nbparams = 0;
    
	if (argc <= 1) {
		usage(argv[0]);
		return(1);
	}
    
    for (i = 1; i < argc; i++) {
        if (argv[i][0] != '-') {
            printf("break on option:%s, ", argv[i]);
            break;
        }
        if (strncmp(argv[i], "-cat:", 5)==0) {
            catalog = argv[i];
            catalog = catalog.erase(0, 5);
            
        } else if (strncmp(argv[i], "-cwd:", 5)==0) {
            cwd = argv[i];
            cwd= cwd.erase(0, 5);
            fprintf(stderr, "cwd: %s\n",cwd.c_str());
            
        } else if (strncmp(argv[i], "-dr:", 4)==0) {
    
        driverfile = argv[i];
            driverfile = driverfile.erase(0, 4);
            
        } else if (strncmp(argv[i], "-out:", 5)==0) {
            if(sizeof(argv[i])<=5) {
                fprintf(stderr, "result parameter not supplied\n");
                outputDir = "results";
                continue;
            }
            outputDir = argv[i];
            outputDir = outputDir.erase(0,5);
            
        } else if(strncmp(argv[i], "-t:", 3)==0){
            if(sizeof(argv[i])<=3) {
                fprintf(stderr, "pattern parameter not supplied\n");
                //testPattern = ".*";
                continue;
            }
            testPattern = argv[i];
            testPattern.erase(0, 3);
            
        } else {
            fprintf(stderr, "Unknown option %s\n", argv[i]);
            usage(argv[0]);
            return (1);
        }
    }
    
    if(catalog.empty()) {
        fprintf(stderr, "catalog parameter not supplied\n");
        usage(argv[0]);
        catalog = "catalog.xml";
    }
    
    if(driverfile.empty()) {
        fprintf(stderr, "driver parameter not supplied\n");
        usage(argv[0]);
        driverfile = "drivers.xml";
    }
    
    if(outputDir.empty())
    {
        fprintf(stderr, "result parameter not supplied\n");
        usage(argv[0]);
        outputDir = "results";
    }
    
#ifdef DEBUG
    fprintf(stderr, "Options - cwd: %s, catalog: %s, DriverFile: %s, OutputDir: %s\n", cwd.c_str(), catalog.c_str(), driverfile.c_str(), outputDir.c_str());
#endif
	try {
    (new RunSpeedo(cwd))->run(catalog, driverfile, outputDir, testPattern);
	} catch(SaxonApiException &e) {
		std:cerr << "Failure in driver: "<< e.what()<< std::endl;
	}
    

	return(0);
}

void RunSpeedo::run(string catalogFile, string driverFile, string outputDirectory, string testPattern){
  
    builder = processor->newDocumentBuilder();
    buildDriverList(driverFile, builder);
    XPathProcessor * xpathProcessor = processor->newXPathProcessor();
    
    XdmNode* doc;
	XdmNode * cur = nullptr;
    /*xmlNodePtr cur, assertCur;
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathStylesheetFileObj, xpathSourceFileObj, xpathAssertObj, xpathObj;*/
    string xpathStylesheet = "";
	string xpathSource = "";
    const char * assertData = NULL ;
    string catalog = cwd+catalogFile;
    double xsltversion = 0;
    clock_t begin, end;
    int size, sizei;
    
    doc = builder->parseXmlFromFile(catalog.c_str());
    if (doc == NULL) {
        cout<<"Error: unable to parse file: "<<catalog.c_str()<<endl;
        return;
    }


    /* Evaluate xpath expression */
    string xpathStr = "//test-case";
    xpathProcessor->setContextItem(doc);
    XdmValue * xpathObj = xpathProcessor->evaluate(xpathStr.c_str());

    size = xpathObj->size();
	cout<<"catalog test case nodes:"<<size<<endl;
    int i, j;
    
    /*Traverse through drivers*/
    for(std::list<IDriver*>::iterator it=drivers.begin(); it != drivers.end(); ++it){
        xsltversion = (*it)->getXsltVersion();
        string driverOutputDir = outputDirectory + "/driverSet-All/output/"+(*it)->getName()+"/";
        
        
        XdmNode * attribute;
        const char* value;
        bool outcomeBool = false;
                ofstream pFile;
        string resultFilename = outputDirectory + "/driverSet-All/"+(*it)->getName()+".xml";
		cout<<"Result file:"<<resultFilename<<endl;
        pFile.open(resultFilename.c_str());
        pFile <<"<testResults driver='"<<(*it)->getName()<<"' baseline='no'>"<<endl;

        /* Traverse through test cases*/
        for(i = 0; i < size; ++i) {
            cur = (XdmNode *)xpathObj->itemAt(i);
  			if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
				if(cur != nullptr && cur->toString() != nullptr){
					std::cerr << "cur:"<<cur->toString() << std::endl;
				} else {
					std::cerr << "cur["<<i<<"] is nullptr"  << std::endl;
				}
  			}
            double xsltversionAtrr = 1.0;
            string testCaseName = "";


			value = cur->getAttributeValue("name");

			if(value != nullptr){
				testCaseName = std::string(value);
				delete [] value;
			}

			value = cur->getAttributeValue("xslt-version");

            if(value != nullptr){
            	xsltversionAtrr = atof(value);
            }

			XdmNode** childNodes = cur->getChildren();
			int childSize = cur->getChildCount();

			XdmNode * assertNode = nullptr;

			for(int j =0; j < childSize; j++) {
  				if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
					if(childNodes[j] != nullptr){
						std::cerr << "outer child:"<<childNodes[j]->toString() << std::endl;
					} else {
						std::cerr << "childNodes["<<j<<"] is nullptr"  << std::endl;
					}
  				}
				const char * childName = childNodes[j]->getNodeName();
  				if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
					if(childName != nullptr){
						std::cerr << "childName:"<< childName << std::endl;
					} else {
						std::cerr << "childNodes["<<j<<"] name is nullptr"  << std::endl;
					}
  				}
				if(childName != nullptr && strcmp("test", childName)==0) {
					if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
							std::cerr << "Found test node"<< std::endl;
  					}
                    /*if(strcmp((*it)->getTestRunOption(childName).c_str(), "no")) {
                        continue;
                    }*/
					XdmNode ** testNodes = childNodes[j]->getChildren();
					int testNodeChildSize = childNodes[j]->getChildCount();

  					if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
						std::cerr << "testNodeChildSize:"<< testNodeChildSize << std::endl;
  					}
					for(int z= 0; z < testNodeChildSize; z++ ) {
						if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
							if(testNodes[z] != nullptr && testNodes[z]->toString() != nullptr){
								std::cerr << "child:"<<testNodes[z]->toString() << std::endl;
							} else {
								std::cerr << "childNodes["<<z<<"] is nullptr"  << std::endl;
							}
  						}
						const char * testCaseNamei = testNodes[z]->getNodeName();
						if(testCaseNamei != nullptr && strcmp("stylesheet", testCaseNamei)==0) {
							const char * stylesheetURI = testNodes[z]->getAttributeValue("file");
							if(stylesheetURI != nullptr) {
			                   	xpathStylesheet = string(stylesheetURI);
                			}

						} else if(testCaseNamei != nullptr && strcmp("source", testCaseNamei)==0) {
							const char * sourceURI  = testNodes[z]->getAttributeValue("file");

							if(sourceURI != nullptr) {
			       				xpathSource = string(sourceURI);
								delete [] sourceURI;
							}
						}
					}
				} else if(childName != nullptr && strcmp("result", childName)==0) {
					XdmNode ** resultNodes = childNodes[j]->getChildren();
					int resultNodeChildSize = childNodes[j]->getChildCount();
					for(int z= 0; z < resultNodeChildSize; z++) {
						const char * resultNodeName = resultNodes[z]->getNodeName();
						if(resultNodeName != nullptr &&  strcmp("assert", resultNodeName)==0) {
							assertNode = resultNodes[z];
						}
					}
				}
			}


			bool patternCheck = false;

				cerr<<"testPattern: "<<testPattern<<endl;
				cerr<<"testCaseName: "<<testCaseName<<endl;
				patternCheck = 	0;
				if(!testPattern.empty()){
					patternCheck = testCaseName.compare(0, testPattern.length(),testPattern);
				}
				cerr<<"patternCheck = "<<patternCheck<<endl;
				if(patternCheck==0){
						cerr<<"patternCheck is true: "<<endl;
				} else {
					cerr<<"patternCheck is false: "<<endl;
					continue;
				}
				cerr<<"xsltversion = "<<xsltversion <<" xsltversonAttr = " << xsltversionAtrr<<std::endl;
            	if(xsltversion >= xsltversionAtrr && patternCheck==0) {

					try {
                		XdmNode * assertNodes = NULL;//xpathAssertObj->nodesetval;
                		int assertNodeSize = 0;//(assertNodes) ? assertNodes->nodeNr : 0;
                		float msConst = 1000.0;
                		float compiledTime = 0;
                		int y =0;
		
	               		//Stylesheet
						if(!xpathStylesheet.empty()) {
        	       			string stylesheetFile =  xpathStylesheet;
							//(*it)->compileStylesheetString("<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\"\nversion=\"2.0\">\n<xsl:template match=\"/\">\n<xsl:copy-of select=\".\"/>\n</xsl:template></xsl:stylesheet>");
	              	    	(*it)->compileStylesheet(stylesheetFile);
		   					for (y = 0; y < MAX_ITERATIONS && compiledTime < MAX_TOTAL_TIME; y++) {
								begin = clock();
                        		(*it)->compileStylesheet(stylesheetFile);
                        		compiledTime += (((double)(clock() - begin) / (float)CLOCKS_PER_SEC)); //seconds
                    		}
                    		compiledTime = ( (float)compiledTime / (float)y)*(double)msConst; // in ms
                		}

						if (getenv("SAXONC_XSPEEDO_DEBUG_MODE")) {
							cerr<<"compiledTime: "<<compiledTime<<endl;
						}
                		string sourceFile = "";
	
                		//Source document
                		if(!xpathSource.empty()) {
                    		sourceFile =  xpathSource;
                    		(*it)->buildSource(sourceFile);
                		}
                            
                		double transformTimeTreeToTree = 0.0;
                		double transformTimeFileToFile = 0.0;
                
                		for (y = 0; y < MAX_ITERATIONS && transformTimeFileToFile < MAX_TOTAL_TIME; y++) {
                   			begin = clock();
                    		(*it)->fileToFileTransform(sourceFile, driverOutputDir+testCaseName+".xml");
                    		transformTimeFileToFile += ((double)(clock() - begin) / (float)CLOCKS_PER_SEC);
                		}
                		transformTimeFileToFile = ((float)transformTimeFileToFile / (float)y)*(double)msConst;

                		for (y = 0; y < MAX_ITERATIONS && transformTimeTreeToTree < MAX_TOTAL_TIME; y++) {
		    				begin = clock();
                    		(*it)->treeToTreeTransform();
                    		transformTimeTreeToTree += (double)(clock() - begin) /(float) CLOCKS_PER_SEC;
                		}
                		transformTimeTreeToTree = ((float) transformTimeTreeToTree / (double) y)*(double)msConst;

                		string outcome = "failure";
                		outcomeBool = false;
                
                		if(assertData != NULL) {

                    		outcomeBool = (*it)->testAssertion((const char *)assertData);
                    		if(outcomeBool){
                        		outcome = "success";
                    		}
                    		assertData = NULL ;
                		}
            
                		(*it)->cleanUp();
		 				std::stringstream outputData;

		  				outputData <<std::setprecision(15)<<"<test name='"<<testCaseName<<"' run='"<<outcome<<"' compileTime='"<<(compiledTime)<<"' transformTimeFileToFile='"<<(transformTimeFileToFile)<<"' transformTimeTreeToTree='"<<(transformTimeTreeToTree)<<"' />";

						cout<<outputData.str()<<endl;
                		pFile<< outputData.str()<<endl;
					} catch(SaxonApiException &e) {
						std::stringstream outputData;
						std:cerr << "Failure in test: "<< e.what()<< std::endl;
						outputData <<std::setprecision(15)<<"<test name='"<<testCaseName<<"' run='failure' compileTime='0' transformTimeFileToFile='0' transformTimeTreeToTree='0' />";

						cout<<outputData.str()<<endl;
                		pFile<< outputData.str()<<endl;
					}
            	}
            
      		} // inner for loop to traverse test cases

        pFile<<"</testResults>"<<endl;
        pFile.close();
    } //outer for loop

}



void RunSpeedo::buildDriverList(string driverFile, DocumentBuilder * builder){
   
    XdmNode * doc;
	XPathProcessor * xpathProc = processor->newXPathProcessor();
    //xmlXPathContextPtr xpathCtx;
    XdmValue * xpathObj;
    string filename = cwd+driverFile;
#ifdef DEBUG
    cout<<"BuildDriverList filename: "<<filename<<endl;
#endif
    
    doc = builder->parseXmlFromFile(filename.c_str());
    if (doc == nullptr) {
        cout<<"Error: unable to parse file "<<filename<<endl;

        return;
    }
    /* Create xpath evaluation context */
    xpathProc->setContextItem((XdmItem *)doc);
    
    /* Evaluate xpath expression */
    string xpathStr = "//driver[@language='c/c++']";
    xpathObj = xpathProc->evaluate(xpathStr.c_str());
    if(xpathObj == nullptr) {
        cout<<"Error: unable to evaluate xpath expression "<<xpathStr<<endl;
        delete doc;
        return;
    }
    
    XdmNode * cur;
    int size;
    int i, j;
    
    size = xpathObj->size();
    cout<<"Result ("<<size<<" nodes)"<<endl;
    //xmlAttr* attribute;
    const char* value;
    for(i = 0; i < size; ++i) {
        cur = (XdmNode *)xpathObj->itemAt(i);
        const char * classDriverName = cur->getAttributeValue("class");
		SaxonHECDriver * driver = nullptr;
        if(classDriverName != nullptr) {

				XdmNode ** driverChildren = cur->getChildren();
				int driverChildrenSize = cur->getChildCount();

                cout<<"Value of attribute "<< classDriverName<<endl;
                if(strcmp("LibxmlDriver",classDriverName)==0) {
                    
                } else if(strcmp("SaxonHECDriver",classDriverName)==0) {
                    driver =  new SaxonHECDriver(cwd);

                }
				if(driver != nullptr) {
					for(int j = 0; j < driverChildrenSize; ++j) {
						const char * testRunOption = driverChildren[j]->getNodeName();
						if(testRunOption != nullptr && strcmp("test-run-option", testRunOption)==0) {
							const char * optionName = driverChildren[j]->getAttributeValue("name");
							const char * optionValue = driverChildren[j]->getAttributeValue("value");
							if(optionName != nullptr && optionValue != nullptr) {
								driver->setTestRunOption(optionName, optionValue);
							}

						}
					}
					drivers.push_back(driver);
				}
			delete [] classDriverName;

        }
    }

}
