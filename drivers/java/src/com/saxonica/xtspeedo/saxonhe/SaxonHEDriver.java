package com.saxonica.xtspeedo.saxonhe;

import com.saxonica.xtspeedo.IDriver;
import com.saxonica.xtspeedo.TransformationException;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.*;

import javax.xml.transform.stream.StreamSource;
import java.net.URI;

/**
 *XT-Speedo driver for Saxon-HE XSLT Processor
 */
public class SaxonHEDriver implements IDriver {

    private Processor processor = new Processor(false);
    private XdmNode sourceDocument;
    private XsltExecutable stylesheet;
    private XdmNode resultDocument;

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
    public void transform() throws TransformationException {
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
     * Test that the result of the transformation satisfies a given assertion
     *
     * @param assertion the assertion, in the form of an XPath expression which
     *                  must evaluate to TRUE when executed with the transformation
     *                  result as the context item
     */
    @Override
    public void testAssertion(String assertion) throws TransformationException {
        try {
            XPathCompiler compiler = processor.newXPathCompiler();
            XPathExecutable exec = compiler.compile(assertion);
            XPathSelector selector = exec.load();
            selector.setContextItem(resultDocument);
            boolean ok = selector.effectiveBooleanValue();
            if (!ok) {
                throw new TransformationException("Assertion (" + assertion + ") failed");
            }
        } catch (SaxonApiException e) {
            throw new TransformationException(e);
        }
    }

    /**
     * Show the result document
     */
    @Override
    public void displayResultDocument() {
        try {
            Serializer serializer = processor.newSerializer();
            serializer.setOutputStream(System.err);
            serializer.setOutputProperty(Serializer.Property.INDENT, "yes");
            processor.writeXdmValue(resultDocument, serializer);
        } catch (SaxonApiException e) {
            System.err.println("Failed to serialize result document");
        }
    }
}
