//
//  main.cpp
//
//
//  Created by O'Neil Delpratt on 16/04/2014.
//
//

#include "main.h"
#include "LibxmlDriver.h"
#include "SaxonHECDriver.h"
#include <string.h>
#include <libxml/xmlmemory.h>
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
#include <libxslt/xsltutils.h>
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
                testPattern = "";
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
      // Init libxml
     xmlInitParser();
    (new RunSpeedo(cwd))->run(catalog, driverfile, outputDir, testPattern);
    // Shutdown libxml 
    xmlCleanupParser();
    

	return(0);
}

void RunSpeedo::run(string catalogFile, string driverFile, string outputDirectory, string testPattern){
  
  
    buildDriverList(driverFile);
    
    xmlDocPtr doc;
    xmlNodePtr cur, assertCur;
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathStylesheetFileObj, xpathSourceFileObj, xpathAssertObj, xpathObj;
    string xpathStylesheet, xpathSource;
   xmlChar* assertData = NULL ;
    string catalog = cwd+catalogFile;
    double xsltversion = 0;
    clock_t begin, end;
    int size, sizei;
    
    doc = xmlParseFile(catalog.c_str());
    if (doc == NULL) {
        cout<<"Error: unable to parse file: "<<catalog.c_str()<<endl;
        return;
    }
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    
    if(xpathCtx == NULL) {
        cout<<"Error: unable to create new XPath context\n"<<endl;
        xmlFreeDoc(doc);
        return;
    }
    
    /* Evaluate xpath expression */
    string xpathStr = "//test-case";
    xpathObj = xmlXPathEvalExpression(BAD_CAST xpathStr.c_str(), xpathCtx);

    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    size = (nodes) ? nodes->nodeNr : 0;
	cout<<"catalog test case nodes:"<<size<<endl;
    int i, j;
    
    /*Traverse through drivers*/
    for(std::list<IDriver*>::iterator it=drivers.begin(); it != drivers.end(); ++it){
        xsltversion = (*it)->getXsltVersion();
        string driverOutputDir = outputDirectory + "/output/"+(*it)->getName()+"/";
        
        
        xmlAttr* attribute;
        xmlChar* value;
        bool outcomeBool = false;
                ofstream pFile;
        string resultFilename = cwd + outputDirectory + "/selection/"+(*it)->getName()+".xml";
        pFile.open(resultFilename.c_str());
        pFile <<"<testResults driver='"<<(*it)->getName()<<"' baseline='no'>"<<endl;
        
        /* Traverse through test cases*/
        for(i = 0; i < size; ++i) {
            cur = nodes->nodeTab[i];
            double xsltversionAtrr = 1.0;
            string testCaseName = "";
            
            attribute = cur->properties;
            while(attribute && attribute->name && attribute->children)
            {
                if(strcmp("name",(const char*)attribute->name)==0) {
                    
                    value = xmlNodeListGetString(doc, attribute->children, 1);
                    
                    testCaseName = (const char * )value;
                    
                    //do something with value
                   xmlFree(value);
                    
                } else if(strcmp("xslt-version",(char*)attribute->name)==0) {
                    value = xmlNodeListGetString(doc, attribute->children, 1);
                    if(value != NULL){
                        xsltversionAtrr = atof((char *)value);
                    }
                    xmlFree(value);
                }
                attribute = attribute->next;
            }
	xmlFreeProp(attribute);
	xmlNode* childNode = cur->children;
	xmlNode *testNode = NULL; 
	xmlNode* assertNode = NULL;         
	while(childNode && childNode->name) {
		if(strcmp("test", (const char*)childNode->name)==0) {
			testNode = childNode->children;
			while(testNode && testNode->name) {
				if(strcmp("stylesheet", (const char*)testNode->name)==0) {
					 attribute = testNode->properties;
					if(strcmp("file",(char*)attribute->name)==0) {
						 value = xmlNodeListGetString(doc, attribute->children, 1);
                    				if(value != NULL){
			                        	xpathStylesheet = (char *)value;
                			    	}	
                			    xmlFree(value);
					}
				} else if(strcmp("source", (const char*)testNode->name)==0) {
					 attribute = testNode->properties;
					if(strcmp("file",(char*)attribute->name)==0) {
						 value = xmlNodeListGetString(doc, attribute->children, 1);
                    				if(value != NULL){
			                        	xpathSource = (char *)value;
                			    	}	
                			    xmlFree(value);
					}
				}
				testNode = testNode->next;
			}
	
		} else if(strcmp("result", (const char*)childNode->name)==0) {
			assertNode = childNode->children;
			while(assertNode && assertNode->name) {
				if(strcmp("assert", (const char*)assertNode->name)==0) {
		                        assertData = xmlNodeListGetString(doc, assertNode->xmlChildrenNode, 1);
				}
				assertNode = assertNode->next;
			}
		}
		childNode = childNode->next;
	}  
         // xmlFreeNode(childNode); 
	bool patternCheck = false;
	if(!testPattern.empty()){
		cerr<<"testPattern: "<<testPattern<<endl;
		patternCheck = 	testCaseName.compare(0, testPattern.length(),testPattern);	 
	}
            if(xsltversion >= xsltversionAtrr && patternCheck==false) {
        	
                xmlNodeSetPtr assertNodes = NULL;//xpathAssertObj->nodesetval;
                int assertNodeSize = 0;//(assertNodes) ? assertNodes->nodeNr : 0;
                float msConst = 1000.0;
                float compiledTime = 0;
                int y =0;
		
               //Stylesheet
                if(!xpathStylesheet.empty()) {
                    string stylesheetFile =  xpathStylesheet;
                    (*it)->compileStylesheetString("<xsl:stylesheet xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\"\nversion=\"2.0\">\n<xsl:template match=\"/\">\n<xsl:copy-of select=\".\"/>\n</xsl:template></xsl:stylesheet>");
//                  (*it)->compileStylesheet("data/"+stylesheetFile); 
		   for (y = 0; y < MAX_ITERATIONS && compiledTime < MAX_TOTAL_TIME; y++)
                    {
			begin = clock();
                        (*it)->compileStylesheet("data/"+stylesheetFile);
                        compiledTime += (((double)(clock() - begin) / (float)CLOCKS_PER_SEC)); //seconds
                    }
                    compiledTime = ( (float)compiledTime / (float)y)*(double)msConst; // in ms
                }
                string sourceFile = "";
	
                //Source document
                if(!xpathSource.empty()) {
                   
                    sourceFile =  xpathSource;
                    (*it)->buildSource("data/"+sourceFile);
                }
                            
                double transformTimeTreeToTree = 0.0;
                double transformTimeFileToFile = 0.0;
                
                for (y = 0; y < MAX_ITERATIONS && transformTimeFileToFile < MAX_TOTAL_TIME; y++)
                {
                   begin = clock();
                    (*it)->fileToFileTransform("data/"+sourceFile, driverOutputDir+testCaseName+".xml");
                    transformTimeFileToFile += ((double)(clock() - begin) / (float)CLOCKS_PER_SEC);
                }
                transformTimeFileToFile = ((float)transformTimeFileToFile / (float)y)*(double)msConst;
                
               
                for (y = 0; y < MAX_ITERATIONS && transformTimeTreeToTree < MAX_TOTAL_TIME; y++)
                {
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
                /*if(!outcomeBool) {
                    pFile.close();
                    exit(0);
                }*/
                
            }
            
            /* String source = ((XmlElement)testCase.SelectSingleNode("test/source")).GetAttribute("file");
             Uri sourceUri = new Uri(catalogUri, source);
             String stylesheet = ((XmlElement)testCase.SelectSingleNode("test/stylesheet")).GetAttribute("file");*/
            if(attribute) {
              //  xmlFreePropList(attribute);
            }
           // xmlFree(cur);
            
        } // inner for loop to traverse test cases
        pFile<<"</testResults>"<<endl;
        pFile.close();
    } //outer for loop
   // xmlFreeDoc(doc);
   // xmlXPathFreeContext(xpathCtx);
   
   
    
}



void RunSpeedo::buildDriverList(string driverFile){
   
    xmlDocPtr doc;
    xmlXPathContextPtr xpathCtx;
    xmlXPathObjectPtr xpathObj;
    string filename = cwd+driverFile;
#ifdef DEBUG
    cout<<"BuildDriverList filename: "<<filename<<endl;
#endif
    
    doc = xmlParseFile(filename.c_str());
    if (doc == NULL) {
        cout<<"Error: unable to parse file "<<filename<<endl;
        xmlFreeDoc(doc);
        xmlXPathFreeObject(xpathObj);
        xmlXPathFreeContext(xpathCtx);
        return;
    }
    /* Create xpath evaluation context */
    xpathCtx = xmlXPathNewContext(doc);
    if(xpathCtx == NULL) {
        cout<<"Error: unable to create new XPath context"<<endl;
        xmlFreeDoc(doc);
        xmlXPathFreeObject(xpathObj);
        return;
    }
    
    /* Evaluate xpath expression */
    string xpathStr = "//driver[@language='c/c++']";
    xpathObj = xmlXPathEvalExpression(BAD_CAST xpathStr.c_str(), xpathCtx);
    if(xpathObj == NULL) {
        cout<<"Error: unable to evaluate xpath expression "<<xpathStr<<endl;
        xmlXPathFreeContext(xpathCtx);
        xmlFreeDoc(doc);
         xmlXPathFreeObject(xpathObj);
        return;
    }
    xmlNodeSetPtr nodes = xpathObj->nodesetval;
    
    xmlNodePtr cur;
    int size;
    int i, j;
    
    size = (nodes) ? nodes->nodeNr : 0;
    cout<<"Result ("<<size<<" nodes)"<<endl;
    xmlAttr* attribute;
    xmlChar* value;
    for(i = 0; i < size; ++i) {
        cur = nodes->nodeTab[i];
        attribute = nodes->nodeTab[i]->properties;
        while(attribute && attribute->name && attribute->children)
        {
            if(strcmp("class",(char*)attribute->name)==0) {
                
                
                value = xmlNodeListGetString(doc, attribute->children, 1);
                cout<<"Value of attribute "<< value<<endl;
                if(strcmp("LibxmlDriver",(char*)value)==0) {
                    drivers.push_back(new LibxmlDriver(cwd));
                    
                    
                } else if(strcmp("SaxonHECDriver",(char*)value)==0) {
                    drivers.push_back(new SaxonHECDriver(cwd));
                    
                    
                }
                
                //do something with value
                xmlFree(value);
                
            }
            attribute = attribute->next;
        }
    }
    xmlXPathFreeContext(xpathCtx);
    xmlFreeDoc(doc);
    xmlXPathFreeObject(xpathObj);

    
    
}
