using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.Xml.Linq;


namespace Speedo
{
    class MSDriver : IDriver
    {
        private XslCompiledTransform xslCompiledTransform;
        private String driverName;
        protected String resultFile;
        private XmlDocument xmlDocument;

        public MSDriver()
        {
            xslCompiledTransform = new XslCompiledTransform();
        }

        /**
         * Parse a source file and build a tree representation of the XML
         * @param sourceUri the location of the XML input file
         */

        public void BuildSource(Uri sourceUri) 
        {
            //Console.WriteLine(sourceUri.ToString());
            //xmlDocument.Load(sourceUri.ToString());        
        }

        /**
         * Compile a stylesheet
         * @param stylesheetUri the file containing the XSLT stylesheet
         */

        public void CompileStylesheet(Uri stylesheetUri)
        {
            xslCompiledTransform.Load(stylesheetUri.ToString());
        }                      

        /**
         * Run a transformation, transforming the supplied source document using the
         * supplied stylesheet
         */

        public void TreeToTreeTransform() {}

        /**
         * Run a transformation, from an input file to an output file
         */

        public void FileToFileTransform(Uri sourceUri, String resultFileLocation)
        {
            //String resultString = result.ToString().Replace("file:///", "");
            xslCompiledTransform.Transform(sourceUri.ToString(), resultFileLocation);

            this.resultFile = resultFileLocation;
        }

        /**
         * Test that the result of the transformation satisfies a given assertion
         * @param assertion the assertion, in the form of an XPath expression which
         *                  must evaluate to TRUE when executed with the transformation
         *                  result as the context item
         * @return the result of testing the assertion
         */

        public bool TestAssertion(String assertion)
        {           
            XPathDocument resultDoc = new XPathDocument(resultFile);            
            XPathNavigator navigator = resultDoc.CreateNavigator();            
            return (bool)navigator.Evaluate(XPathExpression.Compile(assertion));            
        }
        
        /**
         * Show the result document
         */

        public void DisplayResultDocument() {}

        /**
         * Gets version of XSLT processor supported
         * @return version of XSLT
         */

        public double GetXsltVersion()
        {
            return 1.0;
        }

        /**
         * Set a short name for the driver to be used in reports
         * @param name name to be used for driver
         */

        public void SetName(String name)
        {
            this.driverName = name;
        }

        /**
         * Get the short name for the driver to be used in reports
         * @return the name
         */

        public String GetName()
        {
            return this.driverName;
        }

    }
}
