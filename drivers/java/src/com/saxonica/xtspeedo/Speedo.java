package com.saxonica.xtspeedo;

import com.saxonica.xtspeedo.saxonhe.SaxonHEDriver;
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

    List<IDriver> drivers = new ArrayList<IDriver>();

    public static void main(String[] args) {
        new Speedo().run(new File(args[0]));
    }

    public void run(File catalogFile) {
        drivers.add(new SaxonHEDriver());
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
        for (Element testCase : catalogElement.getChildren("test-case")) {
            System.err.println("Running " + testCase.getAttributeValue("name"));
            String source = testCase.getChild("test").getChild("source").getAttributeValue("file");
            URI sourceURI = catalogURI.resolve(source);
            String stylesheet = testCase.getChild("test").getChild("stylesheet").getAttributeValue("file");
            URI stylesheetURI = catalogURI.resolve(stylesheet);
            for (IDriver driver : drivers) {
                try {
                    driver.buildSource(sourceURI);
                    driver.compileStylesheet(stylesheetURI);
                    driver.transform();
                    for (Element assertion : testCase.getChild("result").getChildren("assert")) {
                        String xpath = assertion.getText();
                        driver.testAssertion(xpath);
                    }
                    System.err.println("Test succeeded");
                } catch (TransformationException e) {
                    driver.displayResultDocument();
                    System.err.println("Test failed: " + e.getMessage());
                }
            }
        }

    }
}
