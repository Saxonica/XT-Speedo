using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Xml;
using XmlPrime;
using XmlPrime.Serialization;
using System.Xml.Schema;

namespace Speedo
{
    class XmlPrimeDriver : IDriver
    {
        protected String resultFile;
        private NameTable nameTable = new NameTable();
        private XmlReaderSettings xmlReaderSettings;
        private XmlReaderSettings xmlReaderSettingsSchemaAware;
        private XdmDocument document;
        private XdmDocument sourceDocument;
        private XdmDocument resultDocument;
        private XsltSettings xsltSettings;
        private XsltSettings xsltSettingsSchemaAware;
        private Xslt stylesheet;
        private Boolean schemaAware = false;
        private XmlReaderDocumentResolver documentResolver;
        private XmlReaderDocumentResolver documentResolverSchemaAware;
        private XmlResourceResolver resourceResolver;



        public XmlPrimeDriver()
        {
            var uriResolver = new XmlUrlResolver();
            xmlReaderSettings = new XmlReaderSettings { NameTable = nameTable, XmlResolver = uriResolver, ProhibitDtd = false };
            xmlReaderSettings.CloseInput = true;
            xsltSettings = new XsltSettings(nameTable) { ContextItemType = XdmType.Node };
            xsltSettings.ModuleResolver = new XmlUrlResolver();
            xsltSettings.CodeGeneration = CodeGeneration.DynamicMethods;

            xmlReaderSettingsSchemaAware = new XmlReaderSettings { NameTable = nameTable, XmlResolver = uriResolver, ProhibitDtd = false };
            xmlReaderSettingsSchemaAware.CloseInput = true;
            xsltSettingsSchemaAware = new XsltSettings(nameTable) { ContextItemType = XdmType.Node };
            xsltSettingsSchemaAware.ModuleResolver = new XmlUrlResolver();
            xsltSettingsSchemaAware.CodeGeneration = CodeGeneration.DynamicMethods;
            
            //var xmlReaderSettingsUnparsedText = new XmlReaderSettings { XmlResolver = uriResolver };
            //xmlReaderSettingsUnparsedText.CloseInput = true;
            documentResolver = new XmlReaderDocumentResolver(xmlReaderSettings);
            documentResolverSchemaAware = new XmlReaderDocumentResolver(xmlReaderSettingsSchemaAware);
            resourceResolver = new XmlResourceResolver(uriResolver);
        }

        public override void LoadSchema(Uri schemaUri)
        {
            XmlSchemaSet schemaSet = new XmlSchemaSet();
            schemaSet.Add(null, schemaUri.ToString());
            xsltSettingsSchemaAware.Schemas = schemaSet;
            xsltSettingsSchemaAware.IsSchemaAware = true;
            xmlReaderSettingsSchemaAware.Schemas = schemaSet;
            xmlReaderSettingsSchemaAware.ValidationType = ValidationType.Schema;
            schemaAware = true;
        }

        public override void BuildSource(Uri sourceUri)
        {
            using (XmlReader reader = XmlReader.Create(sourceUri.ToString(), schemaAware ? xmlReaderSettingsSchemaAware : xmlReaderSettings))
            {
                sourceDocument = new XdmDocument(reader, XmlSpace.Preserve);
                reader.Close();
            }
        }

        public override void CompileStylesheet(Uri stylesheetUri)
        {
            stylesheet = Xslt.Compile(stylesheetUri.ToString(), schemaAware ? xsltSettingsSchemaAware : xsltSettings);
            stylesheet.SerializationSettings.NewLineChars = "\n";
        }

        public override void TreeToTreeTransform()
        {
            if (sourceDocument != null)
            {
                XdmNavigator contextItem = sourceDocument.CreateNavigator();
                var documentSet = new DocumentSet(nameTable, stylesheet.InputSettings, schemaAware ? documentResolverSchemaAware : documentResolver, null, resourceResolver);
                DynamicContextSettings settings = new DynamicContextSettings();
                settings.ContextItem = contextItem;
                settings.DocumentSet = documentSet;
                //DynamicContextSettings settings = new DynamicContextSettings { ContextItem = contextItem };
                using (XdmDocumentWriter writer = XdmDocumentWriter.Create())
                {
                    stylesheet.ApplyTemplates(settings, writer);
                    resultDocument = writer.Document;
                }
            }
            else
            {                
                var documentSet = new DocumentSet(nameTable, stylesheet.InputSettings, documentResolver, null, resourceResolver);
                DynamicContextSettings settings = new DynamicContextSettings { DocumentSet = documentSet };
                XmlQualifiedName qname = new XmlQualifiedName("main");
                using (XdmDocumentWriter writer = XdmDocumentWriter.Create())
                {
                    stylesheet.CallTemplate(qname, settings, writer);
                    resultDocument = writer.Document;
                }
            }

        }

        public override void FileToFileTransform(Uri sourceUri, string resultFileLocation)
        {
            if (sourceUri != null)
            {
                using (XmlReader reader = XmlReader.Create(sourceUri.ToString(), schemaAware ? xmlReaderSettingsSchemaAware : xmlReaderSettings))
                {
                    document = new XdmDocument(reader, XmlSpace.Preserve);
                    reader.Close();
                }
                XdmNavigator contextItem = document.CreateNavigator();
                var documentSet = new DocumentSet(nameTable, stylesheet.InputSettings, schemaAware ? documentResolverSchemaAware : documentResolver, null, resourceResolver);
                DynamicContextSettings settings = new DynamicContextSettings();
                settings.ContextItem = contextItem;
                settings.DocumentSet = documentSet;
                //DynamicContextSettings settings = new DynamicContextSettings { ContextItem = contextItem };
                stylesheet.SerializationSettings.CloseOutput = true;
                TextWriter writer = new StreamWriter(resultFileLocation);
                stylesheet.ApplyTemplates(settings, writer);
                writer.Close();                    
            }
            else
            {
                var documentSet = new DocumentSet(nameTable, stylesheet.InputSettings, documentResolver, null, resourceResolver);
                DynamicContextSettings settings = new DynamicContextSettings { DocumentSet = documentSet };
                stylesheet.SerializationSettings.CloseOutput = true;
                XmlQualifiedName qname = new XmlQualifiedName("main");
                TextWriter writer = new StreamWriter(resultFileLocation);
                stylesheet.CallTemplate(qname, settings, writer);
                writer.Close();         
            }

            this.resultFile = resultFileLocation;
        }

        public override bool TestAssertion(string assertion)
        {
            bool DocOK = true;
            bool FileOK = true;
            if (resultDocument != null)
            {
                XPathSettings xpathSettings = new XPathSettings(nameTable) { ContextItemType = XdmType.Node };
                var xpath = XPath.Compile(assertion, xpathSettings);
                var contextItem = resultDocument.CreateNavigator();
                var settings = new DynamicContextSettings { ContextItem = contextItem };
                DocOK = xpath.EvaluateToItem(contextItem).ValueAsBoolean;
            }
            if (resultFile != null)
            {
                XdmDocument resultDoc;
                using (var reader = XmlReader.Create(resultFile, xmlReaderSettings))
                {
                    resultDoc = new XdmDocument(reader);
                    reader.Close();
                }
                XPathSettings xpathSettings = new XPathSettings(nameTable) { ContextItemType = XdmType.Node };
                var xpath = XPath.Compile(assertion, xpathSettings);
                var contextItem = resultDoc.CreateNavigator();
                var settings = new DynamicContextSettings { ContextItem = contextItem };
                FileOK = xpath.EvaluateToItem(contextItem).ValueAsBoolean;
            }
            return DocOK && FileOK; 
        }

        public override void DisplayResultDocument()
        {
        }

        public override void ResetVariables()
        {
            sourceDocument = null;
            stylesheet = null;
            resultDocument = null;
            resultFile = null;
            schemaAware = false;
        }

        public override double GetXsltVersion()
        {
            return 2.0;
        }

        public override void SetOption(string name, string value)
        {
            if (name == "generateByteCode")
            {
                var codeGeneration = value == "true" ? CodeGeneration.DynamicMethods : CodeGeneration.None;
                xsltSettingsSchemaAware.CodeGeneration = codeGeneration;
                xsltSettings.CodeGeneration = codeGeneration;
            }
        }
    }
}
