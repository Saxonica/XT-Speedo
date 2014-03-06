package com.saxonica.xtspeedo.xalan;

import com.saxonica.xtspeedo.IDriver;
import com.saxonica.xtspeedo.TransformationException;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.IOException;
import java.net.URI;

/**
 * XT-Speedo driver for Xalan Processor
 */
public class XalanDriver implements IDriver {

    private TransformerFactory transformerFactory;
    private DocumentBuilder documentBuilder;
    private XPathFactory xPathFactory;
    private Document sourceDocument;
    private Templates stylesheet;
    private Document resultDocument;

    public XalanDriver(){
        try {
            //org.apache.xalan.processor.TransformerFactoryImpl
            transformerFactory = TransformerFactory.newInstance("org.apache.xalan.processor.TransformerFactoryImpl", getClass().getClassLoader());
            documentBuilder = DocumentBuilderFactory.newInstance().newDocumentBuilder();
            xPathFactory = XPathFactory.newInstance();
        } catch (ParserConfigurationException e) {
            e.printStackTrace();
        }

    }

    /**
     * Parse a source file and build a tree representation of the XML
     *
     * @param sourceURI the location of the XML input file
     */

    public void buildSource(URI sourceURI) throws TransformationException {
        try {
            sourceDocument = documentBuilder.parse(sourceURI.toString());
        } catch (SAXException e) {
            throw new TransformationException(e);
        } catch (IOException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Compile a stylesheet
     *
     * @param stylesheetURI the file containing the XSLT stylesheet
     */

    public void compileStylesheet(URI stylesheetURI) throws TransformationException {
        try {
            stylesheet = transformerFactory.newTemplates(new StreamSource(stylesheetURI.toString()));
        } catch (TransformerConfigurationException e) {
            throw new TransformationException(e);
        }
        if (stylesheet == null)
            throw new TransformationException("Stylesheet compilation failed");
    }

    /**
     * Run a transformation, transforming the supplied source document using the
     * supplied stylesheet
     */

    public void transform() throws TransformationException {
        try {
            Transformer transformer = stylesheet.newTransformer();
            resultDocument = documentBuilder.newDocument();
            transformer.transform(new DOMSource(sourceDocument), new DOMResult(resultDocument));
        } catch (TransformerException e) {
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
    public void testAssertion(String assertion) throws TransformationException {
        try {
            boolean ok = (Boolean)xPathFactory.newXPath().evaluate(assertion, resultDocument, XPathConstants.BOOLEAN);
            if (!ok) {
                throw new TransformationException("Assertion (" + assertion + ") failed");
            }
        } catch (XPathExpressionException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Show the result document
     */
    @Override
    public void displayResultDocument() {
        try {
            Transformer transformer = transformerFactory.newTransformer();
            transformer.transform(new DOMSource(resultDocument), new StreamResult(System.err));
        } catch (TransformerException e) {
            System.err.println("Failed to serialize result document");
        }

    }

    /**
     * Gets version of XSLT processor supported
     *
     * @return version of XSLT
     */
    @Override
    public double getXsltVersion() {
        return 1.0;
    }
}
