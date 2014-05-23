using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Saxon.Api;
using System.IO;

namespace Speedo
{
    class SaxonEEDriver : IDriver
    {
        private Processor processor;
        private DocumentBuilder documentBuilder;
        private XdmNode sourceDocument;
        private XdmNode resultDocument;
        private XsltCompiler compiler;
        private XsltExecutable stylesheet;
        protected String resultFile;
        private Boolean schemaAware = false;

        public SaxonEEDriver()
        {
            processor = new Processor(true);
            compiler = processor.NewXsltCompiler();
            // Console.WriteLine(processor.ProductTitle + " Version:"+ processor.ProductVersion);
        }

        public override void SetOption(String name, String value)
        {
            processor.SetProperty("http://saxon.sf.net/feature/" + name, value);
        }

        public override String GetOption(String name)
        {
            return processor.GetProperty(name);
        }

        public override void LoadSchema(Uri schemaUri)
        {
            SchemaManager manager = processor.SchemaManager;
            manager.Compile(schemaUri);
            documentBuilder = processor.NewDocumentBuilder();
            documentBuilder.SchemaValidationMode = SchemaValidationMode.Strict;
            schemaAware = true;
        }

        public override void BuildSource(Uri sourceUri)
        {
            if (documentBuilder == null)
            {
                documentBuilder = processor.NewDocumentBuilder();
            }
            sourceDocument = documentBuilder.Build(sourceUri);
        }

        public override void CompileStylesheet(Uri stylesheetUri)
        {
            stylesheet = compiler.Compile(stylesheetUri);
        }

        public override void TreeToTreeTransform()
        {
            XsltTransformer transformer = stylesheet.Load();
            processor.SetProperty(net.sf.saxon.lib.FeatureKeys.SCHEMA_VALIDATION_MODE, schemaAware ? "strict" : "strip");
            //transformer.SchemaValidationMode = SchemaValidationMode.Strict;   // not working in 9.5.1.5: see bug 2062
            if (sourceDocument != null)
            {
                transformer.InitialContextNode = sourceDocument;
            }
            else
            {
                transformer.InitialTemplate = new QName("main");
            }            
            XdmDestination destination = new XdmDestination();
            transformer.Run(destination);
            resultDocument = destination.XdmNode;
        }

        public override void FileToFileTransform(Uri sourceUri, string resultFileLocation)
        {
            XsltTransformer transformer = stylesheet.Load();
            processor.SetProperty(net.sf.saxon.lib.FeatureKeys.SCHEMA_VALIDATION_MODE, schemaAware ? "strict" : "strip");
            //transformer.SchemaValidationMode = SchemaValidationMode.Strict;    // not working in 9.5.1.5: see bug 2062
            if (sourceUri != null)
            {
                transformer.SetInputStream(File.Open(sourceUri.AbsolutePath, FileMode.Open), sourceUri);
            }
            else
            {
                transformer.InitialTemplate = new QName("main");
            }            
            Serializer serializer = processor.NewSerializer();
            serializer.SetOutputFile(resultFileLocation);
            transformer.Run(serializer);
            resultFile = resultFileLocation;
            //serializer.Close();
        }

        public override bool TestAssertion(string assertion)
        {
            schemaAware = false;
            if (resultDocument != null)
            {
                XPathCompiler xPathCompiler = processor.NewXPathCompiler();
                XPathExecutable exec = xPathCompiler.Compile(assertion);
                XPathSelector selector = exec.Load();
                selector.ContextItem = resultDocument;
                return selector.EffectiveBooleanValue();
            }
            if (resultFile != null)
            {
                DocumentBuilder builder = processor.NewDocumentBuilder();
                XdmNode resultDoc = builder.Build(new Uri(resultFile));
                XPathCompiler xPathCompiler = processor.NewXPathCompiler();
                XPathExecutable exec = xPathCompiler.Compile(assertion);
                XPathSelector selector = exec.Load();
                selector.ContextItem = resultDoc;
                return selector.EffectiveBooleanValue();
            }
            return false;
        }

        public override void DisplayResultDocument()
        {

        }

        public override void ResetVariables()
        {
            documentBuilder = null;
            sourceDocument = null;
            stylesheet = null;
            resultDocument = null;
            resultFile = null;
            schemaAware = false;
            processor.SetProperty(net.sf.saxon.lib.FeatureKeys.SCHEMA_VALIDATION_MODE, "strip");
        }

        public override double GetXsltVersion()
        {
            return 3.0;
        }
    }
}
