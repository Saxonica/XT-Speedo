package com.saxonica.xtspeedo.saxonhe;

import com.saxonica.xtspeedo.IDriver;
import com.saxonica.xtspeedo.TransformationException;
import net.sf.saxon.Configuration;
import net.sf.saxon.om.DocumentInfo;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.*;
import net.sf.saxon.trans.XPathException;
import nu.validator.htmlparser.sax.HtmlParser;
import org.xml.sax.ErrorHandler;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

import javax.xml.transform.sax.SAXSource;
import javax.xml.transform.stream.StreamSource;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.net.URI;

/**
 *XT-Speedo driver for Saxon-HE XSLT Processor
 */
public class SaxonHEDriver extends IDriver {

    private Processor processor = new Processor(false);
    private XdmNode sourceDocument;
    private XsltExecutable stylesheet;
    private XdmNode resultDocument;
    private File resultFile;
    private String driverName;

    /**
     * Parse a source file and build a tree representation of the XML
     *
     * @param sourceURI the location of the XML input file
     */
    @Override
    public void buildSource(URI sourceURI) throws TransformationException {
        try {
            sourceDocument = processor.newDocumentBuilder().build(new StreamSource(sourceURI.toString()));
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
            transformer.setSource(sourceDocument.asSource());
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
            transformer.setSource(new StreamSource(source));
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
                    HtmlParser parser = new nu.validator.htmlparser.sax.HtmlParser();
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

    /**
     * Gets version of XSLT processor supported
     *
     * @return version of XSLT
     */
    @Override
    public double getXsltVersion() {
        return 2.0;
    }
    /**
     * Set a short name for the driver to be used in reports
     *
     * @param name name to be used for driver
     */
    @Override
    public void setName(String name) {
        this.driverName = name;
    }

    /**
     * Get the short name for the driver to be used in reports
     *
     * @return the name
     */
    @Override
    public String getName() {
        return driverName;
    }
}
