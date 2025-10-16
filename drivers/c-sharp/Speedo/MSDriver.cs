using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.IO;


namespace Speedo
{
    class MSDriver : IDriver
    {
        private XslCompiledTransform xslCompiledTransform;
        protected String resultFile;
        private XmlDocument sourceDocument;
        private XmlDocument resultDocument;

        public MSDriver()
        {
            xslCompiledTransform = new XslCompiledTransform();
        }

        /**
         * Parse a source file and build a tree representation of the XML
         * @param sourceUri the location of the XML input file
         */

        public override void BuildSource(Uri sourceUri) 
        {
            sourceDocument = new XmlDocument();
            sourceDocument.Load(sourceUri.ToString());                               
        }

        /**
         * Compile a stylesheet
         * @param stylesheetUri the file containing the XSLT stylesheet
         */

        public override void CompileStylesheet(Uri stylesheetUri)
        {
            xslCompiledTransform.Load(stylesheetUri.ToString());
        }                      

        /**
         * Run a transformation, transforming the supplied source document using the
         * supplied stylesheet
         */

        public override void TreeToTreeTransform() 
        {
            resultDocument = new XmlDocument();
            using (XmlWriter writer = resultDocument.CreateNavigator().AppendChild())
            {
                xslCompiledTransform.Transform(sourceDocument, writer);
            };                  
        }

        /**
         * Run a transformation, from an input file to an output file
         */

        public override void FileToFileTransform(Uri sourceUri, String resultFileLocation)
        {
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

        public override bool TestAssertion(String assertion)
        {
            bool DocOK = true;
            bool FileOK = true;
            if (resultDocument != null)
            {                
                XPathNavigator navigator = resultDocument.CreateNavigator();
                DocOK = (bool)navigator.Evaluate(XPathExpression.Compile(assertion));
            }

            if (resultFile != null)
            {
                XPathDocument resultDoc = new XPathDocument(resultFile);
                XPathNavigator navigator = resultDoc.CreateNavigator();
                FileOK = (bool)navigator.Evaluate(XPathExpression.Compile(assertion));
            }
            return DocOK && FileOK;           
        }
        
        /**
         * Show the result document
         */

        public override void DisplayResultDocument() { }

        public override void ResetVariables()
        {
            sourceDocument = null;
            resultDocument = null;
            resultFile = null;
        }

        /**
         * Gets version of XSLT processor supported
         * @return version of XSLT
         */

        public override double GetXsltVersion()
        {
            return 1.0;
        }               

    }
}
