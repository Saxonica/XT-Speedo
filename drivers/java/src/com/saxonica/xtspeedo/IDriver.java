package com.saxonica.xtspeedo;

import java.io.File;
import java.net.URI;

/**
 * XT-Speedo interface to be implemented by each driver
 */

public interface IDriver {

    /**
     * Parse a source file and build a tree representation of the XML
     * @param sourceURI the location of the XML input file
     */

    public void buildSource(URI sourceURI) throws TransformationException;

    /**
     * Compile a stylesheet
     * @param stylesheetURI the file containing the XSLT stylesheet
     */

    public void compileStylesheet(URI stylesheetURI) throws TransformationException;

    /**
     * Run a transformation, transforming the supplied source document using the
     * supplied stylesheet
     */

    public void transform() throws TransformationException;

    /**
     * Test that the result of the transformation satisfies a given assertion
     * @param assertion the assertion, in the form of an XPath expression which
     *                  must evaluate to TRUE when executed with the transformation
     *                  result as the context item
     */

    public void testAssertion(String assertion) throws TransformationException;

    /**
     * Show the result document
     */

    public void displayResultDocument();
}
