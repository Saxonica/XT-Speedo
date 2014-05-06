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
#include "SaxonProcessor.h"
#include "XsltProcessor.h"
//#include "XQueryProcessor.h"
//#include "XdmValue.h" 
#define MAX_ITERATIONS 20
#define MAX_TOTAL_TIME 60

using namespace std;


class IDriver
{
private:
    string driverName;
    std::map<string,string> options;
    
public:
    
    virtual ~IDriver(){}
    
    /**
     * Parse a source file and build a tree representation of the XML
     * @param sourceUri the location of the XML input file
     */
    
    virtual void buildSource(string sourceUri) = 0;
    
    /**
     * Compile a stylesheet
     * @param stylesheetUri the file containing the XSLT stylesheet
     */
    
    virtual void compileStylesheet(string stylesheetUri)= 0;

    virtual void compileStylesheetString(string str){}
    
    /**
     * Run a transformation, transforming the supplied source document using the
     * supplied stylesheet
     */
    
    virtual void treeToTreeTransform()= 0;
    
    /**
     * Run a transformation, from an input file to an output file
     */
    
    virtual void fileToFileTransform(string sourceUri, string resultFileLocation)= 0;
    
    /**
     * Test that the result of the transformation satisfies a given assertion
     * @param assertion the assertion, in the form of an XPath expression which
     *                  must evaluate to TRUE when executed with the transformation
     *                  result as the context item
     * @return the result of testing the assertion
     */
    
    virtual bool testAssertion(string assertion)= 0;
    
    /**
     * Show the result document
     */
    
    virtual void displayResultDocument()= 0;
    
    /**
     * Gets version of XSLT processor supported
     * @return version of XSLT
     */
    
    virtual double getXsltVersion()= 0;
    
    virtual void cleanUp() = 0;
    
    /**
     * Set a short name for the driver to be used in reports
     * @param name the name to be used for driver
     */
    
    void setName(string name)
    {
        driverName = name;
    }
    
    /**
     * Get the short name for the driver to be used in reports
     * @return the name
     */
    
    string getName()
    {
        return driverName;
    }
    
    /**
     * Set an option for this driver
     * @param name the name of the option
     * @param value the value of the option
     */
    
    void setOption(string name, string value)
    {
        if(!name.empty() || !value.empty())
            options[name] =  value;
    }
    
    /**
     * Get the value of an option that has been set
     * @param name the name of the option
     * @return the value of the option, or null if none has been set
     */
    
    string GetOption(string name)
    {
        return options[name];
    }
    
    
};


class RunSpeedo {
public:
    RunSpeedo(string cwdi=""){
        cwd = cwdi;
    }
    
    void run(string catalogFile, string driverFile, string outputDirectory, string testPattern);
    
private:
    void buildDriverList(string driverFile);
    string cwd;
    std::list <IDriver*>drivers;
};





/*
// in base.hpp:
template<typename T> IDriver * createT() { return new T; }

struct BaseFactory {
    typedef std::map<std::string, IDriver*(*)()> map_type;
    
    static IDriver * createInstance(std::string const& s) {
        map_type::iterator it = getMap()->find(s);
        if(it == getMap()->end())
            return 0;
        return it->second();
    }
    
protected:
    static map_type * getMap() {
        // never delete'ed. (exist until program termination)
        // because we can't guarantee correct destruction order
        if(!map) { map = new map_type; }
        return map;
    }
    
private:
    static map_type * map;
};

template<typename T>
struct DerivedRegister : public BaseFactory {
    DerivedRegister(std::string const& s) {
        getMap()->insert(std::make_pair(s, &createT<T>));
    }
};*/




#endif /* defined(____main__) */
