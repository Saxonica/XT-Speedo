using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Saxon.Api;
using System.IO;

namespace Speedo
{
    class SaxonDriver : IDriver
    {
        private Processor processor;
        private XsltCompiler compiler;
        private XsltExecutable stylesheet;
        protected String resultFile;      
        
        public SaxonDriver()
        {
            processor = new Processor();
            compiler = processor.NewXsltCompiler();
        }

        public override void BuildSource(Uri sourceUri)
        {
            
        }

        public override void CompileStylesheet(Uri stylesheetUri)
        {
            stylesheet = compiler.Compile(stylesheetUri);
        }

        public override void TreeToTreeTransform()
        {
            
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
            DocumentBuilder builder = processor.NewDocumentBuilder();
            XdmNode resultDoc = builder.Build(new Uri(resultFile));
            XPathCompiler xPathCompiler = processor.NewXPathCompiler();
            XPathExecutable exec = xPathCompiler.Compile(assertion);
            XPathSelector selector = exec.Load();            
            selector.ContextItem = resultDoc;
            return selector.EffectiveBooleanValue();            
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
