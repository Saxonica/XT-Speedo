using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Saxon.Api;
using System.IO;

namespace Speedo
{
    class SaxonHEDriver : IDriver
    {
        private Processor processor;
        private XdmNode sourceDocument;
        private XdmNode resultDocument;
        private XsltCompiler compiler;
        private XsltExecutable stylesheet;
        protected String resultFile;      
        
        public SaxonHEDriver()
        {
            processor = new Processor(false);
            compiler = processor.NewXsltCompiler();
        }

        public override void SetOption(String name, String value)
        {
            processor.SetProperty("http://saxon.sf.net/feature/" + name, value);
        }

        public override String GetOption(String name)
        {
            return processor.GetProperty(name);
        }

        public override void BuildSource(Uri sourceUri)
        {
            sourceDocument = processor.NewDocumentBuilder().Build(sourceUri);
        }

        public override void CompileStylesheet(Uri stylesheetUri)
        {
            stylesheet = compiler.Compile(stylesheetUri);
        }

        public override void TreeToTreeTransform()
        {
            XsltTransformer transformer = stylesheet.Load();
            transformer.InitialContextNode = sourceDocument;
            XdmDestination destination = new XdmDestination();            
            transformer.Run(destination);
            resultDocument = destination.XdmNode;
        }

        public override void FileToFileTransform(Uri sourceUri, string resultFileLocation)
        {
            XsltTransformer transformer = stylesheet.Load();
            transformer.SetInputStream(File.Open(sourceUri.AbsolutePath, FileMode.Open), sourceUri);
            Serializer serializer = processor.NewSerializer();
            serializer.SetOutputFile(resultFileLocation);
            transformer.Run(serializer);
            resultFile = resultFileLocation;
        }

        public override bool TestAssertion(string assertion)
        {
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

        public override double GetXsltVersion()
        {
            return 2.0;
        }
    }
}
