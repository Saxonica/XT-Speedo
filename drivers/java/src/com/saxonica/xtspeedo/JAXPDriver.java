////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2013 Saxonica Limited.
// This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0.
// If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
// This Source Code Form is “Incompatible With Secondary Licenses”, as defined by the Mozilla Public License, v. 2.0.
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

package com.saxonica.xtspeedo;

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
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.File;
import java.io.IOException;
import java.net.URI;

/**
 * XT-Speedo driver for Xalan Processor
 */
public abstract class JAXPDriver extends IDriver {

    private TransformerFactory transformerFactory;
    private DocumentBuilder documentBuilder;
    private XPathFactory xPathFactory;
    private Document sourceDocument;
    protected Templates stylesheet;
    private Document resultDocument;
    protected File resultFile;

    public JAXPDriver(){
        try {
            //org.apache.xalan.processor.TransformerFactoryImpl
            transformerFactory = TransformerFactory.newInstance(getFactoryName(), getClass().getClassLoader());
            DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
            documentBuilderFactory.setNamespaceAware(true);
            documentBuilder = documentBuilderFactory.newDocumentBuilder();
            xPathFactory = XPathFactory.newInstance();
        } catch (ParserConfigurationException e) {
            e.printStackTrace();
        }

    }

    /**
     * Get the JAXP transformer factory name for this driver
     * @return factory name
     */
    public abstract String getFactoryName();

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

    public void treeToTreeTransform() throws TransformationException {
        try {
            Transformer transformer = stylesheet.newTransformer();
            transformer.setErrorListener(new ErrorListener() {

                public void warning(TransformerException exception) throws TransformerException {
                    exception.printStackTrace();
                }

                public void error(TransformerException exception) throws TransformerException {
                    exception.printStackTrace();
                    throw exception;
                }

                public void fatalError(TransformerException exception) throws TransformerException {
                    exception.printStackTrace();
                    throw exception;
                }
            });
            resultDocument = documentBuilder.newDocument();
            transformer.transform(new DOMSource(sourceDocument), new DOMResult(resultDocument));
        } catch (TransformerException e) {
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
            Transformer transformer = stylesheet.newTransformer();
            resultFile = result;
            transformer.transform(new StreamSource(source), new StreamResult(result));
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

    public boolean testAssertion(String assertion) throws TransformationException {
        if (resultDocument != null) {
            try {
                return (Boolean)xPathFactory.newXPath().evaluate(assertion, resultDocument, XPathConstants.BOOLEAN);

            } catch (XPathExpressionException e) {
                throw new TransformationException(e);
            }
        }
        if (resultFile != null) {
            try {
                Document resultDoc = documentBuilder.parse(resultFile);
                return (Boolean)xPathFactory.newXPath().evaluate(assertion, resultDoc, XPathConstants.BOOLEAN);

            } catch (XPathExpressionException e) {
                throw new TransformationException(e);
            } catch (SAXException e) {
                throw new TransformationException(e);
            } catch (IOException e) {
                throw new TransformationException(e);
            }
        }
        return false;
    }

    /**
     * Show the result document
     */

    public void displayResultDocument() {
        try {
            Transformer transformer = transformerFactory.newTransformer();
            transformer.transform(new DOMSource(resultDocument), new StreamResult(System.err));
        } catch (TransformerException e) {
            System.err.println("Failed to serialize result document");
        }

    }

    @Override
    public void resetVariables() {
        sourceDocument = null;
        stylesheet = null;
        resultDocument = null;
        resultFile = null;
    }

    /**
     * Gets version of XSLT processor supported
     *
     * @return version of XSLT
     */

    public double getXsltVersion() {
        return 1.0;
    }


}
