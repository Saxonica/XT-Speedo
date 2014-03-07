package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.saxonhe.SaxonHEDriver;
import com.saxonica.xtspeedo.xalan.XalanDriver;
import org.jdom2.Content;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import org.jdom2.input.SAXBuilder;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.util.ArrayList;
import java.util.List;


/**
 * Run the XT-Speedo benchmark
 */
public class Speedo {

    public static final int MAX_ITERATIONS = 20;
    public static final long MAX_TOTAL_TIME = 20L*1000L*1000L*1000L;

    List<IDriver> drivers = new ArrayList<IDriver>();

    public static void main(String[] args) {
        new Speedo().run(new File(args[0]));
    }

    public void run(File catalogFile) {
        drivers.add(new SaxonHEDriver());
        drivers.add(new XalanDriver());
        SAXBuilder builder = new SAXBuilder();
        Document doc = null;
        try {
            doc = builder.build(catalogFile);
        } catch (JDOMException e) {
            e.printStackTrace();
            return;
        } catch (IOException e) {
            e.printStackTrace();
            return;
        }
        URI catalogURI = catalogFile.toURI();
        Element catalogElement = doc.getRootElement();
        for (IDriver driver : drivers) {
            System.err.println("Driver implemented: " + driver.getClass().getSimpleName());
            for (Element testCase : catalogElement.getChildren("test-case")) {
                System.err.println("Running " + testCase.getAttributeValue("name"));
                String attributeValue = testCase.getAttributeValue("xslt-version");
                double xsltVersion = (attributeValue == null) ? 1.0 : Double.parseDouble(attributeValue);
                String source = testCase.getChild("test").getChild("source").getAttributeValue("file");
                URI sourceURI = catalogURI.resolve(source);
                String stylesheet = testCase.getChild("test").getChild("stylesheet").getAttributeValue("file");
                URI stylesheetURI = catalogURI.resolve(stylesheet);
                    if (xsltVersion <= driver.getXsltVersion()) {
                        try {
                            long totalBuildSource = 0;
                            int i;
                            for (i = 0; i < MAX_ITERATIONS && totalBuildSource < MAX_TOTAL_TIME; i++) {
                                long start = System.nanoTime();
                                driver.buildSource(sourceURI);
                                totalBuildSource += System.nanoTime() - start;
                            }
                            System.err.println("Average time for source parse: " + totalBuildSource/(1000000*i) +
                                    "ms. Number of iterations: " + i);
                            long totalCompileStylesheet = 0;
                            for (i = 0; i < MAX_ITERATIONS && totalCompileStylesheet < MAX_TOTAL_TIME; i++) {
                                long start = System.nanoTime();
                                driver.compileStylesheet(stylesheetURI);
                                totalCompileStylesheet += System.nanoTime() - start;
                            }
                            System.err.println("Average time for stylesheet compile: " + totalCompileStylesheet/(1000000*i) +
                                    "ms. Number of iterations: " + i);
                            long totalTransform = 0;
                            for (i = 0; i < MAX_ITERATIONS && totalTransform < MAX_TOTAL_TIME; i++) {
                                long start = System.nanoTime();
                                driver.transform();
                                totalTransform += System.nanoTime() - start;
                            }
                            System.err.println("Average time for transform: " + totalTransform/(1000000*i) +
                                    "ms. Number of iterations: " + i);
                            for (Element assertion : testCase.getChild("result").getChildren("assert")) {
                                String xpath = assertion.getText();
                                driver.testAssertion(xpath);
                            }
                            System.err.println("Test succeeded with " + driver.getClass().getSimpleName());
                        } catch (TransformationException e) {
                            driver.displayResultDocument();
                            System.err.println("Test failed: " + e.getMessage());
                        }
                    }
            }
        }

    }
}
