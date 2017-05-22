using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using System.Xml.Xsl;
using System.Xml.XPath;
using System.IO;
using XmlPrime;
using XmlPrime.Serialization;


namespace Speedo
{
    class MSDriver2 : IDriver
    {
        private XslCompiledTransform xslCompiledTransform;
        protected String resultFile;
        private XdmDocument _sourceDocument;
        private XdmDocument _resultDocument;
        private readonly XmlReaderSettings _xmlReaderSettings;

        public MSDriver2()
        {
            xslCompiledTransform = new XslCompiledTransform();
            var uriResolver = new XmlUrlResolver();
            _xmlReaderSettings = new XmlReaderSettings
            {
                NameTable = new NameTable(),
                XmlResolver = uriResolver,
                DtdProcessing = System.Xml.DtdProcessing.Parse,
                CloseInput = true
            };
        }

        /**
         * Parse a source file and build a tree representation of the XML
         * @param sourceUri the location of the XML input file
         */

        public override void BuildSource(Uri sourceUri)
        {
            using (XmlReader reader = XmlReader.Create(sourceUri.ToString(), _xmlReaderSettings))
            {
                _sourceDocument = new XdmDocument(reader, XmlSpace.Preserve);
                reader.Close();
            }
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
            using (var writer = XdmDocumentWriter.Create())
            {
                xslCompiledTransform.Transform(_sourceDocument, writer);
                writer.Close();
                _resultDocument = writer.Document;
            }
        }

        /**
         * Run a transformation, from an input file to an output file
         */

        public override void FileToFileTransform(Uri sourceUri, String resultFileLocation)
        {
            XdmDocument document;

            using (var reader = XmlReader.Create(sourceUri.ToString(), _xmlReaderSettings))
            {
                document = new XdmDocument(reader, XmlSpace.Preserve);
                reader.Close();
            }

            using (var file = File.OpenWrite(resultFileLocation))
            {
                xslCompiledTransform.Transform(document, null, file);
            }

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
            if (_resultDocument != null)
            {
                XPathNavigator navigator = _resultDocument.CreateNavigator();
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
            _sourceDocument = null;
            _resultDocument = null;
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
