﻿using System;
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
        private XsltCompiler compiler;
        private XsltExecutable stylesheet;
        protected String resultFile;

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
            return 3.0;
        }
    }
}
