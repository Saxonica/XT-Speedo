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


        public XmlPrimeDriver()
        {
            xmlReaderSettings = new XmlReaderSettings { NameTable = nameTable };
            xsltSettings = new XsltSettings(nameTable) { ContextItemType = XdmType.Node };
            xsltSettings.ModuleResolver = new XmlUrlResolver();
            xmlReaderSettingsSchemaAware = new XmlReaderSettings { NameTable = nameTable };
            xsltSettingsSchemaAware = new XsltSettings(nameTable) { ContextItemType = XdmType.Node };
            xsltSettingsSchemaAware.ModuleResolver = new XmlUrlResolver();
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
                sourceDocument = new XdmDocument(reader);
            }
        }

        public override void CompileStylesheet(Uri stylesheetUri)
        {
            stylesheet = Xslt.Compile(stylesheetUri.ToString(), schemaAware ? xsltSettingsSchemaAware : xsltSettings);
        }

        public override void TreeToTreeTransform()
        {
            XdmNavigator contextItem = sourceDocument.CreateNavigator();
            DynamicContextSettings settings = new DynamicContextSettings { ContextItem = contextItem };
            using (XdmDocumentWriter writer = XdmDocumentWriter.Create())
            {
                stylesheet.ApplyTemplates(settings, writer);
                resultDocument = writer.Document;
            }
        }

        public override void FileToFileTransform(Uri sourceUri, string resultFileLocation)
        {
            using (XmlReader reader = XmlReader.Create(sourceUri.ToString(), schemaAware ? xmlReaderSettingsSchemaAware : xmlReaderSettings))
            {
                document = new XdmDocument(reader);
            }

            XdmNavigator contextItem = document.CreateNavigator();
            DynamicContextSettings settings = new DynamicContextSettings { ContextItem = contextItem };

            using (var outputStream = File.Create(resultFileLocation))
            {
                stylesheet.ApplyTemplates(settings, outputStream);
            }

            this.resultFile = resultFileLocation;
        }

        public override bool TestAssertion(string assertion)
        {            
            if (resultDocument != null)
            {
                XPathSettings xpathSettings = new XPathSettings(nameTable) { ContextItemType = XdmType.Node };
                var xpath = XPath.Compile(assertion, xpathSettings);
                var contextItem = resultDocument.CreateNavigator();
                var settings = new DynamicContextSettings { ContextItem = contextItem };
                return xpath.EvaluateToItem(contextItem).ValueAsBoolean;
            }
            if (resultFile != null)
            {
                XdmDocument resultDoc;
                using (var reader = XmlReader.Create(resultFile, xmlReaderSettings))
                {
                    resultDoc = new XdmDocument(reader);
                }
                XPathSettings xpathSettings = new XPathSettings(nameTable) { ContextItemType = XdmType.Node };
                var xpath = XPath.Compile(assertion, xpathSettings);
                var contextItem = resultDoc.CreateNavigator();
                var settings = new DynamicContextSettings { ContextItem = contextItem };
                return xpath.EvaluateToItem(contextItem).ValueAsBoolean;
            }
            return false;
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
    }
}
