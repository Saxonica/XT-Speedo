package com.saxonica.xtspeedo.altova;

import com.altova.raptorxml.RaptorXML;
import com.altova.raptorxml.RaptorXMLException;
import com.altova.raptorxml.RaptorXMLFactory;
import com.altova.raptorxml.XSLT;
import com.saxonica.xtspeedo.IDriver;
import com.saxonica.xtspeedo.TransformationException;
import org.w3c.dom.Document;
import org.xml.sax.SAXException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import java.io.*;
import java.net.URI;


public class RaptorDriver extends IDriver {

    static RaptorXMLFactory rxml = RaptorXML.getFactory();
    XSLT xsltEngine = rxml.getXSLT();
    String result = null;
    private DocumentBuilder documentBuilder;

    @Override
    public void buildSource(URI sourceURI) throws TransformationException {
        xsltEngine.setInputXMLFileName("file://"+sourceURI.getRawPath());
    }

    @Override
    public void compileStylesheet(URI stylesheetURI) throws TransformationException {
        xsltEngine.setXSLFileName("file://"+stylesheetURI.getRawPath());
    }

    @Override
    public void treeToTreeTransform() throws TransformationException {
         try {
            rxml.setServerName("192.168.0.110");
            rxml.setServerPort(8087);
        } catch (RaptorXMLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
            result = xsltEngine.executeAndGetResultAsString();
        } catch (RaptorXMLException e) {
            throw new TransformationException(e);
        }
    }

    @Override
    public void fileToFileTransform(File source, File outputFile) throws TransformationException {
         try {
            rxml.setServerName("192.168.0.110");
             rxml.setServerPort(8087);
        } catch (RaptorXMLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
            xsltEngine.setInputXMLFileName(source.getAbsolutePath());
            boolean res = xsltEngine.execute(outputFile.getAbsolutePath());
            if(!res) {
                System.err.println("File not saved: "+outputFile.getAbsolutePath() + " Name: "+outputFile.getName());
            }
        } catch (RaptorXMLException e) {
            throw new TransformationException(e);
        }
    }

    @Override
    public boolean testAssertion(String assertion) throws TransformationException {
        DocumentBuilderFactory documentBuilderFactory = DocumentBuilderFactory.newInstance();
           XPathFactory xPathFactory;
        xPathFactory = XPathFactory.newInstance();
        documentBuilderFactory.setNamespaceAware(true);
        try {
            documentBuilder = documentBuilderFactory.newDocumentBuilder();
           StringReader sr = new StringReader(result);
           InputStream is = new ByteArrayInputStream(result.getBytes());
            Document resultDoc = documentBuilder.parse(is);
            return (Boolean)xPathFactory.newXPath().evaluate(assertion, resultDoc, XPathConstants.BOOLEAN);
             } catch (ParserConfigurationException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } catch (SAXException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } catch (IOException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        } catch (XPathExpressionException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }        return false;  //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override

    public void displayResultDocument() {
        //To change body of implemented methods use File | Settings | File Templates.
    }

    @Override
    public void resetVariables() {

    }

    @Override
    public double getXsltVersion() {
        return 2.0;
    }
}
