#ifndef _SAXONCIDRIVER_h
#define _SAXONCIDRIVER_h


class IDriver
{

public:

    virtual ~IDriver(){}

    /**
     * Parse a source file and build a tree representation of the XML
     * @param sourceUri the location of the XML input file
     */

    virtual void buildSource(std::string sourceUri) = 0;


    /**
     * Load a schema document from a specified URI
     * @param schemaURI the location of the XSD document file
     */
    virtual void loadSchema(std::string schemaUri) = 0;

    /**
     * Compile a stylesheet
     * @param stylesheetUri the file containing the XSLT stylesheet
     */

    virtual void compileStylesheet(std::string stylesheetUri)= 0;

    virtual void compileStylesheetString(std::string str){}

    /**
     * Run a transformation, transforming the supplied source document using the
     * supplied stylesheet
     */

    virtual void treeToTreeTransform()= 0;

    /**
     * Run a transformation, from an input file to an output file
     */

    virtual void fileToFileTransform(std::string sourceUri, std::string resultFileLocation)= 0;

    /**
     * Test that the result of the transformation satisfies a given assertion
     * @param assertion the assertion, in the form of an XPath expression which
     *                  must evaluate to TRUE when executed with the transformation
     *                  result as the context item
     * @return the result of testing the assertion
     */

    virtual bool testAssertion(std::string assertion)= 0;

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

    void setName(std::string name)
    {
        driverName = name;
    }

    /**
     * Get the short name for the driver to be used in reports
     * @return the name
     */

    std::string getName()
    {
        return driverName;
    }

    /**
     * Set an option for this driver
     * @param name the name of the option
     * @param value the value of the option
     */

    virtual void setOption(std::string name, std::string value)
    {
        if(!name.empty() || !value.empty())
            options[name] =  value;
    }

    /**
     * Set a test run option for this driver
     * @param name the name of the test
     * @param value the value of the test run option
     */

    virtual void setTestRunOption(std::string name, std::string value){

        if(!name.empty() || !value.empty())
            runOptions[name] =  value;
    }

    virtual std::string getTestRunOption(std::string name){

        if(!name.empty()) {
            return runOptions[name];
        } else {
            return "";
        }
    }

    /**
     * Get the value of an option that has been set
     * @param name the name of the option
     * @return the value of the option, or null if none has been set
     */

    std::string GetOption(std::string name)
    {
        return options[name];
    }

private:
    std::string driverName;
    std::map<std::string,std::string> options;
    std::map<std::string,std::string> runOptions;

};

#endif