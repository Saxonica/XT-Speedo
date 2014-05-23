package com.saxonica.xtspeedo.saxonhe;

import com.saxonica.xtspeedo.IDriver;
import com.saxonica.xtspeedo.TransformationException;
import net.sf.saxon.Configuration;
import net.sf.saxon.lib.FeatureKeys;
import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.s9api.*;
import net.sf.saxon.trans.XPathException;
import nu.validator.htmlparser.sax.HtmlParser;
import org.xml.sax.*;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.net.URI;


/**
 *XT-Speedo driver for Saxon-EE XSLT Processor
 */
public class SaxonEEAaltoDriver extends IDriver {

    private Processor processor = new Processor(true);
    private DocumentBuilder documentBuilder;
    private XdmNode sourceDocument;
    private XsltExecutable stylesheet;
    private XdmNode resultDocument;
    private File resultFile;
    private boolean schemaAware = false;

    // TODO: because of bug 2062, we are having to set schema validation mode at the Processor level for those
    // tests that are schema-aware, and then clear the option ready for the next test.


    /**
     * Set an option for this driver
     * @param name the name of the option
     * @param value the value of the option
     */

    public void setOption(String name, String value) {
        processor.setConfigurationProperty("http://saxon.sf.net/feature/" + name, value);

    }

    /**
     * Get the value of an option that has been set
     * @param name the name of the option
     * @return the value of the option, or null if none has been set
     */

    public String getOption(String name) {
        return processor.getConfigurationProperty(name).toString();
    }

    /**
     * Load a schema document from a specified URI
     *
     * @param schemaURI the location of the XSD document file
     */
    @Override
    public void loadSchema(URI schemaURI) throws TransformationException {
        try {
            SchemaManager manager = processor.getSchemaManager();
            manager.load(new StreamSource(schemaURI.toString()));
            documentBuilder = processor.newDocumentBuilder();
            documentBuilder.setSchemaValidator(manager.newSchemaValidator());
        } catch (SaxonApiException e) {
            throw new TransformationException(e);
        }
        schemaAware = true;
    }

    /**
     * Parse a source file and build a tree representation of the XML
     *
     * @param sourceURI the location of the XML input file
     */
    @Override
    public void buildSource(URI sourceURI) throws TransformationException {
        try {
            if (documentBuilder == null) {
                documentBuilder = processor.newDocumentBuilder();
            }
            sourceDocument = documentBuilder.build(new StreamSource(sourceURI.toString()));
        } catch (SaxonApiException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Compile a stylesheet
     *
     * @param stylesheetURI the file containing the XSLT stylesheet
     */
    @Override
    public void compileStylesheet(URI stylesheetURI) throws TransformationException {
        try {
            stylesheet = processor.newXsltCompiler().compile(new StreamSource(stylesheetURI.toString()));
        } catch (SaxonApiException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Run a transformation, transforming the supplied source document using the
     * supplied stylesheet
     */
    @Override
    public void treeToTreeTransform() throws TransformationException {
        try {
            XsltTransformer transformer = stylesheet.load();
            processor.setConfigurationProperty(FeatureKeys.SCHEMA_VALIDATION_MODE, schemaAware ? "strict" : "strip");
            //transformer.setSchemaValidationMode(ValidationMode.STRICT);  // not working in 9.5.1.5: see bug 2062
            if (sourceDocument != null){
                transformer.setSource(sourceDocument.asSource());
            }
            else {
                transformer.setInitialTemplate(new QName("main"));
            }
            XdmDestination destination = new XdmDestination();
            transformer.setDestination(destination);
            transformer.transform();
            resultDocument = destination.getXdmNode();
        } catch (SaxonApiException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Run a transformation, from an input file to an output file
     *
     * @param source
     * @param result
     */
    @Override
    public void fileToFileTransform(File source, File result) throws TransformationException {
        try {
            XsltTransformer transformer = stylesheet.load();
            processor.setConfigurationProperty(FeatureKeys.SCHEMA_VALIDATION_MODE, schemaAware ? "strict" : "strip");
            //transformer.setSchemaValidationMode(ValidationMode.STRICT);  // not working in 9.5.1.5: see bug 2062
            SAXParserFactory factory = new com.fasterxml.aalto.sax.SAXParserFactoryImpl();
            XMLReader reader = null;
            try {
                reader = factory.newSAXParser().getXMLReader();
            } catch (SAXException e) {
                e.printStackTrace();
            } catch (ParserConfigurationException e) {
                e.printStackTrace();
            }
            if (source != null) {
                try {
                    transformer.setSource(new SAXSource(reader, new InputSource(new FileInputStream(source))));
                } catch (FileNotFoundException e) {
                    e.printStackTrace();
                }
            }
            else {
                transformer.setInitialTemplate(new QName("main"));
            }
            Destination destination = processor.newSerializer(result);
            transformer.setDestination(destination);
            transformer.transform();
            resultFile = result;
        } catch (SaxonApiException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Test that the result of the transformation satisfies a given assertion
     *
     * @param assertion the assertion, in the form of an XPath expression which
     *                  must evaluate to TRUE when executed with the transformation
     *                  result as the context item
     */
    @Override
    public boolean testAssertion(String assertion) throws TransformationException {
        //schemaAware = false;
        if (resultDocument != null) {
            try {
                XPathCompiler compiler = processor.newXPathCompiler();
                XPathExecutable exec = compiler.compile(assertion);
                XPathSelector selector = exec.load();
                selector.setContextItem(resultDocument);
                return selector.effectiveBooleanValue();

            } catch (SaxonApiException e) {
                throw new TransformationException(e);
            }
        }
        if (resultFile != null) {
            try {
                XdmNode resultDoc = null;
                try {
                    DocumentBuilder builder = processor.newDocumentBuilder();
                    resultDoc = builder.build(resultFile);
                } catch (SaxonApiException e) {
                    Configuration config = processor.getUnderlyingConfiguration();
                    HtmlParser parser = new HtmlParser();
                    parser.setErrorHandler(new ErrorHandler() {
                        public void warning(SAXParseException exception) throws SAXException {
                            System.err.println("Warning: " + exception.getMessage());
                        }

                        public void error(SAXParseException exception) throws SAXException {
                            System.err.println("Error (ignored): " + exception.getMessage());
                        }

                        public void fatalError(SAXParseException exception) throws SAXException {
                            throw exception;
                        }
                    });
                    try {
                        DocumentInfo documentInfo = config.buildDocument(new SAXSource(parser, new InputSource(new FileInputStream(resultFile))));
                        resultDoc = (XdmNode)XdmValue.wrap(documentInfo);
                    } catch (XPathException e1) {
                        e1.printStackTrace();
                    } catch (FileNotFoundException e1) {
                        e1.printStackTrace();
                    }
                }
                XPathCompiler compiler = processor.newXPathCompiler();
                XPathExecutable exec = compiler.compile(assertion);
                XPathSelector selector = exec.load();
                selector.setContextItem(resultDoc);
                return selector.effectiveBooleanValue();

            } catch (SaxonApiException e) {
                throw new TransformationException(e);
            }
        }
        return false;
    }

    /**
     * Show the result document
     */
    @Override
    public void displayResultDocument() {
        if (resultDocument != null) {
            try {
                Serializer serializer = processor.newSerializer();
                serializer.setOutputStream(System.err);
                serializer.setOutputProperty(Serializer.Property.INDENT, "yes");
                processor.writeXdmValue(resultDocument, serializer);
            } catch (SaxonApiException e) {
                System.err.println("Failed to serialize result document");
            }
        } else {
            //
        }
    }

    @Override
    public void resetVariables() {
        documentBuilder = null;
        sourceDocument = null;
        stylesheet = null;
        resultDocument = null;
        resultFile = null;
        schemaAware = false;
        processor.setConfigurationProperty(FeatureKeys.SCHEMA_VALIDATION_MODE, "strip");
    }

    /**
     * Gets version of XSLT processor supported
     *
     * @return version of XSLT
     */
    @Override
    public double getXsltVersion() {
        return 3.0;
    }

}
