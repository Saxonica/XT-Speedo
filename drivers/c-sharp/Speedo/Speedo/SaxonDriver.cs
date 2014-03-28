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
        private String driverName;
        protected String resultFile;
      

        
        public SaxonDriver()
        {
            processor = new Processor();
            compiler = processor.NewXsltCompiler();
        }

        public void BuildSource(Uri sourceUri)
        {
            
        }

        public void CompileStylesheet(Uri stylesheetUri)
        {
            stylesheet = compiler.Compile(stylesheetUri);
        }

        public void TreeToTreeTransform()
        {
            
        }

        public void FileToFileTransform(Uri sourceUri, string resultFileLocation)
        {
            XsltTransformer transformer = stylesheet.Load();
            transformer.SetInputStream(File.Open(sourceUri.AbsolutePath, FileMode.Open), sourceUri);
            Serializer serializer = processor.NewSerializer();
            serializer.SetOutputFile(resultFileLocation);
            transformer.Run(serializer);
            resultFile = resultFileLocation;
        }

        public bool TestAssertion(string assertion)
        {
            DocumentBuilder builder = processor.NewDocumentBuilder();
            XdmNode resultDoc = builder.Build(new Uri(resultFile));
            XPathCompiler xPathCompiler = processor.NewXPathCompiler();
            XPathExecutable exec = xPathCompiler.Compile(assertion);
            XPathSelector selector = exec.Load();            
            selector.ContextItem = resultDoc;
            return selector.EffectiveBooleanValue();            
        }

        public void DisplayResultDocument()
        {
            
        }

        public double GetXsltVersion()
        {
            return 2.0;
        }

        public void SetName(string name)
        {
            this.driverName = name;
        }

        public string GetName()
        {
            return this.driverName;
        }
    }
}
